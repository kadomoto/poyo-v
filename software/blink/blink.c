#include <poyoio.h>

int main() {

    while(1){

        digital_write(0, 1);
        digital_write(1, 0);
        digital_write(2, 1);
        digital_write(3, 0);
        delay(1000);
        digital_write(0, 0);
        digital_write(1, 1);
        digital_write(2, 0);
        digital_write(3, 1);
        delay(1000);

    }

    return 0;

}
