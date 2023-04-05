`timescale 1ns/1ps

module tb_BMPTST_3FRM ();

    reg         clk, rst ;
    wire        VSYNC, HSYNC;
    reg         SYNC_HLD;
    wire [31:0] READ_DATA;
    reg         FRM1, FRM2, FRM3;    

    parameter STEP = 10 ;
    parameter DLY = 0.1 ;

    COMM_VH #( .FRM(3), .H_WIDTH(2448), .V_WIDTH(2048))
    COMM_VH  ( .clk(clk), .rst(rst), .enable(~rst), .VSYNC(VSYNC), .HSYNC(HSYNC) );

    /* FRM */
    BMP_MOD_SEQCNT_FRM3 #(
        .BMP_RD_FILE     ("in.bmp"),
        .BMP_WR_FILE_FRM1("out_frm1.bmp"),
        .BMP_WR_FILE_FRM2("out_frm2.bmp"),
        .BMP_WR_FILE_FRM3("out_frm3.bmp"))
    BMP_MOD_SEQCNT_FRM3  (
        .CLK(clk),
        .RE(VSYNC&HSYNC),
        .RDATA(READ_DATA[31:0]),
        .WE(SYNC_HLD),
        .WDATA(READ_DATA[31:0])
    );

    initial begin
	    clk = 1 ;
		forever #(STEP/2) clk = ~clk ;
	end

    initial begin
	    rst = 1 ;
		#0.1 //psd dly
		#(STEP*20);
		rst = 0 ;
		#(STEP*2500*2170*3);
		$finish();
    end

    always @ (posedge clk) begin
        if(rst==1) begin
            SYNC_HLD <= #DLY 1'd0 ;
        end else begin
            SYNC_HLD <= #DLY VSYNC&HSYNC ;
        end
    end

endmodule