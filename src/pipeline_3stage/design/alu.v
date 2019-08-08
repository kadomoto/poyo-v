//
// alu
//


`include "define.vh"

module alu (
    input wire [5:0] alucode,
    input wire [31:0] op1,
    input wire [31:0] op2,
    output reg [31:0] alu_result,
    output reg br_taken
);

    wire signed [31:0] signed_op1;
    wire signed [31:0] signed_op2;
    reg signed [31:0] signed_alu_result;

    // 符号付き計算用
    assign signed_op1 = op1;
    assign signed_op2 = op2;

    always @* begin
        case (alucode)
            `ALU_LUI: begin
                alu_result = op2;
                br_taken = `DISABLE;
            end
            `ALU_JAL, `ALU_JALR: begin
                alu_result = op2 + 32'd4;
                br_taken = `ENABLE;
            end
            `ALU_BEQ: begin
                alu_result = 32'd0;
                br_taken = (op1 == op2);
            end
            `ALU_BNE: begin
                alu_result = 32'd0;
                br_taken = (op1 != op2);
            end
            `ALU_BLT: begin
                alu_result = 32'd0;
                br_taken = (signed_op1 < signed_op2);
            end
            `ALU_BGE: begin
                alu_result = 32'd0;
                br_taken = (signed_op1 >= signed_op2);
            end
            `ALU_BLTU: begin
                alu_result = 32'd0;
                br_taken = (op1 < op2);
            end
            `ALU_BGEU: begin
                alu_result = 32'd0;
                br_taken = (op1 >= op2);
            end
            `ALU_LB, `ALU_LH, `ALU_LW, `ALU_LBU, `ALU_LHU, `ALU_SB, `ALU_SH, `ALU_SW: begin
                alu_result = op1 + op2;
                br_taken = `DISABLE;
            end
            `ALU_ADD: begin
                alu_result = op1 + op2;
                br_taken = `DISABLE;
            end
            `ALU_SUB: begin
                alu_result = op1 - op2;
                br_taken = `DISABLE;
            end 
            `ALU_SLT: begin
                alu_result = (signed_op1 < signed_op2) ? 32'd1 : 32'd0;
                br_taken = `DISABLE;
            end
            `ALU_SLTU: begin
                alu_result = (op1 < op2) ? 32'd1 : 32'd0;
                br_taken = `DISABLE;
            end
            `ALU_XOR: begin
                alu_result = op1 ^ op2;
                br_taken = `DISABLE;
            end
            `ALU_OR: begin
                alu_result = op1 | op2;
                br_taken = `DISABLE;
            end
            `ALU_AND: begin
                alu_result = op1 & op2;
                br_taken = `DISABLE;
            end
            `ALU_SLL: begin
                alu_result = op1 << op2[4:0];
                br_taken = `DISABLE;
            end
            `ALU_SRL: begin
                alu_result = op1 >> op2[4:0];
                br_taken = `DISABLE;
            end
            `ALU_SRA: begin
                signed_alu_result = signed_op1 >>> signed_op2[4:0];
                alu_result = signed_alu_result;
                br_taken = `DISABLE;
            end
            default: begin
                alu_result = 32'd0;
                br_taken = `DISABLE;
            end
        endcase
    end

endmodule
