#!/bin/sh

if [ $# -ne 2 ]
then
        echo "please input throughput per UE and time"
        exit 0
fi

throughput=$1
timer=$2


iperf3 -u -c 12.12.12.113 -B 10.10.5.1 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.114 -B 10.10.5.2 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.115 -B 10.10.5.3 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.116 -B 10.10.5.4 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.117 -B 10.10.5.5 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.118 -B 10.10.5.6 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.119 -B 10.10.5.7 -p 5001 -b $throughput -l 1024 -t $timer &
iperf3 -u -c 12.12.12.120 -B 10.10.5.8 -p 5001 -b $throughput -l 1024 -t $timer &
