//
// uart_rx
//


module uart_rx(
   input wire uart_rx,
   input wire clk,
   input wire rst_n,
   output wire uart_re,
   output wire [7:0] rd_data
);

    // 24MHzのシステムクロックを1.5MHzのUART用クロックへ変換するためのカウンタ
    // 16サイクル（4'hFサイクル、1/2すると4'h7）
    reg [3:0] clk_count;

    // 受信データの立下りエッジ検出
    reg [2:0] edge_shift_reg;

    // 受信開始/終了パルス信号
    wire start_pulse;
    wire end_pulse;
    reg busy;

    // 受信データのビットカウンタ
    wire data_acq;
    reg [3:0] data_count;

    // SerDes用フリップフロップ
    reg [10:0] serdes_ff;

    // 受信データチェック開始用信号
    reg reception;
    
    // 受信データチェック
    reg rd_en;
    reg [7:0] data;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_count <= 4'd0;
        end else if (start_pulse) begin
            clk_count <= 4'h7;  // スタート時は1/2周期だけずらす
        end else if (busy) begin
            if (clk_count == 4'd0) begin
                clk_count <= 4'hF;  // カウントが0になったら最初からカウント
            end else begin
                clk_count <= clk_count - 4'd1;  // デクリメント
            end
        end else begin
            clk_count <= 4'd0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            edge_shift_reg[2:0] <= 3'd0;
        end else begin
            edge_shift_reg[2:0] <= {edge_shift_reg[1:0], uart_rx};
        end
    end

    assign start_pulse = ((edge_shift_reg[2:1] == 2'b10) && (busy == 1'b0)) ? 1'b1 : 1'b0;
    assign end_pulse = ((data_count == 4'd10) && (data_acq==1'b1)) ? 1'b1 : 1'b0;  // 11bit目の受信タイミング

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy <= 1'b0;
        end else if (start_pulse) begin
            busy <= 1'b1;
        end else if (end_pulse) begin
            busy <= 1'b0;
        end
    end

    assign data_acq = ((busy == 1'b1) && (clk_count == 4'd0)) ? 1'b1 : 1'b0;  // データ取得タイミング

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_count <= 4'd0;
        end else if (start_pulse) begin
            data_count <= 4'd0;
        end else if (data_acq) begin
            data_count <= data_count + 4'd1;  //インクリメント
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            serdes_ff <= 11'h7FF;  // 1埋め
        end else if (data_acq) begin
            serdes_ff <= {edge_shift_reg[2], serdes_ff[10:1]};  // 受信データを取り込んでシフト
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reception <= 1'b0;
        end else begin
            reception <= end_pulse;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_en <= 1'b0;
            data <= 8'd0;
        end else if ((reception == 1'b1) && (serdes_ff[0] == 1'b0) && (serdes_ff[10:9] == 2'b11)) begin
            rd_en <= 1'b1;  // スタートビットとエンドビットが合っていれば受信完了
            data <= serdes_ff[8:1];
        end else begin
            rd_en <= 1'b0;        
            data <= data;
        end
    end

    // 出力ポート
    assign uart_re = rd_en;
    assign rd_data = data;

endmodule
