//
// cpu_top
//


`include "define.vh"

module cpu_top (
    input wire clk,
    input wire rst,
    input wire uart_rx,
    input wire [3:0] gpi_in,
    output wire [3:0] gpo_out,
    output wire uart_tx
);

    // reset
    wire rst_n;
    assign rst_n = ~rst;

    // PC
    wire [31:0] next_PC;
    wire [31:0] ex_br_addr;
    wire ex_br_taken;
    reg [31:0] PC;

    // fetch stage関連の定義
    wire [3:0] imem_we;
    wire [31:0] imem_wr_addr, imem_rd_addr;
    wire [7:0] imem_wr_data [3:0];
    wire [7:0] imem_rd_data [3:0];
    wire [31:0] rom_rd_addr, rom_rd_data;

    // execution stage関連の定義
    reg [31:0] ex_PC;
    
    // decoder
    wire [31:0] decoder_insn;
    wire [4:0] decoder_srcreg1_num, decoder_srcreg2_num, ex_dstreg_num;
    wire [31:0] decoder_imm;
    wire [5:0] ex_alucode;
    wire [1:0] ex_aluop1_type, ex_aluop2_type;
    wire ex_reg_we, ex_is_load, ex_is_store;

    // register file
    wire regfile_we;
    wire [4:0] regfile_srcreg1_num, regfile_srcreg2_num, regfile_dstreg_num;
    wire [31:0] regfile_srcreg1_value, regfile_srcreg2_value, regfile_dstreg_value;

    // ALU
    wire [5:0] alu_alucode;
    wire [31:0] alu_op1, alu_op2, ex_alu_result;

    wire [31:0] ex_srcreg1_value, ex_srcreg2_value, ex_store_value;

    // dmem
    wire [3:0] dmem_we;
    wire [31:0] dmem_addr;
    wire [7:0] dmem_wr_data [3:0]; 
    wire [7:0] dmem_rd_data [3:0];
    wire [31:0] ram_rd_addr, ram_rd_data;
    wire [7:0] mem_rd_data [3:0];

    // UART TX
    wire uart_we;
    wire uart_busy;
    wire [7:0] uart_data_in;
    wire uart_data_out;

    // UART RX
    wire uart_rd_en;
    wire uart_rd_comp;
    wire [7:0] uart_rd_data;
    wire [31:0] uart_tx_value, uart_rx_value;

    // GPIO
    wire [7:0] gpi_data_in;
    wire [7:0] gpi_data_out;
    wire [31:0] gpi_value;
    wire gpo_we;
    wire [7:0] gpo_data_in;
    wire [7:0] gpo_data_out;
    wire [31:0] gpo_value;

    // ハードウェアカウンタ
    wire [31:0] hc_value;

    // write-back stage関連の定義
    reg wb_reg_we;
    reg [4:0] wb_dstreg_num;
    reg wb_is_load;
    reg [5:0] wb_alucode;
    reg [31:0] wb_alu_result;
    wire [31:0] wb_load_value, wb_dstreg_value;


    //====================================================================
    // program counter
    //====================================================================   

    // ex stageの結果をフォワーディング
    assign next_PC = (rst_n == 1'b0) ? PC + 32'd4 : ex_br_taken ? ex_br_addr + 32'd4 : PC + 32'd4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= 32'd0;
        end else begin
            PC <= next_PC;
        end
    end

    //====================================================================
    // fetch stage
    //====================================================================
    
    // ex stageの結果をフォワーディング
    assign rom_rd_addr = (rst_n == 1'b0) ? 32'd0 : ex_br_taken ? ex_br_addr : PC;
    assign imem_rd_addr = (rst_n == 1'b0) ? 32'd0 : (rom_rd_addr - `IMEM_START_ADDR);
    
    bootrom bootrom (
        .clk(clk),
        .addr(rom_rd_addr),
        .rd_data(rom_rd_data)
    );
    
    imem #(.byte_num(2'b00)) imem_0 (
        .clk(clk),
        .we(imem_we[0]),
        .wr_addr(imem_wr_addr),
        .rd_addr(imem_rd_addr),
        .wr_data(imem_wr_data[0]),
        .rd_data(imem_rd_data[0])
    );
    
    imem #(.byte_num(2'b01)) imem_1 (
        .clk(clk),
        .we(imem_we[1]),
        .wr_addr(imem_wr_addr),
        .rd_addr(imem_rd_addr),
        .wr_data(imem_wr_data[1]),
        .rd_data(imem_rd_data[1])
    );
    
    imem #(.byte_num(2'b10)) imem_2 (
        .clk(clk),
        .we(imem_we[2]),
        .wr_addr(imem_wr_addr),
        .rd_addr(imem_rd_addr),
        .wr_data(imem_wr_data[2]),
        .rd_data(imem_rd_data[2])
    );
    
    imem #(.byte_num(2'b11)) imem_3 (
        .clk(clk),
        .we(imem_we[3]),
        .wr_addr(imem_wr_addr),
        .rd_addr(imem_rd_addr),
        .wr_data(imem_wr_data[3]),
        .rd_data(imem_rd_data[3])
    );
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            ex_PC <= 32'd0;
        end else begin
            ex_PC <= rom_rd_addr;
        end
    end
    
    //====================================================================
    // execution stage
    //====================================================================
    
    assign decoder_insn = (ex_PC < (`BOOTROM_START_ADDR + `BOOTROM_SIZE)) ?
                          rom_rd_data : {imem_rd_data[3], imem_rd_data[2], imem_rd_data[1], imem_rd_data[0]};
    
    decoder decoder_0 (
        .insn(decoder_insn),
        .srcreg1_num(decoder_srcreg1_num),
        .srcreg2_num(decoder_srcreg2_num),
        .dstreg_num(ex_dstreg_num),
        .imm(decoder_imm),
        .alucode(ex_alucode),
        .aluop1_type(ex_aluop1_type),
        .aluop2_type(ex_aluop2_type),
        .reg_we(ex_reg_we),
        .is_load(ex_is_load),
        .is_store(ex_is_store)
    );
    
    
    assign regfile_srcreg1_num = decoder_srcreg1_num;
    assign regfile_srcreg2_num = decoder_srcreg2_num;
    
    regfile regfile_0 (
        .clk(clk),
        .we(regfile_we),
        .srcreg1_num(regfile_srcreg1_num),
        .srcreg2_num(regfile_srcreg2_num),
        .dstreg_num(regfile_dstreg_num),
        .dstreg_value(regfile_dstreg_value),
        .srcreg1_value(regfile_srcreg1_value),
        .srcreg2_value(regfile_srcreg2_value)
    );
    
    
    // alu
    assign alu_alucode = ex_alucode;
    
    // wb stageの結果をフォワーディング
    assign ex_srcreg1_value = (regfile_srcreg1_num == 5'd0) ? 32'd0 : 
                              (wb_reg_we && (decoder_srcreg1_num == wb_dstreg_num)) ? wb_dstreg_value : regfile_srcreg1_value;
    assign ex_srcreg2_value = (regfile_srcreg2_num == 5'd0) ? 32'd0 : 
                              (wb_reg_we && (decoder_srcreg2_num == wb_dstreg_num)) ? wb_dstreg_value : regfile_srcreg2_value;
    
    assign alu_op1 = (ex_aluop1_type == `OP_TYPE_REG) ? ex_srcreg1_value :
                     (ex_aluop1_type == `OP_TYPE_IMM) ? decoder_imm :
                     (ex_aluop1_type == `OP_TYPE_PC) ? ex_PC: 32'd0;
    assign alu_op2 = (ex_aluop2_type == `OP_TYPE_REG) ? ex_srcreg2_value :
                     (ex_aluop2_type == `OP_TYPE_IMM) ? decoder_imm :
                     (ex_aluop2_type == `OP_TYPE_PC) ? ex_PC : 32'd0;
    
    alu alu_0 (
        .alucode(alu_alucode),
        .op1(alu_op1),
        .op2(alu_op2),
        .alu_result(ex_alu_result),
        .br_taken(ex_br_taken)
    );
    
    assign ex_store_value = ((ex_alucode == `ALU_SW) || (ex_alucode == `ALU_SH) || (ex_alucode == `ALU_SB)) ? ex_srcreg2_value : 32'd0;
    
    assign ex_br_addr = (ex_alucode == `ALU_JAL) ? ex_PC + decoder_imm :
                        (ex_alucode == `ALU_JALR) ? alu_op1 + decoder_imm :
                        ((ex_alucode == `ALU_BEQ) || (ex_alucode == `ALU_BNE) || (ex_alucode == `ALU_BLT) ||
                         (ex_alucode == `ALU_BGE) || (ex_alucode == `ALU_BLTU) || (ex_alucode == `ALU_BGEU)) ? ex_PC + decoder_imm : 32'd0;
    
        
    // メモリアクセス
    assign dmem_addr = ex_alu_result - `DMEM_START_ADDR;  // データメモリへの入力アドレスに変換
    assign imem_wr_addr = ex_alu_result - `IMEM_START_ADDR;  // 命令メモリへの入力アドレスに変換
    assign ram_rd_addr = ex_alu_result - `BOOTRAM_START_ADDR;  // ブート用データメモリへの入力アドレスに変換
    
    function [31:0] dmem_wr_data_sel(
        input is_store,
        input [5:0] alucode,
        input [1:0] alu_result,
        input [31:0] store_value
    );
        
        begin
            if (is_store) begin
                case (alucode)
                    `ALU_SW: dmem_wr_data_sel = store_value;
                    `ALU_SH: begin
                        case (alu_result)
                            2'b00: dmem_wr_data_sel = {16'd0, store_value[15:0]};
                            2'b01: dmem_wr_data_sel = {8'd0, store_value[15:0], 8'd0};
                            2'b10: dmem_wr_data_sel = {store_value[15:0], 16'd0};
                            default: dmem_wr_data_sel = {16'd0, store_value[15:0]};
                        endcase
                    end
                    `ALU_SB: begin
                        case (alu_result)
                            2'b00: dmem_wr_data_sel = {24'd0, store_value[7:0]};
                            2'b01: dmem_wr_data_sel = {16'd0, store_value[7:0], 8'd0};
                            2'b10: dmem_wr_data_sel = {8'd0, store_value[7:0], 16'd0};
                            2'b11: dmem_wr_data_sel = {store_value[7:0], 24'd0};
                        endcase
                    end                    
                    default: dmem_wr_data_sel = store_value;
                endcase
            end else begin
                dmem_wr_data_sel = 32'd0;
            end
        end
        
    endfunction
    
    // dmemへの書き込みデータ
    assign {dmem_wr_data[3], dmem_wr_data[2], dmem_wr_data[1], dmem_wr_data[0]} = dmem_wr_data_sel(ex_is_store, ex_alucode, ex_alu_result[1:0], ex_store_value);
    
    // imemへの書き込みデータ
    assign {imem_wr_data[3], imem_wr_data[2], imem_wr_data[1], imem_wr_data[0]} = dmem_wr_data_sel(ex_is_store, ex_alucode, ex_alu_result[1:0], ex_store_value); 
    
     
    function [3:0] dmem_we_sel(
        input is_store,
        input [5:0] alucode,
        input [1:0] alu_result
    );
        
        begin
            if (is_store) begin
                case (alucode)
                    `ALU_SW: dmem_we_sel = 4'b1111;
                    `ALU_SH: begin
                        case (alu_result)
                            2'b00: dmem_we_sel = 4'b0011;
                            2'b01: dmem_we_sel = 4'b0110;
                            2'b10: dmem_we_sel = 4'b1100;
                            default: dmem_we_sel = 4'b0000;
                        endcase
                    end
                    `ALU_SB: begin
                        case (alu_result)
                            2'b00: dmem_we_sel = 4'b0001;
                            2'b01: dmem_we_sel = 4'b0010;
                            2'b10: dmem_we_sel = 4'b0100;
                            2'b11: dmem_we_sel = 4'b1000;
                        endcase
                    end                    
                    default: dmem_we_sel = 4'b0000;
                endcase
            end else begin
                dmem_we_sel = 4'b0000;
            end
        end
        
    endfunction

    // メモリマップのデータメモリにあたるアドレスが指定されていれば書き込み有効化
    assign dmem_we = (dmem_addr < `DMEM_SIZE) ? dmem_we_sel(ex_is_store, ex_alucode, ex_alu_result[1:0]) : 4'd0;

    // メモリマップの命令メモリにあたるアドレスが指定されていれば書き込み有効化
    assign imem_we = (imem_wr_addr < `IMEM_SIZE) ? dmem_we_sel(ex_is_store, ex_alucode, ex_alu_result[1:0]) : 4'd0;
    
    
    bootram bootram (
        .clk(clk),
        .addr(ram_rd_addr),
        .rd_data(ram_rd_data)
    );
    
    
    dmem #(.byte_num(2'b00)) dmem_0 (
        .clk(clk),
        .we(dmem_we[0]),
        .addr(dmem_addr),
        .wr_data(dmem_wr_data[0]),
        .rd_data(dmem_rd_data[0])
    );
    
    dmem #(.byte_num(2'b01)) dmem_1 (
        .clk(clk),
        .we(dmem_we[1]),
        .addr(dmem_addr),
        .wr_data(dmem_wr_data[1]),
        .rd_data(dmem_rd_data[1])
    );
    
    dmem #(.byte_num(2'b10)) dmem_2 (
        .clk(clk),
        .we(dmem_we[2]),
        .addr(dmem_addr),
        .wr_data(dmem_wr_data[2]),
        .rd_data(dmem_rd_data[2])
    );
    
    dmem #(.byte_num(2'b11)) dmem_3 (
        .clk(clk),
        .we(dmem_we[3]),
        .addr(dmem_addr),
        .wr_data(dmem_wr_data[3]),
        .rd_data(dmem_rd_data[3])
    );
    

    // UART
    assign uart_data_in = ex_store_value[7:0];
    assign uart_we = ((ex_alu_result == `UART_TX_ADDR) && ex_is_store) ? `ENABLE : `DISABLE;
    assign uart_tx = uart_data_out;
    assign uart_rd_comp = ((ex_alu_result == `UART_RX_ADDR) && ex_is_store) ? ex_store_value[0] : 1'b0;

    uart uart_0 (
        .clk(clk),
        .rst_n(rst_n),
        .wr_data(uart_data_in),
        .wr_en(uart_we),
        .uart_tx(uart_data_out),
        .busy(uart_busy)
    );

    uart_rx uart_rx_0 (
        .clk(clk),
        .rst_n(rst_n),
        .uart_rx(uart_rx),
        .rd_comp(uart_rd_comp),
        .rd_data(uart_rd_data),
        .rd_en(uart_rd_en)
    );

    // GPIO
    assign gpi_data_in = {4'd0, gpi_in};  // デフォルトでは汎用入力は4bit
    assign gpo_data_in = ex_store_value[7:0];
    assign gpo_we = ((ex_alu_result == `GPO_ADDR) && ex_is_store) ? `ENABLE : `DISABLE;
    assign gpo_out = gpo_data_out[3:0];  // デフォルトでは汎用出力は4bit

    gpi gpi_0 (
		.clk(clk),
		.rst_n(rst_n),
		.wr_data(gpi_data_in),
		.gpi_out(gpi_data_out)
    );

    gpo gpo_0 (
		.clk(clk),
		.rst_n(rst_n),
		.we(gpo_we),
		.wr_data(gpo_data_in),
		.gpo_out(gpo_data_out)
    );


    // hardware counter
    hardware_counter hardware_counter_0 (
        .clk(clk),
        .rst_n(rst_n),
        .hc_out(hc_value)
    );

    
    // パイプラインレジスタ
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_reg_we <= `DISABLE;
            wb_dstreg_num <= 5'd0;
            wb_is_load <= `DISABLE;
            wb_alucode <= 6'd0;
            wb_alu_result <= 32'd0;
        end else begin
            wb_reg_we <= ex_reg_we;
            wb_dstreg_num <= ex_dstreg_num;
            wb_is_load <= ex_is_load;
            wb_alucode <= ex_alucode;
            wb_alu_result <= ex_alu_result;
        end
    end

    //====================================================================
    // write-back stage
    //====================================================================

    // メモリからのロード値
    assign mem_rd_data[0] = ((`BOOTRAM_START_ADDR <= wb_alu_result) &&
                             (wb_alu_result < (`BOOTRAM_START_ADDR + `BOOTRAM_SIZE))) ? ram_rd_data[7:0] : dmem_rd_data[0];
    assign mem_rd_data[1] = ((`BOOTRAM_START_ADDR <= wb_alu_result) &&
                             (wb_alu_result < (`BOOTRAM_START_ADDR + `BOOTRAM_SIZE))) ? ram_rd_data[15:8] : dmem_rd_data[1];
    assign mem_rd_data[2] = ((`BOOTRAM_START_ADDR <= wb_alu_result) &&
                             (wb_alu_result < (`BOOTRAM_START_ADDR + `BOOTRAM_SIZE))) ? ram_rd_data[23:16] : dmem_rd_data[2];
    assign mem_rd_data[3] = ((`BOOTRAM_START_ADDR <= wb_alu_result) &&
                             (wb_alu_result < (`BOOTRAM_START_ADDR + `BOOTRAM_SIZE))) ? ram_rd_data[31:24] : dmem_rd_data[3];

    // 各種I/Oからのロード値
    assign gpi_value = {28'd0, gpi_data_out[3:0]};
    assign gpo_value = {28'd0, gpo_data_out[3:0]};
    assign uart_tx_value = {31'd0, uart_busy};
    assign uart_rx_value = {23'd0, uart_rd_en, uart_rd_data};
    
    function [31:0] load_value_sel(
        input is_load,
        input [5:0] alucode,
        input [31:0] alu_result,
        input [7:0] dmem_rd_data_0, dmem_rd_data_1, dmem_rd_data_2, dmem_rd_data_3,
        input [31:0] uart_tx_value, uart_rx_value,
        input [31:0] hc_value,
        input [31:0] gpi_value,
        input [31:0] gpo_value
    );
        
        begin
            if (is_load) begin
                case (alucode)
                    `ALU_LW: begin
                        if (alu_result == `HARDWARE_COUNTER_ADDR) begin
                            load_value_sel = hc_value;
                        end else if (alu_result == `UART_TX_ADDR) begin
                            load_value_sel = uart_tx_value;
                        end else if (alu_result == `UART_RX_ADDR) begin
                            load_value_sel = uart_rx_value;
                        end else if (alu_result == `GPI_ADDR) begin
                            load_value_sel = gpi_value;
                        end else if (alu_result == `GPO_ADDR) begin
                            load_value_sel = gpo_value;
                        end else begin
                            load_value_sel = {dmem_rd_data_3, dmem_rd_data_2, dmem_rd_data_1, dmem_rd_data_0};
                        end
                    end
                    `ALU_LH: begin
                        case (alu_result[1:0])
                            2'b00: load_value_sel = {{16{dmem_rd_data_1[7]}}, dmem_rd_data_1, dmem_rd_data_0};
                            2'b01: load_value_sel = {{16{dmem_rd_data_2[7]}}, dmem_rd_data_2, dmem_rd_data_1};
                            2'b10: load_value_sel = {{16{dmem_rd_data_3[7]}}, dmem_rd_data_3, dmem_rd_data_2};
                            default: load_value_sel = {{16{dmem_rd_data_1[7]}}, dmem_rd_data_1, dmem_rd_data_0};
                        endcase
                    end
                    `ALU_LB: begin
                        case (alu_result[1:0])
                            2'b00: load_value_sel = {{24{dmem_rd_data_0[7]}}, dmem_rd_data_0};
                            2'b01: load_value_sel = {{24{dmem_rd_data_1[7]}}, dmem_rd_data_1};
                            2'b10: load_value_sel = {{24{dmem_rd_data_2[7]}}, dmem_rd_data_2};
                            2'b11: load_value_sel = {{24{dmem_rd_data_3[7]}}, dmem_rd_data_3};
                        endcase
                    end
                    `ALU_LHU: begin
                        case (alu_result[1:0])
                            2'b00: load_value_sel = {16'd0, dmem_rd_data_1, dmem_rd_data_0};
                            2'b01: load_value_sel = {16'd0, dmem_rd_data_2, dmem_rd_data_1};
                            2'b10: load_value_sel = {16'd0, dmem_rd_data_3, dmem_rd_data_2};
                            default: load_value_sel = {16'd0, dmem_rd_data_1, dmem_rd_data_0};
                        endcase
                    end
                    `ALU_LBU: begin
                        case (alu_result[1:0])
                            2'b00: load_value_sel = {24'd0, dmem_rd_data_0};
                            2'b01: load_value_sel = {24'd0, dmem_rd_data_1};
                            2'b10: load_value_sel = {24'd0, dmem_rd_data_2};
                            2'b11: load_value_sel = {24'd0, dmem_rd_data_3};
                        endcase
                    end 
                    default: load_value_sel = {dmem_rd_data_3, dmem_rd_data_2, dmem_rd_data_1, dmem_rd_data_0};
                endcase
            end else begin
                load_value_sel = 32'd0;
            end
        end
        
    endfunction

    assign wb_load_value = load_value_sel(wb_is_load, wb_alucode, wb_alu_result, mem_rd_data[0],
                                          mem_rd_data[1], mem_rd_data[2], mem_rd_data[3], uart_tx_value, uart_rx_value, hc_value, gpi_value, gpo_value);
    
    assign wb_dstreg_value = wb_is_load ? wb_load_value : wb_alu_result;

    // wb stageの結果に応じてレジスタへ書き込み
    assign regfile_we = wb_reg_we;
    assign regfile_dstreg_num = wb_dstreg_num;
    assign regfile_dstreg_value = wb_dstreg_value;


endmodule
