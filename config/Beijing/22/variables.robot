*** Variables ***
${USERNAME}       root
${PASSWORD}       123456
${local_password}    123456
${HOST}    172.21.6.103   #core ip addr
${NRHOST}  172.21.6.22    #cu and du ip
${NRUSR}   root
${NRPWD}   certusnet@22
${startxfe}     startxfe   #cd /opt/fesw/bin&&./startupmgrd.exe
${startupf}     cd /root/upf-1.8&&./upf   #cd /root/upf-1.6-e500&&./upf
${startsmf}     cd /home/5gc-1.8-latest&&./smf   #cd /root/check_E500_V1.6/5gc-v1.6&&./smf_0626
${confd}   cd /home/rel18_dev/confd_18_new && ./start_oam.sh INIT_CFG
${startamf}     cd /home/5gc-1.8-latest&&./amf   #cd /root/check_E500_V1.6/5gc-v1.6&&./amf_0702
${startcu}      cd /home/rel18_dev/cu-radisys1.8/bin&&./gnb_cu_opt_nrup_3_24 2>&1 | tee cu_console.log
   #cd /home/mxw/cu_single_ue/cu&&./gnb_cu_0720_Ofast_04
${startdu}      cd /home/rel18_dev/du-radisys1.8/bin&&./gnb_du_clms_r18_2020-03-25-09-49-09 -f ../config/ssi_mem 2>&1 | tee du_console.log
   #cd /home/mxw/du_bin_20_single_ue/bin&&./gnb_du_harq -f ../config/ssi_mem_mcs27
${startphy}     cd /home/Q3_temp/Q3patch/phy_20200304_0434&&./phystart.sh 2>&1 | tee phy_console.log
   #cd /home/mxw/phy_20190727_0730&&./phy_start.sh