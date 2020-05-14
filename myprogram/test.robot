*** Settings ***
Library       Telnet
Library       SSHLibrary
Resource       ${EXECDIR}${/}NR${/}resources${/}PowerSwitchControl.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_RealUe.robot
#Resource       ${EXECDIR}${/}NR${/}resources${/}nr_E500.robot

Documentation
...  *How To execute test case:*
...  cd /home/robot5g
...  robot -t login_test -d results -L Trace --debug debug myprogram/

*** Variables ***
${host1}  172.21.16.106
${usr}  root
${passwd1}  certusnet@106
${host2}  172.21.6.103
${passwd2}  123456

*** Test Cases ***
login_test
    ${log_file_name}  Get Timestamp String
    Set Global Variable  ${log_file_name}
    log to console  ${log_file_name}
    Case Scenario Execution


*** Keywords ***
Case Scenario Execution
    realue start spark log  #spark_log_path= D:\\sparkLogfiles\\
    sleep  5s
    realue stop spark log

