#!/bin/bash
DATE=`date +%Y.%m.%d`
rm -rf /opt/nmap-xml/*.xml
nmap -sV -p1-65535 -oX /opt/nmap-xml/nmap-${DATE}.xml 192.168.1.0/24
