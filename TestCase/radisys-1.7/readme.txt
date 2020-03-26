1.自动化脚本，通过sshlibary登入到linux server

2.然后通过alias命令，跳转cu/du/ue/uec，并启动cu/du/ue bin

alias命令例子如下，根据自己的环境来修改
alias cussh='sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.20'
alias dussh='sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30'
alias uecssh='sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.40'
alias uessh='sshpass -p 123456 ssh -o StrictHostKeyChecking=no root@192.169.4.30'
alias startamf='cd /root/5gc-1.7 && ./amf'
alias startsmf='cd /root/5gc-1.7 && ./smf'
alias startcu='cd /root/radisys-new/radisys-cu-1.7/bin && ./gnb_cu'
alias startdu='cd /root/radisys-new/radisys-du-1.7/bin && ./gnb_du_0817_1 -f ../config/ssi_mem'
alias startue='cd /root/radisys-new/uesim-1.7 && ./uesim_0817'

当你的版本更新后，需要手动将server端的alias更新指定到新的bin

3.一些辅助脚本
auto_logs.sh  需要放在core vm上，用来启动抓取各个网元的log和pcap
iperf_dl.sh   用来启动多UE客户端iperf downlink灌包，放在uec vm/root下
iperf_dl_server.sh  用来启动多UE，服务端iperf downlink，放在app vm/root下
iperf_ul.sh	用来启动多UE客户端iperf uplink灌包，放在app vm/root下
iperf_ul_server.sh  用来启动多UE服务端iperf uplink，放在uec vm/root下
ping_dl.sh  多UE ping downlink，放在app vm/root下
ping_ul.sh  多UE ping uplink，放在uec vm/root下