*** Settings ***
Documentation
...  Keyword part of main case script

Resource       ${CURDIR}${/}variables.robot
Resource       ${config_path}
Resource       ${CURDIR}${/}config_modify.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_E500.robot


*** Keywords ***
case cell Setup
    [Arguments]
    EM500 Stop
    E500 du close
    E500 cu close
    E500 amf close
    E500 smf close
    E500 upf close
    E500 xfe close
    E500 clean log
    E5000 xfe setup
    E500 upf setup
    E500 smf setup
    E500 amf setup
    E500 log setup
    E500 cu setup
    E500 du setup
    Sleep      3s
case cell delete
    EM500 Stop
    E500 du close
    E500 phy close
    E500 cu close
    E500 amf close
    E500 smf close
    E500 upf close
    E500 xfe close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write   pkill -9 sshpass
    SSHLibrary.close all connections
loop attach and detach
    [Arguments]             ${loop}
    ${loop_log_path}   Set Variable   ${TESTSUITE_LOG_DIR}${/}${loop}
    OperatingSystem.Create Directory             ${loop_log_path}
    E500 log setup
    E500 Send Script
    E500 stop logging

    run keyword and continue on failure  case cell delete
    E500 download log to folder  ${loop_log_path}
