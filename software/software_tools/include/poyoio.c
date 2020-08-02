#include <poyoio.h>


void digital_write(int pin, int vol) {
    volatile int* output_addr = GPO_WRADDR;
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


int serial_write_en() {
    volatile int* input_addr = UART_TX_ADDR;
    return (1 - *input_addr);
}


void serial_write(unsigned char c) {
    volatile int* output_addr = UART_TX_ADDR;
    //delay(UART_TX_DELAY_TIME);
    while (!serial_write_en()) {
        ;
    }
    *output_addr = c;
}


int serial_read_en() {
    volatile int* input_addr = UART_RX_ADDR;
    return (*input_addr >> 8) & 1;
}


char serial_read() {
    volatile int* input_addr = UART_RX_ADDR;
    volatile int* output_addr = UART_RX_ADDR;
    char c;
    while (!serial_read_en()) {
        ;
    }
    c = *input_addr;
    *output_addr = 1;
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
