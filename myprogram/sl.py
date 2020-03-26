# _*_ coding: utf-8 _*_
from tkinter import *
import random
import time

def zuo_button(event):
    fx = root.winfo_x()
    fy = root.winfo_y()
    x = event.x_root-fx-7
    y = event.y_root-fy-TIME_HIGHT-30
    x = x//LABLE_LEN
    y = y//LABLE_LEN
    grids.zuo_button(y,x)
def you_buttton(event):
    fx = root.winfo_x()
    fy = root.winfo_y()
    x = event.x_root - fx - 7
    y = event.y_root - fy - TIME_HIGHT - 30
    x = x // LABLE_LEN
    y = y // LABLE_LEN
    grids.you_button(y, x)
    pass
def newgame():
    grids.newgame()
    global time_start
    time_start = time.time()
def update_clock():
    end_time = time.time()
    t = round(end_time-time_start)
    global grids
    if grids.flag==0:
        time_var.set(t)
    root.after(1000, update_clock)
class Grids:
    flag = 0
    num_zhadan = 70
    num_all = 30*15
    num_kai = 0
    num = [] #01,2,3,4,5,6,7,8, 10表示炸弹
    stats=[] #0没有1棋子2问号3打开
    str=["","🚩","❓"]
    lables = []
    num_var = []
    game_frame=None
    def produce(self):#随机生成炸弹
        self.zhadans = random.sample(range(0, 30*15-1), self.num_zhadan)
        for zhadan in self.zhadans:
            i = zhadan//30
            j = zhadan%30
            self.num[zhadan]=10
    def count(self):#计算周围炸弹
        self.fix = [(-1,-1),(0,-1),(1,-1),(-1,0),(1,0),(-1,1),(0,1),(1,1)]#八个方向
        for i in range(15):
            for j in range(30):
                if self.num[i*30+j]==10:
                    continue
                for f in self.fix:
                    li, lj = f
                    lx = i-li
                    ly = j-lj
                    if 0<=lx<=14 and 0<=ly<=29 and self.num[lx*30+ly]==10:
                        self.num[i * 30 + j] = self.num[i * 30 + j]+1
        pass
    def newgame(self):
        for i in range(15):
            for j in range(30):
                self.num[i*30+j]=0
                self.stats[i*30+j]=0
                self.num_var[i*30+j].set('')
                self.lables[i*30+j].configure(bg='yellow')
                self.flag = 0
                self.num_kai = 0
        self.produce()
        self.count()
        pass
    def showzhadan(self):
        for zhadan in self.zhadans:
            self.num_var[zhadan].set('💣')
        pass
    def draw(self,i,j):
        if not(0<=i<=14 and 0<=j<=29) or self.stats[i*30+j]==3:#越界
            return
        elif 0<self.num[i*30+j]<10:#数字
            self.num_var[i*30+j].set(self.num[i*30+j])
            self.lables[i*30+j].configure(bg='white')
            self.stats[i * 30 + j] = 3
            self.num_kai = self.num_kai + 1
            print(self.num_kai)
            if self.num_kai >= self.num_all - self.num_zhadan:
                self.flag = 1
                time_var.set('你赢了！！')
        else:
            self.num_var[i * 30 + j].set('')
            self.lables[i * 30 + j].configure(bg='white')
            self.stats[i * 30 + j] = 3
            for f in self.fix:
                li, lj = f
                lx = i - li
                ly = j - lj
                self.draw(lx,ly)
            self.num_kai = self.num_kai + 1
            print(self.num_kai)
            if self.num_kai >= self.num_all - self.num_zhadan:
                self.flag = 1
                time_var.set('你赢了！！')
    def drawqizi(self,i,j):
        count = 0
        for f in self.fix:
            li, lj = f
            lx = i - li
            ly = j - lj
            if 0 <= lx <= 14 and 0 <= ly <= 29 and self.stats[lx * 30 + ly] == 1:
                count = count+1
        if count==self.num[i*30+j]:
            print('kai')
            #打开八个方向除了插了🚩的格子
            for f in self.fix:
               li, lj = f
               lx = i - li
               ly = j - lj
               if 0 <= lx <= 14 and 0 <= ly <= 29 and self.stats[lx * 30 + ly] != 1 and self.stats[lx * 30 + ly] != 3:#状态不是🚩的话就开
                   if self.num[lx*30+ly]==10:#开到炸弹游戏结束
                        self.flag=1
                        time_var.set('踩雷了！！')
                        self.showzhadan()
                        return
                   else:
                       # self.num_var[lx * 30 + ly].set(self.num[lx * 30 + ly])
                       # self.lables[lx * 30 + ly].configure(bg='white')
                       # self.stats[lx * 30 + ly] = 3
                       # self.num_kai = self.num_kai + 1
                       # print(self.num_kai)
                       # if self.num_kai >= self.num_all - self.num_zhadan:
                       #     self.flag = 1
                       #     time_var.set('你赢了！！')
                        self.draw(lx,ly)
    def zuo_button(self,i,j):
        if self.flag==1:
            return
        #判断界限,或结束游戏,或已经开牌
        if not(0<=i<=14 and 0<=j<=29) :
            return
        if self.stats[i*30+j]==3:
            #开牌了的话，计算周围棋子数，棋子数与数字一样则打开这个棋子周围全部
            if self.num[i*30+j]==0:
                return
            else:self.drawqizi(i,j)
        if self.num[i*30+j]==10:#翻到炸弹
            print('炸弹')
            self.flag=1
            self.showzhadan()
            return
        else:
            self.draw(i,j)
        pass

    def you_button(self,i,j):
        if self.stats[i*30+j]!=3:
            self.stats[i*30+j] = (self.stats[i*30+j]+1)%3
            self.num_var[i*30+j].set(self.str[self.stats[i*30+j]])
        pass

    def __init__(self,game_frame,LABLE_LEN):
        self.game_frame = game_frame
        for i in range(15):
            for j in range(30):
                var = StringVar()
                var.set('')
                self.num.append(0)
                self.num_var.append(var)
                self.stats.append(0)
                la = Label(game_frame,height=LABLE_LEN,width=LABLE_LEN,borderwidth=1,relief='ridge',textvariable=var)
                la.place(x=j*LABLE_LEN,y=i*LABLE_LEN,width=LABLE_LEN, height=LABLE_LEN)
                la.bind("<Button-1>", zuo_button)
                la.bind("<Button-3>", you_buttton)
                self.lables.append(la)
        self.newgame()

"""
    设置界面大小参数
"""
LABLE_LEN = 30  #格子大小
LABLE_cow = 15  #各自多少行
LABLE_lis = 30  #格子多少列
TIME_HIGHT = 40 #按钮和时间的高度
MAIN_WEIGHT = LABLE_lis*LABLE_LEN#主界面大小
MAIN_HIGHT = LABLE_cow*LABLE_LEN+TIME_HIGHT
GAME_HIGHT=LABLE_cow*LABLE_LEN
#1.定义主界面
root = Tk()
root.minsize(MAIN_WEIGHT, MAIN_HIGHT)  # 最小尺寸
root.maxsize(MAIN_WEIGHT, MAIN_HIGHT)  # 最大尺寸
#2.定义游戏设置界面:开始按钮，结束按钮，时间
setframe = Frame(root,height=TIME_HIGHT,width=MAIN_WEIGHT)
setframe.grid_location(0,0)
setframe.pack()
#2.1开始游戏按钮
newgame_button = Button(setframe,text= '新游戏',fg= 'blue',command=newgame)#事件尚未添加
newgame_button.grid(row=0,column=0,padx=10,pady=5)
#2.2游戏时间
time_start=time.time()
time_var = StringVar()
time_var.set('')
time_lable = Label(setframe,textvariable=time_var,width=50)
time_lable.grid(row=0,column=1,padx=10,pady=5)
#2.3退出按钮
quit_buttton = Button(setframe,text= '退出游戏',fg= 'blue',command=quit)
quit_buttton.grid(row=0,column=2,padx=10,pady=5)
#3游戏界面
game_frame = Frame(root,width=MAIN_WEIGHT,height=GAME_HIGHT)
game_frame.place(x=0,y=TIME_HIGHT)
grids = Grids(game_frame=game_frame,LABLE_LEN=LABLE_LEN)
update_clock()
root.mainloop()