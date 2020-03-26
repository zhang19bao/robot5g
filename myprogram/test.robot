*** Settings ***
Library       Telnet
Library       SSHLibrary
Resource       ${EXECDIR}${/}NR${/}resources${/}PowerSwitchControl.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_E500.robot

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
    SSHLibrary.Open Connection   ${host2}  timeout=10s
    SSHLibrary.Login    ${usr}    ${passwd2}
    SSHLibrary.Close all connections


*** Keywords ***
Case Scenario Execution
    ButtonSixOnOff
