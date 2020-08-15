//
// dmem
//


`include "define.vh"

module dmem #(parameter byte_num = 2'b00) (
    input wire clk,
    input wire we,
    input wire [31:0] addr,
    input wire [7:0] wr_data,
    output wire [7:0] rd_data
);

    // 2KiB
    reg [7:0] mem [0:511];  // 2KiB(11bitアドレス空間)
    reg [8:0] addr_sync;  // 2KiBを表現するための11bitアドレス(下位2bitはここでは考慮しない)     
   
    always @(posedge clk) begin
        if (we) mem[addr[10:2]] <= wr_data;  // 書き込みタイミングをクロックと同期することでBRAM化
        addr_sync <= addr[10:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end

    assign rd_data = mem[addr_sync];

endmodule
