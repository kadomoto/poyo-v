#ifndef POYOIO_H
#define POYOIO_H

// ハードウェアカウンタのアドレス指定
#define HARDWARE_COUNTER_ADDR (int*)0x20010

// 1msあたりにかかるサイクル数(周波数[Hz]/1000)を指定
#define HARDWARE_COUNT_FOR_ONE_MSEC 45000

// UART関係の設定
#define UART_TX_ADDR (char*)0x20020
#define UART_TX_DELAY_TIME 1
#define UART_RX_ADDR (int*)0x20030

// GPIO関係の設定
#define GPI_ADDR (int*)0x20040
#define GPO_WRADDR (char*)0x20050
#define GPO_RDADDR (int*)0x20050

// poyoio.c
void digital_write(int pin, int vol);
int digital_read(int pin);
void serial_write(char c);
char serial_read();
void delay(unsigned int time);


#endif
