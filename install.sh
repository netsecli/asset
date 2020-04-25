#!/bin/bash

Date=$(date +%F)
Dire=/opt/nmap-xml/
Pip2_Install=$(rpm -qa python2-pip | wc -l)
Nmap_Install=$(rpm -qa nmap | wc -l)
Docker_Install=$(rpm -qa | grep docker-ce | wc -l)
Selinux_Status=$(getenforce)
Firewall_Status=$(systemctl status firewalld | grep Active | awk '{print $2}')
Iptable_Status=$(rpm -qa iptables | wc -l)

# 导入elastic登录密码
function Elastic-Password
{
    elastic_user='elastic'
    elastic_pass=$(openssl rand -hex 6)
    sed -i "s/ELASTIC_PASSWORD: .*/ELASTIC_PASSWORD: ${elastic_pass}/" docker-compose.yml
    sed -i "s/elasticsearch.password: .*/elasticsearch.password: ${elastic_pass}/" kibana/config/kibana.yml
    num=$(test -d ${Dire} && echo 1 || echo 0 )
    if [ ! $num -eq 1 ];then
        mkdir -p ${Dire}
    fi
    echo "密码设置完成！"
}

# 基础安装，判断软件是否安装
function Base_install
{
    echo "基础环境安装，请稍等....."
    if [ !$Selinux_Status = 'Disabled' ];then
        sed -i 's/SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    fi
	
    if [ !$Firewall_Status = 'inactive' ];then
        systemctl stop firewalld && systemctl disable firewalld
    fi
	
    if [ $Iptable_Status -eq 0 ];then
        yum -y install iptables-services git &> /dev/null 
	systemctl enable iptables &> /dev/null  
	systemctl start iptables &> /dev/null 
	iptables -F &> /dev/null
	service iptables save &> /dev/null
    fi
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    
    if [ $Nmap_Install -eq 0 ];then
        rpm -vhU https://nmap.org/dist/nmap-7.80-1.x86_64.rpm &> /dev/null
    fi
    
    if [ $Pip2_Install -eq 0 ];then
        yum -y install epel-release docker-compose &> /dev/null
        yum -y install python-devel python2-pip &> /dev/null
        mkdir -p  ~/.pip/
	echo "[global]" > ~/.pip/pip.conf
        echo "index-url = https://mirrors.aliyun.com/pypi/simple/" >> ~/.pip/pip.conf
        echo "[install]" >> ~/.pip/pip.conf
        echo "trusted-host = https://mirrors.aliyun.com" >> ~/.pip/pip.conf
        /usr/bin/pip install elasticsearch &> /dev/null
    fi
    
    if [ $Docker_Install -eq 0 ];then
  
        yum -y install yum-utils git &> /dev/null
	yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo &>/dev/null
	yum -y install docker-ce &> /dev/null
	systemctl start docker &> /dev/null
	systemctl enable docker &> /dev/null

    fi
    Docker_Status=$(systemctl status docker | grep Active | awk '{print $2}')
    if [ $Docker_Status = 'inactive' ];then
	systemctl start docker &> /dev/null
	systemctl enable docker &> /dev/null
    fi
    echo "基础环境配置完毕！"
}

# 启动扫描任务
function Nmap_Scan
{
    /usr/bin/docker-compose up -d &> /dev/null
    echo "开始扫描，请稍等......"
    sleep 60
    /usr/bin/nmap -sV -p1-65535 -oX /opt/nmap-xml/nmap-${Date}.xml $ipaddr &> /dev/null
    if [ $? -eq 0 ];then
        /usr/bin/python2.7 nmap_es.py -i /opt/nmap-xml/nmap-${Date}.xml -e 127.0.0.1 -r nmap -I nmap-${Date} -u ${elastic_user} -P ${elastic_pass}
    fi
}

read -p "请输入需要扫描的IP地址或网段： " ipaddr
Base_install
Elastic-Password
Nmap_Scan
echo "------------------------"
echo "部署完成!"
echo "访问地址：http://0.0.0.0:5601"
echo "用户名：${elastic_user} ,密码：${elastic_pass}"
echo "------------------------"
