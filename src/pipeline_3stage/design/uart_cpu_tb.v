//
// uart_cpu_tb
//


module uart_cpu_tb;

    reg clk;
    reg rst;

    // cpu0
    wire [3:0] gpio_data_out_0;
    wire uart_tx_0;
    wire uart_rx_0;
    
    wire [15:0] imem_addr_0;
    wire [31:0] imem_rd_data_0;

    // cpu1
    wire [3:0] gpio_data_out_1;
    wire uart_tx_1;
    wire uart_rx_1;
    
    wire [15:0] imem_addr_1;
    wire [31:0] imem_rd_data_1;

    assign uart_rx_1 = uart_tx_0;

    parameter CYCLE = 10;

    always #(CYCLE/2) clk = ~clk;

    cpu_top cpu_0 (
        .clk(clk),
        .rst(rst),
        .imem_rd_data_in(imem_rd_data_0),
        .uart_rx_i(uart_rx_0),
        .imem_addr_out(imem_addr_0),
        .gpio_data_out(gpio_data_out_0),
        .uart_tx_o(uart_tx_0)
    );

    imem0 imem_0 (
        .clk(clk),
        .addr(imem_addr_0),
        .rd_data(imem_rd_data_0)
    );

    cpu_top cpu_1 (
        .clk(clk),
        .rst(rst),
        .imem_rd_data_in(imem_rd_data_1),
        .uart_rx_i(uart_rx_1),
        .imem_addr_out(imem_addr_1),
        .gpio_data_out(gpio_data_out_1),
        .uart_tx_o(uart_tx_1)
    );

    imem1 imem_1 (
        .clk(clk),
        .addr(imem_addr_1),
        .rd_data(imem_rd_data_1)
    );

    initial begin
        #10 clk = 1'd0;
        rst = 1'd1;
        #(CYCLE) rst = 1'd0;
    end

endmodule

module imem0 (
    input wire clk,
    input wire [15:0] addr,
    output reg [31:0] rd_data
);
   wire [13:0] iaddr = addr[15:2];
   always @(posedge clk) begin
      case (iaddr)
	// blink program
	14'h0000 : rd_data <= 32'hf6fff0b7; // lui  x1,0xf6fff
	14'h0001 : rd_data <= 32'h07008093; // addi x1,x1,0x070 / x1=f6fff070
    14'h0003 : rd_data <= 32'h02706213; // li   x4,h27 / ori x0,x4,h27
	14'h0004 : rd_data <= 32'h0040a023; // sw   x4,0(x1) ; UART=h27
    default : rd_data <= 32'h00000000;  
       endcase
   end
   
endmodule

module imem1 (
    input wire clk,
    input wire [15:0] addr,
    output reg [31:0] rd_data
);
   wire [13:0] iaddr = addr[15:2];
   always @(posedge clk) begin
      case (iaddr)
	// blink program
	14'h0000 : rd_data <= 32'h5ffff0b7; // lui  x1,0x5ffff
	14'h0001 : rd_data <= 32'h07008093; // addi x1,x1,0x070 / x1=5ffff070
	14'h0100 : rd_data <= 32'h0000A203; // lw   x4,0(x1) ; UART
    default : rd_data <= 32'h00000000;  
       endcase
   end
   
endmodule
