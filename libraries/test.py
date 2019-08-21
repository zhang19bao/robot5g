import logging
import telnetlib
import time
class TelnetClient():
    def __init__(self,):
        self.tn = telnetlib.Telnet()
    def login_host(self,host_ip,username,password):
        try:
            # self.tn = telnetlib.Telnet(host_ip,port=23)
            self.tn.open(host_ip,port=23)
            print("connect ok")
        except:
            logging.warning('%sconnect fail'%host_ip)
            return False
        self.tn.read_until(b'login: ',timeout=20)
        self.tn.write(username.encode('ascii') + b'\n')
        self.tn.read_until(b'Password: ',timeout=10)
        self.tn.write(password.encode('ascii') + b'\n')
        time.sleep(2)
        command_result = self.tn.read_very_eager().decode('ascii')
        if 'Login incorrect' not in command_result:
            logging.warning('%slogin ok'%host_ip)
            return True
        else:
            logging.warning('%slogin fail'%host_ip)
            return False
    def execute_some_command(self,command):
        self.tn.write(command.encode('ascii')+b'\n')
        time.sleep(2)
        command_result = self.tn.read_very_eager().decode('ascii')
        logging.warning('%sresult\n%s' % command_result)
    def logout_host(self):
        self.tn.write(b"exit\n")
if __name__ == '__main__':
    host_ip = '192.168.10.31'
    username = 'root'
    password = '123456'
    command = 'whoami'
    telnet_client = TelnetClient()
    if telnet_client.login_host(host_ip,username,password):
        telnet_client.execute_some_command(command)
        telnet_client.logout_host()