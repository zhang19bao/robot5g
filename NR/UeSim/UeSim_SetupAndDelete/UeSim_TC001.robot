*** Settings ***
Documentation
...  Case name:E500 attach first call
     ...  The purpose for this TC is to:
          ...  The procedure is as followed:
          ...
...  "Author: zhangbr@certusnet.com.cn"
...  History:
     ...    2020.02.27 First Template.
...  *How To execute test case:*
...  cd /home/robot5g
...  robot -t 'Nr_uesim_setup_delete' --variable config:102 -d results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  uesim

Suite Setup          NR Test Suite Common Setup
#Test Setup           Testline Setup   # testline launch
#Test Teardown        Testline Close    # testline close
Suite Teardown       NR Test Suite Teardown

*** Test Cases ***
Nr_uesim_setup_delete
    Case Scenario Execution
    Case Log Analysis

*** Keywords ***
Case Scenario Execution
    log to console  Test Case Scenario Executio
    :FOR  ${index}  IN RANGE  ${2}
    \   ${status}   run keyword and return status  loop cellsetup and delete   ${index}
    \   log to console  ${status}
Case Log Analysis
   Log To Console      Test Case Loop Log Analysis

