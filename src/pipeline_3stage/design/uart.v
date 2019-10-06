//
// uart
//


`include "define.vh"

module uart (
   input wire clk,
   input wire rst_n,
   input wire [7:0] wr_data,  // プロセッサから書き込まれるパラレルデータ
   input wire uart_we,  // 書き込み有効
   output reg uart_tx  // 送信シリアルデータ
);

    // UART用クロック生成用信号
    wire uart_clk;
    reg [28:0] val;
    wire [28:0] next_val;
    wire [28:0] delta;

    // シフトレジスタ関係
    reg [3:0] bit_count;
    reg [8:0] shift_reg;
    wire en_seq;
  
    // システムクロックをUART用クロックへ変換
    assign delta = val[28] ? (`BAUD_RATE) : (`BAUD_RATE - `SYSCLK_FREQ);  
    assign next_val = val + delta;
    
    assign uart_clk = ~val[28];  // 1システムクロック幅だけ立ち上がるUART用クロック
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            val <= 29'b0;
        end else begin
            val <= next_val;
        end
    end

    // ビットカウンタ
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_count <= 4'd0;
        end else begin
            if (uart_we && (!en_seq)) begin
                bit_count <= 4'd11;  // スタート 1bit + データ 8bit + ストップ 2bit で 合計 11bit
            end else if (uart_clk && en_seq) begin
                bit_count <= bit_count - 4'd1;
            end
        end
    end

    assign en_seq = (bit_count != 4'd0);  // カウンタが0でなければ送信中

    // シフトレジスタ
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 9'd0;
        end else begin
            if (uart_we && (!en_seq)) begin
                shift_reg <= {wr_data[7:0], 1'd0};  // パラレルデータをシフトレジスタへ格納
            end else if (uart_clk && en_seq) begin
                shift_reg <= {1'd1, shift_reg[8:1]};
            end
        end
    end

    // データ送信
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_tx <= 1'b1;
        end else begin
            if (uart_clk && en_seq) begin
                uart_tx <= shift_reg[0];
            end
        end
    end

endmodule
