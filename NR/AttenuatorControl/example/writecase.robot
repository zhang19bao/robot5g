*** Settings ***
Documentation
...  Case name:AttenuatorControl
...  "Author: licx@certusnet.com.cn"
...  History:
     ...    2020.01.18 First Template.

Library    Telnet    prompt=(> |# )    timeout=5 

Resource             ${CURDIR}${/}AttenuatorControl.robot

*** Variables ***

*** Test Cases ***
AttenyatorControl
    Connection
    Set one  A1  16.0

*** Keywords ***
Connection
    Open connection    172.21.6.13   port=4001    timeout=3
    BuiltIn.Sleep  10
    Read Until   SHX, SHX8X8-95, S/N8X8, Rev.17.01.09

Read one
       [Arguments]    ${COMMAND}   ${PORT}
       Write   ${COMMAND}
       BuiltIn.Sleep  2
       ${ReadResult}=  Read
       Log to Console     ${ReadResult}
Read any
       [Arguments]    ${PORT}
       Read one  R${PORT}   ${PORT}

Read any test
       [Arguments]    ${PORT}
       Run Keyword If    '${PORT}'=='A1'   Read one  RA1   A2
       Run Keyword If    '${PORT}'=='A64'   Read one  RA64   A64

Set one
      [Arguments]     ${PORT}  ${VALUE}
       Log to Console    set S${PORT} value to be ${VALUE}
       Write   S${PORT} ${VALUE}
       BuiltIn.Sleep  2
       ${ReadResult}=    Read Until    >>${PORT}:${VALUE};
       Log to Console     ${ReadResult}