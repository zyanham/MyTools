// 32x32x16=16384/256=64adrs->6bit
module in_ram (
	clk,
	wen,
	waddr,
	raddr,
	wdat,
	rdat
);

//	parameter DWIDTH=256;
	parameter DWIDTH=160;
	parameter AWIDTH=6;
	parameter WORDS=64;
	
	input  clk,wen;
	input  [AWIDTH-1:0] waddr,raddr;
	input  [DWIDTH-1:0] wdat;
	output [DWIDTH-1:0] rdat;
	
	reg    [DWIDTH-1:0] rdat;
//    (* ram_style="distributed" *)
	reg    [DWIDTH-1:0] mem [WORDS-1:0];
	
	always @(posedge clk)
	begin
		if(wen) mem[waddr] <= wdat;
	end
	
	always @(posedge clk)
	begin
		rdat <= mem[raddr];
	end

endmodule