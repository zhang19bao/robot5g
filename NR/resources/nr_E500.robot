*** Settings ***
Documentation
...  common keywords for E500 TL
...  "Author: zhangbr@certusnet.com.cn"

Library       Telnet
Resource      .${/}common.robot
Resource      .${/}PowerSwitchControl.robot


*** Variables ***
#${USERNAME}       root
#${PASSWORD}       123456
#${local_password}    123456
${psexec_tool_dir_cygwin}  /cygdrive/c/
${E500_main_folder}    C:\\Program Files (x86)
${E500_version}     5G NR - NLA 4.18.0
${E500_host}  172.21.6.60
${E500_user}  E500
${E500_password}  12345688
${upfssh}   sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.5
${coressh}  sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.10
${cussh}    sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.20

*** Keywords ***

E500 Testline Setup
    E500 Testline Close  1
    :FOR  ${index}  IN RANGE  ${3}
    \   ${stat}     run keyword and return status    E5000 xfe setup
    \   Exit For Loop If	 ${stat} == True
    \   E500 xfe close
    E500 clean log
    E500 upf setup
    E500 smf setup
    E500 amf setup
    E500 cu setup
    E500 phy setup
    E500 log setup  cell_setup
    sleep  5s
    E500 du setup
    E500 log stop
    Sleep      3s
    E500 Start To NAS Mode
    Sleep          10s

E5000 xfe setup
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
    SSHLibrary.Write    modprobe uio_pci_generic
    sleep    3s
    SSHLibrary.Write    ${startxfe}
    ${output}=    SSHLibrary.Read    delay=120s
#    log to console   ${output}
    Should Contain    ${output}=    FE startup successful

E500 upf setup
    log to console  start to setup upf
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
    SSHLibrary.Write    ${startupf}
    ${output}=    SSHLibrary.Read    delay=20s
#    log to console   ${output}
    Should Contain    ${output}=    xFEIngress
    log to console  upf start completed

E500 smf setup
    log to console  start to setup smf
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${startsmf}
    ${output}=    SSHLibrary.Read    delay=10s
#    log to console   ${output}
    Should Contain    ${output}=    10.10.8.20
    log to console  smf start completed

E500 amf setup
    log to console  start to setup amf
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${startamf}
    ${output}=    SSHLibrary.Read    delay=10s
#    log to console   ${output}
    log to console  amf start completed

E500 cu setup
    log to console  start to setup cu
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    ulimit -c unlimited
    SSHLibrary.Write    ${confd}
    sleep  30s
    SSHLibrary.Write    ps -ef|grep confd
    sleep  3s
    SSHLibrary.Write    ${startcu}
    ${output}=	SSHLibrary.Read	delay=20s
#    log to console   ${output}
#    Write log to text   cu.log   ${output}
#    Should Contain    ${output}=    STARTING GNB CONFIGURATION
    log to console  cu start completed

E500 phy setup
    log to console  start to setup phy
    ${phy_ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    set global variable   ${phy_ssh_index}
    SSHLibrary.Write    ${startphy}
    ${output}=    SSHLibrary.Read    delay=20s
#    log to console   ${output}
    Should Contain    ${output}=    welcome to application console
    log to console  phy start completed

E500 du setup
    log to console  start to setup du
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    ulimit -c unlimited
    SSHLibrary.Write    ${startdu}
    sleep  5s
    SSHLibrary.Write Bare  0
    ${output}=    SSHLibrary.Read    delay=10s
#    log to console   ${output}
    Should Contain    ${output}=    CELL[1] is UP
    log to console  du start completed

E500 Testline Close
    [Arguments]  ${if_init}=0
    EM500 Stop
    E500 phy close
    E500 du close
    E500 cu close
    E500 amf close
    E500 smf close
    E500 upf close
    E500 xfe close
    run keyword if      ${if_init}==0
    ...        E500 get console log
    run keyword if      ${if_init}==0
    ...        E500 download log to folder  ${TESTSUITE_LOG_DIR}
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write   pkill -9 sshpass
    sleep  1s
    SSHLibrary.Write   pkill -2 get_nr_log_E500
    SSHLibrary.close all connections

E500 log setup
    [Arguments]  ${logname}=${empty}
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    /home/get_nr_log_E500.sh start ${logname}
    sleep   10s
    ${output}=    SSHLibrary.Read    delay=30s
    Should Contain    ${output}=    tcpdump: listening on
    log to console  start to catch log

E500 clean log
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} ssh root@${HOST} rm -rf /tmp/nr_loh_tmp/*
    sleep   3s
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} ssh root@${HOST} /home/get_nr_log_E500.sh clcore
    sleep   5s
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} ssh root@${HOST} /home/get_nr_log_E500.sh clconsole
    sleep   5s

E500 log stop
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} ssh root@${HOST} /home/get_nr_log_E500.sh stop
    sleep   30s
    log to console  tcpdump log stopped

E500 get console log
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} ssh root@${HOST} /home/get_nr_log_E500.sh console
    sleep  40s
    log to console  logging stopped

E500 download log to folder
    [Arguments]  ${log_folder}=${TESTSUITE_LOG_DIR}
    ${rc} =	OperatingSystem.Run and Return RC  sshpass -p ${PASSWORD} scp root@${HOST}:/tmp/nr_log_tmp/* ${log_folder}
    log to console  download logs to ${log_folder}
    sleep   20s
    OperatingSystem.run   sshpass -p ${PASSWORD} ssh root@${HOST} rm -f /tmp/nr_log_tmp/*

E500 xfe close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
    SSHLibrary.Write    pkill -9 startupmgrd.exe
    sleep  3s
    log to console  xfe stopped

E500 upf close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    ${upfssh}
    SSHLibrary.Write    pkill -9 upf
    log to console  upf stopped

E500 smf close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Write    pkill -9 smf
    log to console  smf stopped

E500 amf close
    ${ssh_index}  Create Ssh Connection    ${HOST}   ${USERNAME}   ${PASSWORD}
    SSHLibrary.Switch Connection        ${ssh_index}
    SSHLibrary.Write    pkill -9 amf
    sleep  1s
    SSHLibrary.Write    pkill -9 tcpdunp
    log to console  amf stopped

E500 cu close
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    pkill -9 gnb_cu
    sleep  1s
    SSHLibrary.Write    pkill -9 tcpdunp
    log to console  cu stopped

E500 phy close
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    pkill -2 l1app
    sleep  5s
    SSHLibrary.Write    pkill -9 l1app
    log to console  phy stopped

E500 du close
    ${ssh_index}  Create Ssh Connection    ${NRHOST}   ${NRUSR}    ${NRPWD}
    SSHLibrary.Write    pkill -2 gnb_du
    sleep  3s
    SSHLibrary.Write    pkill -9 gnb_du
    log to console  du stopped

E500 Start To NAS Mode
    [Documentation]         Start tm500 service
    Log To Console          -----------TM500 Start-------------
    Run Keyword And Return Status                               TMA Stop          make_info=False
    ${ssh_index}            SSHLibrary.Open Connection    ${E500_host}    timeout=30    encoding=GBK
    SSHLibrary.Login    ${E500_user}    ${E500_password}
#    ${ssh_cmd_send}         Set variable                        ${psexec_tool_dir_cygwin}/psExec/PsExec.exe -i 1 -d -u ${E500_user} -p ${E500_password} "${E500_main_folder}\\Aeroflex\\TM500\\${E500_version}\\Test Mobile Application\\TMA.exe" /u E500 /c y /p 5003 /l n /a y /ea y /pa
    ${ssh_cmd_send}         Set variable                        ${psexec_tool_dir_cygwin}/PsExec/PsExec.exe -i 2 -d -u ${E500_user} -p ${E500_password} "${E500_main_folder}\\Aeroflex\\TM500\\${E500_version}\\Test Mobile Application\\TMA.exe" /u "Default User" /c y /p 5003 /l n /a y /ea y /pa
    Ssh Execute Cmd         ${ssh_index}                        ${ssh_cmd_send}
    sleep  30s
    SSHLibrary.Close Connection

    sleep  10s
    Telnet.Open Connection              ${E500_host}            port=5003      timeout=180
    Log To Console      start to connect to TM500
    Telnet.Write Bare                   script "D:\\E500_script\\connect.txt"\n\r
    ${output}                           Telnet.Read Until Regexp    I: TMAE 0x0 Information - RDA Connection complete
    Write log to text  E500_start_cmdl.log  ${output}
#    #m2
#    Telnet.Write Bare                   \#$$CONNECT\n\r
#    ${output}                           Telnet.Read Until Regexp            C: CONNECT 0x00 ok
#    sleep      2s
#    Telnet.Write Bare                   GSTS\n\r
#    ${output}                           Telnet.Read Until Regexp            C: GSTS 0x00 Ok Reset
#    sleep      1s
#    Telnet.Write Bare                   ABOT 0 0 0\n\r
#    ${output}                           Telnet.Read Until Regexp            C: ABOT 0x00 Ok 0x0000001e
#    sleep      1s
#    Telnet.Write Bare                   MULT 192.168.10.9\n\r
#    ${output}                           Telnet.Read Until Regexp            C: MULT 0x00 Ok
#    sleep      1s
#    Telnet.Write Bare                   SCXT 0 LTE\n\r
#    ${output}                           Telnet.Read Until Regexp            C: SCXT 0x00 Ok
#    sleep      1s
#    Telnet.Write Bare                   SCXT 1 NR\n\r
#    ${output}                           Telnet.Read Until Regexp            C: SCXT 0x00 Ok
#    sleep      1s
#    Telnet.Write Bare                   SCFG SWL\n\r
#    ${output}                           Telnet.Read Until Regexp            C: SCFG 0x00 Ok SWL
#    sleep      1s
#    Telnet.Write Bare                   STRT\n\r
#    ${output}                           Telnet.Read Until Regexp            C: STRT 0x00 Ok
#    sleep      1s
#    Telnet.Write Bare                   forw swl setlicenseserver none\n\r
#    ${output}                           Telnet.Read Until Regexp            C: FORW 0x00 Ok SWL
#    sleep      1s
#	Telnet.Write Bare                   RSET\n\r
#    ${output}                           Telnet.Read Until Regexp            C: RSET 0x00 Ok
#    sleep      1s
#	Telnet.Write Bare                   MULT 192.168.10.9\n\r
#    ${output}                           Telnet.Read Until Regexp            C: MULT 0x00 Ok
#    sleep      1s
#	Telnet.Write Bare                   SCXT 0 LTE\n\r
#    ${output}                           Telnet.Read Until Regexp            C: SCXT 0x00 Ok
#    sleep      2s
#	Telnet.Write Bare                   SCXT 1 NR\n\r
#    ${output}                           Telnet.Read Until Regexp            C: SCXT 0x00 Ok
#    sleep      1s
##	Telnet.Write Bare                   SELR 0 1 RC2 1 DEDICATED\n\r
#    Telnet.Write Bare                   SELR 0 1 RC1 1 DEDICATED\n\r
#    ${output}                           Telnet.Read Until Regexp           C: SELR 0x00 Ok
#    sleep      1s
#	Telnet.Write Bare                   CFGR 0 SCS 1 1\n\r
#    ${output}                           Telnet.Read Until Regexp            C: CFGR 0x00 Ok
#    sleep      1s
#	Telnet.Write Bare                   EREF 0 1 0\n\r
#    ${output}                           Telnet.Read Until Regexp            C: EREF 0x00 Ok
#    sleep      1s
#	Telnet.Write Bare                   GETR\n\r
#    ${output}                           Telnet.Read Until Regexp            C: GETR 0x00 Ok
#    sleep      1s
#	Telnet.Write Bare                  SCFG NAS_MODE\n\r
#    ${output}                           Telnet.Read Until Regexp            C: SCFG 0x00 Ok NAS_MODE
#    sleep      1s
#	Telnet.Write Bare                   STRT\n\r
#    ${output}                           Telnet.Read Until Regexp            C: STRT 0x00 Ok
#    sleep      1s  #m2

    Telnet.Close Connection
    Log To Console          -----------TM500 Finished-------------

E500 sheck status
    Telnet.Open Connection              ${E500_host}           port=5003      timeout=30
    Telnet.Write Bare                   FORW MTE CLEARSTATS\n\r
    Sleep                               5s
    Telnet.Write Bare                   FORW MTE GETSTATS [0] [0] [0]\n\r
    Sleep                               5s
    Telnet.Write Bare                   FORW MTE GETSTATS [0] [0] [0]\n\r
    Sleep                               5s
    Telnet.Write Bare                   FORW MTE GETSTATS [0] [0] [0]\n\r
    Sleep                               5s
    ${output}=   Telnet.Read
    Write log to text   E500_ststus.log   ${output}
    Sleep                               10s
    Telnet.Close Connection

E500 Send Script
    [Documentation]        Send cmd to tm500
    [Arguments]             #${tm500_script}     ${timeout}=30

    Telnet.Open Connection              ${E500_host}           port=5003      timeout=30    #${timeout}
#    Telnet.Write Bare    \#$$START_LOGGING\n\r
#    sleep   5s
    Telnet.Write Bare                   script "D:\\E500_script\\5G_SA_Registration_ok_version_2_version_2.txt"\n\r
    Sleep                               20s
    ${output}                           Telnet.Read
    Write log to text  E500_send_Script_cmdl.log  ${output}
    Should Contain    ${output}  Registration Result: 3GPP Access Only  msg=attach fail
    Sleep                               10s
#    Telnet.Write Bare    \#$$STOP_LOGGING\n\r
    Telnet.Close Connection

EM500 Stop
    Run Keyword And Return Status                               TMA Stop           make_info=True


TMA Stop
    [Arguments]             ${make_info}=${True}
    Run Keyword If          ${make_info}==${True}               Log To Console          -----------TM500 Stop Starting-------------

    Telnet.Open Connection              ${E500_host}           port=5003      timeout=15
    Telnet.Write Bare                   \#$$DISCONNECT\n\r
    Sleep                               2s
    Telnet.Close Connection
    sleep   3s
    SSHLibrary.Open Connection    ${E500_host}    timeout=30    encoding=GBK
    SSHLibrary.Login    ${E500_user}    ${E500_password}
    ${ssh_cmd_send}         Set variable                        taskkill /f /t /im TMA.exe /im TmaApplication.exe
    SSHLibrary.Write    ${ssh_cmd_send}
    SSHLibrary.Close Connection
    Run Keyword If          ${make_info}==${True}               Log To Console          -----------TM500 Stop Finished-------------


E500 Shernick Login
    [Documentation]         Shernick login
    ${cmd_read_prompt}      Set Variable                    cli@diversifEye:~$
    SSHLibrary.Write                ssh cli@192.168.10.200
    Sleep                           1
    ${output}=    SSHLibrary.Read    delay=20s
    Should Contain    ${output}=   password
#    SSHLibrary.Read Until           Password:
    SSHLibrary.Write                diversifEye
    Sleep                           1
    SSHLibrary.Read Until           ${cmd_read_prompt}


E500 Shernick Start
    [Documentation]         Start Shernick via cli
    ${test_group_name}      Set Variable    //1UE-UDP-FTP
    ${ssh_index}     SSHLibrary.Open Connection    ${E500_host}    timeout=30    encoding=utf-8
    SSHLibrary.Login    ${E500_user}    ${E500_password}
    E500 Shernick Login
    SSHLibrary.Write                cli -u tm500 -p 1 stopTestGroup
    Sleep                           5
    SSHLibrary.Write                cli -u tm500 -p 1 startTestGroup ${test_group_name}
    ${output}=    SSHLibrary.Read    delay=10s
    Should Contain    ${output}=    tm500@localhost/1: Test group configuration complete
#    SSHLibrary.Read Until           tm500@localhost/2: Test group configuration complete
    Sleep                           3
    SSHLibrary.Write                exit
    Sleep                           1
    SSHLibrary.Close Connection

E500 Shernick Stop
    [Documentation]         Stop Shernick via cli
    ${ssh_index}     SSHLibrary.Open Connection    ${E500_host}    timeout=30    encoding=utf-8
    SSHLibrary.Login    ${E500_user}    ${E500_password}
    E500 Shernick Login
    SSHLibrary.Write                cli -u tm500 -p 1 stopTestGroup
    ${output}=    SSHLibrary.Read    delay=3s
    Should Contain    ${output}=   tm500@localhost/1: All test entities stopped
#    SSHLibrary.Read Until          tm500@localhost/2: All test entities stopped
    Sleep                           3
    SSHLibrary.Write                exit
    Sleep                           1
    SSHLibrary.Close Connection
