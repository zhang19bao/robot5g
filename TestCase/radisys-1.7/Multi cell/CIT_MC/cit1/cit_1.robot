*** Settings ***
Documentation     cit to check multicell ue attach/ping/dl udp/ul udp
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary

*** Variables ***
${gNB HOST}       192.168.10.56
${core HOST}      192.168.10.56
${USERNAME}       root
${PASSWORD}       123456

*** Test Cases ***
check UE attach
    Open Connection    ${gNB HOST}
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

check ping traffic
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -I 10.10.5.11 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13
    Write    ping 12.12.12.13 -I 10.10.5.12 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13

check CELL1 DL UDP traffic
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -s -B 10.10.5.11 -p 5001
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.11 -B 12.12.12.13 -p 5001 -b 2M -l 1024 -t 30
    ${output}=    Read    delay=50s
    Should Contain    ${output}=    iperf Done

check CELL1 UL UDP traffic
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.11 -p 5001 -b 2M -l 1024 -t 30
    ${output}=    Read    delay=50s
    Should Contain    ${output}=    iperf Done

check CELL2 DL UDP traffic
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -s -B 10.10.5.12 -p 5001
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.12 -B 12.12.12.13 -p 5001 -b 2M -l 1024 -t 30
    ${output}=    Read    delay=50s
    Should Contain    ${output}=    iperf Done

check CELL2 UL UDP traffic
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.12 -p 5001 -b 2M -l 1024 -t 30
    ${output}=    Read    delay=50s
    Should Contain    ${output}=    iperf Done

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
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    startxfe
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    FE startup successful

upf setup
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    startupf
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    xFEIngress

smf setup
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    startsmf
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    10.10.8.20

amf setup
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    startamf
    ${output}=    Read    delay=10s

log setup
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh start
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on

cu setup
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    ulimit -c unlimited
    Write    startcu
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    STARTING GNB CONFIGURATION

du setup
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    ulimit -c unlimited
    Write    startdu
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    CELL[1] is UP
    Should Contain    ${output}=    CELL[2] is UP
    Should Contain    ${output}=    TTI received at APP

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
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh all
    ${output}=    Read    delay=200s
    Should Contain    ${output}=    all done

xfe close
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    pkill -9 xfe

upf close
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    pkill -9 upf

smf close
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -9 smf

amf close
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    pkill -9 amf

cu close
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    pkill -9 gnb_cu
    ${output}=    Read    delay=10s

du close
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    pkill -9 gnb_du
    ${output}=    Read    delay=10s

ue close
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    pkill -9 uesim
    ${output}=    Read    delay=10s
