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
...  robot -t E500_attach --variable config:22 -d results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  E500

Suite Setup          NR Test Suite Common Setup
#Test Setup           E500 Testline Setup    # testline launch
#Test Teardown        E500 Testline Close    # testline close
Suite Teardown       NR Test Suite Teardown

*** Test Cases ***
E500_attach
    Case Scenario Execution
    Case Log Analysis

*** Keywords ***
Case Scenario Execution
    case cell Setup
    E500 stop logging
    E500 Start To NAS Mode
    E500 download log to folder
    :FOR  ${index}  IN RANGE  ${10}
    \    log to console  ${index}
    \    loop attach and detach   ${index}
    TMA Stop


Case Log Analysis
   Log To Console      Test Case Loop Log Analysis

