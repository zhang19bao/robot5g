*** Settings ***
Documentation
Library        OperatingSystem
Library        SSHLibrary
Library        DateTime
Library        String
Resource      .${/}common.robot


*** Variables ***
${cu_console_log}    /root/radisys-new/radisys-cu-1.6-E500/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.6-E500/bin/du.log
${upfssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.5
${coressh}  sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.10
${cussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.20
${dussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30
${uessh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30
${uecssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.40
*** Keywords ***

Testline Setup
    Testline Close
#    :FOR  ${index}  IN Range  ${3}
#    \   ${stat}     run keyword and return status    xfe setup
#    \   Exit For Loop If	 ${stat} == True
#    \   xfe close
#    upf setup
    smf setup
    amf setup
    #log setup
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
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh start
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on
    log to console  start to catch log

cu setup
    log to console  start to setup cu
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${cussh}
    Write    ulimit -c unlimited
    Write    ${startcu}
    ${output}=	Read	delay=20s
    Write log to text   cu.log   ${output}
    Should Contain    ${output}=    STARTING GNB CONFIGURATION
    log to console  cu start completed

du setup
    log to console  start to setup du
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${dussh}
    Write    ulimit -c unlimited
    Write    ${startdu}
    ${output}=    Read    delay=20s
    Should Contain    ${output}=    CELL[1] is UP
    log to console  du start completed

Testline Close
    ue close
    du close
    cu close
    #stop logging
    amf close
    smf close
#    upf close
#    xfe close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write   pkill -9 sshpass
    close all connections

stop logging
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh all
    ${output}=    Read    delay=200s
    Should Contain    ${output}=    all done
    log to console  logging stopped

xfe close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${upfssh}
    Write    pkill -9 xfe
    log to console  xfe stopped

upf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${upfssh}
    Write    pkill -9 upf
    log to console  upf stopped

smf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -9 smf
    log to console  smf stopped

amf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -9 amf
    log to console  amf stopped

cu close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${cussh}
    Write    pkill -9 gnb_cu
    log to console  cu stopped

du close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${dussh}
    Write    pkill -9 gnb_du
    log to console  du stopped

ue close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uessh}
    Write    pkill -9 uesim
    log to console  ue closed

Write log to text
    [Documentation]   write log to specified file
    [Arguments]       ${log_name}  ${context}
    OperatingSystem.Append To File  ${TESTSUITE_LOG_DIR}${/}${log_name}  ${context}  encoding=UTF-8

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
    \  Should Contain    ${output}=    UE IPv4 ADDR allocated
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
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uecssh}
    Write    iperf3 -s -B 10.10.5.1 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.1 -B 12.12.12.13 -p 5001 -b 2M -l 1024 -t 30
    ${output}=    Read    delay=50s
    Write log to text   DL traffic.txt  ${output}
    Should Contain    ${output}=    iperf Done
    log to console  start DL UDP traffic successful

check UL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uecssh}
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.1 -p 5001 -b 2M -l 1024 -t 30
    ${output}=    Read    delay=50s
    Write log to text   UL traffic.txt  ${output}
    Should Contain    ${output}=    iperf Done
    log to console  start UL UDP traffic successful