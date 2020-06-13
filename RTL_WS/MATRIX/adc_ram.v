// (32,4096)*16bit=2097152bit/256bit=8192adrs
//
//
module adc_ram (
	clk,
	wen,
	waddr,
	raddr,
	wdat,
	rdat
);

//	parameter DWIDTH = 256  ;
	parameter DWIDTH = 160  ;
	parameter AWIDTH = 13   ;
	parameter WORDS  = 8192 ;
	
	input  clk,wen;
	input  [AWIDTH-1:0] waddr,raddr;
	input  [DWIDTH-1:0] wdat;
	output [DWIDTH-1:0] rdat;
	
	reg    [DWIDTH-1:0] rdat;
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