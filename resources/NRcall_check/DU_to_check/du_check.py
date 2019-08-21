#!/usr/bin/python
# -*- coding: UTF-8 -*-
# this .py is used to check NR call handling result based on du.log
# 文件名：du_check.py

import os

#syslog file path
path = r'F:\Certusnet\Trace\20190522\console_log'
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
a = 'NR_RACH_DBG: RA REQ IND Received'
b = 'NR_RACH_DBG: Processing MSG2 SUCCESS for raRnti'
c = 'Scheduled RAR'
d = 'NR_RACH_DBG: MSG3 RECVED'
e = 'NR_RACH_DBG: Alloc MSG4'
f = 'NR_RACH_DBG: RGSCH_RA_MSG4_DONE'
g = 'SA UE CONTEXT ADDITION SUCCESSFUL'

tmp = open('result.txt','r')
z = tmp.read()
if (
        a in z and
        b in z and
        c in z and
        d in z and
        e in z and
        f in z and
        g in z):
    print ("Case Pass")
else:
    print ("Case Fail")
tmp.close()


