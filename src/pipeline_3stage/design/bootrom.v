//
// bootrom
//


`include "define.vh"

module bootrom (
    input wire clk,
    input wire [31:0] addr,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:1023];  // 4KiB(12bitアドレス空間)
    reg [9:0] addr_sync;  // 4KiBを表現するための10bitアドレス(下位2bitはここでは考慮しない)

    initial $readmemh({`BOOTROM_DATA_PATH, "code.hex"}, mem);
     
    always @(posedge clk) begin
        addr_sync <= addr[11:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end
    
    assign rd_data = mem[addr_sync];

endmodule
