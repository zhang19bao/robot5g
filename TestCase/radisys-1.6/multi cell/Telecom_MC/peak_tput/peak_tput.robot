*** Settings ***
Documentation     to check ue peak tput under multi cell
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary

*** Variables ***
${HOST}           192.168.10.56
${USERNAME}       root
${PASSWORD}       123456
${cu_console_log}    /root/radisys-new/radisys-cu-1.6-E500-multicell/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.6-E500-multicell/bin/du.log
${target_dl_tput}    5M
${target_ul_tput}    5M
${default_tti}    10000000    #ms
${new_tti}        1000000    #ms

*** Test Cases ***
check UE attach
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    rachReq->cellId =1
    Should Contain    ${output}=    UE IPv4 ADDR allocated
    Should Contain    ${output}=    RRC Reconfiguration Complete
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    rachReq->cellId =2
    Should Contain    ${output}=    UE IPv4 ADDR allocated
    Should Contain    ${output}=    RRC Reconfiguration Complete

do cell1 ping traffic 1st
    check cell1 ping traffic

check CELL1 DL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -s -B 10.10.5.1 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.1 -B 12.12.12.13 -p 5001 -b ${target_dl_tput} -l 1024 -t 20
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    iperf Done

check CELL1 UL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.1 -p 5001 -b ${target_ul_tput} -l 1024 -t 20
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    iperf Done

do cell1 ping traffic 2nd
    check cell1 ping traffic

do cell2 ping traffic 3rd
    check cell2 ping traffic

check CELL2 DL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -s -B 10.10.5.2 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.2 -B 12.12.12.13 -p 5001 -b ${target_dl_tput} -l 1024 -t 20
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    iperf Done

check CELL2 UL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.2 -p 5001 -b ${target_ul_tput} -l 1024 -t 20
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    iperf Done

do cell2 ping traffic 4th
    check cell2 ping traffic

*** Keywords ***
Testline Setup
    #xfe setup
    #upf setup
    smf setup
    amf setup
    #log setup
    cu setup
    du setup

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

log setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh start
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on

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
    #Write    cd /root/radisys-new/radisys-du-1.6-E500/config
    #Write    sed -i 's/L2_TTI_INTERVAL_LEN = ${default_tti}/L2_TTI_INTERVAL_LEN = ${new_tti}/g' ./du_config.txt
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
    #Write    cd /root/radisys-new/radisys-du-1.6-E500/config
    #Write    sed -i 's/L2_TTI_INTERVAL_LEN = ${new_tti}/L2_TTI_INTERVAL_LEN = ${default_tti}/g' ./du_config.txt
    Write    pkill -9 gnb_du
    ${output}=    Read    delay=10s

ue close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    pkill -9 uesim
    ${output}=    Read    delay=10s

check cell1 ping traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -I 10.10.5.1 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13

check cell2 ping traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -I 10.10.5.2 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13
