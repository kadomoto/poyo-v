#include <poyoio.h>

char c;

int main() {

    while(1){

        c = serial_read();
        delay(1000);
        serial_write(c);
        delay(1000);

    }

    return 0;

}
