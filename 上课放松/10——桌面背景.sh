#!/bin/bash
#备份文件内容
#桌面背景：/usr/share/backgrounds/tedu-wallpaper.png
#当前目录
j=`pwd`
#输出文档
while :
do
k=`find $j | grep png$ | wc -l`
ls -l | grep png$ |awk '{print $NF}' > a.txt
if [ $j = "/usr/share/backgrounds" ] ; then
while :
do
i=`find $j | grep png$ | wc -l`
m=$[$RANDOM%$i+1]
n=`sed -n "/$m/p" a.txt`
        rm -rf /usr/share/backgrounds/tedu-wallpaper.png
        cp /usr/share/backgrounds/"$n" /usr/share/backgrounds/tedu-wallpaper.png
        sleep 2
[ $i -ne $k ] && continue
done
else

while :
do
i=`find $j | grep png$ | wc -l`
m=$[$RANDOM%$i+1]
n=`sed -n ""$m"p" a.txt`
        rm -rf /usr/share/backgrounds/tedu-wallpaper.png
        cp "$j"/"$n" /usr/share/backgrounds/tedu-wallpaper.png
        sleep 2
[ $i -ne $k ] && continue
done
fi
done
