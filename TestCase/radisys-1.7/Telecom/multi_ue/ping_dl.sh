#! /bin/bash


if [ $# -ne 1 ]
then
        echo "please input number of UE"
        exit 0
fi

num=$1
ip=10+$num

echo "start ping uplink"
for ((i=11, j=13; i<=$ip; i++,j++))
        do
                ping 10.10.5.$i -I 12.12.12.$j -c 100 &
        done