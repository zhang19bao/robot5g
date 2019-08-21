*** Settings ***
Documentation     cit to do gNB SW upgrade
Suite Setup       Testline Setup    # testline setup
Suite Teardown    Testline Close    # testline close
Test Teardown     Test Teardown
Library           SSHLibrary

*** Variables ***
${HOST}           192.168.10.56
${USERNAME}       root
${PASSWORD}       123456
${cu_console_log}    /root/radisys-new/radisys-cu-1.6-E500/bin/cu.log
${du_console_log}    /root/radisys-new/radisys-du-1.6-E500/bin/du.log
${new_cu_sw}      gnb_cu_tmp    #target cu sw bin
${new_du_sw}      gnb_du_tmp    #target du sw bin
${new_ue_sw}      uesim_tmp    #target uesim sw bin
${old_cu_sw}      gnb_cu_screen    #current cu sw bin
${old_du_sw}      gnb_du_619    #current du sw bin
${old_ue_sw}      uesim_version    #current uesim sw bin

*** Test Cases ***
do sw replacment
    sw replacment

update launch command
    change alias

check cell status
    log setup
    cu setup
    du setup
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    startue
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    MT Task Handler
    Write Bare    z
    ${output}=    Read    delay=30s
    Should Contain    ${output}=    Send RRC Reconfiguration Complete
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uecssh
    Write    ping 12.12.12.13 -c 10
    ${output}=    Read    delay=12s
    Should Contain    ${output}=    64 bytes from 12.12.12.13

*** Keywords ***
Testline Setup
    #xfe setup
    #upf setup
    smf setup
    amf setup

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
    Write    ulimit -c unlimited
    Write    startdu > ${du_console_log}
    ${output}=    Read    delay=30s
    #Should Contain    ${output}=    Num Ue Per TTI state

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

sw replacment
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Put File    C:\\Users\\Ying Cong\\Documents\\Work\\Log\\0-SW Build\\radisys-1.6-e500-sc\\radisys-cu-1.6-E500\\bin\\${new_cu_sw}    /root/gNB/tmp
    Put File    C:\\Users\\Ying Cong\\Documents\\Work\\Log\\0-SW Build\\radisys-1.6-e500-sc\\radisys-du-1.6-E500\\bin\\${new_du_sw}    /root/gNB/tmp
    Put File    C:\\Users\\Ying Cong\\Documents\\Work\\Log\\0-SW Build\\radisys-1.6-e500-sc\\uesim-1.6-E500\\${new_ue_sw}    /root/gNB/tmp
    Write    cd /root/gNB/tmp
    Write    sshpass -p 123456 scp -r ${new_cu_sw} root@192.169.4.20:/root/radisys-new/radisys-cu-1.6-E500/bin
    Write    sshpass -p 123456 scp -r ${new_du_sw} root@192.169.4.30:/root/radisys-new/radisys-du-1.6-E500/bin
    Write    rm -rf gnb*

change alias
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    sed -i 's/${old_cu_sw}/${new_cu_sw}/g' ./.bashrc
    Write    source /root/.bashrc
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    sed -i 's/${old_du_sw}/${new_du_sw}/g' ./.bashrc
    Write    source /root/.bashrc
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    uessh
    Write    sed -i 's/${old_ue_sw}/${new_ue_sw}/g' ./.bashrc
    Write    source /root/.bashrc

Test Teardown
    Run Keyword If Test Failed    rollback alias

rollback alias
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    cussh
    Write    sed -i 's/${new_cu_sw}/${old_cu_sw}/g' ./.bashrc
    Write    source /root/.bashrc
    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write    dussh
    Write    sed -i 's/${new_du_sw}/${old_du_sw}/g' ./.bashrc
    Write    source /root/.bashrc
