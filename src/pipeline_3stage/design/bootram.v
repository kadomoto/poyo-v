//
// bootram
//


`include "define.vh"

module bootram (
    input wire clk,
    input wire [31:0] addr,
    output wire [31:0] rd_data
);

    //reg [31:0] mem [0:127];  // 512B(9bitアドレス空間)
    wire [31:0] mem [0:71];  // 512B(9bitアドレス空間)
    reg [6:0] addr_sync;  // 512Bを表現するための7bitアドレス(下位2bitはここでは考慮しない)

    //initial $readmemh({`BOOTROM_DATA_PATH, "data.hex"}, mem);

    assign mem[0] = 32'h746f6f72;
    assign mem[1] = 32'h00002023;
    assign mem[2] = 32'h64616f6c;
    assign mem[3] = 32'h00000000;
    assign mem[4] = 32'h4f4d580a;
    assign mem[5] = 32'h204d4544;
    assign mem[6] = 32'h6e617274;
    assign mem[7] = 32'h72656673;
    assign mem[8] = 32'h72726520;
    assign mem[9] = 32'h0a21726f;
    assign mem[10] = 32'h00000000;
    assign mem[11] = 32'h4f4d580a;
    assign mem[12] = 32'h204d4544;
    assign mem[13] = 32'h6e617274;
    assign mem[14] = 32'h72656673;
    assign mem[15] = 32'h6d6f6320;
    assign mem[16] = 32'h74656c70;
    assign mem[17] = 32'h00000a65;
    assign mem[18] = 32'h006e7572;
    assign mem[19] = 32'h72617473;
    assign mem[20] = 32'h00000a74;
    assign mem[21] = 32'h65726373;
    assign mem[22] = 32'h65666e65;
    assign mem[23] = 32'h00686374;
    assign mem[24] = 32'h20232320;
    assign mem[25] = 32'h23232020;
    assign mem[26] = 32'h23232020;
    assign mem[27] = 32'h23232323;
    assign mem[28] = 32'h23202020;
    assign mem[29] = 32'h0a232323;
    assign mem[30] = 32'h00000000;
    assign mem[31] = 32'h23232320;
    assign mem[32] = 32'h23232320;
    assign mem[33] = 32'h20232020;
    assign mem[34] = 32'h23202323;
    assign mem[35] = 32'h20202020;
    assign mem[36] = 32'h000a2323;
    assign mem[37] = 32'h23232320;
    assign mem[38] = 32'h23232323;
    assign mem[39] = 32'h20202020;
    assign mem[40] = 32'h20202323;
    assign mem[41] = 32'h20202020;
    assign mem[42] = 32'h000a2323;
    assign mem[43] = 32'h20232320;
    assign mem[44] = 32'h23232023;
    assign mem[45] = 32'h20202020;
    assign mem[46] = 32'h20202323;
    assign mem[47] = 32'h20202020;
    assign mem[48] = 32'h20202323;
    assign mem[49] = 32'h000a2320;
    assign mem[50] = 32'h20232320;
    assign mem[51] = 32'h23232020;
    assign mem[52] = 32'h20202020;
    assign mem[53] = 32'h20202323;
    assign mem[54] = 32'h20202020;
    assign mem[55] = 32'h20202323;
    assign mem[56] = 32'h000a2323;
    assign mem[57] = 32'h20232320;
    assign mem[58] = 32'h23232020;
    assign mem[59] = 32'h23202020;
    assign mem[60] = 32'h20232323;
    assign mem[61] = 32'h23202020;
    assign mem[62] = 32'h23232323;
    assign mem[63] = 32'h000a2323;
    assign mem[64] = 32'h6e6b6e75;
    assign mem[65] = 32'h2e6e776f;
    assign mem[66] = 32'h0000000a;
    assign mem[67] = 32'h33323130;
    assign mem[68] = 32'h37363534;
    assign mem[69] = 32'h62613938;
    assign mem[70] = 32'h66656463;
    assign mem[71] = 32'h00000000;
     
    always @(posedge clk) begin
        addr_sync <= addr[8:2];  // 読み出しアドレス更新をクロックと同期することでBRAM化
    end
    
    assign rd_data = mem[addr_sync];

endmodule
