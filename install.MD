1、安装方法：

    #  wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.2-x86_64.rpm
    #  wget https://artifacts.elastic.co/downloads/kibana/kibana-7.4.2-x86_64.rpm
    #  rpm -Uvh elasticsearch-7.4.2-x86_64.rpm kibana-7.4.2-x86_64.rpm
    #  systemctl enable elasticsearch
    #  systemctl enable kibana
    #  systemctl start elasticsearch
    #  systemctl start kibana
    #  rpm -vhU https://nmap.org/dist/nmap-7.80-1.x86_64.rpm

2、添加定时任务执行nmap进行扫描
    
    #  0 1 * * 6 /opt/nmap-elk-sh/nmap-scan.sh
 
