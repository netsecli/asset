#!/bin/bash

FILES=/opt/nmap-xml/*.xml
DATE=`date +%Y.%m.%d`
curl -XDELETE "localhost:9200/nmap*"
for f in $FILES
do
    echo "Processing $f file..."
    python /opt/nmap-elk-sh/vulntoES.py -i $f -e localhost -r nmap -I nmap-$DATE
done
