*** Settings ***
Documentation     cit to check ue attach/ping/dl udp/ul udp
Suite Setup       Testline Setup    # testline launch
Suite Teardown    Testline Close    # testline close
Library           SSHLibrary

*** Variables ***
${HOST}           192.168.10.57
${USERNAME}       root
${PASSWORD}       123456
${HOST_10}        192.169.4.10
${cu_console_log}    /root/radisys-new/radisys-cu-1.6-E500/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.6-E500/bin/du.log
${UL_BW_DEFAULT}    10
${DL_BW_DEFAULT}    10
${DL_EARFCN_DEFAULT}    503358
${DL_ARFCN_POINT_A_DEFAULT}    503358
${DL_FREQ_POINT_A_DEFAULT}    2516790
${DL_CENTER_FREQ_DEFAULT}    2565930
${UL_EARFCN_DEFAULT}    503358
${UL_ARFCN_POINT_A_DEFAULT}    503358
${UL_FREQ_POINT_A_DEFAULT}    2516790
${UL_CENTER_FREQ_DEFAULT}    2565930
${UL_BW}          9
${DL_BW}          9
${DL_EARFCN}      664188
${DL_ARFCN_POINT_A}    664188
${DL_FREQ_POINT_A}    3320940
${DL_CENTER_FREQ}    3360000
${UL_EARFCN}      664188
${UL_ARFCN_POINT_A}    664188
${UL_FREQ_POINT_A}    3320940
${UL_CENTER_FREQ}    3360000

*** Test Cases ***
Change du config_1_100M_N41_Left
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    ulimit -c unlimited
    Write    cd /root/radisys-new/radisys-du-1.6-E500/config
    Write    sed -i '/5GNR_UL_CHN_BW/c 5GNR_UL_CHN_BW = ${UL_BW}' ./cell_config_1.txt
    Write    sed -i '/5GNR_DL_CHN_BW/c 5GNR_DL_CHN_BW = ${DL_BW}' ./cell_config_1.txt
    Write    sed -i '/NR_DL_EARFCN/c NR_DL_EARFCN = ${DL_EARFCN}' ./cell_config_1.txt
    Write    sed -i '/NR_DL_ABS_ARFCN_POINT_A/c NR_DL_ABS_ARFCN_POINT_A = ${DL_ARFCN_POINT_A} ' ./cell_config_1.txt
    Write    sed -i '/NR_DL_ABS_FREQ_POINT_A/c NR_DL_ABS_FREQ_POINT_A = ${DL_FREQ_POINT_A} ' ./cell_config_1.txt
    Write    sed -i '/NR_DL_CENTER_FREQ/c NR_DL_CENTER_FREQ = ${DL_CENTER_FREQ} ' ./cell_config_1.txt
    Write    sed -i '/NR_UL_EARFCN/c NR_UL_EARFCN = ${UL_EARFCN} ' ./cell_config_1.txt
    Write    sed -i '/NR_UL_ABS_ARFCN_POINT_A/c NR_UL_ABS_ARFCN_POINT_A = ${UL_ARFCN_POINT_A}' ./cell_config_1.txt
    Write    sed -i '/NR_UL_ABS_FREQ_POINT_A/c NR_UL_ABS_FREQ_POINT_A = ${UL_FREQ_POINT_A}' ./cell_config_1.txt
    Write    sed -i '/NR_UL_CENTER_FREQ/c NR_UL_CENTER_FREQ = ${UL_CENTER_FREQ} ' ./cell_config_1.txt
    Write    grep -i 5GNR_UL_CHN_BW cell_config_1.txt
    Write    grep -i 5GNR_DL_CHN_BW cell_config_1.txt
    Write    grep -i NR_DL_EARFCN cell_config_1.txt
    Write    grep -i NR_DL_ABS_ARFCN_POINT_A cell_config_1.txt
    Write    grep -i NR_DL_ABS_FREQ_POINT_A cell_config_1.txt
    Write    grep -i NR_DL_CENTER_FREQ cell_config_1.txt
    Write    grep -i NR_UL_EARFCN cell_config_1.txt
    Write    grep -i NR_UL_ABS_ARFCN_POINT_A cell_config_1.txt
    Write    grep -i NR_UL_ABS_FREQ_POINT_A cell_config_1.txt
    Write    grep -i NR_UL_CENTER_FREQ cell_config_1.txt
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    NR_UL_CENTER_FREQ = ${UL_CENTER_FREQ}

Testline Setup1
    smf setup
    amf setup
    cu setup
    du setup

check UE attach
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    Send RRC Reconfiguration Complete

check ping traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13

check DL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -s -B 10.10.5.1 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -u -c 10.10.5.1 -B 12.12.12.13 -p 5001 -b 2M -l 1024 -t 100
    ${output}=    Read    delay=120s
    Should Contain    ${output}=    iperf Done

check UL UDP traffic
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    iperf3 -s -B 12.12.12.13 -p 5001
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    iperf3 -u -c 12.12.12.13 -B 10.10.5.1 -p 5001 -b 2M -l 1024 -t 100
    ${output}=    Read    delay=200s
    Should Contain    ${output}=    iperf Done

Change du config_1_100M_N41_Default
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    ulimit -c unlimited
    Write    cd /root/radisys-new/radisys-du-1.6-E500/config
    Write    sed -i '/5GNR_UL_CHN_BW/c 5GNR_UL_CHN_BW = ${UL_BW_DEFAULT}' ./cell_config_1.txt
    Write    sed -i '/5GNR_DL_CHN_BW/c 5GNR_DL_CHN_BW = ${DL_BW_DEFAULT}' ./cell_config_1.txt
    Write    sed -i '/NR_DL_EARFCN/c NR_DL_EARFCN = ${DL_EARFCN_DEFAULT}' ./cell_config_1.txt
    Write    sed -i '/NR_DL_ABS_ARFCN_POINT_A/c NR_DL_ABS_ARFCN_POINT_A = ${DL_ARFCN_POINT_A_DEFAULT} ' ./cell_config_1.txt
    Write    sed -i '/NR_DL_ABS_FREQ_POINT_A/c NR_DL_ABS_FREQ_POINT_A = ${DL_FREQ_POINT_A_DEFAULT} ' ./cell_config_1.txt
    Write    sed -i '/NR_DL_CENTER_FREQ/c NR_DL_CENTER_FREQ = ${DL_CENTER_FREQ_DEFAULT} ' ./cell_config_1.txt
    Write    sed -i '/NR_UL_EARFCN/c NR_UL_EARFCN = ${UL_EARFCN} ' ./cell_config_1.txt
    Write    sed -i '/NR_UL_ABS_ARFCN_POINT_A/c NR_UL_ABS_ARFCN_POINT_A = ${UL_ARFCN_POINT_A_DEFAULT}' ./cell_config_1.txt
    Write    sed -i '/NR_UL_ABS_FREQ_POINT_A/c NR_UL_ABS_FREQ_POINT_A = ${UL_FREQ_POINT_A_DEFAULT}' ./cell_config_1.txt
    Write    sed -i '/NR_UL_CENTER_FREQ/c NR_UL_CENTER_FREQ = ${UL_CENTER_FREQ_DEFAULT} ' ./cell_config_1.txt
    Write    grep -i 5GNR_UL_CHN_BW cell_config_1.txt
    Write    grep -i 5GNR_DL_CHN_BW cell_config_1.txt
    Write    grep -i NR_DL_EARFCN cell_config_1.txt
    Write    grep -i NR_DL_ABS_ARFCN_POINT_A cell_config_1.txt
    Write    grep -i NR_DL_ABS_FREQ_POINT_A cell_config_1.txt
    Write    grep -i NR_DL_CENTER_FREQ cell_config_1.txt
    Write    grep -i NR_UL_EARFCN cell_config_1.txt
    Write    grep -i NR_UL_ABS_ARFCN_POINT_A cell_config_1.txt
    Write    grep -i NR_UL_ABS_FREQ_POINT_A cell_config_1.txt
    Write    grep -i NR_UL_CENTER_FREQ cell_config_1.txt
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    NR_UL_CENTER_FREQ = ${UL_CENTER_FREQ_DEFAULT}

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
    ${output}=    Read    delay=40s
    Should Contain    ${output}=    tcpdump: listening on

cu setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    ulimit -c unlimited
    Write    startcu > ${cu_console_log}
    ${output}=    Read    delay=40s
    #Should Contain    ${output}=    STARTING GNB CONFIGURATION

du setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    ulimit -c unlimited
    Write    startdu > ${du_console_log}
    ${output}=    Read    delay=30s
    #Should Contain    ${output}=    Received GNB-DU CONFIG UPDATE ACK

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
    Write    killall -9 xfe

upf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    upfssh
    Write    killall -9 upf

smf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    killall -9 smf

amf close
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    killall -9 amf

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
