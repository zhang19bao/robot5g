#! /bin/sh

##put script under app server:/root
##app ip address may need to modify accroding to testline

ping 10.10.5.1 -I 12.12.12.113 -c 100 &
ping 10.10.5.2 -I 12.12.12.114 -c 100 &
ping 10.10.5.3 -I 12.12.12.115 -c 100 &
ping 10.10.5.4 -I 12.12.12.116 -c 100 &
ping 10.10.5.5 -I 12.12.12.117 -c 100 &
ping 10.10.5.6 -I 12.12.12.118 -c 100 &
ping 10.10.5.7 -I 12.12.12.119 -c 100 &
ping 10.10.5.8 -I 12.12.12.120 -c 100 &
