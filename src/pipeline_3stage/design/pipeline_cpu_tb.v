//
// cpu_tb
//


module pipeline_cpu_tb;

    reg clk;
    reg rst;
    
    wire uart_tx;

    parameter CYCLE = 10;

    always #(CYCLE/2) clk = ~clk;

    cpu_top cpu_top(
        .clk(clk),
        .rst(rst),
        .imem_rd_data_in(imem_rd_data_in),
        .imem_addr_out(imem_rd_data_in),
        .gpio_data_out(gpio_data_out),
        .uart_tx(uart_tx)
    );

    initial begin
        #10 clk = 1'd0;
        rst = 1'd1;
        #(CYCLE) rst = 1'd0;
    end

endmodule
