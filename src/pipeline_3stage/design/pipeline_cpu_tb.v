//
// cpu_tb
//


module pipeline_cpu_tb;

    reg clk;
    reg rst;

    parameter CYCLE = 10;

    always #(CYCLE/2) clk = ~clk;

    cpu_top cpu_top(
       .clk(clk),
       .rst(rst)
    );

    initial begin
        #10 clk = 1'd0;
        rst = 1'd1;
        #(CYCLE) rst = 1'd0;
    end

endmodule
