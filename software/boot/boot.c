#include <poyoio.h>
#include <poyolib.h>
#include <xmodem.h>


static int init(void) {
    //extern int erodata, data_start, edata, bss_start, ebss;
    extern int _rodata_end, _data_start, _data_end;

    //memcpy(&data_start, &erodata, (long)&edata - (long)&data_start);
    memcpy(&_data_start, &_rodata_end, (long)&_data_end - (long)&_data_start);

    return 0;
}


static int dump(char *buf, long size) {
    long i;

    if (size < 0) {
        puts("no data.\n");
        return -1;
    }
    for (i = 0; i < size; i++) {
        putxval(buf[i], 2);
        if ((i & 0xf) == 15) {
            puts("\n");
        } else {
            if ((i & 0xf) == 7) puts(" ");
            puts(" ");
        }
    }
    puts("\n");

    return 0;
}


int main() {
    static char buf[16];
    static long size = -1;
    static unsigned char *entry_point = ((void *)0);
    extern int _rom_start;
    void (*f)(void);

    init();

    while (1) {
        puts("root# ");
        gets(buf);

        if (!strcmp(buf, "load")) {
            entry_point = (char *)(&_rom_start);
            size = xmodem_recv(entry_point);
            if (size < 0) {
	            puts("\nXMODEM transfer error!\n");
            } else {
	            puts("\nXMODEM transfer complete\n");
            }
        // } else if (!strcmp(buf, "dump")) {
        //     puts("size: ");
        //     putxval(size, 0);
        //     puts("\n");
        //     dump(loadbuf, size);
        } else if (!strcmp(buf, "run")) {
            puts("start\n");
            f = (void (*f)(void))entry_point;
            f();
        } else if (!strcmp(buf, "screenfetch")) {
            puts(" ######    #####   ##  ##    #####\n");
            puts("  ##  ##  ##   ##  ##  ##   ##   ##\n");
            puts("  ##  ##  ##   ##  ##  ##   ##   ##\n");
            puts("  #####   ##   ##   ####    ##   ##\n");
            puts("  ##      ##   ##    ##     ##   ##\n");
            puts("  ##      ##   ##    ##     ##   ##\n");
            puts(" ####      #####    ####     #####\n");
        } else {
            puts("unknown.\n");
        }
    }

    return 0;
}
