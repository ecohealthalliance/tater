import re
import sys
import pymongo

numeric = re.compile('[0-9]+|[!a-zA-Z](one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|hundred|thousand|first|second|third|fifth|twelfth')

def computeKappa(mat):
    """ Computes the Kappa value
        @param n Number of rating per subjects (number of human raters)
        @param mat Matrix[subjects][categories]
        @return The Kappa value """
    n = checkEachLineCount(mat)   # PRE : every line count must be equal to n
    N = len(mat)
    k = len(mat[0])
    
    # Computing p[]
    p = [0.0] * k
    for j in xrange(k):
        p[j] = 0.0
        for i in xrange(N):
            p[j] += mat[i][j]
        p[j] /= N*n

    # Computing P[]    
    P = [0.0] * N
    for i in xrange(N):
        P[i] = 0.0
        for j in xrange(k):
            P[i] += mat[i][j] * mat[i][j]
        P[i] = (P[i] - n) / (n * (n - 1))

    # Computing Pbar
    Pbar = sum(P) / N

    # Computing PbarE
    PbarE = 0.0
    for pj in p:
        PbarE += pj * pj

    kappa = (Pbar - PbarE) / (1 - PbarE)

    return kappa

def checkEachLineCount(mat):
    """ Assert that each line has a constant number of ratings
        @param mat The matrix checked
        @return The number of ratings
        @throws AssertionError If lines contain different number of ratings """
    n = sum(mat[0])

    assert all(sum(line) == n for line in mat[1:]), "Line count != %d (n value)." % n
    return n

def annotator_category_for_phrase(db, phrase, access_code):
    """
    Checks if any of the given annotator's annotations mark the given phrase as a case count or death count.
    Returns:
        0 if they marked it as a death count
        1 if they marked it as a case count
        2 if they did not annotate it
    """
    death_count_id = db.codingKeywords.find_one({'header': "Death count"})['_id']
    case_count_id = db.codingKeywords.find_one({'header': "Case count"})['_id']

    annotations = list(db.annotations.find({'accessToken': access_code}))

    for annotation in annotations:
        if annotation['startOffset'] <= phrase.start() and annotation['endOffset'] >= phrase.end():
            if annotation["codeId"] == death_count_id:
                return 0
            elif annotation["codeId"] == case_count_id:
                return 1
    # if none of the annotations contain the phrase
    return 2

def all_categories_for_phrase(db, phrase, access_codes):
    """
    For the given phrase, constructs an array [i, j, k] where 
    i is the number of annotators who identified it as a death count,
    j is the number of annotators who identified it as a case count, and
    k is the number of annotators who did not annotate it.
    """
    ratings = [0, 0, 0]
    for access_code in access_codes:
        category_index = annotator_category_for_phrase(db, phrase, access_code)
        ratings[category_index] += 1
    return ratings

def document_has_annotations(db, documentId):
    """
    Returns true if the document has been annotated at least once
    """
    document = db.documents.find_one({'_id': documentId})
    annotations = db.annotations.find({'documentId': document['_id']})
    return annotations.count() > 0

def document_has_numbers(db, documentId):
    """
    Returns true if the numeric regex matches multiple words in the document
    """
    document = db.documents.find_one({'_id': documentId})
    phrases = list(numeric.finditer(document['body']))

    return len(phrases) > 1

def get_kappa_for_document(db, documentId):
    """
    Returns Fleiss's Kappa for the given document
    """
    document = db.documents.find_one({'_id': documentId})

    phrases = list(numeric.finditer(document['body']))

    annotations = db.annotations.find({'documentId': document['_id']})
    access_codes = map(lambda annotation: annotation['accessToken'], list(annotations))

    # Remove codes that don't have access codes and duplicated values
    access_codes = filter(None, access_codes)
    access_codes = list(set(access_codes))

    ratings_matrix = []
    for phrase in phrases:
        ratings_matrix.append(all_categories_for_phrase(db, phrase, access_codes))
    return computeKappa(ratings_matrix)

def average_kappa_for_group(db, groupId):
    """
    Returns the average Fleiss's Kappa value for all documents in the given group
    """
    documents = db.documents.find({'groupId': groupId})
    kappas = []
    for document in documents:
        if document_has_annotations(db, document['_id']) and document_has_numbers(db, document['_id']):
            kappas.append(get_kappa_for_document(db, document['_id']))
    return sum(kappas)/float(len(kappas))

def main(groupId):
    db = pymongo.Connection(host='127.0.0.1', port=27017).tater
    # db = pymongo.Connection(host='127.0.0.1', port=3001).meteor

    print average_kappa_for_group(db, groupId)

if __name__ == "__main__":
    main(sys.argv[1])
