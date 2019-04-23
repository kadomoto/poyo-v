//
// hardware counter
//


module hardware_counter(
    input wire clk,
    input wire rst_n,
    output wire [31:0] out
);

    reg [31:0] cycles;

    assign out = cycles;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycles <= 32'd0;
        end else begin
            cycles <= cycles + 1;
        end
    end

endmodule
