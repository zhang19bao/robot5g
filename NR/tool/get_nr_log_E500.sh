#! /bin/bash

if [ $# -lt 1 ]
then
        echo "please input action: start|stop|console"
      	exit 0
fi

action=$1     #start/stop
password='123456'
t=10         #catch t second then stop
core_cfg='192.169.4.20,root/5gc-1.7-e500'
cu_cfg='192.169.4.20,/root/radisys-cu-1.7-e500/bin,cu'    #cu vm ip and path
du_cfg='192.169.4.30,/root/radisys-du-1.7-E500/bin,du'    #du vm ip and path
tcpdumpList=($cu_cfg $du_cfg)    #if cu and du in two vm; there are will be two cfg in tcpdumplist
#tcpdumpList=($cu_cfg)            #if cu and du in same vm/pm; catch cu_log is enough
trap 'onCtrlC' INT           #when deceted ctrl+c, stop catch tcpdump log
function onCtrlC ()          #when deceted ctrl+c, call this function
{
    echo 'Ctrl+C is captured'
	./$0 stop
	exit 0
}

if [ $action == 'start' ]; then
    for item in ${tcpdumpList[*]}; do
    {
	    i=(${item//,/ })   #replace "," to "Space"
        sshpass -p $password ssh root@${i[0]} tcpdump -i any -w "${i[1]}/${i[2]}_log.pcap"&
        sleep 1
    }
    done
	sleep $t
	./$0 stop
	exit 0
fi

if [ $action == 'stop' ]; then
    rm -rf /tmp/nr_log_tmp
    mkdir /tmp/nr_log_tmp
	for item in $cu_cfg $du_cfg; do
    {
	    i=(${item//,/ })
		sshpass -p $password ssh root@${i[0]} pkill -9 tcpdump
		sleep 1
        sshpass -p $password scp root@${i[0]}:${i[1]}/*_log.pcap /tmp/nr_log_tmp
		sleep 1
        sshpass -p $password ssh root@${i[0]} rm -f ${i[1]}/*_log.pcap
    }
	done
	exit 0
fi

if [ $action == 'console' ]; then
	for item in $cu_cfg; do
    {
	    i=(${item//,/ })

		sleep 1
        sshpass -p $password scp root@${i[0]}:${i[1]}/*.log /tmp/nr_log_tmp
		sleep 1
        sshpass -p $password scp root@${i[0]}:${i[1]}/*.txt /tmp/nr_log_tmp
    }
	done
	for item in $du_cfg; do
    {
	    i=(${item//,/ })

		sleep 1
        sshpass -p $password scp root@${i[0]}:${i[1]}/*.log /tmp/nr_log_tmp
		sleep 1
        sshpass -p $password scp root@${i[0]}:${i[1]}/*.rlg /tmp/nr_log_tmp
    }
	done
	exit 0
fi