*** Settings ***
Library         String
Library         DateTime
Library         SSHLibrary
Library         Process
Library         OperatingSystem
Library         Collections
Library         Dialogs
#Resource      .${/}testline_fixed_parameters.robot


*** Variables ***

*** Keywords ***
Set Common Suite Variables
    [Documentation]  Set common suite variables in DV case tempalte
	...              \n Usage example: DV Set Common Suite Variables
	...              \n Author: zhangbr@certusnet.com.cn
	#${HOST}           Get Localhost Ip   ens3 #172.21.6.102
    ${HOST}           set global variable   ${HOST}
    ${to_cu_path}  fetch from left  ${startcu}  &&
    ${to_du_path}  fetch from left  ${startdu}  &&
    ${cu_path}  fetch from right  ${to_du_path}  ${SPACE}
    ${du_path}  fetch from right  ${to_du_path}  ${SPACE}
    set global variable  ${to_cu_path}
    set global variable  ${to_du_path}
    set global variable  ${cu_path}
    set global variable  ${du_path}


Create Ssh Connection
    [Documentation]     open ssh connection and login, need colse later
	...                 \n${ip}         (String)-host ip
	...                 \n${user}         (String)-user name
	...                 \n${password}     (String)-password
	...                 \n return:(String)-the index of this connection which can be used later to switch back to it
	...                 \n use Switch Connection
    ...                 \n e.g. ${ssh_index}  Create Ssh Connection    ${ip}    ${user}    ${password}
    [Arguments]    ${ip}    ${user}    ${password}
    ${ssh_index}            SSHLibrary.Open Connection         ${ip}      timeout=30
                            SSHLibrary.Login    ${user}    ${password}
    [Return]                ${ssh_index}

Ssh Close Connection
    [Documentation]     close ssh connection
	...                 \n${ssh_index}  (String)-Switch Connection   {ssh_index}
	...                 \n e.g. Ssh Close Connection              ${ssh_index}
	...              \n Author: zhangbr@certusnet.com.cn
    [Arguments]    ${ssh_index}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Close Connection


Ssh Execute Cmd
    [Documentation]     execute ssh cmd, need close
	...                 \n${ssh_index}   (String)-Switch Connection   {ssh_index}
	...                 \n${command}=ls  (String)-command
	...                 \n return:(String)-Command Output
    ...                 \n e.g. excute ssh cmd
    [Arguments]    ${ssh_index}         ${command}=ls
    SSHLibrary.Switch Connection        ${ssh_index}
    ${stdout}  SSHLibrary.Execute Command   ${command}   return_stdout=${True}
    [Return]            ${stdout}


Ssh Execute Cmd And Check Result
    [Documentation]     excute ssh cmd, and check excute result whether contains pass regexp or fail regexp
	...                 \n${host}         (String)-host ip
	...                 \n${user}         (String)-user name
	...                 \n${password}     (String)-password
	...                 \n${command}=ls   (String)-command
	...                 \n${fail_regexp}=${EMPTY}     (String)-no except regx string in normal result
	...                 \n${pass_regexp}=${EMPTY}     (String)-except regx string with normal result
    ...                 \n${if_fail_with_rc}=${True}  (Boolean)-it True will check retrun code(rc) first, if False it will check ${fail_regexp}
    ...                 \n return:(String)-Standard output and Standard error information
	...                 \n e.g. Ssh Execute Cmd And Check Result       ${ip}   ute    ute   rm /opt/iphy/latest.lua    ${EMPTY}   ${EMPTY}
    ...                 \n Author: zhangbr@certusnet.com.cn
    [Arguments]           ${ip}      ${user}      ${password}     ${command}    ${fail_regexp}=${EMPTY}     ${pass_regexp}=${EMPTY}    ${if_fail_with_rc}=${True}

    ${ssh_index}          Create Ssh Connection     ${ip}    ${user}     ${password}
    #use return code is easy way to judge if cmd success so make change to get all output(stdout,stderr,rc) for ssh execute command. When failed stdout is none
    ${stdout}   ${stderr}   ${rc}           SSHLibrary.Execute Command          ${command}            ${True}      ${True}     ${True}
                                            Ssh Close Connection  ${ssh_index}
    Run keyword if        ${rc} != 0 and ${if_fail_with_rc} == ${True}
    ...                   Fail                                ${stderr}

    Run keyword if        '${fail_regexp}' != '${EMPTY}'
    ...                   Should Not Contain                  ${stdout}         ${fail_regexp}        ${stderr}
    Run keyword if        '${pass_regexp}' != '${EMPTY}'
    ...                   Should Contain                      ${stdout}         ${pass_regexp}        ${stderr}
    [Return]              ${stdout}${stderr}

Get Localhost Ip
    [Documentation]
    ...                     get localhost ip
    ...                     \n return:(String)-like 10.68.250.43
	...                     \n e.g. ${ip}      Get Localhost Ip  ens3
	...                     \n Author: zhangbr@certusnet.com.cn
    [Arguments]             ${eth_index}
    #change from sudo ifconfig to ip cmd as debian chagne to be Debian 9.5 ifconfig format change
    ${ssh_cmd_send}         Set variable    ip -f inet addr show ${eth_index} | awk '/inet / {print $2}' | awk -F"/" '{print $1}'

    ${output}               Ssh Execute Cmd And Check Result
    ...                     127.0.0.1
    ...                     root
    ...                     123456
    ...                     ${ssh_cmd_send}

    ${match}    ${host}     Should Match Regexp     ${output}   (\\d+\\.\\d+\\.\\d+\\.\\d+)      Fail: no address for ${eth_index} found, please check the ip

    [Return]    ${host}

Get Timestamp String
    [Documentation]          get current timestamp information
    ...                      \n return:(String)-current timestamp in YYYYMMDD_HHMMSS type
	...                      \n e.g. ${date_time}      Get Timestamp String

    ${date_time}             Builtin.Get Time   #2019-11-21 19:41:08
    ${date_time}             Replace String            ${date_time}    -          ${EMPTY}   6
    ${date_time}             Replace String            ${date_time}    ${SPACE}   _          2
    ${date_time}             Replace String            ${date_time}    :          ${EMPTY}   3
    [Return]                 ${date_time}

NR Test Suite Common Setup
    ${start_time}=	Get Timestamp String
    Set Global Variable  ${log_file_name}  ${start_time}
    Set Global Variable  ${TESTSUITE_LOG_DIR}  ${OUTPUT_DIR}${/}${log_file_name}
    Log To Console         ******************************************************************************
    Log To Console         *****************************Test Log Directory:******************************
    Log To Console         ${TESTSUITE_LOG_DIR}
    Log To Console         ******************************************************************************
    Log To Console         ******************************************************************************
    ${path_not_exist}      Run Keyword And Return Status
    ...                    OperatingSystem.Directory Should Not Exist   ${TESTSUITE_LOG_DIR}
    Run Keyword If         ${path_not_exist}
    ...                    OperatingSystem.Create Directory             ${TESTSUITE_LOG_DIR}
    Set Common Suite Variables

NR Test Suite Teardown
    log to console   testsuite teardown

Write log to text
    [Documentation]   write log to specified file
    [Arguments]       ${log_name}  ${context}
    OperatingSystem.Append To File  ${TESTSUITE_LOG_DIR}${/}${log_name}  ${context}  encoding=CONSOLE

