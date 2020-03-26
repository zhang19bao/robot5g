*** Settings ***
Documentation     multi ue dl and ul udp simultaneous with tti=1:8
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary
Library           Process

*** Variables ***
${UE_NUM}         8
${gNB HOST}       192.168.10.56
${core HOST}      192.168.10.56
${USERNAME}       root
${PASSWORD}       123456
${du_config_path}    /root/radisys-new/radisys-du-1.7-E500/config
${default_DL_tti}    1    #SCH_DL_UE_PER_TTI
${new_DL_tti}     1    #SCH_DL_UE_PER_TTI
${default_UL_tti}    1    #SCH_UL_UE_PER_TTI
${new_UL_tti}     8    #SCH_UL_UE_PER_TTI
${target_dl_tput}    1M
${target_ul_tput}    1M
${timer}          100    # iperf checking timer also need to update: delay=xxx

*** Test Cases ***
UE attach
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler
    Repeat Keyword    ${UE_NUM}    attach ue

check DL UDP traffic
    check DL UDP traffic

check UL UDP traffic
    check UL UDP traffic

check DL ping traffic
    check dl ping traffic

check UL ping traffic
    check ul ping traffic

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
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./auto_logs.sh start
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on

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

amf setup
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    startamf
    ${output}=    Read    delay=10s

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
    Write    cd ${du_config_path}
    Write    sed -i 's/SCH_DL_UE_PER_TTI = ${default_DL_tti}/SCH_DL_UE_PER_TTI = ${new_DL_tti}/g' ./cell_config_1.txt
    Write    sed -i 's/SCH_UL_UE_PER_TTI = ${default_UL_tti}/SCH_UL_UE_PER_TTI = ${new_UL_tti}/g' ./cell_config_1.txt
    Write    ulimit -c unlimited
    Write    startdu
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    CELL[1] is UP
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
    #Write    cussh
    Write    pkill -9 gnb_cu
    ${output}=    Read    delay=10s

du close
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    cd ${du_config_path}
    Write    sed -i 's/SCH_DL_UE_PER_TTI = ${new_DL_tti}/SCH_DL_UE_PER_TTI = ${default_DL_tti}/g' ./cell_config_1.txt
    Write    sed -i 's/SCH_UL_UE_PER_TTI = ${new_UL_tti}/SCH_UL_UE_PER_TTI = ${default_UL_tti}/g' ./cell_config_1.txt
    Write    pkill -9 gnb_du
    ${output}=    Read    delay=10s

ue close
    Open Connection    ${gNB HOST}
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
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ./iperf_dl_server.sh start
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./iperf_dl.sh ${target_dl_tput} ${timer}
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    iperf Done
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ./iperf_dl_server.sh stop

check UL UDP traffic
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./iperf_ul_server.sh start
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ./iperf_ul.sh ${target_ul_tput} ${timer}
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    iperf Done
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./iperf_ul_server.sh stop

check ul ping traffic
    Open Connection    ${gNB HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ./ping_ul.sh
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    100 packets transmitted, 100 received, 0% packet loss

check dl ping traffic
    Open Connection    ${core HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    ./ping_dl.sh
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    100 packets transmitted, 100 received, 0% packet loss
