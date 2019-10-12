//
// uart_rx
//


`include "define.vh"

module uart_rx(
    input wire clk,
    input wire rst_n,
    input wire uart_rx,
    output reg [7:0] rd_data,
    output reg rd_en
);

    // UART用クロック生成用信号
    wire uart_clk;
    reg [28:0] val;
    wire [28:0] next_val;
    wire [28:0] delta;

    // 受信データの立下りエッジ検出
    reg [2:0] edge_shift_reg;

    // 受信開始信号
    wire rd_begin;

    // 受信データのビットカウンタ
    reg [3:0] bit_count;
    wire en_seq;

    // SerDes用シフトレジスタ
    reg [10:0] shift_reg;

    // 受信データチェック用信号
    reg reception;
    wire data_valid;


    // システムクロックをUART用クロックへ変換
    assign delta = val[28] ? (`BAUD_RATE) : (`BAUD_RATE - `SYSCLK_FREQ);  
    assign next_val = val + delta;
    
    assign uart_clk = ~val[28];  // 1システムクロック幅だけ立ち上がるUART用クロック
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            val <= 29'b0;
        end else if (rd_begin) begin
            val <= -`SYSCLK_FREQ_HALF;  // 半クロックだけずらしてデータの中央を叩く
        end else if (en_seq) begin
            val <= next_val;
        end else begin
            val <= 29'b0;
        end
    end

    // データの立下り(スタートビット)検出
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            edge_shift_reg[2:0] <= 3'd0;
        end else begin
            edge_shift_reg[2:0] <= {edge_shift_reg[1:0], uart_rx};
        end
    end

    assign rd_begin = ((edge_shift_reg[2:1] == 2'b10) && (en_seq == 1'b0));

    // ビットカウンタ
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bit_count <= 4'd0;
        end else begin
            if (rd_begin && (!en_seq)) begin
                bit_count <= 4'd11;  // スタート 1bit + データ 8bit + ストップ 2bit で 合計 11bit
            end else if (uart_clk && en_seq) begin
                bit_count <= bit_count - 4'd1;
            end
        end
    end

    assign en_seq = (bit_count != 4'd0);  // カウンタが0でなければ受信中

    // シフトレジスタ
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg <= 11'd0;  // 1埋め
        end else if (uart_clk && en_seq) begin
            shift_reg <= {edge_shift_reg[2], shift_reg[10:1]};  // 受信データを取り込んでシフト
        end
    end

    // 受信完了信号
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reception <= 1'b0;
        end else if (uart_clk && en_seq) begin
            if (bit_count == 4'd1) begin
                reception <= 1'b1;
            end else begin
                reception <= 1'b0;
            end
        end
    end

    assign data_valid = ((shift_reg[0] == 1'b0) && (shift_reg[10:9] == 2'b11));  // スタート/エンドビットのチェック

    // 受信データ
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data <= 8'd0;
        end else if (reception && data_valid) begin
            rd_data <= shift_reg[8:1];  // スタートビットとエンドビットが合っていればデータ読み出し
        end else begin     
            rd_data <= rd_data;
        end
    end

    // データ読出し可否
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_en <= 1'b0;
        end else if (reception && data_valid) begin
            rd_en <= 1'b1;  // スタートビットとエンドビットが合っていれば受信完了
        end else begin
            rd_en <= 1'b0;        
        end
    end

endmodule
