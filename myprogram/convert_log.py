# _*_ coding: utf-8 _*_
import re
import csv

def match_line_separate(string):
    pattern = r'(\-+\|){4,}'
    result = re.match(pattern, string)
    return result


if __name__ == '__main__':
    file_path = r'/home/PhyStats-c0.txt'
    new_file = r'/home/new_file.txt'
    f1 = open(file_path, newline='')
    fh = open(r'/home/head.txt', 'w', newline='')
    n = 0
    while 1:
        line = f1.readline()
        if not line:
            break
        result = match_line_separate(line)
        if result is None:
            fh.write(line)
        else:
            fh.close()
            break
    while True:
        line = f1.readline()
        if not line:
            break
        list_one_line = []
        while 1:
            result = match_line_separate(line)
            result1 = re.match(r'^\s+Slot\s+\|.*$', line)
            if result is None and result1 is None:
                list_one_line.append(line)
                line = f1.readline()
                if not line:
                    break
            else:
                print(list_one_line)
                break
    f1.close()
