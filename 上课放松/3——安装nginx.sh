#!/bin/bash
#检测yum源
yum=`yum repolist | awk '/repolist/{print $2}'| awk -F, '{print $1$2}'`
if [ "$yum" -eq 0 ] ; then
echo "未安装yum源，正在初始化yum..."
rm -rf /etc/yum.repos.d/*
	echo "[dvd]
name=dvd
baseurl = http://content.example.com/rhel7.0/x86_64/dvd
enabled = 1
gpgcheck = 0" > /etc/yum.repos.d/dvd.repo
else
	echo "yum源已存在，正在安装nginx"
fi
#安装相应软件包
yum -y install openssl-devel  pcre-devel  gcc make &> /dev/null
#下载nginx源码包
wget -O /nginx-1.15.1.tar.gz  ftp://172.25.0.250/yuammaba/nginx-1.15.1.tar.gz &> /dev/null
#解压安装nginx软件包 
tar -xf /nginx-1.15.1.tar.gz
cd /nginx-1.15.1
./configure &> /dev/null
make &> /dev/null
make install &> /dev/null
	echo "nginx 已安装完毕！！"
