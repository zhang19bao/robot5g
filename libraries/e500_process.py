from e500 import eTelnet,eSerial,srioWeb,TMA
import time
import sys
import os
import threading
import re
def startBBS1eTelnet(env,logPath):
    print(1)
    tnBbs1 = eTelnet(env.bbs1Ip, env.bbs1Port,logPath=logPath)
    tnBbs1.receiveKeep()
def startBBS2eTelnet(env,logPath):
    print(1)
    tnBbs1 = eTelnet(env.bbs2Ip, env.bb21Port,logPath=logPath)
    tnBbs1.receiveKeep()
def startHLSeTelnet(env,logPath):
    print(1)
    tnBbs1 = eTelnet(env.hlsIp, env.hlsPort,logPath=logPath)
    tnBbs1.receiveKeep()
def rebootTM500eSerial(env,logPath):
    tm500Serial = eSerial(env.tm500SerialPort, env.tm500SerialBaudrate,logPath=logPath)
    tm500Serial.send("reboot")
    tm500Serial.receiveKeep()
def autoSrioReserve(env):
    Srio = srioWeb(env.srioIp, env.srioUser, env.srioGroups)
    Srio.autoReserve()
def stopTMA(env):
    cmdTMA = TMA(env.tmaExePath, env.tmaAddParam)
    cmdTMA.stopTMA()
def checkTMA(env):
    cmdTMA = TMA(env.tmaExePath, env.tmaAddParam)
    return cmdTMA.checkTMA()
def autoStartTMA(env):
    tma=TMA(env.tmaExePath,env.tmaAddParam)
    if tma.startTMA():
        print("Start TMA OK")
        if tma.checkTelnetPort(env.tmaEcPort):
            print("Check Port 5003 OK")
        if tma.checkTelnetPort(env.tmaAcPort):
            print("Check Port 5030 OK")
    time.sleep(80)
def startE500Cons(env,logPath=None):
    print(logPath)
    T1 = threading.Thread(target=eTelnet, args=(env.bbs1Ip, env.bbs1Port), kwargs={"auto": True,"logPath":logPath }, name="AutoT1")
    T2 = threading.Thread(target=eTelnet, args=(env.bbs2Ip, env.bbs2Port), kwargs={"auto": True,"logPath":logPath}, name="AutoT2")
    T3 = threading.Thread(target=eTelnet, args=(env.hlsIp, env.hlsPort), kwargs={"auto": True,"logPath":logPath}, name="AutoT3")
    Srio = srioWeb(env.srioIp, env.srioUser, env.srioGroups, auto=True)
    T4 = threading.Thread(target=eSerial,args=(env.tm500SerialPort,env.tm500SerialBaudrate),kwargs={"auto":True,"logPath":logPath}, name="AutoT4")
    T1.start()
    T2.start()
    T3.start()
    T4.start()
    print("Start E500 Connections Done")

def checkE500Ready(logPath,passRegex="TM500 NR5G VERSION",fileNum=None,timeout=120):
    passRegexp=re.compile(r"{}".format(passRegex),re.I)
    versionInfoRegexp=re.compile(r"Version:(.*)\r[\s\S]*?App:(.*)\r[\s\S]*?Label:(.*?)\r",re.I)
    endTime=int(time.time())+int(timeout)
    files=os.listdir(logPath)
    if fileNum!=len(files):
        raise Exception("{} files are found in log path:{}, not equal with {}".format(len(files),logPath,fileNum))
    while  time.time()<=endTime:
        passCount=0
        time.sleep(5)
        version=""
        for file in files:
            filePath=os.path.join(logPath,file)
            if os.path.isfile(filePath):
                with open(filePath,"r") as f:
                    text=f.read()
                    rough=re.findall(passRegexp,text)
                    if len(rough)==1:
                        detials=re.findall(versionInfoRegexp,text)
                        if len(detials)==1:
                            version+=(",".join(detials[0]))
                    else:
                        break
                passCount+=1
        if passCount==len(files):
            return  True,version
    return False,version
def startE500BackProcess(configPath,logPath):
    print(configPath,logPath)
    if not os.path.isfile(configPath):
        raise Exception("{} Don't exist".format(configPath))
    env=None
    paths=str(configPath).split(os.path.sep)
    if "config" in paths:
        index=paths.index("config")
        rootPath=os.path.sep.join(paths[:index])
        sys.path.append(rootPath)
        print(rootPath)
        indexT=-1
        if ".py" not in paths[indexT]:
            indexT=0
        modules=".".join(paths[index:indexT])
        exec("from {} import {}".format(modules,"env"))
    else:
        raise  Exception("{} Isn't Valid ENV Config File Path,It Must IN config folder".format(configPath))
    if not env:
        raise  Exception("Import ENV Config Failed:{}".format(configPath))
    startE500Cons(env,logPath)
    time.sleep(10)
def getE500ProcessFilePath():
    return  os.path.split(os.path.realpath(__file__).replace(".pyc",".py"))
if __name__ == "__main__":
    print(sys.argv)
    if len(sys.argv) ==3:
        print(sys.argv)
        startE500BackProcess(sys.argv[1],sys.argv[2])
