"""
Importing ProMED articles:

1. Use promed mail scraper (https://github.com/ecohealthalliance/promed_mail_scraper) to place scraped promed
   articles into a local mongo database
2. Run write_promed_articles_to_csv.py to copy the useful information to a csv
3. Copy both that csv and add_promed_articles.py to the Tater production environment
4. Run add_promed_articles.py in the production environment, passing in the groupId and the number of articles
"""
import pymongo
import sys
import csv
from bson.objectid import ObjectId

def add_promed_articles(group_id, number_of_articles):
    tater_db = pymongo.Connection(host='127.0.0.1', port=27017).tater
    with open('promed_articles.csv', 'rb') as csvfile:
        reader = csv.reader(csvfile)
        count = 0
        for row in reader:
            if count < number_of_articles:
                title = row[0]
                body = row[1]

                object_id = str(ObjectId())
                document = tater_db.documents.insert({'_id': object_id, 'groupId': group_id, 'title': title, 'body': body})
                count = count + 1

if __name__ == '__main__':
    add_promed_articles(sys.argv[1], int(sys.argv[2]))
