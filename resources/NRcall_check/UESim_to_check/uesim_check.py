#!/usr/bin/python
# -*- coding: UTF-8 -*-
# this .py is used to check NR call handling result based on uesim.log,cu.log,du.log
# 文件名：ue_check.py

import os

#syslog file path
path = r'F:\Certusnet\Robot\NRcall\UESim_to_check\log'
#keywords file
criteria = open('criteria.txt','r')
#result file
checkresult = open('result.txt','w')

class LogAnalysis:
    errorLogCount = 0

    def __init__(self, line, filename):
        self.line = line
        self.filename = filename
        LogAnalysis.errorLogCount += 1

    def Write(self):
        checkresult.write(line)

    def display(self):
        print ("Log Analysis : ", self.line, ", File: ", self.filename)

    def displayCount(self):
        print ("Total Error Log %d" % LogAnalysis.errorLogCount)

#check syslog
pathDir = os.listdir(path)
print (pathDir)
#read criteria to decide case pass or not
checkList = criteria.readlines()

for filename in iter(pathDir):
    syslog = open(path + "/" + filename)
    for line in syslog:
        for check in checkList:
            if check.strip() in line:
                errorLog = LogAnalysis(line, filename)
                errorLog.Write()

#close file
syslog.close()
criteria.close()
checkresult.close()

#Case pass or fail
a = 'Sending MSG 1 for RAPID'
b = 'received connection setup'
c = 'Processing Identity Request Message'
d = 'Processing Authenctication Request Message'
e = 'Rcvd RRC Re-configuration'
f = 'SRB(1) configuration received at UE'
g = 'SRB(2) configuration received at UE'
h = 'DRB(1) is configuread with LCG(1)'
i = 'DRB(2) is configuread with LCG(1)'
j = 'DRB(3) is configuread with LCG(1)'
k = 'DRB(4) is configuread with LCG(1)'
l = 'UE IPv4 ADDR allocated'
m = 'Send RRC Reconfiguration Complete for UEId'

tmp = open('result.txt','r')
z = tmp.read()
if (
        a in z and
        b in z and
        c in z and
        d in z and
        e in z and
        f in z and
        g in z and
        h in z and
        i in z and
        j in z and
        k in z and
        l in z and
        m in z):
    print ("Case Pass")
else:
    print ("Case Fail")
tmp.close()


