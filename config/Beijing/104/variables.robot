*** Variables ***
${HOST}    172.21.6.104
${startxfe}   cd /opt/fesw/bin && ./startupmgrd.exe
${startupf}   cd /root/upf-1.8 && ./upf
${startsmf}  cd /root/5gc-1.8 && ./smf
${startamf}  cd /root/5gc-1.8 && ./amf
${startcu}   cd  /root/radisys-cu-1.8/radisys-cu-1.8/bin && ./gnb_cu
${startdu}   cd /root/radisys-du-1.8/radisys-du-1.8/bin && ./gnb_du_new -f ../config/ssi_mem
${startue}   cd /root/uesim-1.8 && ./uesim-e500