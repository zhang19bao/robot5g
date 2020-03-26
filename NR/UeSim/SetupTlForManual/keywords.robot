*** Settings ***
Documentation
...  Keyword part of main case script

Resource       ${EXECDIR}${/}NR${/}resources${/}nr_uesim.robot
Resource       ${CURDIR}${/}variables.robot
Resource       ${CURDIR}${/}config_modify.robot


*** Keywords ***
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
#    Write    ulimit -c unlimited
    Write    ${startcu}
    ${output}=	Read	delay=20s
    Write log to text   cu.log   ${output}
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
Write log to text
    [Documentation]   write log to specified file
    [Arguments]       ${log_name}  ${context}
    OperatingSystem.Append To File  ${TESTSUITE_LOG_DIR}${/}${log_name}  ${context}  encoding=UTF-8