*** Settings ***
Documentation
...  Keyword part of main case script

Resource       ${CURDIR}${/}variables.robot
Resource       ${CURDIR}${/}config_modify.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_uesim.robot
Resource       ${config_path}

*** Keywords ***

case cell Setup
    [Arguments]
    ue close
    du close
    cu close
    amf close
    smf close
    upf close
    xfe close
    clean log
    xfe setup
    upf setup
    smf setup
    amf setup
    log setup
    cu setup
    du setup
case cell delete
    du close
    cu close
    amf close
    smf close
    upf close
    xfe close

    Open Connection    ${HOST}
    Login    ${USERNAME}    ${PASSWORD}
    Write   pkill -9 sshpass
    close all connections

loop cellsetup and delete
    [Arguments]             ${loop}
    ${loop_log_path}   Set Variable   ${TESTSUITE_LOG_DIR}${/}${loop}
    OperatingSystem.Create Directory             ${loop_log_path}
    run keyword and continue on failure  case cell Setup
    stop logging
    run keyword and continue on failure  case cell delete
    download log to folder    ${loop_log_path}