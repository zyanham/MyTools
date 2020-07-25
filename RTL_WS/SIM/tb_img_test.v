`timescale 1ns/1ps

module tb_img_test ();
    reg  clk, rst ;
    wire VSYNC, HSYNC, VSYNC_1d, HSYNC_1d ;

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

    integer fp_out01, fp_out02, fp_out03, fp_out04, fp_out05,
	        fp_out06, fp_out07, fp_out08, fp_out09, fp_out10,
			fp_out11, fp_out12, fp_out13, fp_out14, fp_out15,
			fp_out16, fp_out17, fp_out18, fp_out19, fp_out20;

    initial begin
	    fp_out01 = $fopen("test01_out.txt");
	end

    video_signal_generate video_signal_generate(
	    .clk(clk), .rst(rst), .enable(~rst),
		.VSYNC(VSYNC), .HSYNC(HSYNC), .VSYNC_1d(VSYNC_1d), .HSYNC_1d(HSYNC_1d));

    initial begin
	    clk = 1 ;
		forever #(STEP/2) clk = ~clk ;
	end

    initial begin
	    rst = 1 ;
		#0.1 //psd dly
		#(STEP*20);
		rst = 0 ;
		#((STEP*2448*2048)+(STEP*1000));
		$finish();
    end

    reg [1:0] test01_STATE ;
	always @ (posedge clk) begin
	    if(rst) begin
		    test01_STATE[1:0] <= #(DLY) 2'd0 ;
		end else begin
		    case (test01_STATE[1:0])
			    2'd0 : begin
				    if(VSYNC & ~VSYNC_1d) test01_STATE[1:0] <=  #(DLY) 2'd1 ;
				end
				2'd1 : begin
				    if(HSYNC_1d) $fdisplay(fp_out01, "FFF");
					if(~VSYNC & VSYNC_1d) test01_STATE[1:0] <= #(DLY) 2'd2 ;
				end
				2'd2 : begin
				    $fclose(fp_out01);
				    test01_STATE[1:0] <= #(DLY) 2'd3 ;
				end
				2'd3 : begin
				    test01_STATE[1:0] <= #(DLY) test01_STATE[1:0] ;
				end
				default : begin
				    test01_STATE[1:0] <= #(DLY) 2'd0 ;
				end
			endcase
		end
	end

endmodule