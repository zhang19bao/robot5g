*** Settings ***
Documentation
...  robot -t 'helloworld'  -d results -L Trace --debug debug NR/s

Library        OperatingSystem
Library        SSHLibrary
Library        DateTime
Library        String
*** Test Cases ***
helloworld
    Case Scenario Execution

*** Keywords ***
Case Scenario Execution
    log to console  hello world

Case Log Analysis
   Log To Console      Test Case Loop Log Analysis

