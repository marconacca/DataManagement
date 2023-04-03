from google.colab import drive
drive.mount('/content/drive')

import csv

with open('/content/drive/My Drive/DMDS/archive/goalscorers.csv', 'r') as f:
  with open('/content/drive/My Drive/DMDS/archive/goalscorers2.csv', 'w') as g:
    writer = csv.writer(g, delimiter=',', lineterminator='\n')
    for line in csv.reader(f, delimiter=','):
      if line[5] == 'NA':
        writer.writerow([line[0], line[1], line[2], line[3], line[4], '0', line[6], line[7]])
      else:
        writer.writerow(line)