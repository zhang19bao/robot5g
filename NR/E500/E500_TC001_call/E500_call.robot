*** Settings ***
Documentation
...  Case name:E500 attach first call
...  The purpose for this TC is to:
    ...  a temple for E500 Automation
...  "Author: zhangbr@certusnet.com.cn"
...  History:
    ...   2019.11.22 First Template
    ...   2020.1.7 First call successed
...  *How To execute test case:*
...  cd /home/robot5g
...  robot -t E500_call --variable config:22 -d results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  E500

Suite Setup          NR Test Suite Common Setup
Test Setup           case reset rru   # testline launch
Test Teardown        case Testline Close    # testline close
Suite Teardown       NR Test Suite Teardown

*** Variables ***


*** Test Cases ***
E500_call
    Case Scenario Execution
    Case Log Analysis

*** Keywords ***
Case Scenario Execution

    :FOR  ${index}  IN RANGE  ${1}
    \    log to console  loop ${index} start
    \    ${case_stat}  Run Keyword And Return Status    loop repeadedly attach   ${index}
    \    run keyword if  ${case_stat} == False  OperatingSystem.Run  echo loop ${index} fail >> ${TESTSUITE_LOG_DIR}${/}result.log
    \    run keyword if  ${case_stat} == True  OperatingSystem.Run  echo loop ${index} pass >> ${TESTSUITE_LOG_DIR}${/}result.log
    ${result}  OperatingSystem.Get File  ${TESTSUITE_LOG_DIR}${/}result.log
    ${count} =	Get Count	${result}	fail
    log to console  ${count} fails loop
    should be true  ${count} == 0


Case Log Analysis
   Log To Console      Test Case Loop Log Analysis

