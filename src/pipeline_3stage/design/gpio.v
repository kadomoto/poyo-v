//
// gpio
//

module gpio (
    input wire gpio_we,
    input wire [7:0] wr_data,
    input wire clk,
    input wire rst_n,
    output reg [7:0] gpio
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
	        gpio <= 8'b00000000;
        end else begin
            if (gpio_we) begin
	            gpio <= wr_data;
            end
        end
    end

endmodule