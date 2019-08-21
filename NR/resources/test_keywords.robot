*** Settings ***
Documentation
...  for test case level common keywords
Resource                ${EXECDIR}${/}resources${/}suite_keywords.robot
Library                 ${EXECDIR}${/}libraries${/}e500_process.py

*** Keywords ***

NR E500 Test Setup
    Log  NR E500 Test Setup
    NR Test Setup
    @{TMAProcessBack}  create list
    Set Test Variable  ${TMAProcessBack}
    NR E500 Connections Setup
NR E500 Test Teardown
    Log  NR E500 Test Teardown
    NR E500 Connections Teardown
    NR Test Teardown
NR Test Setup
    Log  NR Test Setup
    @{testProcessBack}  create list
    Set Test Variable  ${TC_OUTPUT_DIR_ROOT}  ${OUTPUT_DIR}${/}${StartTimeString}${/}${TEST_NAME}${/}
    Set Test Variable  ${TC_OUTPUT_DIR}       ${OUTPUT_DIR}${/}${StartTimeString}${/}${TEST_NAME}${/}
    Create Directory  ${TC_OUTPUT_DIR}
    Log To Console  \n************Log Store Path:${TC_OUTPUT_DIR}************\n
NR Test Teardown
    [Arguments]  ${timeout}=1200s
    Run keyword If Test Passed  Set Test Variable  ${Test_Case_Execute_Result}  PASS
    Run keyword If Test Failed  Set Test Variable  ${Test_Case_Execute_Result}  FAIL
    ${result1}  Split String From Right  ${TC_OUTPUT_DIR_ROOT}  separator=${/}  max_split=1
    ${result2}  Split String From Right  @{result1}[0]  separator=${/}  max_split=1
    ${result}  Set Variable If  "@{result1}[-1]" == ""   ${result2}  ${result1}
    ${zipPath}  Set Variable  ${result}[0]${/}${Test_Case_Execute_Result}_${result}[1].zip
    ${compressionCmd}  set variable    cd ${result}[0] && zip -r ${zipPath} ${result}[1] && rm -rf ${result}[1]
    ${compression}  Start Process  ${compressionCmd}  shell=True
    Wait For Process  handle=${compression}  timeout=${timeout}  on_timeout=terminate
    ${DOCUMENTATION}  Set Variable  \n\nTest Logs:[file:///${zipPath}|${Test_Case_Execute_Result}_${result}[1].zip]
    Set Test Documentation  ${DOCUMENTATION}
NR E500 Connections Setup
   [Arguments]  ${times}=2  ${timeout}=150
    stopTMA  env=${env}
    sleep   5s
    NR E500 Start TMA Application
    :For  ${index}  IN RANGE  ${times}
    \   ${e500_back_process}  NR E500 Start Background Process  logPath=${TC_OUTPUT_DIR}
    \   Append To List  ${TMAProcessBack}  ${e500_back_process}
    \   ${readyResult}  ${versionInfo}  checkE500Ready  logPath=${TC_OUTPUT_DIR}  fileNum=${4}  timeout=${timeout}
    \   run keyword if  "${readyResult}"=="False"  Terminate Process  ${e500_back_process}  False
    \   run keyword if  "${readyResult}"=="False"  Remove Values From List  ${TMAProcessBack}  ${e500_back_process}
    \   exit for loop if  "${readyResult}"=="True"
    \   sleep    10s
    run keyword if  "${readyResult}"=="False"  fail  E500 Start Failed
NR E500 Start Background Process
    [Arguments]  ${logPath}=${TC_OUTPUT_DIR}
    ${path}  ${file}  getE500ProcessFilePath
    log to console  Start E500 Background Process
    ${e500_back_process}              Start Process  python  ${file}  ${ENV_CONFIG_PATH}  ${logPath}  cwd=${path}  shell=True  ##stdout=stdout.txt  stderr=stderr.txt
    sleep    30s
    [Return]  ${e500_back_process}
NR E500 Start TMA Application
    log to console  Start TMA.exe
    ${cmd}  set variable  "${env.tmaExePath} ${env.tmaAddParam}"
    ${hour}  ${min}  Get Time  hour and min  UTC + 8hour 61s
    ${schtasks_cmd}    set variable  SCHTASKS.EXE /create /sc once /tn onceTMATask /tr ${cmd} /st ${hour}:${min} /f
    Start Process   ${schtasks_cmd}  shell=True
    :For  ${index}  IN RANGE  ${8}
    \   sleep    10s
    \   ${result}  ${pid}  checkTMA  env=${env}
    \   exit for loop if   "${result}"=="True"
    run keyword if   "${result}"=="False"  fail  "Start TMA Failed"
NR E500 Connections Teardown
    log to console   teardown
    ${result}  get variable value  ${TMAProcessBack}  None
    return from keyword if  "${result}" == "None"
    :for  ${process}  IN  @{TMAProcessBack}
    \   log to console  ${process}
    \   Terminate Process  ${process}  False
NR E500 Start Telnet TMA
    [Arguments]  ${host}  ${port}=23  ${alias}=None  ${timeout}=10  ${prompt}=\r
    ${telnetIndex}   Telnet.Open Connection  host=${host}  port=${port}  timeout=${timeout}  prompt=${prompt}
    ${cmd}  set variable  \#$$PORT 192.168.10.70 5001 5002 5003\r\n
    Telnet.Write Bare  ${cmd}
    ${output}  Telnet.Read Until Prompt
    Telnet.Close Connection

NR E500 Telnet TMA Script Execute
    [Arguments]  ${EC_OR_AC}=None  ${filePath}=None  ${passRegex}=^c:.*ok.*  ${timeout}=10  ${prompt}=\r  ${ignoreError}=True
    ${context}  OperatingSystem.get file  ${filePath}
    ${cmdList}  Split String  ${context}  separator=\n
    ${finalResult}  set variable  True
    : For  ${cmd}  IN  @{cmdList}
    \   ${tmp}  Replace String  ${cmd}  search_for="  replace_with='  count=-1
    \   continue for loop if  "${tmp}"=="${EMPTY}"
    \   log to console  EC CMD: ${cmd}
    \   ${execResult}  ${result}  Run Keyword And Ignore Error  NR E500 Telnet TMA Command Execute  ${EC_OR_AC}  ${cmd}  passRegex=${passRegex}  timeout=${timeout}  prompt=${prompt}
    \   run keyword if  "${ignoreError}"=="False"  AND  "${execResult}"=="FAIL"  fail  Error Occurs during Script Execution
    \   run keyword if  "${execResult}"=="PASS"   log to console  EXECUTE:@{result}[0]\r\n@{result}[1]
NR E500 Telnet TMA Command Execute
    [Arguments]  ${EC_OR_AC}=None  ${cmd}=None  ${passRegex}=^c\:.*ok.*  ${timeout}=10  ${prompt}=\r
    ${tmp}  Replace String  ${cmd}  search_for="  replace_with='  count=-1
    return from keyword if  "${tmp}"=="${EMPTY}"
    ${host}  Set Variable  ${env.tmaLocalIp}
    ${port}  Set Variable If  "${EC_OR_AC}"=="EC"  ${env.tmaEcPort}
    ...                       "${EC_OR_AC}"=="AC"  ${env.tmaAcPort}
    ...                        None
    run keyword if  "${port}"=="None"  fail  "Only Support EC OR AC Mode"
    ${telnetIndex}   Telnet.Open Connection  host=${host}  port=${port}  timeout=${timeout}  prompt=${prompt}
    Telnet.Write Bare  ${cmd}\r\n
#    sleep  0.5s
    ${output}  Telnet.Read Until Prompt
    ${result}  run keyword and return status  Should Match Regexp  ${output.lower()}  ${passRegex}
    ${output1}  Telnet.Read
    ${output1}  Replace String  ${output1}  \t  ${EMPTY}
    Telnet.Close Connection
    [Return]   ${result}  ${output}${output1}



