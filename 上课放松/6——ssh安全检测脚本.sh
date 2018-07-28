#!/bin/bash
while :
do
grep Failed /var/log/secure |awk '{ip[$11]++}END{for (x in ip){print x,ip[x]}}' | awk '$2>=3  { print $1}' > /mnt/tmp.txt
for i in $(cat /mnt/tmp.txt)
do
if firewall-cmd --list-all --zone=block | egrep -qw "$ip" ; then
	echo "已禁用" &> /dev/null
else 
firewall-cmd --add-source=$i --zone=block
firewall-cmd --reload 
fi
if firewall-cmd --list-all --zone=drop | egrep -qw "$ip" ; then
	echo "已禁用" &> /dev/null
else 
firewall-cmd --add-source=$i --zone=block 
firewall-cmd --reload
fi
#$firewall-cmd --add-source=$i --zone=block
#firewall-cmd --reload
done
#rm -rf /mnt/tmp.txt
done
