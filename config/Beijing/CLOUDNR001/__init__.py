from env_config import E500
env = E500(
    nbType="5gnr",
    tlType="e500",
    tmaPcIp="172.21.6.60",
    tmaLocalIp= "192.168.10.100",
    # tmaExePath=r"C:\Program Files (x86)\Aeroflex\TM500\5G NR - NLA 4.11.0\Test Mobile Application\TMA.exe",
    tmaExePath=r"C:\Program Files (x86)\Aeroflex\TM500\5G NR - NLA 4.17.0\Test Mobile Application\TMA.exe",
    # Don't allow space in user name
    tmaAddParam='/u E500 /c y /p 5003 /l n /a y /ea y /pa',
    tm500Ip= "192.168.10.70",
    tm500SerialPort= "COM3",
    tm500SerialBaudrate= "115200",
    tmaAcPort= "5030",
    # Must same with tmaAddParam port
    tmaEcPort= "5003",
    bbs1Ip= "192.168.10.30",
    bbs1Port= "23",
    bbs2Ip= "192.168.10.31",
    bbs2Port= "23",
    hlsIp= "192.168.10.70",
    hlsPort= "23",
    srioIp="192.168.10.9",
    srioUser= "tm500",
    srioGroups="AllUnitsPresent",
    srioPasswd= "",
)









