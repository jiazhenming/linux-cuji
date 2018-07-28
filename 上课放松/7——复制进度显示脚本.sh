#!/bin/bash
#i=`du -s $1 | awk '{print $1}'`
jindu(){
while :
do
i=`du -s $1 | awk '{print $1}'`
j=`du -s $2 | awk '{print $1}'`
#	echo -n "#"
#	sleep 0.1 
if [ $j -eq $i ] ; then
	exit 1
else
        echo -n "#"
        sleep 0.1

fi 
done
}
jindu &
cp -r $1 $2

