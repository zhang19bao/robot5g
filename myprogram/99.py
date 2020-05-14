# _*_ coding: utf-8 _*_
def fact(n):  #递归
    if n == 1:
        return n
    else:
        return n*fact(n-1)


def fact1(n):
    return fact_inter(n, 1)


def fact_inter(num, p):  #尾递归
    if num == 1:
        return p
    return fact_inter(num-1, p*num)

def mutiplication_table():
    i = 1
    j = 1
    while i < 10:
        while 1:
            if j <= i:
                print('%d*%d=%d ' % (i, j, i*j), end='')
                j += 1
            else:
                break
        print('')
        j = 1
        i += 1


if __name__ == '__main__':
    mutiplication_table()

