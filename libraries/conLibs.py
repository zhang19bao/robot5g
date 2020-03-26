import paramiko
import telnetlib
import os
import re
import time
import socket
import signal
# from memory_profiler import profile
# @profile(precision=4)
# @profile
keep_ssh_dict={}
keep_ssh_channel_dict={}
ssh_count=0
monitor_log_path="/home/ute/main_alarm_monitor/alarm_monitor.log"
def logging(*str_log):
    try:
        strloging=""
        for i in str_log:
            strloging=strloging+" "+str(i)
        # print(strloging)
        with open(monitor_log_path,"a+") as log:
           log.writelines([strloging,"\r\n"])
    except:
        pass
def pingable_ip_check(ip,port=22):
    try:
        s=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
        s.settimeout(1)
        s.connect((ip,port))
        s.shutdown(2)
        return True
    except Exception as e:
        logging("pingable_ip_check error:",e)
        return False
    finally:
        s.close()
# @profile
def keep_ssh2(ip, username, passwd, cmd, port=22, timeout=3,separator=""):
    output = ""
    global keep_ssh_channel_dict
    global ssh_count
    keep_ssh_name = "keep_ssh_channel_{}".format(ip)
    if not isinstance(cmd,list):
        raise Exception("cmd must be list")
    try:
        pre_check = pingable_ip_check(ip)
        if pre_check:
            if keep_ssh_name in keep_ssh_channel_dict.keys() and keep_ssh_channel_dict[keep_ssh_name][1] and keep_ssh_channel_dict[keep_ssh_name][1]:
                ssh=keep_ssh_channel_dict[keep_ssh_name][0]
                channel=keep_ssh_channel_dict[keep_ssh_name][1]
            else:
                ssh_count += 1
                logging("create new keep ssh for:{},SN:{}".format(ip,ssh_count))
                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                if os.path.isfile(passwd):
                    ssh.connect(ip, port, username, password='',key_filename=passwd, timeout=timeout,banner_timeout=timeout)
                else:
                    ssh.connect(ip, port, username, password=passwd, timeout=timeout,banner_timeout=timeout)
                channel=ssh.invoke_shell()
        else:
            if keep_ssh_name in keep_ssh_channel_dict.keys():
                try:
                    keep_ssh_channel_dict[keep_ssh_name][0].close()
                    ssh_count -= 1
                except:
                    pass
                keep_ssh_channel_dict.pop(keep_ssh_name)
            logging("ssh {} ping failed now".format(ip))
            return False, output
        exec ("keep_ssh_channel_dict['{}']=[ssh,channel]".format(keep_ssh_name))
        for m in cmd:
            channel.send("{}\n".format(m))
            time.sleep(0.1)
            output = output + separator + str(channel.recv(65536))
        return True, output
    except Exception as e:
        try:
            ssh.close()
            ssh_count -= 1
        except:
            pass
        logging("keep ssh2 error:",e)
        if keep_ssh_name in keep_ssh_channel_dict.keys():
            keep_ssh_channel_dict.pop(keep_ssh_name)
            ssh_count -= 1
        return False, output
# @profile
def ssh2(ip, username, passwd, cmd, port=22, channel=False,timeout=3,separator="",output_flag=False,for_quick=False):
    output = ""
    global ssh_count
    if not isinstance(cmd,list):
        raise Exception("cmd must be list")
    try:
        if for_quick==True:
            pre_check = os.system("ping {} -c 2 -w 300 >/dev/null 2>&1".format(ip))
            pre_check = eval("not {}".format(pre_check))
        else:
            pre_check = pingable_ip_check(ip)
        if pre_check:
            ssh_count += 1
            logging("create new ssh for:{},SN:{}".format(ip,ssh_count))
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            if os.path.isfile(passwd):
                ssh.connect(ip, port, username, password='',key_filename=passwd, timeout=timeout,banner_timeout=timeout)
            else:
                ssh.connect(ip, port, username, password=passwd, timeout=timeout,banner_timeout=timeout)
        else:
            logging("ssh {} ping failed now".format(ip))
            return False, output
        if channel == True:
            transport = ssh.get_transport()
            channel = transport.open_session()
            channel.get_pty()
            for m in cmd:
                channel.exec_command(m)
                timeout = 2
                while timeout >= 0:
                    if channel.exit_status_ready():
                        break
                    else:
                        time.sleep(0.1)
                        timeout -= 0.1
                output = output + '\n' + str(channel.recv(65536))
            channel.close()
        else:
            for m in cmd:
                stdin, stdout, stderr = ssh.exec_command(m,bufsize=0,get_pty=True,timeout=timeout)
                if output_flag==False:
                    for line in stdout.readlines():
                        output = output+separator+str(line)
        return True, output
    except Exception as e:
        logging("ssh2 error:",e)
        return False, output
    finally:
        try:
            ssh.close()
            ssh_count -= 1
        except:
            pass
def local_telnet(ip, tn_port, cmd, pass_regexp,timeout=2):
    output = 'Telnet server:%s,port:%s,cmd:%s,pass_regexp:%s' % (ip, tn_port, cmd, pass_regexp)
    if not isinstance(cmd,list):
        raise Exception("cmd must be list")
    # if not os.system("ping {} -c 2 -w 300 >/dev/null 2>&1".format(ip)):
    if pingable_ip_check(ip):
        try:
            tn = telnetlib.Telnet(ip, tn_port, timeout)
            tmp1 = tn.read_until(pass_regexp, timeout = timeout)
            if tmp1=="":
                return None,None
            for command in cmd:
                tn.write('%s\n' % (command))
            tmp2 = tn.read_until(pass_regexp, timeout = timeout)
            output = output + str(tmp2)
            if tmp2 != "":
                return True, output
            else:
                return None,None
        except:
            return False, output
        finally:
            tn.close()
            pass
    else:
        logging("telnet {} ping failed now".format(ip))
        return None,None
# @profile
def sftp_down_file(ip, username, passwd,remote_path, file_name_regexp,local_path,port=22,timeout=20):
    try:
        t = paramiko.Transport((ip, port))
        t.connect(username=username, password=passwd)
        sftp = paramiko.SFTPClient.from_transport(t)
        files_list=[]
        for filename in sftp.listdir(remote_path):
            # logging(file_name_regexp,filename)
            if re.match(file_name_regexp,filename,re.I):
                files_list.append(filename)
        logging("start sftp downloading")
        for filename in files_list:
            sftp.get(os.path.join(remote_path, filename), os.path.join(local_path, filename))
            sftp.remove(os.path.join(remote_path, filename))

    except Exception as e:
        print ("sftp_down_file",e)
    finally:
        t.close()
        pass
def ssh_sftp_get_files(ip, username, passwd, ssh_cmd,sftp_paths, port=22,timeout=3,separator="",output_flag=False,for_quick=False):
    output = ""
    global ssh_count
    try:
        if for_quick==True:
            pre_check = os.system("ping {} -c 2 -w 300 >/dev/null 2>&1".format(ip))
            pre_check = eval("not {}".format(pre_check))
        else:
            pre_check = pingable_ip_check(ip)
        if pre_check:
            ssh_count += 1
            logging("create new ssh for:{},SN:{}".format(ip,ssh_count))
            ssh = paramiko.SSHClient()
            ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            if os.path.isfile(passwd):
                ssh.connect(ip, port, username, password='',key_filename=passwd, timeout=timeout,banner_timeout=timeout)
            else:
                ssh.connect(ip, port, username, password=passwd, timeout=timeout,banner_timeout=timeout)
        else:
            logging("ssh {} ping failed now".format(ip))
            return False, output
        sftp = ssh.open_sftp()
        for m in ssh_cmd:
            stdin, stdout, stderr = ssh.exec_command(m,bufsize=0,get_pty=True,timeout=timeout)
            if output_flag==False:
                for line in stdout.readlines():
                    output = output+separator+str(line)
        try:
            logging("start sftp downloading")
            for path in sftp_paths:
                sftp.get(path[0],path[1])
        except Exception as e:
            print(e)
        return True, output
    except Exception as e:
        logging("ssh2 sftp error:",e)
        return False, output
    finally:
        try:
            sftp.close()
        except:
            pass
        try:
            ssh.close()
            ssh_count -= 1
        except:
            pass

if __name__=="__main__":
    result=ssh_sftp_get_files('192.168.129.38', "root", "/home/ute/.ssh/id_rsa", ["tar -cpf /tmp/LSP2_K2C_tmp.tar /tmp","tar -cpf /tmp/LSP2_K2C_var.tar /var"], [["/tmp/LSP2_K2C_tmp.tar","/home/ute/main_alarm_monitor/LSP2_K2C_tmp.tar"],["/tmp/LSP2_K2C_var.tar","/home/ute/main_alarm_monitor/LSP2_K2C_var.tar"]], port=22, timeout=3, separator="", output_flag=False,for_quick=False)
    print(result)



