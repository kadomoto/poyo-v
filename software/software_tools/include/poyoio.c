#include <poyoio.h>


void digital_write(int pin, int vol) {

    volatile char* output_addr = GPO_WRADDR;
    volatile int* input_addr = GPO_RDADDR;

    // 0ビット目は0ピンの状態、1ビット目は1ピンの状態というように値を格納しているので、
    // ピンの値に応じたビットのみを変更する
    if (vol == 1) {
        *output_addr = (*input_addr | (1 << pin));
    } else if (vol == 0) {
        *output_addr = (*input_addr & ~(1 << pin));
    }
}


int digital_read(int pin) {

    volatile int* input_addr = GPI_ADDR;
    int vol;

    // 0ビット目は0ピンの状態、1ビット目は1ピンの状態というように値を格納しているので、
    // ピンの値に応じて特定ビットを読み出す
    vol = (*input_addr >> pin) & 1;

    return vol;
}


void serial_write(char c) {

    volatile char* output_addr = UART_TX_ADDR;

    delay(UART_TX_DELAY_TIME);
    *output_addr = c;
}


char serial_read() {
    
    volatile int* input_addr = UART_RX_ADDR;
    char c;

    c = *input_addr;
    
    return c;
}


void delay(unsigned int time) {
    
    volatile unsigned int* input_addr = HARDWARE_COUNTER_ADDR;
    unsigned int start_cycle = *input_addr;

    while (time > 0) {
        while ((*input_addr - start_cycle) >= HARDWARE_COUNT_FOR_ONE_MSEC) {
            time--;
            start_cycle += HARDWARE_COUNT_FOR_ONE_MSEC;
        }
        if (*input_addr < start_cycle) {
            start_cycle = *input_addr;
        }
    }
}
