//
// bootrom
//


`include "define.vh"

module bootrom (
    input wire clk,
    input wire [31:0] addr,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:8191];  // 32KiB(8bitアドレス空間)
    reg [12:0] addr_sync;  // 32KiBを表現するための13bitアドレス(下位2bitはここでは考慮しない)

    initial $readmemh({`BOOTROM_DATA_PATH, "boot.hex"}, mem);
     
    always @(posedge clk) begin
        addr_sync <= addr[14:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end
    
    assign rd_data = mem[addr_sync];

endmodule
