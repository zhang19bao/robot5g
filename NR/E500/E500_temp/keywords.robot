*** Settings ***
Documentation
...  Keyword part of main case script

Resource       ${CURDIR}${/}variables.robot
Resource       ${config_path}
Resource       ${CURDIR}${/}config_modify.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_E500.robot


*** Keywords ***

