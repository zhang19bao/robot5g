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


if __name__ == '__main__':
    y = fact1(5)
    print(y)
