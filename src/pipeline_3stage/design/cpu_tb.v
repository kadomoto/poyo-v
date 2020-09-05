//
// cpu_tb
//


module cpu_tb;

    reg clk;
    reg rst;
    // reg rst2;
    //wire uart_tx, uart_rx;
    wire uart_tx;
    reg uart_rx;

    parameter CYCLE = 20;
    parameter DELAY = 6940;

    always #(CYCLE/2) clk = ~clk;

    cpu_top cpu_top (
        .clk(clk),
        .rst(rst),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx)
    );

    // cpu_top cpu_top_2 (
    //     .clk(clk),
    //     .rst(rst2),
    //     .uart_rx(uart_tx),
    //     .uart_tx(uart_rx)
    // );

    initial begin
        #10 clk = 1'd0;
        rst = 1'd1;
        #(CYCLE) rst = 1'd0;
        // uart_rx = 1'd1;
        // #(1000000)
        // rst2 = 1'd1;
        // #(CYCLE) rst2 = 1'd0;
        #(1000000);

        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY);
        // #(DELAY);

        //#(1000000);
        // repeat (128) begin
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY)
        // uart_rx = 1'd0;
        // #(DELAY)
        // uart_rx = 1'd1;
        // #(DELAY);
        // #(DELAY);
        // end        

    end

endmodule
