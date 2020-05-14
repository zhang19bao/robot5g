*** Variables ***
${USERNAME}       root
${PASSWORD}       certusnet@119
${HOST}    172.21.6.119   #core ip addr
${NRHOST}  172.21.6.20    #cu and du ip
${rru_ip}  172.21.6.208    #rru and du ip
${NRUSR}   root
${NRPWD}   certusnet@20
${startxfe}    modprobe uio_pci_generic && startxfe
${startupf}    cd /root/upf-1.6-e500&&./upf_20200226
${startsmf}    cd /root/check_E500_V1.6/5gc-v1.6-cpe&&./smf_0224
${startamf}    cd /root/check_E500_V1.6/5gc-v1.6-cpe&&./amf_0306
${confd}    cd /home/cmcc/regression_q3/confd_16&&./start_oam.sh  INIT_CFG
${startcu}    cd /home/cmcc/regression_q3/cu_cpe/cu/&&./gnb_cu_R16_Regression 2>&1 | tee cu_console.log
${startdu}    cd /home/cmcc/regression_q3/du_cpe/du_bin/bin&&./gnb_du_clms_cpe_0424-1754  -f ../config/ssi_mem 2>&1 | tee du_console.log
${startphy}    cd /home/cmcc/regression_q3/l1/phy_20200403_0531&&./phystart.sh

#cd /home/regression1.8/confd_18_main&&./start_oam.sh INIT_CFG
#cd /home/regression1.8/cu/bin/&&./gnb_cu_0420 2>&1 | tee cu_console.log
#cd /home/regression1.8/phy_20200414_0146 && ./phystart.sh
#cd /home/regression1.8/du/bin&&./gnb_du_clms_r18_2020-04-26-16-48-30 -f ../config/ssi_mem 2>&1 | tee du_console.log

#cd /home/regression1.8/confd_18_auth&&./start_oam.sh INIT_CFG
#cd /home/regression1.8/cu/bin/&&./gnb_cu_0410 2>&1 | tee cu_console.log
#cd /home/regression1.8/du/bin&&./gnb_r18_du_0416_ydl -f ../config/ssi_mem 2>&1 | tee du_console.log
#cd /home/qnx/pucch0123/phy_20200326_0548 && ./phystart.sh

#cd /home/yilang/confd_18_auth && ./start_oam.sh INIT_CFG
#cd /home/yilang/cu_auth/bin && ./gnb_cu_0407_15c7c82bcd270473d6db8635263b07775ba4aefd 2>&1 | tee cu_console.log
#cd /home/qnx/pucch0123/phy_20200326_0548 && ./phystart.sh
#cd /home/yilang/du/bin && ./gnb_r18_du_0416_ydl -f ../config/ssi_mem 2>&1 | tee du_console.log
