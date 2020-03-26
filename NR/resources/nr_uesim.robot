*** Settings ***
Documentation
Resource      .${/}common.robot


*** Variables ***
#${USERNAME}       root
#${PASSWORD}       123456
#${local_password}    123456
${cu_console_log}    */cu.log
${du_console_log}    */du.log
${upfssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.5
${coressh}  sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.10
${cussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.20
${dussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30
${uessh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30
${uecssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.40
*** Keywords ***

Testline Setup
    Testline Close  1   #close tl wirhout catch log
    clean log
    :FOR  ${index}  IN RANGE  ${3}
    \   ${stat}     run keyword and return status    xfe setup
    \   Exit For Loop If	 ${stat} == True
    \   xfe close
    upf setup
    smf setup
    amf setup
    log setup
    cu setup
    du setup

xfe setup
#    [Documentation]     start xfe
#    [Arguments]  ${HOST}  ${USERNAME}    ${PASSWORD}
    Open Connection   ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${upfssh}
    Write    modprobe uio_pci_generic
    sleep    3s
    Write    ${startxfe}
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    FE startup successful

upf setup
    log to console  start to setup upf
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${upfssh}
    Write    ${startupf}
    ${output}=    Read    delay=20s
    Should Contain    ${output}=    xFEIngress
    log to console  upf start completed

smf setup
    log to console  start to setup smf
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${startsmf}
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    10.10.8.20
    log to console  smf start completed

amf setup
    log to console  start to setup amf
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${startamf}
    ${output}=    Read    delay=10s
    log to console  amf start completed

log setup
    [Arguments]   ${log_name}=none
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    /home/get_nr_log_E500.sh start
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on
    log to console  start to catch log

clean log
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    /home/get_nr_log_E500.sh clcore
    sleep    3s
    Write    /home/get_nr_log_E500.sh clconsole
    sleep    10s

cu setup
    log to console  start to setup cu
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${cussh}
    sleep    3s
    Write    ulimit -c unlimited
    Write    ${startcu}
    ${output}=	Read   delay=20s
#    ${output}=	read until   STARTING GNB CONFIGURATION
#    OperatingSystem.Append To File  ${TESTSUITE_LOG_DIR}${/}cu_setup.log  ${output}  encoding=bytes
    Write log to text   cu_setup.log   ${output}
    Should Contain    ${output}=    STARTING GNB CONFIGURATION
    log to console  cu start completed

du setup
    log to console  start to setup du
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${dussh}
    sleep  3s
    Write    ulimit -c unlimited
    sleep  3s
    Write    ${startdu}
    ${output}=    Read    delay=30s
    Write log to text   du_setup.log   ${output}
    Should Contain    ${output}=    CELL[1] is UP
    Write Bare    0
    log to console  du start completed

Testline Close
    [Arguments]  ${if_init}=0
    ue close
    du close
    cu close
    run keyword if      ${if_init}==0
    ...        stop logging
    amf close
    smf close
    upf close
    xfe close
    run keyword if      ${if_init}==0
    ...        download log to folder    ${log_folder}
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write   pkill -9 sshpass
    close all connections

download log to folder
    [Arguments]  ${TESTSUITE_LOG_DIR}
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} scp root@${HOST}:/tmp/nr_log_tmp/* ${TESTSUITE_LOG_DIR}
    log to console  download logs to ${TESTSUITE_LOG_DIR}
    sleep   10s
    OperatingSystem.run   sshpass -p ${PASSWORD} ssh root@${HOST} rm -f /tmp/nr_log_tmp/*


stop logging
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    /home/get_nr_log_E500.sh stop
    sleep   30s
    Write    /home/get_nr_log_E500.sh console
    sleep  5s
#    ${output}=    Read    delay=2s
#    Should Contain    ${output}=    all done
    log to console  logging stopped

xfe close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${upfssh}
    Write    pkill -2 startupmgrd.exe
    log to console  xfe stopped

upf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${upfssh}
    Write    pkill -2 upf
    Write    pkill -9 upf
    log to console  upf stopped

smf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -2 smf
    Write    pkill -9 smf
    log to console  smf stopped

amf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -2 amf&&pkill -9 amf
    log to console  amf stopped

cu close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${cussh}
    Write    pkill -2 gnb_cu&&pkill -9 gnb_cu
    log to console  cu stopped

du close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${dussh}
    Write    pkill -2 gnb_du&&pkill -9 gnb_du
    log to console  du stopped

ue close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uessh}
    Write    pkill -2 uesim&&pkill -9 uesim
    log to console  ue closed


check UE attach
    [Arguments]    ${Ue_Num}=1
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uessh}
    Write    ${startue}
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    MT Task Handler
    :For  ${index}  IN RANGE  ${Ue_Num}
    \  Write Bare    z
    \  ${output}=    Read    delay=20s
    \   sleep   20s
#    \  Should Contain    ${output}=    UE IPv4 ADDR allocated
    \  Should Contain    ${output}=    RRC Reconfiguration Complete
    \  log to console   ue ${index} attach complete

check ping traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uecssh}
    Write    ping 12.12.12.13 -c 10
    ${output}=    Read    delay=12s
    Write log to text   ping.txt  ${output}
    Should Contain    ${output}=    64 bytes from 12.12.12.13
    log to console   ping successful

check DL UDP traffic
    [Arguments]  ${bandwidth}=2M  ${time}=30  ${len}=1360
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uecssh}
    Write    iperf3 -s -B 10.10.5.1 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.1 -B 12.12.12.13 -p 5001 -b ${bandwidth} -l ${len} -t ${time}
    ${output}=    Read    delay=${time}s
    Write log to text   DL traffic.txt  ${output}
#    Should Contain    ${output}=    iperf Done
    log to console  start DL UDP traffic successful

check UL UDP traffic
    [Arguments]  ${bandwidth}=2M  ${time}=30  ${len}=1360
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uecssh}
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.1 -p 5001 -b ${bandwidth} -l ${len} -t ${time}
    ${output}=    Read    delay=${time}s
    Write log to text   UL traffic.txt  ${output}
#    Should Contain    ${output}=    iperf Done
    log to console  start UL UDP traffic successful