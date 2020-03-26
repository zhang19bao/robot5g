*** Settings ***
Documentation     random access case
Suite Setup       Testline Setup    # reboot server
Suite Teardown    Testline Close    # close all connection
Library           SSHLibrary
Library           AutoItLibrary

*** Variables ***
${HOST}           172.21.6.94
${USERNAME}       root
${PASSWORD}       123456
${amf}            E:\\5.Tools\\MobaXterm_Portable_v11.0\\MobaXterm_Personal_11.0.exe -bookmark "172.21.6.94_Testline\\172.21.6.94_amf"
${cu}             E:\\5.Tools\\MobaXterm_Portable_v11.0\\MobaXterm_Personal_11.0.exe -bookmark "172.21.6.94_Testline\\172.21.6.94_cu"
${du}             E:\\5.Tools\\MobaXterm_Portable_v11.0\\MobaXterm_Personal_11.0.exe -bookmark "172.21.6.94_Testline\\172.21.6.94_du"
${uesim}          E:\\5.Tools\\MobaXterm_Portable_v11.0\\MobaXterm_Personal_11.0.exe -bookmark "172.21.6.94_Testline\\172.21.6.94_uesim"

*** Test Cases ***
Case1: start amf
    [Documentation]    start ue attach
    ...    The keyword returns the standard output by default.
    AutoItLibrary.Run    ${amf}
    Sleep    5s    wait for startup

Case2: start cu
    AutoItLibrary.Run    ${cu}
    Sleep    12s    wait for startup

Case3: start du
    AutoItLibrary.Run    ${du}
    Sleep    15s    wait for start up

Case4: start uesim and attach
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./ue.sh > /root/log/ue.log
    Sleep    30s
    Write Bare    zzz
    Sleep    60s

Case5: Log collect
    Get File    /root/env/cu/bin/*.log
    Get File    /root/env/du/bin/*.log
    Get File    /root/log/*.log
    #    Get File    /root/log/*.pcap

*** Keywords ***
Testline Setup
    #    Open Connection    ${HOST}
    #    Login    ${USERNAME}    ${PASSWORD}
    #    Start Command    reboot
    #    Sleep    30s
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Execute Command    ./env/setup.sh start
    Write    cd /root/env/cu/bin
    Write    ./clear_log.sh    #log clean
    Write    cd /root/env/du/bin
    Write    ./clear_log.sh    #log clean
    Write    cd /root/log
    Write    ./clear_log.sh    #log clean

Testline Close
    Execute Command    killall -9 amf_226
    Execute Command    killall -9 gnb_cu_pdu_stub
    Execute Command    killall -9 gnb_du_txl_0130
    Execute Command    killall -9 uesim_test2
    Execute Command    ./env/setup.sh stop
    Write    cd /root/env/cu/bin
    Write    ./clear_log.sh    #log clean
    Write    cd /root/env/du/bin
    Write    ./clear_log.sh    #log clean
    Write    cd /root/log
    Write    ./clear_log.sh    #log clean
    close all connections
