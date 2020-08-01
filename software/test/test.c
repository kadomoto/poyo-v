#include <poyoio.h>
#include <poyolib.h>


int main() {

    while(1){

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

        delay(3000);

        puts("Hello\n");

    }

    return 0;

}
