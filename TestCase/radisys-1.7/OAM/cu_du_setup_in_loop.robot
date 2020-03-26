*** Settings ***
Documentation     oam to check cell setup in loop
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary

*** Variables ***
${HOST}           192.168.10.56
${USERNAME}       root
${PASSWORD}       123456
${cu_console_log}    /root/radisys-new/radisys-cu-1.7/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.7/bin/du.log
${ue_console_log}    /root/radisys-new/uesim-1.7/ue.log
${repeat_times}    5

*** Test Cases ***
launch cu, du and ue
    Repeat Keyword    ${repeat_times}    setup cu/du/ue

*** Keywords ***
Testline Setup
    #xfe setup
    #upf setup
    #smf setup
    #amf setup
    log setup
    #cu setup
    #du setup

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

setup cu/du/ue
    smf setup
    amf setup
    cu setup
    du setup
    ue setup
    ue close
    du close
    cu close
    amf close
    smf close

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
    Should Contain    ${output}=    TTI received at APP

ue setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    UE IPv4 ADDR allocated
    Should Contain    ${output}=    RRC Reconfiguration Complete

ue ping
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13

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
    Write    pkill -9 gnb_du
    ${output}=    Read    delay=10s

ue close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    pkill -9 uesim
    ${output}=    Read    delay=10s
