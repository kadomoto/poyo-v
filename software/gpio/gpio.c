#include <poyoio.h>

int led[4] = {1, 1, 1, 1};

int main() {

    while(1){

        for (int i=0; i < 4; i++) {
            led[i] = digital_read(i);
            digital_write(i, led[i]);  
        }
        delay(1000);

    }

    return 0;

}
