//
// uart_tb
//


module uart_tb;

    reg clk;
    reg rst_n;

    wire uart_tx;

    reg wr_i;
    reg [7:0] dat_i;

    wire uart_re;
    wire [7:0] rd_data;

    parameter CYCLE = 20;

    always #(CYCLE/2) clk = ~clk;

    uart uart (
        .uart_tx(uart_tx),
        .uart_we(wr_i),
        .wr_data(dat_i),
        .clk(clk),
        .rst_n(rst_n)
    );

    uart_rx uart_rx (
        .uart_rx(uart_tx),
        .clk(clk),
        .rst_n(rst_n),
        .uart_re(uart_re),
        .rd_data(rd_data)
    );

    initial begin
        #10 clk = 1'd0;
        rst_n  = 1'd0;
        #(CYCLE) rst_n = 1'd1;
        dat_i = 8'h43;  // 01000011
        wr_i = 1'b1; #(CYCLE)
        dat_i = 8'h00;
        wr_i = 1'b0; #100000;
        dat_i = 8'h50;  // 01010000
        wr_i = 1'b1; #(CYCLE)
        dat_i = 8'h00;
        wr_i = 1'b0; #100000;
        dat_i = 8'h55;  // 01010101
        wr_i = 1'b1; #(CYCLE)
        dat_i = 8'h00;
        wr_i = 1'b0; #100000;
    end

endmodule
