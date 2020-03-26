*** Settings ***
Documentation     check ue inactivity in loop
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary

*** Variables ***
${loop_time}      2
${HOST}           192.168.10.56
${USERNAME}       root
${PASSWORD}       123456
${cu_console_log}    /root/radisys-new/rrc_inactive/cu/bin/cu.log
${du_console_log}    /root/radisys-new/rrc_inactive/du/bin/du.log
${default_tti}    10000000    #ms
${new_tti}        1000000    #ms
${du_config_path}    /root/radisys-new/rrc_inactive/du/config
${inactivity_timer}    2000    #s

*** Test Cases ***
start ue
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler

do UE attach
    UE attach

do UE inactivity in loop
    check ue inactivity in loop

do ping traffic
    check ping traffic

*** Keywords ***
Testline Setup
    #xfe setup
    #upf setup
    smf setup
    amf setup
    log setup
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
    Write    startcu > ${cu_console_log}
    ${output}=    Read    delay=30s
    #Should Contain    ${output}=    STARTING GNB CONFIGURATION

du setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    #Write    cd ${du_config_path}
    #Write    sed -i 's/L2_TTI_INTERVAL_LEN = ${default_tti}/L2_TTI_INTERVAL_LEN = ${new_tti}/g' ./du_config.txt
    Write    ulimit -c unlimited
    Write    startdu > ${du_console_log}
    ${output}=    Read    delay=30s
    #Should Contain    ${output}=    Num Ue Per TTI stats

Testline Close
    ue close
    du close
    cu close
    stop logging
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
    #Write    cd ${du_config_path}
    #Write    sed -i 's/L2_TTI_INTERVAL_LEN = ${new_tti}/L2_TTI_INTERVAL_LEN = ${default_tti}/g' ./du_config.txt
    Write    pkill -9 gnb_du
    ${output}=    Read    delay=10s

ue close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    pkill -9 uesim
    ${output}=    Read    delay=10s

UE attach
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    NAS PDU received
    Should Contain    ${output}=    UE IPv4 ADDR allocated

UE inactivity
    Write Bare    b
    ${output}=    Read    delay=${inactivity_timer}
    Should Contain    ${output}=    RRC Release Msg Rcvd
    Should Contain    ${output}=    isUeInactivity

UE resume
    Write Bare    e
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    RRC_RESUME
    Should Contain    ${output}=    RRC resume Complete

check ue inactivity in loop
    : FOR    ${time}    IN RANGE    ${loop_time}
    \    ${time}    Evaluate    ${time}+1
    \    UE inactivity
    \    UE resume

check ping traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13
