//
// gpo
//


module gpo (
    input wire clk,
    input wire rst_n,
    input wire we,
    input wire [7:0] wr_data,
    output reg [7:0] gpo_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
	        gpo_out <= 8'b00000000;
        end else begin
            if (we) begin
	            gpo_out <= wr_data;
            end
        end
    end

endmodule
