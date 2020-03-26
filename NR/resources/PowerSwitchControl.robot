*** Settings ***
Documentation
...  Case name:PowerSwitchControl
...  "Author: licx@certusnet.com.cn"
...  History:
     ...    2020.01.02 First Template.

Library  Selenium2Library

#Resource             ${CURDIR}${/}keywords.robot

*** Variables ***

${TMA_LOCATION}    172.21.6.10
${TMA_USER_NAME}   admin
${TMA_USER_PASSWORD}   admin
${PASS}   root

*** Keywords ***
#example:ButtonOnOff '5' running result is power off first ,then power on for button 5
ButtonOnOff '${ButtonNumber}'
      Log to Console  Button number is ${ButtonNumber}
      Run Keyword If    '${ButtonNumber}'=='1'    ButtonOneOnOff
      Run Keyword If    '${ButtonNumber}'=='2'    ButtonTwoOnOff
      Run Keyword If    '${ButtonNumber}'=='3'    ButtonThreeOnOff
      Run Keyword If    '${ButtonNumber}'=='4'    ButtonFourOnOff
      Run Keyword If    '${ButtonNumber}'=='5'    ButtonFiveOnOff
      Run Keyword If    '${ButtonNumber}'=='6'    ButtonSixOnOff
      Run Keyword If    '${ButtonNumber}'=='7'    ButtonSevenOnOff
      Run Keyword If    '${ButtonNumber}'=='8'    ButtonEightOnOff

#when status is 0, means power off, 1 means power on
Button '${ButtonNumber}' be '${status}'
      Log to Console   make Button ${ButtonNumber} status be ${status}
      login to mobilepage
      #power off
      Run Keyword If    '${ButtonNumber}'=='1'and '${status}'=='0'  click MobileButtonOneOFF
      Run Keyword If    '${ButtonNumber}'=='2'and '${status}'=='0'  click MobileButtonTwoOFF
      Run Keyword If    '${ButtonNumber}'=='3'and '${status}'=='0'  click MobileButtonThreeOFF
      Run Keyword If    '${ButtonNumber}'=='4'and '${status}'=='0'  click MobileButtonFourOFF
      Run Keyword If    '${ButtonNumber}'=='5'and '${status}'=='0'  click MobileButtonFiveOFF
      Run Keyword If    '${ButtonNumber}'=='6'and '${status}'=='0'  click MobileButtonSixOFF
      Run Keyword If    '${ButtonNumber}'=='7'and '${status}'=='0'  click MobileButtonSevenOFF
      Run Keyword If    '${ButtonNumber}'=='8'and '${status}'=='0'  click MobileButtonEightOFF
      #power on
      Run Keyword If    '${ButtonNumber}'=='1'and '${status}'=='1'  click MobileButtonOneON
      Run Keyword If    '${ButtonNumber}'=='2'and '${status}'=='1'  click MobileButtonTwoON
      Run Keyword If    '${ButtonNumber}'=='3'and '${status}'=='1'  click MobileButtonThreeON
      Run Keyword If    '${ButtonNumber}'=='4'and '${status}'=='1'  click MobileButtonFourON
      Run Keyword If    '${ButtonNumber}'=='5'and '${status}'=='1'  click MobileButtonFiveON
      Run Keyword If    '${ButtonNumber}'=='6'and '${status}'=='1'  click MobileButtonSixON
      Run Keyword If    '${ButtonNumber}'=='7'and '${status}'=='1'  click MobileButtonSevenON
      Run Keyword If    '${ButtonNumber}'=='8'and '${status}'=='1'  click MobileButtonEightON
      click Quit

ButtonOneOnOff
      login to mobilepage
      click MobileButtonOneOFF
      click MobileButtonOneON
      click Quit

ButtonTwoOnOff
      login to mobilepage
      click MobileButtonTwoOFF
      click MobileButtonTwoON
      click Quit

ButtonThreeOnOff
      login to mobilepage
      click MobileButtonThreeOFF
      click MobileButtonThreeON
      click Quit

ButtonFourOnOff
      login to mobilepage
      click MobileButtonFourOFF
      click MobileButtonFourON
      click Quit

ButtonFiveOnOff
      login to mobilepage
      click MobileButtonFiveOFF
      click MobileButtonFiveON
      click Quit

ButtonSixOnOff
      login to mobilepage
      click MobileButtonSixOFF
      click MobileButtonSixON
      click Quit

ButtonSevenOnOff
      login to mobilepage
      click MobileButtonSevenOFF
      click MobileButtonSevenON
      click Quit

ButtonEightOnOff
      login to mobilepage
      sleep  1s
      click MobileButtonEightOFF
      sleep  1s
      click MobileButtonEightON
      sleep  1s
      click Quit

wait until login page disappear
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class, "login_but")]    timeout=15

Comoperation
      login to compage
      wait until login page disappear
      click Closebox
      click Button_five
      click Button_control

login to mobilepage
     Open Browser    http://${TMA_LOCATION}   
     Input Text    id=login_username    ${TMA_USER_NAME}
     Input Password    name=login_password    ${TMA_USER_PASSWORD}
     Click button    id=login_but

click Closebox
     Log to Console  start to click closebox
     Click Element   xpath=//*[@id="main_table"]/tbody/tr[5]/td[2]/label[2]

click Quit
     Log to Console  start to click Quit
     Click Element  xpath= //*[@id="top_table"]/tbody/tr[1]/td[2]/a
     Close Browser

click MobileButtonOneOFF
     Log to Console  start to click button one  OFF
     Click Element  xpath= //*[@id="td3_1"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_11"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_1"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_1"]

click MobileButtonOneON
     Log to Console  start to click button one  ON
     Click Element  xpath= //*[@id="td3_1"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_01"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_1"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_1"]

click MobileButtonTwoOFF
     Log to Console  start to click button two  OFF
     Click Element  xpath= //*[@id="td3_2"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_12"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_2"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_2"]

click MobileButtonTwoON
     Log to Console  start to click button two  ON
     Click Element  xpath= //*[@id="td3_2"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_02"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_2"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_2"]

click MobileButtonThreeOFF
     Log to Console  start to click button three  OFF
     Click Element  xpath= //*[@id="td3_3"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_13"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_3"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_3"]

click MobileButtonThreeON
     Log to Console  start to click button three  ON
     Click Element  xpath= //*[@id="td3_3"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_03"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_3"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_3"]

click MobileButtonFourOFF
     Log to Console  start to click button four  OFF
     Click Element  xpath= //*[@id="td3_4"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_14"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_4"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_4"]

click MobileButtonFourON
     Log to Console  start to click button four  ON
     Click Element  xpath= //*[@id="td3_4"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_04"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_4"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_4"]

click MobileButtonFiveOFF
     Log to Console  start to click button five  OFF
     Click Element  xpath= //*[@id="td3_5"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_15"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_5"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_5"]

click MobileButtonFiveON
     Log to Console  start to click button five  ON
     Click Element  xpath= //*[@id="td3_5"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_05"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_5"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_5"]

click MobileButtonSixOFF
     Log to Console  start to click button six  OFF
     Click Element  xpath= //*[@id="td3_6"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_16"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_6"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_6"]

click MobileButtonSixON
     Log to Console  start to click button six  ON
     Click Element  xpath= //*[@id="td3_6"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_06"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_6"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_6"]

click MobileButtonSevenOFF
     Log to Console  start to click button seven  OFF
     Click Element  xpath= //*[@id="td3_7"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_17"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_7"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_7"]

click MobileButtonSevenON
     Log to Console  start to click button seven  ON
     Click Element  xpath= //*[@id="td3_7"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_07"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_7"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_7"]

click MobileButtonEightOFF
     Log to Console  start to click button eight  OFF
     Click Element  xpath= //*[@id="td3_8"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_18"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_8"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_8"]

click MobileButtonEightON
     Log to Console  start to click button eight  ON
     Click Element  xpath= //*[@id="td3_8"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="radio_function_08"]
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="fd_8"]/fieldset/table/tbody/tr[3]/td[2]/a
     BuiltIn.Sleep  3
     Click Element  xpath= //*[@id="td3_8"]

login to compage
     Open Browser    http://${TMA_LOCATION}    chrome
     Input Text    id=login_username    ${TMA_USER_NAME}
     Input Password    name=login_password    ${TMA_USER_PASSWORD}
     choose Compoperation
     Click button    id=login_but

choose Compoperation
     Log to Console  start to click sel_comp
     Click Element  xpath= /html/body/form/div/div/a[2]
click Button_five
     Log to Console  start to click  click button_five
     Click Element   xpath=//*[@id="socket_table2"]/tbody/tr[1]/td[5]/label
click Button_control
     Log to Console  start to click  click button_control
     Click Element   xpath=//*[@id="main_table"]/tbody/tr[4]/td[2]/input

#
#wait until login page appear
#    Wait Until Page Contains Element    xpath=//form[contains(@class, "Sign in")]    timeout=15

#enter password input '${USER_PASSWORD}'
#    Input Password    name=j_password    ${USER_PASSWORD}
#    Capture Page Screenshot
#
#enter username input '${USER_NAME}'
#    Input Text    id=j_username    ${USER_NAME}  //UserName should be the id
