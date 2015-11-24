import pymongo
import csv

def write_promed_articles_to_csv():
    promed_db = pymongo.Connection('localhost')['promed']
    with open('promed_articles.csv', 'wb') as csvfile:
        writer = csv.writer(csvfile)
        for post in promed_db.posts.find():
            if post['articles']:
                title = post['subject']['description']
                body = post['articles'][0]['content'].encode("utf8","ignore")
                writer.writerow([title, body])

if __name__ == '__main__':
    write_promed_articles_to_csv()
