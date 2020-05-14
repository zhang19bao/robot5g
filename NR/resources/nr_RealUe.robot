*** Settings ***
Documentation
...  common keywords for realue TL
...  "Author: zhangbr@certusnet.com.cn"

Library       Telnet
Resource      .${/}common.robot
Resource      .${/}PowerSwitchControl.robot


*** Variables ***
${spark_host}  172.21.6.60
${spark_user}  E500
${spark_password}  12345688
${upfssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.5
${coressh}  sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.10
${cussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.20

*** Keywords ***

realUe Testline Setup
    realUe Testline Close  1
#    rru reboot
    :FOR  ${index}  IN RANGE  ${3}
    \   ${stat}     run keyword and return status    realUe xfe setup
    \   Exit For Loop If	 ${stat} == True
    \   realUe xfe close
    realUe clean log
    realUe upf setup
    realUe smf setup
    realUe amf setup
    realUe cu setup
    realUe phy setup
    realUe log start
    sleep  3s
    realUe du setup
    realUe log stop
    realUe AutoCheck and ConnectEQ
    sleep  3s

realUe xfe setup
    log to console  start to setup xfe
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
#    SSHLibrary.Write    feappctl --start
#    sleep    3s
#    SSHLibrary.Write    feappctl --status
    SSHLibrary.Write    ${startxfe}
    ${output}=    SSHLibrary.Read    delay=120s
#    log to console   ${output}
    Should Contain    ${output}=    FE startup successful
#    Should Contain    ${output}=   FE Status       READY
    log to console  xfe start completed

realUe upf setup
    log to console  start to setup upf
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
    SSHLibrary.Write    ${startupf}
    ${output}=    SSHLibrary.Read    delay=20s
    Should Contain    ${output}=    xFEIngress
    log to console  upf start completed

realUe smf setup
    log to console  start to setup smf
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${startsmf}
    ${output}=    SSHLibrary.Read    delay=10s
    Should Contain    ${output}=    10.10.8.20
    log to console  smf start completed

realUe amf setup
    log to console  start to setup amf
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${startamf}
    ${output}=    SSHLibrary.Read    delay=10s
    log to console  amf start completed

realUe cu setup
    log to console  start to setup cu
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    ulimit -c unlimited
    SSHLibrary.Write    ${confd}
    sleep  30s
    SSHLibrary.Write    ps -ef|grep confd
    sleep  3s
    SSHLibrary.Write    ${startcu}
    ${output}=	SSHLibrary.Read	delay=20s
    Should Contain    ${output}=    STARTING GNB CONFIGURATION  #Running SCTP server
    log to console  cu start completed

realUe phy setup
    log to console  start to setup phy
    ${phy_ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    set global variable   ${phy_ssh_index}
    SSHLibrary.Write    ${startphy}
    ${output}=    SSHLibrary.Read    delay=20s
    Should Contain    ${output}=    welcome to application console
    log to console  phy start completed

rru reboot
    log to console  start to reboot rru
    ${phy_ssh_index}  Create Ssh Connection    ${rru_ip}  root  root
    SSHLibrary.Write    reboot
    ${output}=    SSHLibrary.Read    delay=5s
    Should Contain    ${output}=    The system is going down for reboot NOW
    log to console  reboot rru completed

realUe du setup
    log to console  start to setup du
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    ulimit -c unlimited
    SSHLibrary.Write    ${startdu}
    sleep  5s
    SSHLibrary.Write Bare  0
    ${output}=    SSHLibrary.Read    delay=10s
    Should Contain    ${output}=   CELL[1] is UP  # CELL[1] is UP
    log to console  du start completed

realUe Testline Close
    [Arguments]  ${if_init}=0
    realUe PowerOff
    realUe phy close
    realUe du close
    realUe cu close
    realUe amf close
    realUe smf close
    realUe upf close
    realUe xfe close
    run keyword if      ${if_init}==0
    ...        realUe get console log
    run keyword if      ${if_init}==0
    ...        realUe download log to folder  ${TESTSUITE_LOG_DIR}
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write   pkill -9 sshpass
    sleep  1s
    SSHLibrary.close all connections

realUe log start
    [Arguments]  ${logname}=${empty}
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}   ${NRPWD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    /home/regression1.8/get_nr_log_E500.sh start ${logname}
    sleep   10s
    ${output}=    SSHLibrary.Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on
    log to console  start to catch log

realUe clean log
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${NRPWD} ssh root@${NRHOST} rm -rf /tmp/nr_loh_tmp/*
    sleep   3s
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${NRPWD} ssh root@${NRHOST} /home/regression1.8/get_nr_log_E500.sh clcore
    sleep   5s
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${NRPWD} ssh root@${NRHOST} /home/regression1.8/get_nr_log_E500.sh clconsole
    sleep   5s

realUe log stop
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${NRPWD} ssh root@${NRHOST} /home/regression1.8/get_nr_log_E500.sh stop
    sleep   30s
    log to console  tcpdump log stopped

realUe get console log
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${NRPWD} ssh root@${NRHOST} /home/regression1.8/get_nr_log_E500.sh console
    sleep  40s
    log to console  logging stopped

realUe download log to folder
    [Arguments]  ${log_folder}=${TESTSUITE_LOG_DIR}
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${NRPWD} scp root@${NRHOST}:/tmp/nr_log_tmp/* ${log_folder}
    log to console  download logs to ${log_folder}
    sleep   20s
    OperatingSystem.run   sshpass -p ${NRPWD} ssh root@${NRHOST} rm -f /tmp/nr_log_tmp/*

realUe xfe close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
#    SSHLibrary.Write    feappctl --shutdown
    sleep  3s
    SSHLibrary.Write    pkill -9 startupmgrd.exe
    sleep  3s
    log to console  xfe stopped

realUe upf close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
    SSHLibrary.Write    pkill -9 upf
    log to console  upf stopped

realUe smf close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Write    pkill -9 smf
    log to console  smf stopped

realUe amf close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    pkill -9 amf
    sleep  1s
    SSHLibrary.Write    pkill -9 tcpdump
    log to console  amf stopped

realUe cu close
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    pkill -9 gnb_cu
    sleep  1s
    SSHLibrary.Write    pkill -9 tcpdump
    log to console  cu stopped

realUe phy close
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    pkill -2 l1app
    sleep  5s
    SSHLibrary.Write    pkill -9 l1app
    log to console  phy stopped

realUe du close
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    pkill -2 gnb_du
    sleep  3s
    SSHLibrary.Write    pkill -9 gnb_du
    log to console  du stopped

realUe send cmd to spark
    [Documentation]     ...  AutoCheck
                        ...  ConnectEQ
                        ...  DisConnectEQ
                        ...  StartLog
                        ...  StopLog
    [Arguments]   ${cmd}
    ${output}  OperatingSystem.Run  /home/robot5g/NR/tool/spark_cmd.py ${cmd}
    [return]  ${output}

realUe send cmd with index to spark
    [Documentation]     ...  StartTest  1
                        ...  StopTest  1
                        ...  PowerOff  1
                        ...  PowerOn  1
                        ...  Attach  1
                        ...  Detach  1
                        ...  UpdateTask  1
                        ...  GetParamMAC  1
                        ...  GetParamIMSI  1
    [Arguments]   ${cmd}  ${index}
    ${output}  OperatingSystem.Run  /home/robot5g/NR/tool/spark_cmd.py ${cmd} ${index}
    [return]  ${output}

realUe AutoCheck and ConnectEQ
    ${output}=  realUe send cmd to spark  AutoCheck
    sleep  1s
    Should Contain    ${output}=  "State":0
    ${output}=  RealUe send cmd to spark  ConnectEQ
    sleep  1s
    Should Contain    ${output}=  "State":0

realUe PowerOff and PowerOn
    [Arguments]  ${index}=1
    ${output}=  RealUe send cmd with index to spark  PowerOff  ${index}
    sleep  1s
    Should Contain    ${output}=  "State":0
    ${output}=  RealUe send cmd with index to spark  PowerOn  ${index}
    sleep  1s
    Should Contain    ${output}=  "State":0

realUe DL UDP send
    [Arguments]  ${bandwidth}=200M  ${parallel}=4
    SSHLibrary.Open Connection    ${HOST}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    log to console  start dl transmission
    SSHLibrary.Write    iperf -u -c 10.10.5.1 -B 12.12.12.13 -p 5001 -b ${bandwidth} -l 1400 -t 40 -P ${parallel}
    ${output}=    SSHLibrary.Read    delay=40s
#    log to console  start DL UDP traffic successful

realUe UL UDP send
    [Arguments]  ${index}=1
    log to console  start ul transmission
    ${output}=  RealUe send cmd with index to spark  UpdateTask  ${index}
    sleep  3s
    Should Contain    ${output}=  "State":0
    ${output}=  RealUe send cmd with index to spark  StartTest  ${index}
    sleep  3s
    Should Contain    ${output}=  "State":0

realUe check ping
    SSHLibrary.Open Connection    ${HOST}
    SSHLibrary.Login    ${USERNAME}    ${PASSWORD}
    SSHLibrary.Write    ping 10.10.5.1 -c 3 -W 1
    ${output}=    Read    delay=4s
    Write log to text   ping.txt  ${output}
    Should Contain    ${output}=    64 bytes from 10.10.5.1

realUe stop Testtask
    [Arguments]  ${index}=1
    ${output}=  RealUe send cmd with index to spark  StopTest  ${index}
    sleep  2s
    Should Contain    ${output}=  "State":0

realUe PowerOff
    [Arguments]  ${index}=1
    ${output}=  RealUe send cmd with index to spark  PowerOff  ${index}
    sleep  5s
    Should Contain    ${output}=  "State":0

realUe get ue ipaddr
    [Arguments]  ${index}=1
    ${output}=  RealUe send cmd with index to spark  GetParamIMSI  ${index}
    sleep  3s
    Should Contain    ${output}=  "State":0

realue start spark log
    [Arguments]  ${spark_log_path}= "C:\\\\sparkLogfiles\\\\"
    ${output}  OperatingSystem.Run  /home/robot5g/NR/tool/spark_cmd.py StartLog ${spark_log_path} ${log_file_name}
    [return]  ${output}

realue stop spark log
    realUe send cmd to spark  StopLog