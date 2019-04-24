//
// imem
//


`include "define.vh"

module imem(
    input wire clk,
    input wire [31:0] addr,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:16383];  // 64KiB(16bitアドレス空間)
    reg [15:0] addr_sync;  // 64KiBを表現するための16bitアドレス

    initial $readmemh({`MEM_DATA_PATH, "code.hex"}, mem);
     
    always @(posedge clk) begin
        addr_sync <= addr[17:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end
    
    assign rd_data = mem[addr_sync];

endmodule
