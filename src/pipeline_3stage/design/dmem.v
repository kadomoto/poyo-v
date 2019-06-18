//
// dmem
//


`include "define.vh"

module dmem (
    input wire clk,
    input wire we,
    input wire [31:0] addr,
    input wire [7:0] wr_data,
    output wire [7:0] rd_data
);

    //reg [7:0] mem [0:16383];  // 64KiB(16bitアドレス空間)
    //reg [15:0] addr_sync;  // 64KiBを表現するための16bitアドレス  
    reg [7:0] mem [0:15];  // 64B(6bitアドレス空間)
    reg [3:0] addr_sync;  // 64Bを表現するための6bitアドレスから下位2bitを削減したもの

    always @(posedge clk) begin
        if (we) mem[addr[5:2]] <= wr_data;  // 書き込みタイミングをクロックと同期することでBRAM化
        addr_sync <= addr[5:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end

    assign rd_data = mem[addr_sync];

endmodule
