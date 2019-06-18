//
// cpu_tb
//


module pipeline_cpu_tb;

    reg clk;
    reg rst;

    wire [3:0] gpio_data_out;
    wire uart_tx;
    
    wire [15:0] imem_addr;
    wire [31:0] imem_rd_data;

    parameter CYCLE = 10;

    always #(CYCLE/2) clk = ~clk;

    cpu_top cpu_top (
        .clk(clk),
        .rst(rst),
        .imem_rd_data_in(imem_rd_data),
        .imem_addr_out(imem_addr),
        .gpio_data_out(gpio_data_out),
        .uart_tx(uart_tx)
    );

    imem imem (
        .clk(clk),
        .addr(imem_addr),
        .rd_data(imem_rd_data)
    );

    initial begin
        #10 clk = 1'd0;
        rst = 1'd1;
        #(CYCLE) rst = 1'd0;
    end

endmodule
