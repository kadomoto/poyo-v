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
        if i < 512:
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


if __name__ == "__main__":
    args = sys.argv
    if len(args) == 2:
        prog_file_name = args[1]
        code_file_name = "code.hex"
        data_file_name = "data.hex"
        split(prog_file_name)
    else:
        print("usage: python hexConverter.py <progFilename>")
        quit()
