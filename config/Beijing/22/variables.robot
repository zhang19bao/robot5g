*** Variables ***
${USERNAME}       root
${PASSWORD}       123456
${local_password}    123456
${HOST}    172.21.6.103   #core ip addr
${NRHOST}  172.21.6.22    #cu and du ip
${NRUSR}   root
${NRPWD}   certusnet@22
${startxfe}     startxfe
${startupf}     cd /root/upf-1.8&&./upf
${startsmf}     cd /home/5gc-1.8-latest&&./smf
${confd}   cd /home/yilang/confd_18_new && ./start_oam.sh INIT_CFG
${startamf}     cd /home/5gc-1.8-latest&&./amf
${startcu}      cd /home/regression1.8/cu/bin&&./gnb_cu_0407 2>&1 | tee cu_console.log
${startdu}      cd /home/regression1.8/du/bin&&./gnb_du_clms_r18_2020-04-08-10-27-38 -f ../config/ssi_mem 2>&1 | tee du_console.log
${startphy}     cd /home/Q3_temp/Q3patch/phy_20200304_0434&&./phystart.sh