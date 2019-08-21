*** Settings ***
Documentation
...  Case name:E500 attach first call
     ...  The purpose for this TC is to:
          ...  The procedure is as followed:
          ...
...  "Author: caocy@certusnet.com.cn"
...  History:
     ...    2019.05.14 caocy@certusnet.com.cn
            ...     First Template.
...  *How To execute test case:*
...  cd ~/robot5g
...  robot -t 'E500_TC001' --variable CONFIGURATION:Beijing.CLOUDNR001 -d /results -L Trace --debug debug NR/

Resource             ${CURDIR}${/}keywords.robot

Force Tags      5GNR  E500

Suite Setup          NR E500 Suite Setup
Test Setup           NR E500 Test Setup
Test Teardown        NR E500 Test Teardown
Suite Teardown       NR E500 Suite Teardown

*** Test Cases ***
E500_TC001
    Case Scenario Execution

*** Keywords ***
Case Scenario Execution
    log to console  Test Case Scenario Executio
    NR E500 Telnet TMA Command Execute  EC  \#$$DISCONNECT
    sleep  2s
    NR E500 Telnet TMA Script Execute   EC  ${CURDIR}${/}resources${/}RAW${/}CONNECT.txt

Case Loop Log Analysis
   Log To Console      Test Case Loop Log Analysis
Case Result Checking

   Log To Console      Test Case Result Checking
