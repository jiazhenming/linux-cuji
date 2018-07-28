#!/bin/bash
if [ $# -eq 0 ] ; then
	x="start stop restart status"
else	
	x=$1
fi
#for i in start stop restart status
for i in $x
do
case $i in
start)
	 netstat -ntulp |grep -q nginx &>/dev/null
if [ $? -eq 0 ] ; then
	echo "nginx 服务已开启！！！"
else
	/usr/local/nginx/sbin/nginx &>/dev/null
if [ $? -eq 0 ] ; then
	echo "nginx 服务已成功开启！！！"
else
	echo "nginx 服务未启动，请安装正确源码包！！！"
	exit 1
fi
fi;;
stop)
	/usr/local/nginx/sbin/nginx -s stop &>/dev/null
if [ $? -eq 0 ] ; then
	echo "nginx 服务已成功关闭！！！"
else
	echo "nginx 服务未关闭，请确认程序状态！！！"
	exit 2
fi;;
restart)
	/usr/local/nginx/sbin/nginx -s stop &>/dev/null
	/usr/local/nginx/sbin/nginx &>/dev/null
if [ $? -eq 0 ] ; then
	echo "nginx 服务已成功重起！！！"
else
	echo "nginx 服务重起异常，请检查程序状态！！！"
	exit 3
fi;;
status)
	netstat -ntulp |grep -q nginx &>/dev/null
if [ $? -eq 0 ] ; then
	echo "nginx 服务正常运行，请规范操作！！！"
else
	echo "nginx 服务出现未知错误，请检查服务！！！"
	exit 4
fi;;
*)
	echo "请正确运行4——启动nginx测试.sh";;
esac
done
