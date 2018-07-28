#!/bin/bash
while :
do
clear
#CPU负载
uptime | awk '{print "当前CPU负载"$NF*100"%"}'
#网卡流量
ifconfig eth0 | awk '/RX p/{print "入站网卡流量为"$5,"KB"}'
ifconfig eth0 | awk '/TX p/{print "出站网卡流量为"$5,"KB"}'
#内存剩余空间
free -m | awk '/^Mem/{print "内存剩余"$4,"M"}'
#磁盘剩余容量
df -h | awk '/\/$/{print "根分区剩余空间可用 "$4}'
#计算机账户数量
awk '/$/{print NR}' /etc/passwd | sed -n '$p'|awk '{print "本地账户数量为",$1}'
#当前登陆账户数量
who | awk '{print NR}'|sed -n '$p'| awk '{print "当前登陆计算机的账户数量为",$1}'
#计算机当前开启的进程数量
ps aux | awk '{print NR}' | sed -n '$p' | awk '{print "当前计算机启动进程数量为",$1}'
#本机已安装的软件包数量
rpm -qa |awk '{print NR}' | sed -n '$p' | awk '{print "当前计算机已安装的软件数量",$1}'
sleep 0.5
done
