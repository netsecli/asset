## Asset

#### 1、简介

​	NMAP扫描主机资产信息，并把扫描信息导入到elasticsearch中，通过kibana前端进行展示.

​	目前仅支持Centos7环境中部署

![主机端口1](https://github.com/netsecli/asset/blob/master/%E4%B8%BB%E6%9C%BA%E7%AB%AF%E5%8F%A3.png)
![服务版本1](https://github.com/netsecli/asset/blob/master/%E6%9C%8D%E5%8A%A1%E7%89%88%E6%9C%AC.png)
#### 2、安装方法：

```bash
git clone https://github.com/netsecli/asset.git
cd asset
bash install.sh
```

#### 3、访问

​	打开`http://{IP}:5601`访问，导入`export.ndjson`即可查看


