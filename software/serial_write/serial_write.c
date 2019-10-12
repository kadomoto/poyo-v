#include <poyoio.h>

int main() {

    while(1){

        serial_write('H');
        serial_write('E');

        for (int i=0; i < 2; i++) {
        	serial_write('L');
        }

        serial_write('O');

        serial_write('C');
        serial_write('Q');

        delay(3000);

    }

    return 0;

}
