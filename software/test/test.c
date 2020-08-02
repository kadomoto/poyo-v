#include <poyoio.h>
#include <poyolib.h>


int main() {

    serial_write('H');
    serial_write('E');
    serial_write('L');
    serial_write('L');
    serial_write('O');

    for (int i=0; i < 2; i++) {
        serial_write('P');
        serial_write('O');
        serial_write('Y');
        serial_write('O');
    }

    puts("\n\n")

    while(1){
        puts("Press any key\n");
        char c;
        c = serial_read();
        putc(c);
        puts("\n\n")
    }

    return 0;
}
