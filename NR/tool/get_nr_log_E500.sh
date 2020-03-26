#! /bin/bash

if [ $# -lt 1 ]
then
        echo "please input action: start|stop|console|all"
      	exit 0
fi

action=$1     #start/stop
logname=$2
starttime=`date +%Y_%m%d_%H%M%S`
t=9999        #catch t second then stop
upf_cfg='192.169.4.5,/root/upf-1.7,upf,123456'
core_cfg='192.169.4.10,/root/5gc-1.7-e500,core,12345688'           #core ip and path
cu_cfg='192.169.4.20,/root/radisys-cu-1.7-e500/bin,cu,123456'    #cu ip and path
du_cfg='192.169.4.30,/root/radisys-du-1.7-E500/bin,du,123456'    #du ip and path
#tcpdumpList=($cu_cfg $du_cfg)    #if cu and du in two vm; there are should be two cfg in tcpdumplist
tcpdumpList=($cu_cfg $core_cfg)            #if cu and du in same vm/pm; catch cu_log is enough

trap 'onCtrlC' INT           #when deceted ctrl+c, stop catch tcpdump log
function onCtrlC ()          #when deceted ctrl+c, call this function
{
    echo '  Ctrl+C is captured'
	StopTcpdump
	echo "  stop pid $$"
	exit 0
}

function StartTcpdump(){
    for item in ${tcpdumpList[*]}; do
    {
	    i=(${item//,/ })   #replace "," to "Space"
	    if [ ! $logname ];then
	        echo "  ssh root@${i[0]} tcpdump -i any -w "${i[1]}/${starttime}_${i[2]}_log.pcap""
            sshpass -p ${i[3]} ssh root@${i[0]} tcpdump -i any -w "${i[1]}/${starttime}_${i[2]}_log.pcap"&
            echo "  catch tpdumplog ${i[1]}/${i[2]}_log.pcap"
        else
            echo "  ssh root@${i[0]} tcpdump -i any -w "${i[1]}/${starttime}_${i[2]}_${logname}_log.pcap""
            sshpass -p ${i[3]} ssh root@${i[0]} tcpdump -i any -w "${i[1]}/${starttime}_${i[2]}_${logname}_log.pcap"&
            echo "  catch tpdumplog ${i[1]}/${starttime}_${i[2]}_${logname}_log.pcap"
        fi
        sleep 1
    }
    done
    echo '  start tcpdump complete'
}

function StopTcpdump(){
    if [ -d "/tmp/nr_log_tmp" ];then
        sleep 1
    else
        mkdir /tmp/nr_log_tmp/
    fi
    echo '  stop all tcpdump process'
	for item in ${tcpdumpList[*]}; do
    {
	    i=(${item//,/ })
		sshpass -p ${i[3]} ssh root@${i[0]} pkill -9 tcpdump
		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:${i[1]}/*_log.pcap /tmp/nr_log_tmp
        echo "  save root@${i[0]}:${i[1]}/*_log.pcap to /tmp/nr_log_tmp"
		sleep 1
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f ${i[1]}/*_log.pcap
        echo "  clean root@${i[0]}:${i[1]}/*_log.pcap"
    }
	done
	pkill -9 get_nr_log_E500
}


function GetConsolelog(){
    echo '  start to get console log'
	for item in $cu_cfg; do
    {
	    i=(${item//,/ })

		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:${i[1]}/*.log /tmp/nr_log_tmp
		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:${i[1]}/*.txt /tmp/nr_log_tmp
    }
	done
	for item in $du_cfg; do
    {
	    i=(${item//,/ })

		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:${i[1]}/*.log /tmp/nr_log_tmp
		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:${i[1]}/*.rlg /tmp/nr_log_tmp
    }
	done
	for item in $core_cfg; do
    {
	    i=(${item//,/ })

		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:/var/log/5gc/*.log /tmp/nr_log_tmp
    }
	done
	for item in $upf_cfg; do
    {
	    i=(${item//,/ })

		sleep 1
        sshpass -p ${i[3]} scp root@${i[0]}:/var/log/5gc/*.log /tmp/nr_log_tmp
    }
	done
}

function CleanConsolelog(){
	for item in $cu_cfg; do
    {
	    i=(${item//,/ })
		sleep 1
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f ${i[1]}/*.log
		sleep 1
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f ${i[1]}/*.txt
    }
	done
	for item in $du_cfg; do
    {
	    i=(${item//,/ })
		sleep 1
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f ${i[1]}/*.log
		sleep 1
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f ${i[1]}/*.rlg
    }
	done
}

function CleanCorelog(){
	for item in $core_cfg; do
    {
	    i=(${item//,/ })
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f /var/log/5gc/*log
    }
	done
	for item in $upf_cfg; do
    {
	    i=(${item//,/ })
        sshpass -p ${i[3]} ssh root@${i[0]} rm -f /var/log/5gc/*log
    }
	done
}

if  [ $action == "start" ];then
    echo '  ******start******'
    StartTcpdump
    sleep ${t}
    StopTcpdump
    exit 0
elif [ $action == 'stop' ];then
    echo '  ******stop******'
    StopTcpdump
    exit 0
elif [ $action == 'console' ];then
    echo '  ******get console log******'
    GetConsolelog
    exit 0
elif [ $action == 'clconsole' ];then
    echo '  ******start clean console log******'
    CleanConsolelog
    echo '  ******clean console log completed******'
    exit 0
elif [ $action == 'clcore' ];then
    echo '  ******start clean core and upf *.log******'
    CleanCorelog
    echo '  ******clean core and upf log completed******'
    exit 0
elif [ $action == 'tar' ];then
    if [ ! ${logname} ];then
	        echo '  error: please input which folder to tar'
	        exit 0
	else
        if [ ! -d "/tmp/${logname}/" ];then
            echo "  error: the folder /tmp/$logname  not exists"
            exit 0
        else
            cd /tmp
            tar -czvf ${logname}.tar.gz ${logname}
            echo '  tar log completed'
        fi
    fi
elif [ $action == 'save' ];then
    if [ ! $logname ];then
	        echo '  error: please input logname'
	        exit 0
	else
        if [ -d "/tmp/$logname/" ];then
            echo "  error: the folder /tmp/$logname  already exists"
            exit 0
        else
            mkdir /tmp/$logname/
            cp /tmp/nr_log_tmp/* /tmp/$logname
            rm -rf /tmp/nr_log_tmp/*
            echo '  save log completed'
        fi
    fi
fi

if  [ $action == '-v' ];then
    echo '  version 1.2'
elif [ $action == '-h' ];then
    echo '  start: to start tcpdump'
    echo '  start ${logname}: to start tcpdump and add ${logname} to log name'
    echo '  press ctrl+c: to stop tcpdump and save log to /tmp/nr_log_tmp'
    echo '  console: to catch console log to /tmp/nr_log_tmp'
    echo '  clconsole: clean all txt rlg log in cu and du fodler,use it before test operation'
    echo '  clcore: clean all log in /var/log/5gc, use it before restart core and upf'
    echo '  save ${foldername}: save all log in /tmp/nr_log_tmp to /tmp/${foldername} and clean /tmp/nr_log_tmp'
    echo '  tar ${foldername}: tar foldername in tmp to foldername.tar.gz'
fi