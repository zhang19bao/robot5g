*** Settings ***
Documentation
...  Case name: tm500 nas mode template
     ...  The purpose for this TC is to:
          ...  show how to write DV UTE TM500 cases with template

...  "Author: chao.1.ning@nokia.com"
...  *How To execute test case:*
...  cd ~/robotlte_trunk
...  pybot -t 'cpri_sys_reset_wocpri' --variable CONFIGURATION:Beijing.IAV.LRC40.config -d results -L Trace --debug debug testsuite/DCM/dv_lrc

Resource             ${CURDIR}${/}case_keyword.robot
Library              ${CURDIR}${/}resources${/}CPRI_Delay_check2.py

Force Tags           CA_DevBJ1   Intx   DV_TM500_NAS_Mode_Template

Suite Setup          DV Set Common Suite Variables
Test Setup           Set Common Test Case Variables
Test Teardown        DV Specific TM500 Testline Teardown
Suite Teardown       Suite Common Teardown

*** Test Cases ***
cpri_sys_reset_wocpri
    Test Case Configure And Tl Setup
    Run Keyword And Continue On Failure  Test Case Scenario Execution
    Test Case Result Checking

*** Keywords ***
Test Case Scenario Execution

 #   Log To Console         Start log anlysis by scripts
 #   Log Analyse            ${TC_OUTPUT_DIR}  delay_value=@{max_delay}[0]  kbw=${kbw}

    Run Keyword If  ${sys_rset} == 1
    ...             Case Sys Reset wo cpri


    ${case_procedure}       Set Variable       case_procedure

    Start Pysyslog For Enb Fsm            ${case_procedure}
    Start Mmt Log                         ${case_procedure}



    DV DCT Logs Start       dct_scn=${case_scn_name}
    ...                     dct_id=${case_procedure}
    ...                     covert_txt=False

    LTE TM500 Send Script                 ${CURDIR}${/}resources${/}tm500_call.txt
    Sleep       2s
    Log To Console          -----------TM500 script Started-------------

    TM500 PPPoE Connect

    Sleep       2s

    UE DL Data Start   throughput=20M     forHowManySecond=60   packetLength=1400
    ...                interval=1         server_port=5001      max_buffer_size=100M
    UE UL Data Start   throughput=2M      forHowManySecond=60   packetLength=1400
    ...                interval=1         server_port=5001     max_buffer_size=100M
    Sleep       30s

    UE DL Data Stop
    UE UL Data Stop

    Sleep       2s
    TM500 PPPoE Disconnect

    ${mmt_procedure}   Stop Mmt Log       ${case_procedure}
    ${btslog_proc}     Stop Pysyslog For Enb Fsm                ${case_procedure}
    ${dct_log}         DV DCT Logs Collect                      ${case_procedure}
    Set Test Variable                     ${mmt_procedure}
    Set Test Variable                     ${btslog_proc}

Test Case Result Checking
   Log To Console      Test Case Result Checking
   Run Keyword And Continue On Failure
   ...                 DV Log Check eNB Syslog Exception       ${btslog_proc}
   Run Keyword And Continue On Failure
   ...                 DV Log Check Card Alarm
   Run Keyword And Continue On Failure
   ...                 Case Verify MMT Log                     ${mmt_procedure}
   Run Keyword And Continue On Failure
   ...                 Case Verify Cpri Delay
