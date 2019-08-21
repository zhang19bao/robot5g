*** Settings ***
Documentation     cit to check multicell multi ue dl and ul udp
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary
Library           Process

*** Variables ***
${UE_NUM}         8
${HOST}           192.168.10.56
${USERNAME}       root
${PASSWORD}       123456
${cu_console_log}    /root/radisys-new/radisys-cu-1.6-E500-multicell/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.6-E500-multicell/bin/du.log

*** Test Cases ***
UE attach
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler
    Repeat Keyword    ${UE_NUM}    attach ue

check ping traffic
    check ping traffic

check DL UDP traffic
    check DL UDP traffic

check UL UDP traffic
    check UL UDP traffic

*** Keywords ***
Testline Setup
    #xfe setup
    #upf setup
    smf setup
    amf setup
    #log setup
    cu setup
    du setup

log setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh start
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on

xfe setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    startxfe
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    FE startup successful

upf setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    startupf
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    xFEIngress

smf setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    startsmf
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    10.10.8.20

amf setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    startamf
    ${output}=    Read    delay=10s

cu setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    ulimit -c unlimited
    Write    startcu
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    STARTING GNB CONFIGURATION

du setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    ulimit -c unlimited
    Write    startdu
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    CELL[1] is UP
    Should Contain    ${output}=    CELL[2] is UP
    Should Contain    ${output}=    Num Ue Per TTI stats

Testline Close
    ue close
    du close
    cu close
    #stop logging
    amf close
    smf close
    #upf close
    #xfe close
    close all connections

stop logging
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh all
    ${output}=    Read    delay=200s
    Should Contain    ${output}=    all done

xfe close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    pkill -9 xfe

upf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    pkill -9 upf

smf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -9 smf

amf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -9 amf

cu close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    pkill -9 gnb_cu
    ${output}=    Read    delay=10s

du close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    pkill -9 gnb_du
    ${output}=    Read    delay=10s

ue close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    pkill -9 uesim
    ${output}=    Read    delay=10s

attach ue
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    UE IPv4 ADDR allocated
    Should Contain    ${output}=    RRC Reconfiguration Complete

check DL UDP traffic
    : FOR    ${ueip}    IN RANGE    ${UE_NUM}
    \    ${ueip}    Evaluate    ${ueip}+1
    \    Open Connection    ${HOST}
    \    Login    ${USERNAME}    ${PASSWORD}
    \    Write    uecssh
    \    Write    iperf3 -s -B 10.10.5.${ueip} -p 5001
    \    Open Connection    ${HOST}
    \    Login    ${USERNAME}    ${PASSWORD}
    \    Write    iperf3 -u -c 10.10.5.${ueip} -B 12.12.12.13 -p 5001 -b 2M -l 1024 -t 10
    \    ${output}=    Read    delay=20s
    \    Should Contain    ${output}=    iperf Done

check UL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Write    uecssh
    : FOR    ${ueip}    IN RANGE    ${UE_NUM}
    \    ${ueip}    Evaluate    ${ueip}+1
    \    Open Connection    ${HOST}
    \    Login    ${USERNAME}    ${PASSWORD}
    \    Write    uecssh
    \    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.${ueip} -p 5001 -b 2M -l 1024 -t 10
    \    ${output}=    Read    delay=20s
    \    Should Contain    ${output}=    iperf Done

check ping traffic
    : FOR    ${ueip}    IN RANGE    ${UE_NUM}
    \    ${ueip}    Evaluate    ${ueip}+1
    \    Open Connection    ${HOST}
    \    Login    ${USERNAME}    ${PASSWORD}
    \    Write    uecssh
    \    Write    ping 12.12.12.13 -I 10.10.5.${ueip} -c 10
    \    ${output}=    Read    delay=10s
    \    Should Contain    ${output}=    64 bytes from 12.12.12.13
