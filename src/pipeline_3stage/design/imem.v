//
// imem
//


`include "define.vh"

module imem (
    input wire clk,
    input wire we,
    input wire [31:0] wr_addr,
    input wire [31:0] rd_addr,
    input wire [31:0] wr_data,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:16383];  // 64KiB(16bitアドレス空間)
    reg [13:0] addr_sync;  // 64KiBを表現するための14bitアドレス(下位2bitはここでは考慮しない)

    //initial $readmemh({`MEM_DATA_PATH, "code.hex"}, mem);
     
    always @(posedge clk) begin
        if (we) mem[wr_addr[15:2]] <= wr_data;  // 書き込みタイミングをクロックと同期することでBRAM化
        addr_sync <= rd_addr[15:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end
    
    assign rd_data = mem[addr_sync];

endmodule
