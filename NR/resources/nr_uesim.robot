*** Settings ***
Documentation
Library        OperatingSystem
Library        SSHLibrary
Library        DateTime
Library        String

*** Variables ***
${HOST}           172.21.6.102
${USERNAME}       root
${PASSWORD}       123456
${cu_console_log}    /root/radisys-new/radisys-cu-1.6-E500/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.6-E500/bin/du.log
${upfssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.5
${coressh}  sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.10
${cussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.20
${dussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30
${uessh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30
${uecssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.40
${startxfe}   cd /opt/fesw/bin && ./startupmgrd.exe
${startupf}   cd /root/upf-1.6-e500 && ./upf
${startsmf}  cd /root/5gc-v1.6-e500-new&&./smf_0626
${startamf}  cd /root/5gc-v1.6-e500-new&&./amf_0702
${startcu}   cd /root/radisys-cu-1.6-E500/bin&&./gnb_cu_0708_um
${startdu}   cd /root/radisys-du-1.6-E500/bin&&./gnb_du_801 -f ../config/ssi_mem
${startue}   cd /root/uesim-1.6-E500&&./uesim

*** Keywords ***
Get Timestamp String
    [Documentation]          get current timestamp information
    ...                      \n return:(String)-current timestamp in YYYYMMDD_HHMMSS type
	...                      \n e.g. ${date_time}      Get Timestamp String

    ${date_time}             Builtin.Get Time
    ${date_time}             Replace String            ${date_time}    -          ${EMPTY}   6
    ${date_time}             Replace String            ${date_time}    ${SPACE}   _          2
    ${date_time}             Replace String            ${date_time}    :          ${EMPTY}   3
    [Return]                 ${date_time}

NR Test Suite Common Setup
    ${start_time}=	Get Timestamp String
    Set Global Variable  ${TEST_LOG_OUTPUT_DIR}  ${OUTPUT_DIR}${/}${start_time}
    Log To Console         ******************************************************************************
    Log To Console         *****************************Test Log Directory:******************************
    Log To Console         ${TEST_LOG_OUTPUT_DIR}
    Log To Console         ******************************************************************************
    Log To Console         ******************************************************************************
    ${path_not_exist}      Run Keyword And Return Status
    ...                    OperatingSystem.Directory Should Not Exist   ${TESTSUITE_LOG_DIR}
    Run Keyword If         ${path_not_exist}
    ...                    OperatingSystem.Create Directory             ${TESTSUITE_LOG_DIR}

Testline Setup
    Testline Close
    :FOR  ${index}  IN Range  ${3}
    \   ${stat}     run keyword and return status    xfe setup
    \   Exit For Loop If	 ${stat} == True
    \   xfe close
    upf setup
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
    ${output}=    Read    delay=10s
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
    ${output}=    Read    delay=20s
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
    Should Contain    ${output}=    Num Ue Per TTI stats
    log to console  du start completed

Testline Close
    ue close
    du close
    cu close
    #stop logging
    amf close
    smf close
    upf close
    xfe close
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

check UE attach
    [Arguments]    ${Ue_Num}=1
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uessh}
    Write    ${startue}
    ${output}=    Read    delay=10s
    Should Contain    ${output}=    MT Task Handler
    :For  ${index}  in range  ${Ue_Num}
    \  Write Bare    z
    \  ${output}=    Read    delay=15s
    \   sleep   10s
    \  Should Contain    ${output}=    UE IPv4 ADDR allocated
    \  Should Contain    ${output}=    RRC Reconfiguration Complete
    \  log to console   ue ${index} attach complete

check ping traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ${uecssh}
    Write    ping 12.12.12.13 -c 10
    ${output}=    Read    delay=12s
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
    Should Contain    ${output}=    iperf Done
    log to console  start UL UDP traffic successful