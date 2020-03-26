*** Settings ***
Documentation
...  Keyword part of main case script

Resource       ${CURDIR}${/}variables.robot
Resource       ${CURDIR}${/}config_modify.robot
Resource       ${EXECDIR}${/}NR${/}resources${/}nr_uesim.robot
Resource       ${config_path}

*** Keywords ***

