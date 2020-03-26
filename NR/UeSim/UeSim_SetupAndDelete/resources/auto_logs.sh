#!/bin/bash

if [ $# -ne 1 ]
then
        echo "please input action: start|stop|collect|all"
      	exit 0
fi

action=$1
cur_path=`pwd`
logPath=/root/`date -u +%Y%m%d_%H%M`
password='123456'

###tcpdump collect list
template="ip,nic,log_name"
#server="192.169.4.60,ens4,server"
smf="192.169.4.10,ens5,smf"
amf="192.169.4.10,ens6,amf"
cu0="192.169.4.20,ens4,cu-ngc"
cu1="192.169.4.20,ens5,cu-ngu"
cu2="192.169.4.20,ens6,cu-f1u"
cu3="192.169.4.20,lo,cu-inside"
du0="192.169.4.30,ens4,du-f1c"
du1="192.169.4.30,ens5,du-f1u"
#du2="192.169.4.30,ens6,du-pal"
du3="192.169.4.30,lo,du-inside"
#ue1="192.169.4.40,ens4,ue-pal"
ue2="192.169.4.30,ens5,ue-out"
ue3="192.169.4.30,lo,ue-inside"
uec1="192.169.4.40,ens4,uec1"
#uec2="192.169.4.51,ens4,uec2"

tcpdumpList=( $server $smf $amf $cu0 $cu1 $cu2 $cu3 $du0 $du1 $du2 $du3 $ue1 $ue2 $ue3 $uec1 $uec2 )
###tcpdump collect list

###syslog collect list
template="ip,type,log_path,log_files_num"
cu1s="192.169.4.20,cu,/root/radisys-cu-1.6-E500/bin,10"
du1s="192.169.4.30,du,/root/radisys-du-1.6-E500/bin,10"

syslogList=( $cu1s $du1s )
###syslog collect list
###tcpdump function
if [[ $action == 'start' || $action == 'stop' || $action == 'all' ]]; then
				echo "Start/Stop tcpdump"
				for info in ${tcpdumpList[*]}
				        do
				                array=(${info//,/ })
				                ip=${array[0]}
				                nic=${array[1]}
				                fileName=${array[2]}-
				                if [  $nic == 'any' ];then
				                        nicI=$nic
				                        hostname=`sshpass -p $password ssh root@$ip hostname`
				                        fileName+=$hostname'-any.pcap'
				                else
				                        nicI=`sshpass -p $password ssh root@$ip tcpdump -D|grep -w $nic|awk -F . '{print $1}'`
				                        fileName+=`sshpass -p $password ssh root@$ip ifconfig $nic|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|awk '{print $2}'`.pcap
				                fi
				                if [ $action == 'start' ];

				                then
							
				                        sshpass -p $password ssh root@$ip tcpdump -i $nicI -w /root/$fileName &
							
				                else
				                        
				                 
				                        pid=`sshpass -p $password ssh root@$ip ps -ef|grep -E "tcpdump -i $nicI -w /root/$fileName"|grep -v 'grep'|grep -v 'ssh'|awk '{print $2}'`
				                        
				                        for i in ${pid[*]}
				                        	do
				                        		sshpass -p $password ssh root@$ip kill -9 $pid
				                        
							done
							
							if [[ $pid ]]; then
								mkdir -p $logPath			                        
					                        sshpass -p $password scp root@$ip:/root/$fileName $logPath
							fi			                        
				                fi


				done

fi|
###syslog function
if [[ $action == 'start' ]]; then
				
				for info in ${syslogList[*]}
				        do
				                array=(${info//,/ })
				                ip=${array[0]}
				                folder=${array[1]}
				                sysLogPath=${array[2]}
						taskRunning=`sshpass -p $password ssh root@$ip ps -ef|grep gnb|grep -cv grep`
						if [ $taskRunning == 0 ]; then
							echo "clear $folder syslog"
				                	sshpass -p $password ssh root@$ip rm -rf $sysLogPath/*.log
							sshpass -p $password ssh root@$ip rm -rf $sysLogPath/*log*.txt
						else
							echo "$folder Task is Running, Don't clear syslog"
						fi
						array=''
						ip=''
						folder=''
						sysLogPath=''
				done
fi
if [[ $action == 'collect' || $action == 'all' ]]; then
				echo "Collect syslog"
				mkdir -p $logPath
				for info in ${syslogList[*]}
				        do
				                array=(${info//,/ })
				                ip=${array[0]}
				                folder=${array[1]}
				                sysLogPath=${array[2]}
				                logNum=${array[3]}
				                logs=`sshpass -p $password ssh root@$ip ls -t $sysLogPath/|grep log|grep . -m $logNum`
				                logList=(${logs// / })
				                subLogPath=$logPath/$folder
				                mkdir -p $subLogPath
				                for log in ${logList[*]}
				                	do
				                	sshpass -p $password scp root@$ip:$sysLogPath/$log $subLogPath
				                done
				done
fi
echo "$action done"


