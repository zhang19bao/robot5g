#!/usr/local/bin/python3

'send udp packet no sleep'

import socket
import os
import sys

if __name__=='__main__':
    args = sys.argv
    if len(args) != 4:
        print("usage: python send_udp_no_sleep.py ip port packet_size")
        os._exit(0)

    port = int(args[2])
    packet_size = int(args[3])
    ori_str = "udp packet"
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    i = 0
    while True:
        order_str = "%s %d !" % (ori_str, i)
        pad_str = ''
        pad_str = pad_str.zfill(packet_size - len(order_str))
        send_str = "%s%s" % (order_str, pad_str)
        ret = s.sendto(send_str.encode('utf-8'), (args[1], port))
        if ret < 0:
            print("sendto failed")
        i += 1
