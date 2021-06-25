`timescale 1ns/1ps

module tb_img_test ();
    reg  clk, rst ;
    wire VSYNC, HSYNC;

    reg [11:0] test01_img [0:(2448*2048-1)] ;
    reg [11:0] test02_img [0:(2448*2048-1)] ;
    reg [11:0] test03_img [0:(2448*2048-1)] ;
    reg [11:0] test04_img [0:(2448*2048-1)] ;
    reg [11:0] test05_img [0:(2448*2048-1)] ;
    reg [11:0] test06_img [0:(2448*2048-1)] ;
    reg [11:0] test07_img [0:(2448*2048-1)] ;
    reg [11:0] test08_img [0:(2448*2048-1)] ;
    reg [11:0] test09_img [0:(2448*2048-1)] ;
    reg [11:0] test10_img [0:(2448*2048-1)] ;

    parameter STEP = 10 ;
    parameter DLY = 0.1 ;

    video_signal_generate video_signal_generate(
	    .clk(clk), .rst(rst), .enable(~rst),
		.VSYNC(VSYNC), .HSYNC(HSYNC));


    wire              outV_IMG01, outV_IMG02 , outV_IMG03 , outV_IMG04 , outV_IMG05 ,
                           outV_IMG06 ,  outV_IMG07 , outV_IMG08 , outV_IMG09 , outV_IMG10 ;
    wire              outH_IMG01, outH_IMG02, outH_IMG03 , outH_IMG04 , outH_IMG05 ,
                           outH_IMG06 ,  outH_IMG07 , outH_IMG08 , outH_IMG09 , outH_IMG10 ;
    wire [11:0] outDATA_IMG01, outDATA_IMG02, outDATA_IMG03, outDATA_IMG04, outDATA_IMG05 ,
                            outDATA_IMG06, outDATA_IMG07, outDATA_IMG08, outDATA_IMG09, outDATA_IMG10 ;

    INPUT_IMG #(.INFILE_NAME("test01_image.mem")) INPUT_IMG01(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG01), .outH(outH_IMG01), .outDATA(outDATA_IMG01[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test02_image.mem")) INPUT_IMG02(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG02), .outH(outH_IMG02), .outDATA(outDATA_IMG02[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test03_image.mem")) INPUT_IMG03(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG03), .outH(outH_IMG03), .outDATA(outDATA_IMG03[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test04_image.mem")) INPUT_IMG04(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG04), .outH(outH_IMG04), .outDATA(outDATA_IMG04[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test05_image.mem")) INPUT_IMG05(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG05), .outH(outH_IMG05), .outDATA(outDATA_IMG05[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test06_image.mem")) INPUT_IMG06(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG06), .outH(outH_IMG06), .outDATA(outDATA_IMG06[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test07_image.mem")) INPUT_IMG07(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG07), .outH(outH_IMG07), .outDATA(outDATA_IMG07[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test08_image.mem")) INPUT_IMG08(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG08), .outH(outH_IMG08), .outDATA(outDATA_IMG08[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test09_image.mem")) INPUT_IMG09(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG09), .outH(outH_IMG09), .outDATA(outDATA_IMG09[11:0])) ;
    INPUT_IMG #(.INFILE_NAME("test10_image.mem")) INPUT_IMG10(.clk(clk), .rst(rst), .inV(VSYNC), .inH(HSYNC), .outV(outV_IMG10), .outH(outH_IMG10), .outDATA(outDATA_IMG10[11:0])) ;

    OUTPUT_IMG #(.OUTFILE_NAME("test01_out.txt")) OUTPUT_IMG01(.clk(clk), .rst(rst), .inV(outV_IMG01), .inH(outH_IMG01), .inDATA(outDATA_IMG01[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test02_out.txt")) OUTPUT_IMG02(.clk(clk), .rst(rst), .inV(outV_IMG02), .inH(outH_IMG02), .inDATA(outDATA_IMG02[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test03_out.txt")) OUTPUT_IMG03(.clk(clk), .rst(rst), .inV(outV_IMG03), .inH(outH_IMG03), .inDATA(outDATA_IMG03[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test04_out.txt")) OUTPUT_IMG04(.clk(clk), .rst(rst), .inV(outV_IMG04), .inH(outH_IMG04), .inDATA(outDATA_IMG04[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test05_out.txt")) OUTPUT_IMG05(.clk(clk), .rst(rst), .inV(outV_IMG05), .inH(outH_IMG05), .inDATA(outDATA_IMG05[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test06_out.txt")) OUTPUT_IMG06(.clk(clk), .rst(rst), .inV(outV_IMG06), .inH(outH_IMG06), .inDATA(outDATA_IMG06[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test07_out.txt")) OUTPUT_IMG07(.clk(clk), .rst(rst), .inV(outV_IMG07), .inH(outH_IMG07), .inDATA(outDATA_IMG07[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test08_out.txt")) OUTPUT_IMG08(.clk(clk), .rst(rst), .inV(outV_IMG08), .inH(outH_IMG08), .inDATA(outDATA_IMG08[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test09_out.txt")) OUTPUT_IMG09(.clk(clk), .rst(rst), .inV(outV_IMG09), .inH(outH_IMG09), .inDATA(outDATA_IMG09[11:0])) ;
    OUTPUT_IMG #(.OUTFILE_NAME("test10_out.txt")) OUTPUT_IMG10(.clk(clk), .rst(rst), .inV(outV_IMG10), .inH(outH_IMG10), .inDATA(outDATA_IMG10[11:0])) ;

    initial begin
	    clk = 1 ;
		forever #(STEP/2) clk = ~clk ;
	end

    initial begin
	    rst = 1 ;
		#0.1 //psd dly
		#(STEP*20);
		rst = 0 ;
		#(STEP*2600*2048);
		$finish();
    end

endmodule