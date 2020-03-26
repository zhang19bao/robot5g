import paramiko
import getpass
from collections import OrderedDict
import time

hostL=[["host","172.21.6.82","root","123456"],[["xfe","192.169.4.5","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"],
                                               ["cu","192.169.4.20","root","123456"]]]
sshDcit=OrderedDict()

for index in range(len(hostL[1])):
    print(hostL[1][index])
    sshDcit[hostL[1][index][0]]=paramiko.SSHClient()
    sshDcit[hostL[1][index][0]].set_missing_host_key_policy(paramiko.AutoAddPolicy())
    sshDcit[hostL[1][index][0]].connect(hostname=hostL[0][1], port=22, username=hostL[0][2], password=hostL[0][3])
    time.sleep(1)
    # print("sshpass -p {} ssh -o StrictHostKeyChecking=no {}@{}".format(hostL[1][index][3],hostL[1][index][2],hostL[1][index][1]))
    stdin, stdout, stderr = sshDcit[hostL[1][index][0]].exec_command(\
        "sshpass -p {} ssh -o StrictHostKeyChecking=no {}@{}".format(hostL[1][index][3],hostL[1][index][2],hostL[1][index][1]))
    print(stdout)
