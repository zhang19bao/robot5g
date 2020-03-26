#!/bin/bash

if [ $# -ne 2 ]
then
        echo "please input action: start|stop and ue number: 8|16|32"
        exit 0
fi

action=$1
num=$2
ip=12+$num

if [[ $action == 'start' ]]; then
        echo "start iperf server"
        for ((i=13;i<=$ip;i++))
                do
                        iperf3 -s -B 12.12.12.$i -p 5001 -D &
                done
fi

if [[ $action == 'stop' ]]; then
	echo "stop iperf server"
	pkill -9 iperf
fi

