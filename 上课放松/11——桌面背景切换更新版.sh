#!/bin/bash
#备份文件内容
#桌面背景：/usr/share/backgrounds/tedu-wallpaper.png
#当前目录
j=`pwd`
#输出文档
while :
do
k=`find $j |awk -F. '/png|jpg/{print }' | wc -l`
find $j |awk -F/ '/png|jpg/{print $NF}' > a.txt
if [ $j = "/usr/share/backgrounds" ] ; then
while :
do
i=`find $j |awk -F. '/png|jpg/{print }' | wc -l`
m=$[$RANDOM%$i+1]
n=`sed -n "/$m/p" a.txt`
#        rm -rf /usr/share/backgrounds/tedu-wallpaper.png
        cp -cf /usr/share/backgrounds/"$n" /usr/share/backgrounds/tedu-wallpaper.png &> /dev/null
        sleep 2
[ $i -ne $k ] && break
done
else
while :
do
i=`find $j |awk -F. '/png|jpg/{print }' | wc -l`
m=$[$RANDOM%$i+1]
n=`sed -n ""$m"p" a.txt`
#        rm -rf /usr/share/backgrounds/tedu-wallpaper.png
        cp -rf "$j"/"$n" /usr/share/backgrounds/tedu-wallpaper.png &> /dev/null
        sleep 2
[ $i -ne $k ] && break
done
fi
done
