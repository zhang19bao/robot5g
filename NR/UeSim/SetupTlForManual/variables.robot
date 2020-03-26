*** Settings ***
Documentation
...  case configuration part of main case script


*** Variables ***
${HOST}           172.21.6.107
${USERNAME}       root
${PASSWORD}       123456
${coressh}  sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.10
${startsmf}  cd /root/check_E500_V1.6/5gc-v1.6/ && ./smf_0626
${startamf}  cd /root/check_E500_V1.6/5gc-v1.6/ && ./amf_0702
${startcu}   cd /home/radisys-cu-1.7-e500/bin && ./gnb_cu_0903
#${startdu}   cd /root/radisys-du-1.6-E500/bin&&./gnb_du_801 -f ../config/ssi_mem
${startdu}   cd /root/radisys-du-1.7-E500/bin &&./gnb_du_1.7_0902 -f ../config/ssi_mem
${startue}   cd /root/uesim-1.7-E500  &&./uesim

