module led_chika(
	input clk,
	input rst,
	output led
);

	reg [27:0] led_reg ;

	always @ (posedge clk) begin
		if(~rst) begin
			led_reg[27:0] <= #1 28'd0;
		end else begin
			led_reg[27:0] <= led_reg[27:0] + 28'd1 ;
		end
	end

	assign led = led_reg[27] ;

endmodule

