//
// uart_rx
//


`include "define.vh"

module uart_rx(
    input wire clk,
    input wire rst_n,
    input wire uart_rx,
    input wire rd_comp,
    output wire [7:0] rd_data,
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

    // FIFO
    // reg [7:0] data_buf [0:255];  // 256バイトのバッファ
    // wire [8:0] byte_count;
    // wire full, empty;
    // reg [8:0] wr_count, rd_count;
    // wire [7:0] wr_ptr, rd_ptr;
    reg [7:0] data_buf [0:63];  // 64バイトのバッファ
    wire [6:0] byte_count;
    wire full, empty;
    reg [6:0] wr_count, rd_count;
    wire [5:0] wr_ptr, rd_ptr;


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
        end else begin
            reception <= 1'b0;
        end
    end  

    assign data_valid = ((shift_reg[0] == 1'b0) && (shift_reg[10:9] == 2'b11));  // スタート/エンドビットのチェック

    // FIFO
    assign rd_data = data_buf[rd_ptr];
    assign byte_count = (wr_count - rd_count);
    assign full = byte_count[6]; 
    assign empty = (byte_count == 7'd0);
    assign wr_ptr = wr_count[5:0];  
    assign rd_ptr = rd_count[5:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_count <= 7'd0;
            rd_count <= 7'd0;
        end else begin
            if (reception && data_valid) begin
                data_buf[wr_ptr] <= shift_reg[8:1];  // スタートビットとエンドビットが合っていればデータ書き込み
                wr_count <= wr_count + 7'd1;  // ポインタ進める
            end
            if (rd_comp && (!empty)) begin
                rd_count <= rd_count + 7'd1;  // ポインタ進める 
            end     
        end
    end 

    // データ読出し可否
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_en <= 1'b0;
        end else if (!empty) begin
            rd_en <= 1'b1;  // emptyで無ければ読出し可
        end else begin
            rd_en <= 1'b0;  // emptyなら読出し不可  
        end
    end

endmodule
