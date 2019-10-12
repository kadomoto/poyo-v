#
# Makefile for c code
#

# 共通初期設定ファイルをインクルード
include ../software_tools/Makefile.inc

# C言語ソースコードファイルを指定
SRC = blink.c

SRCS = $(SRC) $(INCLUDE_ROOT)/poyoio.c
OBJS = $(SRCS:.c=.o)


all: code.hex data.hex data0.hex data1.hex data2.hex data3.hex

# オブジェクトファイル生成
%.o: %.c Makefile
	$(CC) $(CFLAGS) -o $@ -c $<

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
	rm $(OBJS) code.hex data.hex data0.hex data1.hex data2.hex data3.hex app.hex app.dump app.bin app.elf crt0.o -f
