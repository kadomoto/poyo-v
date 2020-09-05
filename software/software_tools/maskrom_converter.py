# coding: UTF-8

import sys


# 変換
def conv(file_name):
    f = open(file_name, 'r', encoding="UTF-8")
    line_list = f.readlines()

    line_list_0 = []

    for i, line in enumerate(line_list):
        byte_list = list(line)
        line_list_0.append("assign mem[" + str(i) + "] = 32'h" + ''.join(byte_list).rstrip('\n') + ";\n")

    f.close()

    f0 = open("conv.hex", 'w', encoding="UTF-8")
    f0.writelines(line_list_0)
    f0.close()


if __name__ == "__main__":
    args = sys.argv
    if len(args) == 2:
        file_name = args[1]
        conv(file_name)
    else:
        print("usage: python hexConverter.py <progFilename>")
        quit()
