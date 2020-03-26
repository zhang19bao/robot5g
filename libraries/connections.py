# -*- coding: utf-8 -*-
import telnetlib
import serial
import os
import time
import requests
import threading
import collections
import subprocess
import re
class eTelnet(object):
    def __init__(self,ip,port=23,user=None,passwd=None,logPath=None,fileName=None,auto=False):
        self.tn = telnetlib.Telnet()
        self.tn.open(ip,port)
        self.tn.write('\n')
        # if self.tn.read_until(b'login: ', timeout=0.5):
        #     self.tn.write(user.encode('ascii') + b'\n')
        #     if self.tn.read_until(b'Password: ', timeout=1):
        #         self.tn.write(passwd.encode('ascii') + b'\n')
        print("connect ok")
        if not logPath:
            logPath=os.getcwd()
        if not fileName:
            fileName="{}_{}".format(ip,port)
        logFile=os.path.join(logPath,"{}.log".format(fileName))
        self.port=port
        self.logFile=open(logFile,"w")
        if auto==True:
            self.receiveKeep()
    def receiveKeep(self):
        self.receiveT = threading.Thread(target=self.receive(), name="{}_receive".format(self.port))
        self.receiveT.start()
    def receive(self):
        while True:
            out = self.tn.read_until("\n").rstrip("\n")
            # print(out)
            self.logFile.write(out)
            self.logFile.flush()
    def send(self,cmd,passRegex=None,timeout=10):
        self.tn.write("{}\r\n".format(cmd))
        print("\r\n{}\r\n".format(cmd))
        if passRegex!=None:
            return self.tn.read_until(passRegex,timeout)
        return True
    def checkline(self,passRegex=None,timeout=0):
        while timeout>=0:
            for line in self.logFile.readlines():
                if passRegex in line:
                    return True,line
            timeout-=1
            time.sleep(1)
        return False, None
    def logout(self):
        self.tn.close()
    def rtConsole(self):
        pass
class eSerial(object):
    def __init__(self,port,baudrate=115200,bytesize=8,stopbits=1,logPath=None,fileName="TM500",auto=False):
        try:
            self.scom=serial.Serial(port,baudrate,bytesize,stopbits=stopbits)
        except:
            print("{}:{} connect failed".format(port, baudrate))
            return
        if self.scom.is_open:
            print("{}:{} connect ok".format(port,baudrate))
        else:
            print("{}:{} connect failed".format(port, baudrate))
        if not logPath:
            logPath=os.getcwd()
        logFile=os.path.join(logPath,"{}.log".format(fileName))
        self.port=port
        self.logFile=open(logFile,"w")
        if auto==True:
            self.autoReboot()
    def autoReboot(self):
        print("Auto reboot TM500 and receive serial log")
        self.send("reboot")
        self.receiveKeep()
    def send(self,cmd):
        if self.scom.is_open:
            self.scom.write("{}\n".format(cmd).encode())
    def receiveKeep(self):
        self.receiveT = threading.Thread(target=self.receive(), name="{}_receive".format(self.port))
        self.receiveT.start()
    def receive(self):
        while True:
            while self.scom.is_open:
                out = self.scom.readline().rstrip("\n")
                # print(out)
                self.logFile.write(out)
                self.logFile.flush()
    def checkline(self,passRegex=None,timeout=0):
        while timeout>=0:
            for line in self.logFile.readlines():
                if passRegex in line:
                    return True,line
            timeout-=1
            time.sleep(1)
        return False, None
    def logout(self):
        self.logFile.close()
        self.scom.close()
    def rtConsole(self):
        pass
class srioWeb(object):
    def __init__(self,srioIp,srioUser,groups="AllUnitsPresent",auto=False):
        self.loginWeb="http://{}/?#reso-{}".format(srioIp,srioUser)
        self.lockWeb="http://{}/json/lockgroup?group={}&user={}".format(srioIp,groups,srioUser)
        self.unlockWeb="http://{}/json/unlockgroup?group={}&user={}".format(srioIp,groups,srioUser)
        self.poweronWeb="http://{}/json/setpower?group={}&user={}&power=on".format(srioIp,groups,srioUser)
        self.actionDict=collections.OrderedDict()
        self.actionDict["unlock"]=self.unlockWeb
        self.actionDict["lock"] = self.lockWeb
        self.actionDict["poweron"] = self.poweronWeb
        self.srioWeb = requests.session()
        if auto==True:
            self.autoReserve()
    def login(self):
        try:
            self.web=self.srioWeb.get(self.loginWeb, timeout=4)
            if self.web.status_code == requests.codes.ok:
                return True
        except Exception as e:
            print(e)
            return False
    def operation(self,action):
        if action in self.actionDict.keys():
            try:
                self.web=self.srioWeb.get(self.actionDict[action], timeout=4)
                if self.web.status_code == requests.codes.ok:
                    for item in self.web.content.split(","):
                        if "ok" in item and "true" in item:
                            return True
                    else:
                        return False
            except Exception as e:
                print(e)
                return False
    def autoReserve(self):
        self.login()
        time.sleep(2)
        for key,value in self.actionDict.items():
            print(key)
            self.operation(key)
            time.sleep(10)
def startE500Cons():
    from config.Beijing.CLOUDNR001 import env
    T1 = threading.Thread(target=eTelnet, args=(env.bbs1Ip, env.bbs1Port), kwargs={"auto": True}, name="AutoT1")
    T2 = threading.Thread(target=eTelnet, args=(env.bbs2Ip, env.bbs2Port), kwargs={"auto": True}, name="AutoT2")
    T3 = threading.Thread(target=eTelnet, args=(env.hlsIp, env.hlsPort), kwargs={"auto": True}, name="AutoT3")
    Srio = srioWeb(env.srioIp, env.srioUser, env.srioGroups, auto=True)
    T4 = threading.Thread(target=eSerial,args=(env.tm500SerialPort,env.tm500SerialBaudrate),kwargs={"auto":True}, name="AutoT4")
    T1.start()
    T2.start()
    T3.start()
    T4.start()
    print("Start E500 Connections Done")
class TMA(object):
    def __init__(self,tmaExePath,tmaAddParam=None):
        if os.path.isfile(tmaExePath) and ".exe" not in tmaExePath:
            raise("{} isn't exe file or don't exist ".format(tmaExePath))
        elif tmaAddParam:
            self.cmdTMAStart="{} {}".format(tmaExePath,tmaAddParam)
        else:
            self.cmdTMAStart = "{}".format(tmaExePath)
        self.tmaExeRegex=re.compile("tma.*.exe\s+(\d+)",re.I)
    def startTMA(self):
        print("start TMA")
        tma=subprocess.Popen("{}".format(self.cmdTMAStart),shell=False)
        tma.poll()
        timeout=20
        while timeout>=0:
            result,pidId=self.checkTMA()
            if result:
                # for wait tma initialization finish
                time.sleep(20)
                return True
            time.sleep(1)
        return False
    def stopTMA(self):
        result,pidId=self.checkTMA()
        if result:
            if os.system("kill -fW {}".format(pidId)):
                return False
        return True
    def checkTMA(self):
        check=subprocess.Popen("tasklist",shell=False,stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        check.poll()
        pidList=check.stdout.readlines()
        for pid in pidList:
            if "TmaApplication".lower() in pid.lower():
                pidId=self.tmaExeRegex.match(pid).groups(0)[0]
                return True,pidId
        else:
            return False,None
    def checkTelnetPort(self,port=5003,timeout=20):
        stopTime=time.time()+timeout
        while time.time()<=stopTime:
            check = subprocess.Popen("netstat -a -P tcp -n", shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            check.poll()
            lines = check.stdout.readlines()
            for line in lines:
                if str(port) in line:
                    status=line.split()[-1]
                    return True,status
        return False,None
def demo():
    from config.Beijing.CLOUDNR001 import env
    cmdTMA = TMA(env.tmaExePath, env.tmaAddParam)
    cmdTMA.stopTMA()
    startE500Cons()
    print("Initialization Checking")
    time.sleep(60)
    if cmdTMA.startTMA():
        print("Start TMA OK")
        if cmdTMA.checkTelnetPort(5003):
            print("Check Port 5003 OK")
        if cmdTMA.checkTelnetPort(5030):
            print("Check Port 5030 OK")
    time.sleep(100)
    tnEc=eTelnet(env.tmaLocalIp,env.tmaEcPort)
    result=tnEc.send("#$$PORT 192.168.10.70 5001 5002 5003","OK",5)
    print(result)
    # tnAc = eTelnet(env.tmaLocalIp, env.tmaAcPort)
def startBBS1eTelnet(env):
    tnBbs1 = eTelnet(env.bbs1Ip, env.bbs1Port)
    tnBbs1.receiveKeep()
def startBBS2eTelnet(env):
    tnBbs1 = eTelnet(env.bbs2Ip, env.bb21Port)
    tnBbs1.receiveKeep()
def startHLSeTelnet(env):
    tnBbs1 = eTelnet(env.hlsIp, env.hlsPort)
    tnBbs1.receiveKeep()
def rebootTM500eSerial(env):
    tm500Serial = eSerial(env.tm500SerialPort, env.tm500SerialBaudrate)
    tm500Serial.send("reboot")
    tm500Serial.receiveKeep()
def autoSrioReserve(env):
    Srio = srioWeb(env.srioIp, env.srioUser, env.srioGroups)
    Srio.autoReserve()
def stopTMA(env):
    cmdTMA = TMA(env.tmaExePath, env.tmaAddParam)
    cmdTMA.stopTMA()
def autoConnectTMA(env):
    tma=TMA(env.tmaExePath,env.tmaAddParam)
    if tma.startTMA():
        print("Start TMA OK")
        if tma.checkTelnetPort(env.tmaEcPort):
            print("Check Port 5003 OK")
        if tma.checkTelnetPort(env.tmaAcPort):
            print("Check Port 5030 OK")
    time.sleep(100)
    tnEc=eTelnet(env.tmaLocalIp,env.tmaEcPort)
    result=tnEc.send("#$$PORT 192.168.10.70 5001 5002 5003","OK",5)
    print(result)
    # tnAc = eTelnet(env.tmaLocalIp, env.tmaAcPort)


if __name__ == "__main__":
    # Srio = srioWeb(env.srioIp, env.srioUser, env.srioGroups,auto = True)
    # tnBbs1 = eTelnet(env.bbs1Ip,env.bbs1Port)
    # tnBbs2 = eTelnet(env.bbs2Ip, env.bbs2Port)
    # tnHls = eTelnet(env.hlsIp, env.hlsPort)
    # tm500Serial = eSerial(env.tm500SerialPort,env.tm500SerialBaudrate,auto=True)
    # startE500Cons()
    # cmdTMA=TMA(env.tmaExePath,env.tmaAddParam)
    # print(cmdTMA.checkTelnetPort())
    # cmdTMA.startTMA()
    # print(cmdTMA.checkTMA())
    # cmdTMA.stopTMA()
    demo()
    pass



