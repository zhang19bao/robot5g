*** Variables ***
${USERNAME}       root
${PASSWORD}       12345688
${local_password}    12345688
${HOST}    172.21.6.102
${startxfe}   cd /opt/fesw/bin && ./startupmgrd.exe
${startupf}   cd /root/upf-1.7 && ./upf
${startsmf}  cd /root/5gc-1.7-e500&&./smf
${startamf}  cd /root/5gc-1.7-e500&&./amf
${startcu}   cd /root/radisys-cu-1.7-e500/bin&&./gnb_cu_0918
${startdu}   cd /root/radisys-du-1.7-E500/bin&&./gnb_du_1.7_0902 -f ../config/ssi_mem
${startue}   cd /root/uesim-1.7-E500 &&./uesim