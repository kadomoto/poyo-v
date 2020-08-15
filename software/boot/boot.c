#include <poyoio.h>
#include <poyolib.h>
#include <xmodem.h>


static int init(void) {
    extern int _rodata_end, _data_start, _data_end;

    memcpy(&_data_start, &_rodata_end, (long)&_data_end - (long)&_data_start);

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
        } else if (!strcmp(buf, "run")) {
            puts("start\n");
            f = (void (*)(void))(char *)(&_rom_start);
            f();
        } else if (!strcmp(buf, "screenfetch")) {
            puts(" ##   ##  ######   ####\n");
            puts(" ### ###  # ## #    ##\n");
            puts(" #######    ##      ##\n");
            puts(" #######    ##      ##\n");
            puts(" ## # ##    ##      ##   #\n");
            puts(" ##   ##    ##      ##  ##\n");
            puts(" ##   ##   ####    #######\n");
        } else {
            puts("unknown.\n");
        }
    }

    return 0;
}
