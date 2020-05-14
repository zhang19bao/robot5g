*** Variables ***
${USERNAME}       root
${PASSWORD}       certusnet@109
${HOST}    172.21.6.109   #core ip addr
${NRHOST}  172.21.6.27    #cu and du ip
${NRUSR}   root
${NRPWD}   certusnet@27
#${startxfe}     startxfe
${startupf}    cd /root/upf1.8&&./upf
${startsmf}    cd /home/5gc-v1.8/smf-amf-1.8/ && ./smf_new
${confd}    cd /home/1.8_yanfa/radisys1.8/confd_18_lcc/confd_18_new-auth&&./start_oam.sh INIT_CFG
${startamf}    cd /home/5gc-v1.8/smf-amf-1.8/ && ./amf_0226
${startcu}    cd /home/1.8_yanfa/radisys1.8/cu-radisys1.8/CU-R1.8-Regression && ./gnb_cu_nea0_config 2>&1 | tee cu_console.log
${startdu}    cd /home/1.8_yanfa/radisys1.8/du-radisys1.8/DU-R1.8-ETE-Regression&&./gnb_du_clms_r18_2020-04-08-15-14-41 -f ../config/ssi_mem_5  2>&1 | tee du_console.log
${startphy}    cd /home/1.8_yanfa/radisys1.8/phy-q3/phy_20200214_0348&&./phystart.sh