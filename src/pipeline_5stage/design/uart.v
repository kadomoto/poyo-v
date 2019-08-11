//
// uart
//


module uart (
   input wire uart_we,
   input wire [7:0] wr_data,
   input wire clk,
   input wire rst_n,
   output reg uart_tx
);

    reg [3:0] bit_count;
    reg [8:0] shifter;

    wire uart_clk;
    wire uart_busy = |bit_count[3:1];
    wire sending = |bit_count;

    reg [28:0] count;
  
    // システムクロックを115200HzのUART用クロックへ変換（システムクロックが50MHzの場合は(115200 - 50000000)と記述）
    wire [28:0] d = count[28] ? (115200) : (115200 - 70000000);  
    wire [28:0] count_next = count + d;
    
    assign uart_clk = ~count[28]; // 115200Hzクロック信号
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 29'b0;
        end else begin
            count <= count_next;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_tx <= 1'b1;
            bit_count <= 4'd0;
            shifter <= 9'd0;
        end else begin
            if (uart_we & ~uart_busy) begin
                shifter <= {wr_data[7:0], 1'd0};
                bit_count <= 4'd11;  // 1 start bit + 8 data bit + 2 stop bit = 11bit
            end
            if (sending & uart_clk) begin
                {shifter, uart_tx} <= {1'd1, shifter};
                bit_count <= bit_count - 4'd1;
            end
        end
    end

endmodule
