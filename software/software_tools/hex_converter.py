# coding: UTF-8

import sys


# code.hexとdata.hexを分離
def split(file_name):
    f = open(file_name, 'r', encoding="UTF-8")
    line_list = f.readlines()

    line_list_0 = []
    line_list_1 = []

    for i, line in enumerate(line_list):
        byte_list = list(line)
        if i < 16384:
            line_list_0.append(''.join(byte_list))
        else:
            line_list_1.append(''.join(byte_list))

    f.close()

    f0 = open("code.hex", 'w', encoding="UTF-8")
    f0.writelines(line_list_0)
    f0.close()

    f1 = open("data.hex", 'w', encoding="UTF-8")
    f1.writelines(line_list_1)
    f1.close()


# code.hexを2ファイルへと分割
def code_split(file_name):
    f = open(file_name, 'r', encoding="UTF-8")
    line_list = f.readlines()

    line_list_0 = []
    
    for i, line in enumerate(line_list):
        byte_list = list(line)
        if i < 8192:
        else:
            line_list_0.append(''.join(byte_list))

    f.close()

    f0 = open("code32k.hex", 'w', encoding="UTF-8")
    f0.writelines(line_list_0)
    f0.close()


# data.hexを4ファイルへと分割
def data_split(file_name):
    f = open(file_name, 'r', encoding="UTF-8")
    line_list = f.readlines()

    line_list_0 = []
    line_list_1 = []
    line_list_2 = []
    line_list_3 = []

    for line in line_list:
        byte_list = list(line)
        line_list_0.append(''.join(byte_list[6:8]) + "\n")
        line_list_1.append(''.join(byte_list[4:6]) + "\n")
        line_list_2.append(''.join(byte_list[2:4]) + "\n")
        line_list_3.append(''.join(byte_list[0:2]) + "\n")

    f.close()

    f0 = open("data0.hex", 'w', encoding="UTF-8")
    f0.writelines(line_list_0)
    f0.close()

    f1 = open("data1.hex", 'w', encoding="UTF-8")
    f1.writelines(line_list_1)
    f1.close()

    f2 = open("data2.hex", 'w', encoding="UTF-8")
    f2.writelines(line_list_2)
    f2.close()

    f3 = open("data3.hex", 'w', encoding="UTF-8")
    f3.writelines(line_list_3)
    f3.close()


if __name__ == "__main__":
    args = sys.argv
    if len(args) == 2:
        prog_file_name = args[1]
        code_file_name = "code.hex"
        data_file_name = "data.hex"
        split(prog_file_name)
        code_split(code_file_name)
        data_split(data_file_name)

    else:
        print("usage: python hexConverter.py <progFilename>")
        quit()
