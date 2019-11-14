1、安装方法：

  #### wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.4.2-x86_64.rpm
  #### wget https://artifacts.elastic.co/downloads/kibana/kibana-7.4.2-x86_64.rpm
  #### rpm -Uvh elasticsearch-7.4.2-x86_64.rpm kibana-7.4.2-x86_64.rpm
  #### systemctl enable elasticsearch
  #### systemctl enable kibana
  #### systemctl start elasticsearch
  #### systemctl start kibana

2、添加定时任务执行nmap进行扫描
  
 
3、自动导入扫描结果到elasticsearch中
