*** Settings ***
Documentation
...  Case name:E500 attach first call
...  The purpose for this TC is to:
    ...  a temple for E500 Automation
...  "Author: zhangbr@certusnet.com.cn"
...  History:
    ...   2020.2.27 script done
...  *How To execute test case:*
...  cd /home/robot5g
...  robot -t 'E500_cellsetup' --variable config:22 -d results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  E500

Suite Setup          NR Test Suite Common Setup
#Test Setup           E500 Testline Setup    # testline launch
#Test Teardown        E500 Testline Close    # testline close
Suite Teardown       NR Test Suite Teardown

*** Test Cases ***
E500_cellsetup
    Case Scenario Execution
    Case Log Analysis

*** Keywords ***
Case Scenario Execution
    :FOR  ${index}  IN RANGE  ${3}
    \    log to console  ${index}
    \    loop cellsetup and delete   ${index}



Case Log Analysis
   Log To Console      Test Case Loop Log Analysis