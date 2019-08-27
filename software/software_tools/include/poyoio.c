#include <poyoio.h>


void digital_write(int pin, int vol) {

    volatile char* output_addr = GPO_WRADDR;
    volatile int* input_addr = GPO_RDADDR;

    switch (pin) {
	    case 0:
	        if (vol == 1) {
	        	*output_addr = (*input_addr | 0b0001);
	        } else if (vol == 0) {
	        	*output_addr = (*input_addr & 0b1110);
	        }
	        break;
	    case 1:
	        if (vol == 1) {
	        	*output_addr = (*input_addr | 0b0010);
	        } else if (vol == 0) {
	        	*output_addr = (*input_addr & 0b1101);
	        }
	        break;
	    case 2:
	        if (vol == 1) {
	        	*output_addr = (*input_addr | 0b0100);
	        } else if (vol == 0) {
	        	*output_addr = (*input_addr & 0b1011);
	        }
	        break;
	    case 3:
	        if (vol == 1) {
	        	*output_addr = (*input_addr | 0b1000);
	        } else if (vol == 0) {
	        	*output_addr = (*input_addr & 0b0111);
	        }
	        break;
	}

}


int digital_read(int pin) {

    volatile int* input_addr = GPI_ADDR;
    int vol;

    switch (pin) {
	    case 0:
	        vol = (*input_addr & 0b0001);
	        break;
	    case 1:
	        vol = (*input_addr & 0b0010);
	        break;
	    case 2:
	        vol = (*input_addr & 0b0100);
	        break;
	    case 3:
	        vol = (*input_addr & 0b1000);
	        break;
	}

	return vol;

}


void serial_write(char c) {
	
	delay(UART_TX_DELAY_TIME);

    volatile char* output_addr = UART_TX_ADDR;
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
