#
# Makefile.inc
#

# リポジトリのルートディレクトリの場所を環境に合わせて指定(要変更)
PROJECT_ROOT = $(HOME)/Git/poyo-v

# GCCのインストールパスを環境に合わせて指定(要変更)
GCC_DIR = /opt/riscv

# GCCのバージョンを環境に合わせて指定(要変更)
GCC_VERSION = 10.2.0

# 各種ファイルの場所を指定
TEST_CODE_ROOT = .
TOOLS_ROOT = $(PROJECT_ROOT)/software/software_tools
INCLUDE_ROOT = $(TOOLS_ROOT)/include

# GCCの設定
GCC_PREFIX = riscv32-unknown-elf-
GCC_TOOLS = $(GCC_DIR)/bin

CC = $(GCC_TOOLS)/$(GCC_PREFIX)gcc
AS = $(GCC_TOOLS)/$(GCC_PREFIX)as
LD = $(GCC_TOOLS)/$(GCC_PREFIX)ld
OBJCOPY = $(GCC_TOOLS)/$(GCC_PREFIX)objcopy
OBJDUMP = $(GCC_TOOLS)/$(GCC_PREFIX)objdump


CFLAGS = \
	-g \
	-O3 \
	-fno-zero-initialized-in-bss \
	-ffreestanding \
	-fno-builtin \
	-nostdlib \
	-nodefaultlibs \
	-nostartfiles \
	-mstrict-align \
	-I $(INCLUDE_ROOT) \
	-march=rv32i \

#-march=rv32im \
#-mno-div \


LDFLAGS= \
	-static \

LIBC =
LIBGCC = \
	-L $(GCC_DIR)/lib/gcc/riscv32-unknown-elf/$(GCC_VERSION) \
	-lgcc \
	-lgcov \
	-L $(GCC_DIR)/riscv32-unknown-elf/lib \
	-lm \


# スタートアップルーチンとリンカスクリプトの指定
CRTASM = $(TOOLS_ROOT)/crt0.s
CRTOBJ = $(TEST_CODE_ROOT)/crt0.o
LDSCRIPT = $(TOOLS_ROOT)/ld.script

$(CRTOBJ): $(CRTASM)
	$(CC) $(CFLAGS) -o $@ -c $<


# 下位Makefileを正常動作させるための変数定義
.DEFAULT_GOAL =

# メモリ初期化用ファイルの指定
MEM_INIT = $(TOOLS_ROOT)/mem_init.hex

# .hex形式ファイル生成ツールの指定
HEX_CONVERTER = \
	python3 $(TOOLS_ROOT)/hex_converter.py
