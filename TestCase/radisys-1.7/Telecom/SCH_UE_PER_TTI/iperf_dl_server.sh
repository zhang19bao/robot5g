#! /bin/sh

if [ $# -ne 1 ]
then
        echo "please input action: start|stop"
        exit 0
fi

action=$1

if [[ $action == 'start' ]]; then
	echo "start iperf server"
	iperf3 -s -B 10.10.5.1 -p 5001 -D &
	iperf3 -s -B 10.10.5.2 -p 5001 -D &
	iperf3 -s -B 10.10.5.3 -p 5001 -D &
	iperf3 -s -B 10.10.5.4 -p 5001 -D &
	iperf3 -s -B 10.10.5.5 -p 5001 -D &
	iperf3 -s -B 10.10.5.6 -p 5001 -D &
	iperf3 -s -B 10.10.5.7 -p 5001 -D &
	iperf3 -s -B 10.10.5.8 -p 5001 -D &
fi

if [[ $action == 'stop' ]]; then
	echo "stop iperf server"
	pkill -9 iperf
fi

