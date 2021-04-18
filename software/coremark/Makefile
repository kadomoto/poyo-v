#
# Makefile for Coremark
#

# 共通初期設定ファイルをインクルード
include ../software_tools/Makefile.inc

# Coremark用の設定
# 実行回数を指定(0の場合は自動算出)
ITERATIONS = 0
# 周波数[Hz]を指定
CLOCKS_PER_SEC = 45000000
# 最適化フラグを指定
FLAGS_STR = "-O3"

# C言語ソースコードファイルを指定
SRC = \
	core_list_join.c \
	core_main.c \
	core_matrix.c \
	core_state.c \
	core_util.c \

BAREBONES_ROOT = barebones
BAREBONES_SRC = \
	$(BAREBONES_ROOT)/core_portme.c \
	$(BAREBONES_ROOT)/ee_printf.c \

SRCS = $(SRC) $(BAREBONES_SRC)
OBJS = $(SRCS:.c=.o)

XCFLAGS = \
	-g \
	-DITERATIONS=$(ITERATIONS) \
	-DCLOCKS_PER_SEC=$(CLOCKS_PER_SEC) \
	-I ./ \
	-I $(BAREBONES_ROOT) \
	-DFLAGS_STR=\"$(FLAGS_STR)\" \


all: code.hex data.hex data0.hex data1.hex data2.hex data3.hex

# オブジェクトファイル生成
%.o: %.c Makefile
	$(CC) $(CFLAGS) $(XCFLAGS) -o $@ -c $<

# 下記はアセンブリコードを入力する場合の例
#%.o: %.s Makefile
#	$(CC) $(CFLAGS) -o $@ -c $<

# ELFファイル生成
app.elf: $(OBJS) $(CRTOBJ) Makefile
	$(LD) $(CRTOBJ) $(OBJS) $(LIBC) $(LIBGCC) -T$(LDSCRIPT) $(LDFLAGS) -o app.elf

# バイナリファイル生成
app.bin: app.elf
	$(OBJDUMP) -D $< > app.dump
	$(OBJCOPY) -O binary $< $@

# バイナリファイルから.hex形式ファイルを生成
app.hex: app.bin
	hexdump -v -e '1/4 "%08x" "\n"' $< > app_im.hex
	cat $(MEM_INIT) app_im.hex > $@
	rm -f app_im.hex

# .hex形式ファイルを命令メモリ用ファイルとデータメモリ用ファイルへと分割
code.hex data.hex: app.hex
	$(HEX_CONVERTER) $<


.PHONY: clean
clean:
	rm $(OBJS) code.hex code32k.hex data.hex data0.hex data1.hex data2.hex data3.hex app.hex app.dump app.bin app.elf crt0.o -f
