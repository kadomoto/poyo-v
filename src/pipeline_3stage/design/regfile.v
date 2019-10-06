//
// regfile
//


module regfile (
    input wire clk,
    input wire we,
    input wire [4:0] srcreg1_num,
    input wire [4:0] srcreg2_num,
    input wire [4:0] dstreg_num,
    input wire [31:0] dstreg_value,
    output wire [31:0] srcreg1_value,
    output wire [31:0] srcreg2_value
);

    reg [31:0] regfile [1:31];  // 1-31レジスタ

    always @(posedge clk) begin
        if (we) regfile[dstreg_num] <= dstreg_value;
    end
    
    assign srcreg1_value = (srcreg1_num == 5'd0) ? 32'd0 : regfile[srcreg1_num];
    assign srcreg2_value = (srcreg2_num == 5'd0) ? 32'd0 : regfile[srcreg2_num];

endmodule
