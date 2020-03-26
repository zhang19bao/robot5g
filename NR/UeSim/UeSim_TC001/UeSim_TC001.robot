*** Settings ***
Documentation
...  Case name:E500 attach first call
     ...  The purpose for this TC is to:
          ...  The procedure is as followed:
          ...
...  "Author: zhangbr@certusnet.com.cn"
...  History:
     ...    2019.08.21 First Template.
...  *How To execute test case:*
...  cd /home/robot5g
...  robot -t 'Nr_case1_attach' --variable config:102 -d results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  uesim

Suite Setup          NR Test Suite Common Setup
Test Setup           Testline Setup   # testline launch
Test Teardown        Testline Close    # testline close
Suite Teardown       NR Test Suite Teardown

*** Test Cases ***
Nr_case1_attach
    Case Scenario Execution
    Case Log Analysis

*** Keywords ***
Case Scenario Execution
    log to console  Test Case Scenario Executio
    log to console  ${TEST NAME}
    check UE attach   ${Ue_Num}
    check ping traffic
    check DL UDP traffic
    check UL UDP traffic
Case Log Analysis
   Log To Console      Test Case Loop Log Analysis

