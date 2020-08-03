//
// define.vh
//


// プログラムが格納されたディレクトリの絶対パスを指定
`define BOOTROM_DATA_PATH "D:/Github/poyo-v/software/"
//`define MEM_DATA_PATH "D:/Github/poyo-v/software/Coremark_RV32I_45MHz/"
`define MEM_DATA_PATH "D:/Github/poyo-v/software/test/"

// システムクロックの周波数とその半分の値を指定
`define SYSCLK_FREQ 45000000
`define SYSCLK_FREQ_HALF 22500000

// UARTのbaud rateを指定
`define BAUD_RATE 115200

// ブート用命令メモリの開始アドレスと容量を指定
`define BOOTROM_START_ADDR 32'h0
`define BOOTROM_SIZE 32'h1000

// ブート用データメモリの開始アドレスと容量を指定
`define BOOTRAM_START_ADDR 32'h1000
`define BOOTRAM_SIZE 32'h200

// 命令メモリの開始アドレスと容量を指定
`define IMEM_START_ADDR 32'h1200
`define IMEM_SIZE 32'h800

// データメモリの開始アドレスと容量を指定
`define DMEM_START_ADDR 32'h1A00
`define DMEM_SIZE 32'h800

// address for hardware counter
`define HARDWARE_COUNTER_ADDR 32'h20010

// address for UART
`define UART_TX_ADDR 32'h20020
`define UART_RX_ADDR 32'h20030

// address for GPIO
`define GPI_ADDR 32'h20040
`define GPO_ADDR 32'h20050

`define ENABLE  1'b1
`define DISABLE 1'b0

// 命令形式
`define TYPE_NONE 3'd0
`define TYPE_U    3'd1
`define TYPE_J    3'd2
`define TYPE_I    3'd3
`define TYPE_B    3'd4
`define TYPE_S    3'd5
`define TYPE_R    3'd6

// OPコード
`define LUI    7'b0110111
`define AUIPC  7'b0010111
`define JAL    7'b1101111
`define JALR   7'b1100111
`define BRANCH 7'b1100011
`define LOAD   7'b0000011
`define STORE  7'b0100011
`define OPIMM  7'b0010011
`define OP     7'b0110011

// DSTレジスタの有無
`define REG_NONE 1'd0
`define REG_RD   1'd1

// ALUコード
`define ALU_LUI   6'd0
`define ALU_JAL   6'd1
`define ALU_JALR  6'd2
`define ALU_BEQ   6'd3
`define ALU_BNE   6'd4
`define ALU_BLT   6'd5
`define ALU_BGE   6'd6
`define ALU_BLTU  6'd7
`define ALU_BGEU  6'd8
`define ALU_LB    6'd9
`define ALU_LH    6'd10
`define ALU_LW    6'd11
`define ALU_LBU   6'd12
`define ALU_LHU   6'd13
`define ALU_SB    6'd14
`define ALU_SH    6'd15
`define ALU_SW    6'd16
`define ALU_ADD   6'd17
`define ALU_SUB   6'd18
`define ALU_SLT   6'd19
`define ALU_SLTU  6'd20
`define ALU_XOR   6'd21
`define ALU_OR    6'd22
`define ALU_AND   6'd23
`define ALU_SLL   6'd24
`define ALU_SRL   6'd25
`define ALU_SRA   6'd26
`define ALU_NOP   6'd63

// ALU入力タイプ
`define OP_TYPE_NONE 2'd0
`define OP_TYPE_REG  2'd1
`define OP_TYPE_IMM  2'd2
`define OP_TYPE_PC   2'd3
