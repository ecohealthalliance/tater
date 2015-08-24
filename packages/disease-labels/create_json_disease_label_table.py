import csv
import os
import json

# To update the csv from our google sheet use:
# wget --no-check-certificate --output-document=disease_label_table.csv 'https://docs.google.com/spreadsheet/ccc?key=1MvkBBsvGP6Ax_bPfQJupjRiPDN803IpG1vB-iFzsr6M&output=csv'
table = []
curdir = os.path.dirname(os.path.abspath(__file__))
with open(os.path.join(curdir, "disease_label_table.csv")) as f:
    header = csv.reader(f, delimiter=',', quoting=csv.QUOTE_MINIMAL).next()
    reader = csv.DictReader(f,
        fieldnames=header,
        delimiter=',',
        quoting=csv.QUOTE_MINIMAL)
    for row in reader:
        out_row = {}
        for key, value in row.items():
            value = value.strip()
            if value == "TRUE":
                out_row[key] = True
            elif value == "FALSE":
                out_row[key] = False
            elif value == "":
                continue
            else:
                out_row[key] = value
        table.append(out_row)

with open(os.path.join(curdir, "disease_labels.js"), 'w') as f:
    f.write("DiseaseLabels = ")
    json.dump(table, f)
