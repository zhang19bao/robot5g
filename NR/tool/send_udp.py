#!/usr/local/bin/python3

'send udp packet'

import socket
import os
import sys
import time

def create_socket():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

if __name__=='__main__':
    args = sys.argv
    if len(args) < 5:
        for i in range(len(args)):
            print(args[i])
        print("usage: send_udp.py ip port packet_num packet_size send_rate")
        os._exit(0)

    port = int(args[2])
    packet_num = int(args[3])
    packet_size = int(args[4])
    if len(args) == 6:
        rate_unit = args[5][-1:]
        if rate_unit == 'k' or rate_unit == 'K':
            packet_rate = int(args[5][:-1]) * 1024
        elif rate_unit == 'm' or rate_unit == 'M':
            packet_rate = int(args[5][:-1]) * 1024 * 1024
        else:
            packet_rate = int(args[5])
        sleep_time = packet_size * 8 / packet_rate
        npacket = packet_rate // (packet_size * 80) + 1
        print('packet_rate=%d, rate_unit=%s, npacket=%d' % (packet_rate, rate_unit, npacket))
    else:
        sleep_time = 1
        npacket = 1
        print('npacket=1')

    ori_str = "udp packet"
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    start_time = time.time()
    num = 0
    temp_sleep = sleep_time
    for i in range(packet_num):
        if num == 0:
            loop_time_start = time.time()
        order_str = "%s %d !" % (ori_str, i)
        pad_str = ''
        pad_str = pad_str.zfill(packet_size - len(order_str))
        send_str = "%s%s" % (order_str, pad_str)
        ret = s.sendto(send_str.encode('utf-8'), (args[1], port))
        if ret == -1:
            print("sendto failed")
        num = num+1
        #print("send udp packet: %d" % (i))
        if num == npacket:
            num = 0
            loop_time_end = time.time()
            if loop_time_end - loop_time_start < 0.1:
                time.sleep(0.1 - (loop_time_end - loop_time_start))
        #if (temp_sleep != 0):
        #    time.sleep(temp_sleep)
        
        # if sleep_time < (loop_time_end - loop_time_start):
        #     temp_sleep = sleep_time - (loop_time_end - loop_time_start - sleep_time)
        #     if temp_sleep < 0:
        #         temp_sleep = 0
        # else:
        #     temp_sleep = sleep_time


    end_time = time.time()
    print('send all packet.time=%f' % (end_time-start_time))
