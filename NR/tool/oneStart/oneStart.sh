#!/bin/bash
####Author:caocy@certusnet.com.cn

#sequence=("CU" "L1" "DU")
#startL1="cd /home/ccy/bs1/phy_20191204_1534&&./phystart.sh"
#passL1="welcome to application console"
#startCU="cd /home/ccy/bs1/cu/cu && ./gnb_cu"
#passCU="Running SCTP server"
#startDU="cd /home/ccy/bs1/du/bin && ./gnb_du -f ../config/ssi_mem"
#passDU="Received GNB-DU CONFIG UPDATE ACK"
strPid="l1|gnb_du|gnb_cu|amf|smf|upf|startupmgrd"
#strPid="l1|gnb_du|gnb_cu"
currPath=`pwd`
tPath="/tmp/"
screenExist=`screen -v`
if [ -z "$screenExist" ]; then
    echo "Need Install screen Command, Exit"
    exit 1
fi
rtOS=`uname -r|grep -c rt`
fpgaNum=`lspci|grep -c Alt`
if [ $rtOS -ne 1 ]; then
    echo "OS isn't RT OS, Exit"
#    exit 1
fi

if [ $fpgaNum -ne 2 ]; then
    echo "Num of FPGA isn't 2, Exit"
#    exit 1
fi
if [ -z $1 ]; then
    mode="start"
else
    mode=$1
    shift 1
fi
###config parse
curConfig=$currPath/config
if [ ! -f "$curConfig" ]; then
    echo "No config File, Exit"
    exit 1
fi

flagConf=`cat config|grep -c "\[ONESTART\]"`
if [ $flagConf -eq 1 ]; then
    confPath=$tPath/config
    rm -rf $confPath
    cp config $confPath
    sed -i '/\[ONESTART\]/d' $confPath
    source $confPath
else
    echo "Invalid config File, Exit"
    exit 1
fi
###Prepare
logPath=$currPath/screen_%t.log
screenRC=$tPath/longtimescreenrc
cat /etc/screenrc >$screenRC
echo logfile $logPath >>$screenRC
logPathRemote=$tPath/screen_%t.log
screenRCRemote=$tPath/longtimescreenrcremote
cat /etc/screenrc >$screenRCRemote
echo logfile $logPathRemote >>$screenRCRemote
#####################
#for net in ${sequence[@]}
#do
#    start=`eval echo '$'start"$net"`
#    echo $start >$tPath/start$net.sh
#    chmod +x $tPath/start$net.sh
#done
#####check parameters#####
modeSequence=( )
remoteSequence=()
for net in ${sequence[@]}
do
    ip=`eval echo '$'ip"$net"`
    user=`eval echo '$'user"$net"`
    passwd=`eval echo '$'passwd"$net"`
    if [ "$ip" != "" ]; then
        shortIP=`echo $ip|grep -Po "[0-9]+.[0-9]+$"`
        modeSequence=( "${modeSequence[@]}" "$shortIP" )
        remoteSequence=( "${remoteSequence[@]}" "$net" )
        if [ "$user" == "" ]; then
            eval user$net="root"
        fi
        if [ "$passwd" == "" ]; then
            eval passwd$net="123456"
        fi
    else
        modeSequence=( "${modeSequence[@]}" "Local" )
    fi
done
#########all remote OS ping check
if [ ${#remoteSequence[*]} -ge 1 ]; then
    echo "Remote IPs Checking, Wait..."
    while [ ${#remoteSequence[*]} -ge 1 ]
    do
        passNum=0
        for net in ${remoteSequence[@]}
        do
            ip=`eval echo '$'ip"$net"`
            result=`ping -c 1 $ip|grep -c "1 received"`
            if [[ $result -eq 1 ]]; then
                let passNum++
            fi
######      echo $ip $passNum ${#remoteSequence[*]}
        done
        if [[ ${#remoteSequence[*]} -eq $passNum  ]]; then
            break
        fi
    done
  echo "Remote IPs Checking, Pass..."
fi
##########################
Max=10
####
function check(){
    i=0
    result=0
    while [ $i -le $Max ]
    do
        result=`cat screen_$1.log |grep -c "$2"`
#        echo $1 $2 $result
        if [[ $result -ge 1 ]]; then
        echo "$1 OK"
        return  0
        break;
        fi
        ping -c 6 127.0.0.1 >/dev/null
        let i++
    done
    echo "$1 Failed, exit, please try again"
    exit 1
    return 1
}
#####

#kill exist process in local OS

for net in ${sequence[@]}
do
    IDs=`screen -ls| grep -E "$net"|awk '{print $1}'`
    for pid in $IDs
    do
#	screen -x -S $net -p 0 -X stuff '\nexit\n'
#	sleep  2
        screen -X -S $pid quit >/dev/null
        screen -wipe $pid >/dev/null
    done
done
IDs=`ps -ef| grep -E "$strPid"|grep -v 'grep'|awk '{print $2}'`
for pid in $IDs
do
     kill -SIGINT $pid
#    kill -9 $pid  
done
#kill exist process in remote OS
for net in ${remoteSequence[@]}
do
    ip=`eval echo '$'ip"$net"`
    user=`eval echo '$'user"$net"`
    passwd=`eval echo '$'passwd"$net"`
    IDs=`sshpass -p $passwd ssh $user@$ip "ps -ef| grep -E '$strPid'|grep -v 'grep'|awk '{print \\$2}'"`
    for pid in $IDs
    do
        sshpass -p $passwd ssh $user@$ip "kill -9 $pid"
    done
    IDs=`sshpass -p $passwd ssh $user@$ip "screen -ls| grep -E '$net'|awk '{print \\$1}'"`
    for pid in $IDs
    do  
       shpass -p $passwd ssh $user@$ip "screen -x -S $net -p 0 -X stuff '\nexit\n'"
        sleep  2
        sshpass -p $passwd ssh $user@$ip "screen -X -S $pid quit >/dev/null"
        sshpass -p $passwd ssh $user@$ip "screen -wipe $pid >/dev/null"
        sshpass -p $passwd ssh $user@$ip "rm -rf $tPath/screen_*.log >/dev/null"
    done
done


echo Mode:$mode
if [ "$mode" != "start" ]; then
    exit 0
fi

rm -rf screen_*.log
rm -rf screenlog*
for net in ${sequence[@]}
do
    screen -c $screenRC -t $net -L -dmS $net
done
for net in ${remoteSequence[@]}
do
    sshpass -p $passwd scp $screenRCRemote $user@$ip:$tPath
    sshpass -p $passwd ssh $user@$ip "screen -c $screenRCRemote -t $net -L -dmS $net"
done
ping -c 3 127.0.0.1 >/dev/null

###
echo =====Start Order=====
for i in "${!sequence[@]}";
do
    if [ $i -ne 0 ]; then
        fff="-n \\t"
    else
        fff="-n"
    fi
    echo -e $fff ${sequence[$i]}
done
echo ""
for i in "${!sequence[@]}";
do
    if [ $i -ne 0 ]; then
        fff="-n \\t"
    else
        fff="-n"
    fi
    echo -e $fff "|"
done
echo ""
for i in "${!modeSequence[@]}";
do
    if [ $i -ne 0 ]; then
        fff="-n \\t"
    else
        fff="-n"
    fi
    echo -e $fff ${modeSequence[$i]}
done
echo ""
echo =====================
#################
for net in ${sequence[@]}
do
    echo "$net Starting..."
    start=`eval echo '$'start"$net"`
    #screen -x $net -X stuff '$tPath/start$net.sh\n'
####remote mode
    ip=`eval echo '$'ip"$net"`
if [ "$ip" != "" ]; then
    user=`eval echo '$'user"$net"`
    passwd=`eval echo '$'passwd"$net"`
#####call script to execute command on remote OS
#    screen -x -S $net -p 0 -X stuff "\nsshpass -p $passwd scp $tPath/start$net.sh $user@$ip:$tPath \n"
#    screen -x -S $net -p 0 -X stuff "\nsshpass -p $passwd ssh $user@$ip '$tPath/start$net.sh'\n"
#####execute command on remote OS
#screen -x -S $net -p 0 -X stuff "\nsshpass -p $passwd ssh $user@$ip '$start'\n"
#####screen on remote OS and execute command in remote screen, then tail output to local,need to implement

    screen -x -S $net -p 0 -X stuff "sshpass -p $passwd ssh $user@$ip 'tail -n 1 -f /tmp/screen_$net.log'\n"
    sshpass -p $passwd ssh $user@$ip "screen -x -S $net -p 0 -X stuff '\n$start\n'"
	ping -c 6 127.0.0.1 >/dev/null

####local mode
else
    screen -x -S $net -p 0 -X stuff "\n$start\n"
	ping -c 6 127.0.0.1 >/dev/null
fi
    pass=`eval echo '$'pass"$net"`
    check "$net" "$pass"
done





