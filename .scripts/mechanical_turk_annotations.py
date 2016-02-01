import re
import sys
import csv
import pymongo

numeric = re.compile(('[0-9]+|'
                        'one|two|three|four|five|six|seven|eight|nine|ten|'
                        'eleven|twelve|thirteen|fourteen|fifteen|twenty|thirty|fifty|'
                        'hundred|thousand|first|second|third|fifth|twelfth'
                    ))

def annotator_category_for_phrase(db, phrase, access_code):
    """
    Checks if any of the given annotator's annotations mark the given phrase as a case count or death count, then returns that category.
    """
    death_count_id = db.codingKeywords.find_one({'header': "Death count"})['_id']
    case_count_id = db.codingKeywords.find_one({'header': "Case count"})['_id']

    annotations = list(db.annotations.find({'accessToken': access_code}))

    for annotation in annotations:
        if annotation['startOffset'] <= phrase.start() and annotation['endOffset'] >= phrase.end():
            if annotation["codeId"] == death_count_id:
                return "Death Count"
            elif annotation["codeId"] == case_count_id:
                return "Case Count"
    # if none of the annotations contain the phrase
    return "None"

def expert_category_for_phrase(db, phrase, documentId):
    """
    Returns the categorization made by an 'expert' annotator
    """
    death_count_id = db.codingKeywords.find_one({'header': "Death count"})['_id']
    case_count_id = db.codingKeywords.find_one({'header': "Case count"})['_id']

    annotations = list(db.annotations.find({'documentId': documentId, 'userId': 'EpfEJtYYJ9QSEHPfo'}))

    for annotation in annotations:
        if annotation['startOffset'] <= phrase.start() and annotation['endOffset'] >= phrase.end():
            if annotation["codeId"] == death_count_id:
                return "Death Count"
            elif annotation["codeId"] == case_count_id:
                return "Case Count"
    # if none of the annotations contain the phrase
    return "None"

def create_csv_for_document(db, documentId):
    """
    Creates a csv indicating all annotators' categorization of numeric phrases in the document
    """
    document = db.documents.find_one({'_id': documentId})

    phrases = list(numeric.finditer(document['body']))

    annotations = db.annotations.find({'documentId': document['_id']})
    access_codes = map(lambda annotation: annotation['accessToken'], list(annotations))

    # Remove codes that don't have access codes and duplicated values
    access_codes = filter(None, access_codes)
    access_codes = list(set(access_codes))

    ratings_matrix = []
    with open("annotations/annotations-" + document['groupId'] + "-" + documentId + ".csv", 'wb') as csvfile:
        writer = csv.writer(csvfile)
        headers = ['Phrase', 'Expert']
        for access_code in access_codes:
            headers.append(access_code)
        writer.writerow(headers)

        for phrase in phrases:
            row = [phrase.group(0)]
            row.append(expert_category_for_phrase(db, phrase, documentId))
            for access_code in access_codes:
                row.append(annotator_category_for_phrase(db, phrase, access_code))
            writer.writerow(row)

def create_csvs_for_group(db, groupId):
    """
    Creates a csv representation of annotations for each document in the given group
    """
    documents = db.documents.find({'groupId': groupId})
    for document in documents:
        create_csv_for_document(db, document['_id'])

def main(groupId):
    # db = pymongo.Connection(host='127.0.0.1', port=27017).tater
    db = pymongo.Connection(host='127.0.0.1', port=3001).meteor

    create_csvs_for_group(db, groupId)

if __name__ == "__main__":
    main(sys.argv[1])
