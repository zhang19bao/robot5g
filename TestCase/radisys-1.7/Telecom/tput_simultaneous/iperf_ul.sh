#!/bin/bash

if [ $# -ne 3 ]
then
        echo "please input throughput per UE and time and UE number"
        exit 0
fi

throughput=$1
timer=$2
num=$3
ip=10+$num

for ((i=11, j=13; i<=$ip; i++,j++))
        do
                iperf3 -u -c 12.12.12.$j -B 10.10.5.$i -p 5001 -b $throughput -l 1024 -t $timer &
        done


