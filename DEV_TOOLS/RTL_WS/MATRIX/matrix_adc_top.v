module matrix_adc_top (
    input       clk_250MHz,
	input       rst,        // High_active
    input       trg,

	input [4:0]   row1,    // 0~31
	input [4:0]   row2,    // 0~3
	input [12:0]  column,  // 0~4096
    input [6:0]   column2, // 0~127

    output [3:0] STATE,

    // INPUT DATA
    input  [159:0] adc_ram1_rdat,
    input  [159:0] adc_ram2_rdat,
    input  [159:0] adc_ram3_rdat,
    input  [159:0] adc_ram4_rdat,
    input  [159:0] adc_ram5_rdat,
    input  [159:0] adc_ram6_rdat,
    input  [159:0] adc_ram7_rdat,
    input  [159:0] adc_ram8_rdat,
	output  [12:0] adc_adr,  // 32x4096x10=1310720bit 0~5119:addr->13bit

	// coe_data_bram IF
    input          coe_out_wen,
	input [14:0]   coe_out_wadrs,
	input [255:0]  coe_out_wdat,

	output         adc_out_en1,
	output         adc_out_en2,
	output         adc_out_en3,
	output         adc_out_en4,
	output         adc_out_en5,
	output         adc_out_en6,
	output         adc_out_en7,
	output         adc_out_en8,
    output   [9:0] adc_out_dat1,
    output   [9:0] adc_out_dat2,
    output   [9:0] adc_out_dat3,
    output   [9:0] adc_out_dat4,
    output   [9:0] adc_out_dat5,
    output   [9:0] adc_out_dat6,
    output   [9:0] adc_out_dat7,
    output   [9:0] adc_out_dat8
);

    wire         wire_en1 ;
    wire         wire_en2 ;
    wire         wire_en3 ;
    wire         wire_en4 ;
    wire         wire_en5 ;
    wire         wire_en6 ;
    wire         wire_en7 ;
    wire         wire_en8 ;

    wire [17:0]  wire_dat1 ;
    wire [17:0]  wire_dat2 ;
    wire [17:0]  wire_dat3 ;
    wire [17:0]  wire_dat4 ;
    wire [17:0]  wire_dat5 ;
    wire [17:0]  wire_dat6 ;
    wire [17:0]  wire_dat7 ;
    wire [17:0]  wire_dat8 ;

    wire         div_en1 ;
    wire         div_en2 ;
    wire         div_en3 ;
    wire         div_en4 ;
    wire         div_en5 ;
    wire         div_en6 ;
    wire         div_en7 ;
    wire         div_en8 ;

    wire [31:0]  div_dat1 ;
    wire [31:0]  div_dat2 ;
    wire [31:0]  div_dat3 ;
    wire [31:0]  div_dat4 ;
    wire [31:0]  div_dat5 ;
    wire [31:0]  div_dat6 ;
    wire [31:0]  div_dat7 ;
    wire [31:0]  div_dat8 ;

	wire [159:0] adc_ram1_rdat, adc_ram2_rdat, adc_ram3_rdat, adc_ram4_rdat,
                 adc_ram5_rdat, adc_ram6_rdat, adc_ram7_rdat, adc_ram8_rdat;





    wire [9:0]   coe_out_radrs ;
	
    wire [159:0] coe_out_rdat01 ;
    wire [159:0] coe_out_rdat02 ;
    wire [159:0] coe_out_rdat03 ;
    wire [159:0] coe_out_rdat04 ;
    wire [159:0] coe_out_rdat05 ;
    wire [159:0] coe_out_rdat06 ;
    wire [159:0] coe_out_rdat07 ;
    wire [159:0] coe_out_rdat08 ;
    wire [159:0] coe_out_rdat09 ;
    wire [159:0] coe_out_rdat10 ;
    wire [159:0] coe_out_rdat11 ;
    wire [159:0] coe_out_rdat12 ;
    wire [159:0] coe_out_rdat13 ;
    wire [159:0] coe_out_rdat14 ;
    wire [159:0] coe_out_rdat15 ;
    wire [159:0] coe_out_rdat16 ;
    wire [159:0] coe_out_rdat17 ;
    wire [159:0] coe_out_rdat18 ;
    wire [159:0] coe_out_rdat19 ;
    wire [159:0] coe_out_rdat20 ;
    wire [159:0] coe_out_rdat21 ;
    wire [159:0] coe_out_rdat22 ;
    wire [159:0] coe_out_rdat23 ;
    wire [159:0] coe_out_rdat24 ;
    wire [159:0] coe_out_rdat25 ;
    wire [159:0] coe_out_rdat26 ;
    wire [159:0] coe_out_rdat27 ;
    wire [159:0] coe_out_rdat28 ;
    wire [159:0] coe_out_rdat29 ;
    wire [159:0] coe_out_rdat30 ;
    wire [159:0] coe_out_rdat31 ;
    wire [159:0] coe_out_rdat32 ;


//  input          coe_out_wen,
//	input [14:0]   coe_out_wadrs,
//	input [255:0]  coe_out_wdat,

    reg         coe_out_wen_dd1,   coe_out_wen_dd2,   coe_out_wen_dd3 ;
	reg [4:0] coe_out_wadrs_dd1, coe_out_wadrs_dd2, coe_out_wadrs_dd3 ;
    parameter DLY=0.1;

    /***************************************/
	/* ZZY_YYYY_XXXM_MMMM X*32+Y+column/16*2
	/***************************************/
    wire [2:0] column_num = column[11:9] ;
	wire [2:0] val_x = (column_num[2:0] == 1'd1)? 3'd0 :                      //  512
	                   (column_num[2:0] == 1'd2)? {2'd0, coe_out_wadrs[5]}:   // 1024
					   (column_num[2:0] == 1'd3)? {1'd0, coe_out_wadrs[6:5]}: // 2048
					   (column_num[2:0] == 1'd7)? coe_out_wadrs[7:5]: 3'd0 ;  // 4096

    wire [4:0] val_y = (column_num[2:0] == 1'd1)? coe_out_wadrs[9:5]  :
	                   (column_num[2:0] == 1'd2)? coe_out_wadrs[10:6] :
	                   (column_num[2:0] == 1'd3)? coe_out_wadrs[11:7] :
	                   (column_num[2:0] == 1'd7)? coe_out_wadrs[12:8] : 3'd0 ;
	
    wire [1:0] val_z = (column_num[2:0] == 1'd1)? coe_out_wadrs[11:10]  :
	                   (column_num[2:0] == 1'd2)? coe_out_wadrs[12:11]  :
	                   (column_num[2:0] == 1'd3)? coe_out_wadrs[13:12]  :
	                   (column_num[2:0] == 1'd7)? coe_out_wadrs[14:13]  : 2'd0 ;

    reg [2:0] val_x_dd1 ;
	reg [4:0] val_y_dd1 ;
	reg [1:0] val_z_dd1 ;
	always @(posedge clk_250MHz) begin
	    if(rst) begin
		    val_x_dd1[2:0] <= #DLY 3'd0 ;
		    val_y_dd1[4:0] <= #DLY 5'd0 ;
		    val_z_dd1[1:0] <= #DLY 2'd0 ;
		end else if(coe_out_wen) begin
		    val_x_dd1[2:0] <= #DLY val_x[2:0] ;
		    val_y_dd1[4:0] <= #DLY val_y[4:0] ;
		    val_z_dd1[1:0] <= #DLY val_z[1:0] ;
		end
	end
	
	wire [8:0] mult_x = val_x_dd1[2:0] * 6'd32 ;
    wire [9:0] mult_z = column[11:4] * val_z_dd1[1:0] ;

	reg [4:0] val_y_dd2 ;
    reg [8:0] mult_x_dd2 ;
    reg [9:0] mult_z_dd2 ;
	always @(posedge clk_250MHz) begin
	    if(rst) begin
		    val_y_dd2[4:0]  <= #DLY 5'd0 ;
		    mult_x_dd2[8:0] <= #DLY 9'd0 ;
		    mult_z_dd2[9:0] <= #DLY 10'd0 ;
		end else if(coe_out_wen) begin
		    val_y_dd2[4:0]  <= #DLY val_y_dd1[4:0] ;
		    mult_x_dd2[8:0] <= #DLY mult_x[8:0] ;
		    mult_z_dd2[9:0] <= #DLY mult_z[9:0] ;
		end
	end

    wire [10:0] wire_adrs = {6'd0, val_y_dd2[4:0]} + {2'd0, mult_x_dd2[8:0]} + {1'd0, mult_z_dd2[9:0]} ;

    reg [10:0] reg_adrs_dd3 ;
	always @(posedge clk_250MHz) begin
	    if(rst) begin
		    reg_adrs_dd3[10:0] <= #DLY 11'd0 ;
		end else begin
		    reg_adrs_dd3[10:0] <= #DLY wire_adrs[10:0] ;
		end
	end

	always @(posedge clk_250MHz) begin
	    if(rst) begin
		    coe_out_wen_dd1        <= #DLY 1'd0 ;
		    coe_out_wen_dd2        <= #DLY 1'd0 ;
		    coe_out_wen_dd3        <= #DLY 1'd0 ;
			coe_out_wadrs_dd1[4:0] <= #DLY 5'd0 ;
			coe_out_wadrs_dd2[4:0] <= #DLY 5'd0 ;
			coe_out_wadrs_dd3[4:0] <= #DLY 5'd0 ;
		end else begin
		    coe_out_wen_dd1        <= #DLY coe_out_wen ;
		    coe_out_wen_dd2        <= #DLY coe_out_wen_dd1 ;
		    coe_out_wen_dd3        <= #DLY coe_out_wen_dd2 ;
			coe_out_wadrs_dd1[4:0] <= #DLY coe_out_wadrs[4:0] ;
			coe_out_wadrs_dd2[4:0] <= #DLY coe_out_wadrs_dd1[4:0] ;
			coe_out_wadrs_dd3[4:0] <= #DLY coe_out_wadrs_dd2[4:0] ;
		end
	end 

    wire coe_out_wen01 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd0));
    wire coe_out_wen02 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd1));
    wire coe_out_wen03 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd2));
    wire coe_out_wen04 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd3));
    wire coe_out_wen05 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd4));
    wire coe_out_wen06 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd5));
    wire coe_out_wen07 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd6));
    wire coe_out_wen08 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd7));
    wire coe_out_wen09 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd8));
    wire coe_out_wen10 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd9));
    wire coe_out_wen11 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd10));
    wire coe_out_wen12 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd11));
    wire coe_out_wen13 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd12));
    wire coe_out_wen14 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd13));
    wire coe_out_wen15 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd14));
    wire coe_out_wen16 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd15));
    wire coe_out_wen17 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd16));
    wire coe_out_wen18 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd17));
    wire coe_out_wen19 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd18));
    wire coe_out_wen20 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd19));
    wire coe_out_wen21 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd20));
    wire coe_out_wen22 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd21));
    wire coe_out_wen23 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd22));
    wire coe_out_wen24 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd23));
    wire coe_out_wen25 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd24));
    wire coe_out_wen26 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd25));
    wire coe_out_wen27 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd26));
    wire coe_out_wen28 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd27));
    wire coe_out_wen29 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd28));
    wire coe_out_wen30 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd29));
    wire coe_out_wen31 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd30));
    wire coe_out_wen32 = (coe_out_wen_dd3 & (coe_out_wadrs_dd3[4:0] == 5'd31));
	
    wire[159:0] coe_out_wdat160 = { coe_out_wdat[153:144], coe_out_wdat[137:128], coe_out_wdat[121:112], coe_out_wdat[105:96], coe_out_wdat[89:80],
	                                coe_out_wdat[73:64],   coe_out_wdat[57:48],   coe_out_wdat[41:32],   coe_out_wdat[25:16],  coe_out_wdat[9:0]} ;

	coe_out_ram coe_out_ram01(.clk(clk_250MHz), .wen(coe_out_wen01), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat01[159:0] ));
	coe_out_ram coe_out_ram02(.clk(clk_250MHz), .wen(coe_out_wen02), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat02[159:0] ));
	coe_out_ram coe_out_ram03(.clk(clk_250MHz), .wen(coe_out_wen03), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat03[159:0] ));
	coe_out_ram coe_out_ram04(.clk(clk_250MHz), .wen(coe_out_wen04), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat04[159:0] ));
	coe_out_ram coe_out_ram05(.clk(clk_250MHz), .wen(coe_out_wen05), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat05[159:0] ));
	coe_out_ram coe_out_ram06(.clk(clk_250MHz), .wen(coe_out_wen06), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat06[159:0] ));
	coe_out_ram coe_out_ram07(.clk(clk_250MHz), .wen(coe_out_wen07), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat07[159:0] ));
	coe_out_ram coe_out_ram08(.clk(clk_250MHz), .wen(coe_out_wen08), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat08[159:0] ));
	coe_out_ram coe_out_ram09(.clk(clk_250MHz), .wen(coe_out_wen09), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat09[159:0] ));
	coe_out_ram coe_out_ram10(.clk(clk_250MHz), .wen(coe_out_wen10), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat10[159:0] ));
	coe_out_ram coe_out_ram11(.clk(clk_250MHz), .wen(coe_out_wen11), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat11[159:0] ));
	coe_out_ram coe_out_ram12(.clk(clk_250MHz), .wen(coe_out_wen12), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat12[159:0] ));
	coe_out_ram coe_out_ram13(.clk(clk_250MHz), .wen(coe_out_wen13), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat13[159:0] ));
	coe_out_ram coe_out_ram14(.clk(clk_250MHz), .wen(coe_out_wen14), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat14[159:0] ));
	coe_out_ram coe_out_ram15(.clk(clk_250MHz), .wen(coe_out_wen15), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat15[159:0] ));
	coe_out_ram coe_out_ram16(.clk(clk_250MHz), .wen(coe_out_wen16), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat16[159:0] ));
	coe_out_ram coe_out_ram17(.clk(clk_250MHz), .wen(coe_out_wen17), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat17[159:0] ));
	coe_out_ram coe_out_ram18(.clk(clk_250MHz), .wen(coe_out_wen18), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat18[159:0] ));
	coe_out_ram coe_out_ram19(.clk(clk_250MHz), .wen(coe_out_wen19), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat19[159:0] ));
	coe_out_ram coe_out_ram20(.clk(clk_250MHz), .wen(coe_out_wen20), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat20[159:0] ));
	coe_out_ram coe_out_ram21(.clk(clk_250MHz), .wen(coe_out_wen21), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat21[159:0] ));
	coe_out_ram coe_out_ram22(.clk(clk_250MHz), .wen(coe_out_wen22), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat22[159:0] ));
	coe_out_ram coe_out_ram23(.clk(clk_250MHz), .wen(coe_out_wen23), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat23[159:0] ));
	coe_out_ram coe_out_ram24(.clk(clk_250MHz), .wen(coe_out_wen24), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat24[159:0] ));
	coe_out_ram coe_out_ram25(.clk(clk_250MHz), .wen(coe_out_wen25), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat25[159:0] ));
	coe_out_ram coe_out_ram26(.clk(clk_250MHz), .wen(coe_out_wen26), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat26[159:0] ));
	coe_out_ram coe_out_ram27(.clk(clk_250MHz), .wen(coe_out_wen27), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat27[159:0] ));
	coe_out_ram coe_out_ram28(.clk(clk_250MHz), .wen(coe_out_wen28), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat28[159:0] ));
	coe_out_ram coe_out_ram29(.clk(clk_250MHz), .wen(coe_out_wen29), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat29[159:0] ));
	coe_out_ram coe_out_ram30(.clk(clk_250MHz), .wen(coe_out_wen30), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat30[159:0] ));
	coe_out_ram coe_out_ram31(.clk(clk_250MHz), .wen(coe_out_wen31), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat31[159:0] ));
	coe_out_ram coe_out_ram32(.clk(clk_250MHz), .wen(coe_out_wen32), .waddr(reg_adrs_dd3[9:0]), .raddr(coe_out_radrs[9:0] ), .wdat(coe_out_wdat160[159:0] ), .rdat(coe_out_rdat32[159:0] ));
	
	matrix_adc matrix_adc(
		.clk           (clk_250MHz                ),
		.rst           (rst                       ),
		.trg           (trg                       ),
        .adc_ram1_rdat (adc_ram1_rdat[159:0]      ),
        .adc_ram2_rdat (adc_ram2_rdat[159:0]      ),
        .adc_ram3_rdat (adc_ram3_rdat[159:0]      ),
        .adc_ram4_rdat (adc_ram4_rdat[159:0]      ),
        .adc_ram5_rdat (adc_ram5_rdat[159:0]      ),
        .adc_ram6_rdat (adc_ram6_rdat[159:0]      ),
        .adc_ram7_rdat (adc_ram7_rdat[159:0]      ),
        .adc_ram8_rdat (adc_ram8_rdat[159:0]      ),
		.adc_adr       (adc_adr[12:0]             ),
		.coe_adr       (coe_out_radrs[9:0]        ),
        .coe_dat01     (coe_out_rdat01[159:0]     ),
        .coe_dat02     (coe_out_rdat02[159:0]     ),
        .coe_dat03     (coe_out_rdat03[159:0]     ),
        .coe_dat04     (coe_out_rdat04[159:0]     ),
        .coe_dat05     (coe_out_rdat05[159:0]     ),
        .coe_dat06     (coe_out_rdat06[159:0]     ),
        .coe_dat07     (coe_out_rdat07[159:0]     ),
        .coe_dat08     (coe_out_rdat08[159:0]     ),
        .coe_dat09     (coe_out_rdat09[159:0]     ),
        .coe_dat10     (coe_out_rdat10[159:0]     ),
        .coe_dat11     (coe_out_rdat11[159:0]     ),
        .coe_dat12     (coe_out_rdat12[159:0]     ),
        .coe_dat13     (coe_out_rdat13[159:0]     ),
        .coe_dat14     (coe_out_rdat14[159:0]     ),
        .coe_dat15     (coe_out_rdat15[159:0]     ),
        .coe_dat16     (coe_out_rdat16[159:0]     ),
        .coe_dat17     (coe_out_rdat17[159:0]     ),
        .coe_dat18     (coe_out_rdat18[159:0]     ),
        .coe_dat19     (coe_out_rdat19[159:0]     ),
        .coe_dat20     (coe_out_rdat20[159:0]     ),
        .coe_dat21     (coe_out_rdat21[159:0]     ),
        .coe_dat22     (coe_out_rdat22[159:0]     ),
        .coe_dat23     (coe_out_rdat23[159:0]     ),
        .coe_dat24     (coe_out_rdat24[159:0]     ),
        .coe_dat25     (coe_out_rdat25[159:0]     ),
        .coe_dat26     (coe_out_rdat26[159:0]     ),
        .coe_dat27     (coe_out_rdat27[159:0]     ),
        .coe_dat28     (coe_out_rdat28[159:0]     ),
        .coe_dat29     (coe_out_rdat29[159:0]     ),
        .coe_dat30     (coe_out_rdat30[159:0]     ),
        .coe_dat31     (coe_out_rdat31[159:0]     ),
        .coe_dat32     (coe_out_rdat32[159:0]     ),
		.row1          (row1[4:0]                 ),
		.row2          (row2[4:0]                 ),
		.column        (column[12:0]              ),
        .column2       (column2[6:0]              ),
		.STATE         (STATE[3:0]                ),
        .out_en1       (wire_en1                  ),
        .out_en2       (wire_en2                  ),
        .out_en3       (wire_en3                  ),
        .out_en4       (wire_en4                  ),
        .out_en5       (wire_en5                  ),
        .out_en6       (wire_en6                  ),
        .out_en7       (wire_en7                  ),
        .out_en8       (wire_en8                  ),
        .out_dat1      (wire_dat1[17:0]           ),
        .out_dat2      (wire_dat2[17:0]           ),
        .out_dat3      (wire_dat3[17:0]           ),
        .out_dat4      (wire_dat4[17:0]           ),
        .out_dat5      (wire_dat5[17:0]           ),
        .out_dat6      (wire_dat6[17:0]           ),
        .out_dat7      (wire_dat7[17:0]           ),
        .out_dat8      (wire_dat8[17:0]           )
	);

    div_gen_adc div_gen1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en1), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en1),
        .s_axis_dividend_tdata  ({6'd0, wire_dat1[17:0]}),
        .m_axis_dout_tvalid     (div_en1),
        .m_axis_dout_tdata      (div_dat1[31:0])
    );

    div_gen_adc div_gen2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en2), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en2),
        .s_axis_dividend_tdata  ({6'd0, wire_dat2[17:0]}),
        .m_axis_dout_tvalid     (div_en2),
        .m_axis_dout_tdata      (div_dat2[31:0])
    );
	
    div_gen_adc div_gen3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en3), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en3),
        .s_axis_dividend_tdata  ({6'd0, wire_dat3[17:0]}),
        .m_axis_dout_tvalid     (div_en3),
        .m_axis_dout_tdata      (div_dat3[31:0])
    );
	
    div_gen_adc div_gen4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en4), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en4),
        .s_axis_dividend_tdata  ({6'd0, wire_dat4[17:0]}),
        .m_axis_dout_tvalid     (div_en4),
        .m_axis_dout_tdata      (div_dat4[31:0])
    );
	
    div_gen_adc div_gen5(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en5), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en5),
        .s_axis_dividend_tdata  ({6'd0, wire_dat5[17:0]}),
        .m_axis_dout_tvalid     (div_en5),
        .m_axis_dout_tdata      (div_dat5[31:0])
    );
	
    div_gen_adc div_gen6(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en6), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en6),
        .s_axis_dividend_tdata  ({6'd0, wire_dat6[17:0]}),
        .m_axis_dout_tvalid     (div_en6),
        .m_axis_dout_tdata      (div_dat6[31:0])
    );
	
    div_gen_adc div_gen7(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en7), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en7),
        .s_axis_dividend_tdata  ({6'd0, wire_dat7[17:0]}),
        .m_axis_dout_tvalid     (div_en7),
        .m_axis_dout_tdata      (div_dat7[31:0])
    );
	
    div_gen_adc div_gen8(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en8), 
        .s_axis_divisor_tdata   ({3'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en8),
        .s_axis_dividend_tdata  ({6'd0, wire_dat8[17:0]}),
        .m_axis_dout_tvalid     (div_en8),
        .m_axis_dout_tdata      (div_dat8[31:0])
    );


    assign adc_out_en1 = div_en1 ;
    assign adc_out_en2 = div_en2 ;
    assign adc_out_en3 = div_en3 ;
    assign adc_out_en4 = div_en4 ;
    assign adc_out_en5 = div_en5 ;
    assign adc_out_en6 = div_en6 ;
    assign adc_out_en7 = div_en7 ;
    assign adc_out_en8 = div_en8 ;
    assign adc_out_dat1[9:0] = (div_dat1[31:8] > 24'd1023)? 10'd1023 : div_dat1[17:8] ;
    assign adc_out_dat2[9:0] = (div_dat2[31:8] > 24'd1023)? 10'd1023 : div_dat2[17:8] ;
    assign adc_out_dat3[9:0] = (div_dat3[31:8] > 24'd1023)? 10'd1023 : div_dat3[17:8] ;
    assign adc_out_dat4[9:0] = (div_dat4[31:8] > 24'd1023)? 10'd1023 : div_dat4[17:8] ;
    assign adc_out_dat5[9:0] = (div_dat5[31:8] > 24'd1023)? 10'd1023 : div_dat5[17:8] ;
    assign adc_out_dat6[9:0] = (div_dat6[31:8] > 24'd1023)? 10'd1023 : div_dat6[17:8] ;
    assign adc_out_dat7[9:0] = (div_dat7[31:8] > 24'd1023)? 10'd1023 : div_dat7[17:8] ;
    assign adc_out_dat8[9:0] = (div_dat8[31:8] > 24'd1023)? 10'd1023 : div_dat8[17:8] ;


endmodule