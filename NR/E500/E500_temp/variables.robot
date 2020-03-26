*** Settings ***
Documentation
...  case configuration part of main case script


*** Variables ***
${Ue_Num}                  1
#${startxfe}   cd /opt/fesw/bin && ./startupmgrd.exe #seting in /home/robot5g/NR/config/Beijing/***/variables.robot
#${startupf}   cd /root/upf-1.7 && ./upf
#${startsmf}  cd /root/5gc-1.7-e500&&./smf
#${startamf}  cd /root/5gc-1.7-e500&&./amf
#${startcu}   cd /root/radisys-cu-1.7-e500/bin && ./gnb_cu_0918
#${startdu}   cd /root/radisys-du-1.7-E500/bin && ./gnb_du_1.7_0902 -f ../config/ssi_mem
#${startue}   cd /root/uesim-1.7-E500 &&./uesim

${config}    102
${config_path}    ${EXECDIR}${/}config${/}Beijing${/}${config}${/}variables.robot
