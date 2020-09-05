#ifndef POYOIO_H
#define POYOIO_H

// ハードウェアカウンタのアドレス指定
#define HARDWARE_COUNTER_ADDR (unsigned int*)0x20010

// 1msあたりにかかるサイクル数(周波数[Hz]/1000)を指定
//#define HARDWARE_COUNT_FOR_ONE_MSEC 45000
#define HARDWARE_COUNT_FOR_ONE_MSEC 100

// UART関係の設定
#define UART_TX_ADDR (unsigned int*)0x20020
#define UART_RX_ADDR (unsigned int*)0x20030
#define UART_RX_READ_EN_BIT 8

// GPIO関係の設定
#define GPI_ADDR (unsigned int*)0x20040
#define GPO_WRADDR (unsigned int*)0x20050
#define GPO_RDADDR (unsigned int*)0x20050

// バイアス関係の設定
#define CML_ADDR (unsigned int*)0x20060
#define HYS_ADDR (unsigned int*)0x20070

// poyoio.c
void digital_write(int pin, int vol);
int digital_read(int pin);
void cml_write(int pin, int vol);
int cml_read(int pin);
void hys_write(int pin, int vol);
int hys_read(int pin);
int serial_write_en();
void serial_write(unsigned char c);
int serial_read_en();
unsigned char serial_read();
void delay(unsigned int time);


#endif
