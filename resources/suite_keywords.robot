*** Settings ***
Documentation
...            for suite level common keywords

*** Keywords ***
NR E500 Suite Setup
    Log  E500 Suite Setup
    NR Suite Import Libraries
    Suite Env Variables Setting
    run keyword if  "${env.tlType.lower()}" != "e500"  fail   "Please Run E500 Cases ON E500 ENV"
NR E500 Suite Teardown
    [Arguments]  ${timeout}=1200s
    Log  E500 Suite Teardown
    Run Keyword If  "${env.tlType.lower()}" != "e500"  fail   "Please Run E500 Cases ON E500 ENV"
    NR Suite Teardown
NR Suite Teardown
    Log  NR Suite Teardown
NR Suite Import Libraries
    Import Library  robot${/}libraries${/}Collections.py
    Import Library  robot${/}libraries${/}DateTime.py
    Import Library  robot${/}libraries${/}OperatingSystem.py
    Import Library  robot${/}libraries${/}Process.py
    Import Library  robot${/}libraries${/}Screenshot.py
    Import Library  robot${/}libraries${/}String.py
    Import Library  robot${/}libraries${/}XML.py
    Import Library  robot${/}libraries${/}Telnet.py
    Import Library  SerialLibrary
    Import Library  SSHLibrary
Suite Env Variables Setting
    ${envConfig}  Variable Should Exist  ${CONFIGURATION}  "Please Input ENV Configuration Path By Using Variable:--variablse CONFIGURATION:XXX In Robot Command"
    ${ENV_CONFIGURATION}  Replace String  ${CONFIGURATION}  .  ${/}   count=-1
    Set Suite Variable  ${ENV_CONFIG_PATH}      ${EXEC_DIR}${/}config${/}${ENV_CONFIGURATION}${/}__init__.py
    Set Suite Variable  ${ENV_VARIABLES_PATH}   ${EXEC_DIR}${/}config${/}${ENV_CONFIGURATION}${/}variables.py
    Import Variables  ${ENV_CONFIG_PATH}
    Import Variables  ${ENV_VARIABLES_PATH}
    ${StartTimeString}  Get Current Date  time_zone=UTC  increment=8 hours  result_format=%Y%m%d_%H%M%S   exclude_millis=yes
    ${StartTimeSecond}  Convert Date  ${StartTimeString}  result_format=epoch  exclude_millis=yes  date_format=%Y%m%d_%H%M%S
    Set Suite Variable  ${OUTPUT_DIR_ROOT}  ${OUTPUT_DIR}
    Set Suite Variable  ${StartTimeSecond}
    Set Suite Variable  ${StartTimeString}
    Set Suite Variable  ${env}
    Set Suite Variable  ${Reporting}
    @{suiteProcessBack}  create list

