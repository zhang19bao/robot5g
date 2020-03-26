#!/bin/bash

if [ $# -ne 1 ]
then
        echo "please input action: start|stop"
        exit 0
fi

action=$1

if [[ $action == 'start' ]]; then
	echo "start iperf server"
	iperf3 -s -B 12.12.12.113 -p 5001 -D &
	iperf3 -s -B 12.12.12.114 -p 5001 -D &
	iperf3 -s -B 12.12.12.115 -p 5001 -D &
	iperf3 -s -B 12.12.12.116 -p 5001 -D &
	iperf3 -s -B 12.12.12.117 -p 5001 -D &
	iperf3 -s -B 12.12.12.118 -p 5001 -D &
	iperf3 -s -B 12.12.12.119 -p 5001 -D &
	iperf3 -s -B 12.12.12.120 -p 5001 -D &
fi

if [[ $action == 'stop' ]]; then
	echo "stop iperf server"
	pkill -9 iperf
fi

