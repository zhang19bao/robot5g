#!/usr/bin/python
# -*- coding: UTF-8 -*-
# this .py is used to check NR call handling result based on amf.log
# 文件名：ngap_check.py

import os

#syslog file path
from typing import TextIO

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
a = 'NGAP_INIT_UE_MESSAGE[NAS_5GS_MSG_REGISTRATION_REQ]'
b = 'NGAP_DL_NAS_TRANSPORT[NAS_5GS_MSG_IDENTITY_REQ]'
c = 'NGAP_UL_NAS_TRANSPORT[NAS_5GS_MSG_IDENTITY_RES]'
d = 'NGAP_DL_NAS_TRANSPORT[NAS_5GS_MSG_AUTHENTICATION_REQ]'
e = 'NGAP_UL_NAS_TRANSPORT[NAS_5GS_MSG_AUTHENTICATION_RES]'
f = 'NGAP_DL_NAS_TRANSPORT[NAS_5GS_MSG_SECURITY_MODE_CMD]'
g = 'NGAP_UL_NAS_TRANSPORT[NAS_5GS_MSG_SECURITY_MODE_CMPLT]'
h = 'NGAP_DL_NAS_TRANSPORT[NAS_5GS_MSG_REGISTRATION_ACC]'
i = 'NGAP_UL_NAS_TRANSPORT[NAS_5GS_MSG_REGISTRATION_CMPLT]'
j = 'NGAP_INIT_UE_MESSAGE[NAS_5GS_MSG_PDU_SESSION_ESTABLISHMENT_REQ]'
k = 'NGAP_INIT_CTXT_SETUP_REQ[NAS_5GS_MSG_PDU_SESSION_ESTABLISHMENT_ACCEPT]'
l = 'NG_INITIAL_CONTEXT_SETUP_RSP'

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
        l in z):
    print ("Case Pass")
else:
    print ("Case Fail")
tmp.close()


