//
// bootram
//


`include "define.vh"

module bootram (
    input wire clk,
    input wire [31:0] addr,
    output wire [31:0] rd_data
);

    reg [31:0] mem [0:127];  // 512B(9bitアドレス空間)
    reg [6:0] addr_sync;  // 512Bを表現するための7bitアドレス(下位2bitはここでは考慮しない)

    initial $readmemh({`BOOTROM_DATA_PATH, "data.hex"}, mem);
     
    always @(posedge clk) begin
        addr_sync <= addr[8:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end
    
    assign rd_data = mem[addr_sync];

endmodule
