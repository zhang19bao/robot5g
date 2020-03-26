*** Settings ***
Documentation
...  Keyword part of main case script

Resource       ${CURDIR}${/}variables.robot
Resource       ${config_path}
Resource       ${CURDIR}${/}config_modify.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_E500.robot


*** Keywords ***

case reset rru
    :FOR  ${index}  IN RANGE  ${3}
    \   ${stat}     run keyword and return status    ButtonEightOnOff
    \   Exit For Loop If	 ${stat} == True
    \   E500 xfe close

_case_E500_attach
    E500 log setup  ue_attach
    sleep  3s
    run keyword and continue on failure  E500 Send Script
    sleep  3s
    E500 log stop

_case_E500_trafic
    [Arguments]    ${log_path}
    E500 Shernick Start
#    Dialogs.Pause Execution
    run keyword and continue on failure  case sheck e500 status    ${log_path}
    sleep  10
    E500 Shernick Stop

loop repeadedly attach
    [Arguments]             ${loop}
    ${loop_log_path}   Set Variable   ${TESTSUITE_LOG_DIR}${/}${loop}
    OperatingSystem.Create Directory             ${loop_log_path}
    ${status1}  run keyword and return status  E500 Testline Setup
    run keyword if  ${status1} == True  log to console  setup cell success
    ...    ELSE    log to console  setup cell fail
    ${status2}  run keyword and return status  _case_E500_attach
    run keyword if  ${status2} == True  log to console  attach success
    ...    ELSE    log to console  ue attach fail
    ${status3}  run keyword and return status  _case_E500_trafic  ${loop}
    run keyword if  ${status3} == True  log to console  start trafic
    ...    ELSE    log to console  start trafic fail
    log to console  Test Case loop${loop} Execution finish
    run keyword and continue on failure  E500 Testline Close  1
    E500 get console log
    E500 download log to folder  ${loop_log_path}
    OperatingSystem.run   cp ${TESTSUITE_LOG_DIR}${/}E500*.log ${TESTSUITE_LOG_DIR}${/}${loop}
    Should Be True      ${status1} == True and ${status2} == True and ${status3} == True

case sheck e500 status
    [Arguments]    ${log_path}
    Telnet.Open Connection              ${E500_host}           port=5003      timeout=30
    Telnet.Write Bare                   FORW MTE CLEARSTATS\n\r
    Sleep                               5s
    Telnet.Write Bare                   FORW MTE GETSTATS [0] [0] [0]\n\r
    Sleep                               5s
    Telnet.Write Bare                   FORW MTE GETSTATS [0] [0] [0]\n\r
    Sleep                               5s
    Telnet.Write Bare                   FORW MTE GETSTATS [0] [0] [0]\n\r
    Sleep                               5s
    ${output}=   Telnet.Read
    Write log to text   ${log_path}${/}E500_ststus.log   ${output}
    Sleep                               10s
    Telnet.Close Connection

case Testline Close
    EM500 Stop
    E500 phy close
    E500 du close
    E500 cu close
    E500 amf close
    E500 smf close
    E500 upf close
    E500 xfe close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write   pkill -9 sshpass
    sleep  1s
    SSHLibrary.Write   pkill -2 get_nr_log_E500
    SSHLibrary.Close all connections