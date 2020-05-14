#! /usr/bin/python3
# _*_ coding: utf-8 _*_

import socket
import sys

host = '172.21.9.31'
# host = '172.21.9.139'
port = 30999
AutoCheck = r'{"CMD": "AutoCheck"}'  #自动配置设备
ConnectEQ = r'{"CMD": "ConnectEQ"}'  #连接设备
DisConnectEQ = r'{"CMD": "DisConnectEQ"}'    #断开设备
StartLog = {"CMD": "StartLog", "Param": {"LogPath": "C:\\Program Files (x86)\\Spark\\Data\\", "LogName": "AutoTest2020-030801"}}    #开始记录
StopLog = r'{"CMD": "StopLog"}'    #停止记录
UpdateTask = r'''{"CMD": "UpdateTask","Param":
            {"TestPlans":
            [{"TestTasks": 
            [{"TaskName": "Bandwidth Test", 
                "TaskEnable": true, 
                "TaskType": "iperf", 
                "TestTimes": 1, 
                "TestInterval": 1, 
                "CyclePeriod": 180, 
                "TestContent": {"ConnectionSetup": {"ConnectionType": "app"}, 
                "Protocol": "UDP", 
                "ProtocolVer": 3, 
                "TestType": "UL", 
                "Address": "12.12.12.13", 
                "Port": 5001,
                "TestTime": 60, 
                "UDPBandwidth": 10000, 
                "UDPBufferSize": 1024, 
                "UDPPacketSize": 1400, 
                "Thread": 10}}]}]},"EQIndex":1}''' #测试计划

StartTest = r'{"CMD": "StartTest", "EQIndex": 1}'   #开始测试
StopTest = r'{"CMD": "StopTest", "EQIndex": 1}'    #停止测试
PowerOff = r'{"CMD": "PowerOff", "EQIndex": 1}'    #关机指令
PowerOn = r'{"CMD": "PowerOn", "EQIndex": 1}'    #开机指令
Attach = r'{"CMD": "Attach", "EQIndex": 1}'    #Attach 指令
Detach = r'{"CMD": "Detach", "EQIndex": 1}'    #Detach 指令
GetParamMAC = r'{"CMD": "GetParamMAC", "EQIndex": 1}'    #MAC层上下行速率
GetParamIMSI = r'{"CMD": "GetParamIMSI", "EQIndex": 1}'   #获取IMSI、蜂窝IP

SetSubFrame = r'{"CMD": "SetSubFrame",\
                "Param": {"QualcommEnable": true, "HisiEnable": false,\
                "SubFrameSet":{"ItemListNR5G": [{"Code": 5070, "Checked": true},\
                    {"Code": 5080, "Checked": true},\
                    {"Code": 5081, "Checked": true},\
                    {"Code": 5090, "Checked": true},\
                    {"Code": 5091, "Checked": true}],\
                "ItemListLTE": [{"Code": 180, "Checked": true},\
                    {"Code": 200, "Checked": true},\
                    {"Code": 220, "Checked": true},\
                    {"Code": 280, "Checked": true},\
                    {"Code": 300, "Checked": true},\
                    {"Code": 560, "Checked": true},\
                    {"Code": 580, "Checked": true},\
                    {"Code": 600, "Checked": true},\
                    {"Code": 620, "Checked": true},\
                    {"Code": 680, "Checked": true},\
                    {"Code": 700, "Checked": true}]}}}'  #子帧设置

ExportLogfile = r'{"CMD": "ExportLogfile", "Param": {"TemplateName": "test", "ExportFileName": "C:\\e.csv", "Logfile": "C:\\t1.saf"}}'    #导出数据
dict_cmd = {'AutoCheck': AutoCheck,    #1
        'ConnectEQ': ConnectEQ,    #1
        'DisConnectEQ': DisConnectEQ,    #1
        'StartLog': StartLog,    #1
        'StopLog': StopLog,    #1
        'UpdateTask': UpdateTask,
        'StartTest': StartTest,    #1
        'StopTest': StopTest,    #1
        'PowerOff': PowerOff,    #1
        'PowerOn': PowerOn,    #0
        'Attach': Attach,    #0
        'Detach': Detach,    #0
        'GetParamMAC': GetParamMAC,
        'GetParamIMSI': GetParamIMSI,
        'SetSubFrame': SetSubFrame,
        'ExportLogfile': ExportLogfile}


def find_cmd(arg_in):
    if len(arg_in) == 1:
        try:
            cmd_send = eval(arg_in[0])
            print(cmd_send)
            return cmd_send
        except NameError:
            print('error: this cmd %s is not define' % arg_in[0])
    elif len(arg_in) == 2 and arg_in[1].isdigit():
        try:
            cmd_send = eval(arg_in[0])
            index = eval(arg_in[1])
            cmd_send = cmd_send.replace(cmd_send[-2], str(index))
            print(cmd_send)
            return cmd_send
        except NameError:
            print('error: this cmd %s %s is not define' % (arg_in[0], arg_in[1]))
    elif len(arg_in) == 3 and arg_in[0] == 'StartLog':
        print(arg_in)
        StartLog["Param"]["LogPath"] = arg_in[1]
        StartLog["Param"]["LogName"] = arg_in[2]
        cmd_send=str(StartLog)
        return cmd_send
    else:
        print('error: please input correct cmd')


def send_cmd_and_check_rcv(cmd_send):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        s.connect((host, port))
        cmd_send = cmd_send.encode('utf-8')
        s.send(cmd_send)
        rcv = s.recv(2048)
        s.close()
        return rcv
    except ConnectionRefusedError:
        print('connection refused, please check if host: %s and port: %s is correct' % (host, str(port)))
        return None
    # rcv = s.recv(1024)
    # print(rcv.decode('utf-8'))


if __name__ == '__main__':
    arg_in = sys.argv[1:]
    # arg_in = ["StartLog", "D:\\sparkLogfiles\\", "20200507_145207"]
    cmd_send = find_cmd(arg_in)
    if cmd_send is not None:
        output = send_cmd_and_check_rcv(cmd_send)
        if output is not None:
            print(output.decode('utf-8'))
        else:
            pass
