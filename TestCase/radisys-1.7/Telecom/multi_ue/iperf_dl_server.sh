#! /bin/bash

if [ $# -ne 2 ]
then
        echo "please input action: start|stop and ue number"
        exit 0
fi

action=$1
num=$2
ip=10+$num

if [[ $action == 'start' ]]; then
	echo "start iperf server"
	for ((i=11;i<=$ip;i++))
		do
			iperf3 -s -B 10.10.5.$i -p 5001 -D &
		done
fi

if [[ $action == 'stop' ]]; then
	echo "stop iperf server"
	pkill -9 iperf
fi

