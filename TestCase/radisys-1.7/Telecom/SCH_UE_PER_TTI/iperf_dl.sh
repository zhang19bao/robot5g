#!/bin/bash

if [ $# -ne 2 ]
then
        echo "please input throughput per UE and time"
        exit 0
fi

throughput=$1
time=$2


iperf3 -u -c 10.10.5.1 -B 12.12.12.113 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.2 -B 12.12.12.114 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.3 -B 12.12.12.115 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.4 -B 12.12.12.116 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.5 -B 12.12.12.117 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.6 -B 12.12.12.118 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.7 -B 12.12.12.119 -p 5001 -b $throughput -l 1024 -t $time &
iperf3 -u -c 10.10.5.8 -B 12.12.12.120 -p 5001 -b $throughput -l 1024 -t $time &


