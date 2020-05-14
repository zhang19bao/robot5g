*** Settings ***
Documentation
...  Case name:RealUe attach first call
...  The purpose for this TC is to:
    ...  a temple for RealUe Automation
...  "Author: zhangbr@certusnet.com.cn"
...  History:
    ...   2019.11.22 First Template
    ...   2020.1.7 First call successed
...  *How To execute test case:*
...  cd /home/robot5g
...  robot -t realUe_tmp --variable config:20 -d results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  RealUe

Suite Setup          NR Test Suite Common Setup
Test Setup           RealUe Testline Setup    # testline launch
Test Teardown        RealUe Testline Close    # testline close
Suite Teardown       NR Test Suite Teardown

*** Test Cases ***
realUe_tmp
    Case Scenario Execution
    Case Log Analysis

*** Keywords ***
Case Scenario Execution
    realue start spark log
    realUe log start  attach
    ${attach_result}  run keyword and return status  realUe PowerOff and PowerOn
    realUe log stop
    should be true  ${attach_result} == true
    Dialogs.Pause Execution
#    realUe log start  transmission
    realUe UL UDP send  1
    realUe DL UDP send  200m  4
    realUe stop Testtask  1
    realue stop spark log
    sleep  5s
#    realUe log stop
    log to console  ${TEST NAME}

Case Log Analysis
   Log To Console      Test Case Loop Log Analysis

