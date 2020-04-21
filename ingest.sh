#!/bin/bash

Date=$(date +%F)
Base_Dir=$(/opt/nmap-xml/)
Nmap_status=$(rpm -qa nmap | wc -l)


if [ -d /opt/nmap-xml ];then
    continue
else
    mkdir -p /opt/nmap-xml
fi

if [ $Nmap_status -ne 0 ];then
        continte
else
        rpm -vhU https://nmap.org/dist/nmap-7.80-1.x86_64.rpm &> /dev/null
fi

/usr/bin/nmap -sV -p1-65535 -oX /opt/nmap-xml/nmap-${Date}.xml 192.168.1.0/24
if [ $? -eq 0 ];then
    curl -XDELETE "localhost:9200/nmap*"
    python /opt/nmap-elk-sh/vulntoES.py -i nmap-${Date}.xml -e localhost -r nmap -I nmap-$Date
    echo "importing......"
fi
echo "success!"
