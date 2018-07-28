#!/bin/bash
jindu(){
while :
do
	echo -n "#"
	sleep 0.3
done
}
jindu &
cp -r $1 $2
kill $!
