`timescale 1 ps / 1 ps

module design_1_wrapper
   (sys_clk,
    sys_rst,
    uart);
  input sys_clk;
  input sys_rst;
  output uart;

  wire sys_clk;
  wire sys_rst;
  wire uart;

  design_1 design_1_i
       (.sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .uart(uart));
endmodule
