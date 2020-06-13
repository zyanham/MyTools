module matrix_dac_top (
    input           clk_250MHz,
	input           rst,        // High_active
    input           trg,        // High_active

	input    [4:0]  row1,       // 0~31
	input    [4:0]  row2,       // 0~7
	input    [12:0] column,     // 0~4095

	// in_data_bram1 IF
    input          in_ram1_wen,
	input [5:0]    in_ram1_wadrs,
	input [255:0]  in_ram1_wdat,

	// in_data_bram2 IF
    input          in_ram2_wen,
	input [5:0]    in_ram2_wadrs,
	input [255:0]  in_ram2_wdat,

	// in_data_bram3 IF
    input          in_ram3_wen,
	input [5:0]    in_ram3_wadrs,
	input [255:0]  in_ram3_wdat,

	// in_data_bram4 IF
    input          in_ram4_wen,
	input [5:0]    in_ram4_wadrs,
	input [255:0]  in_ram4_wdat,

	// in_data_bram5 IF
    input          in_ram5_wen,
	input [5:0]    in_ram5_wadrs,
	input [255:0]  in_ram5_wdat,

	// in_data_bram6 IF
    input          in_ram6_wen,
	input [5:0]    in_ram6_wadrs,
	input [255:0]  in_ram6_wdat,

	// in_data_bram7 IF
    input          in_ram7_wen,
	input [5:0]    in_ram7_wadrs,
	input [255:0]  in_ram7_wdat,

	// in_data_bram8 IF
    input          in_ram8_wen,
	input [5:0]    in_ram8_wadrs,
	input [255:0]  in_ram8_wdat,

	// coe_data_bram IF
    input          coe_in_wen,
	input [12:0]   coe_in_wadrs,
	input [255:0]  coe_in_wdat,

    output   [3:0] STATE,

	output         dac_out_en1,
	output         dac_out_en2,
	output         dac_out_en3,
	output         dac_out_en4,
	output         dac_out_en5,
	output         dac_out_en6,
	output         dac_out_en7,
	output         dac_out_en8,
    output   [9:0] dac_out_dat1_1,
    output   [9:0] dac_out_dat1_2,
    output   [9:0] dac_out_dat1_3,
    output   [9:0] dac_out_dat1_4,
    output   [9:0] dac_out_dat2_1,
    output   [9:0] dac_out_dat2_2,
    output   [9:0] dac_out_dat2_3,
    output   [9:0] dac_out_dat2_4,
    output   [9:0] dac_out_dat3_1,
    output   [9:0] dac_out_dat3_2,
    output   [9:0] dac_out_dat3_3,
    output   [9:0] dac_out_dat3_4,
    output   [9:0] dac_out_dat4_1,
    output   [9:0] dac_out_dat4_2,
    output   [9:0] dac_out_dat4_3,
    output   [9:0] dac_out_dat4_4,
    output   [9:0] dac_out_dat5_1,
    output   [9:0] dac_out_dat5_2,
    output   [9:0] dac_out_dat5_3,
    output   [9:0] dac_out_dat5_4,
    output   [9:0] dac_out_dat6_1,
    output   [9:0] dac_out_dat6_2,
    output   [9:0] dac_out_dat6_3,
    output   [9:0] dac_out_dat6_4,
    output   [9:0] dac_out_dat7_1,
    output   [9:0] dac_out_dat7_2,
    output   [9:0] dac_out_dat7_3,
    output   [9:0] dac_out_dat7_4,
    output   [9:0] dac_out_dat8_1,
    output   [9:0] dac_out_dat8_2,
    output   [9:0] dac_out_dat8_3,
    output   [9:0] dac_out_dat8_4
);

//    wire  [255:0] in_ram1_rdat ;
//    wire  [255:0] in_ram2_rdat ;
//    wire  [255:0] in_ram3_rdat ;
//    wire  [255:0] in_ram4_rdat ;
//    wire  [255:0] in_ram5_rdat ;
//    wire  [255:0] in_ram6_rdat ;
//    wire  [255:0] in_ram7_rdat ;
//    wire  [255:0] in_ram8_rdat ;
//    wire  [255:0] coe_in_rdat1 ;
//    wire  [255:0] coe_in_rdat2 ;
//    wire  [255:0] coe_in_rdat3 ;
//    wire  [255:0] coe_in_rdat4 ;
//    wire  [255:0] coe_in_rdat5 ;
//    wire  [255:0] coe_in_rdat6 ;
//    wire  [255:0] coe_in_rdat7 ;
//    wire  [255:0] coe_in_rdat8 ;
    wire  [159:0] in_ram1_rdat ;
    wire  [159:0] in_ram2_rdat ;
    wire  [159:0] in_ram3_rdat ;
    wire  [159:0] in_ram4_rdat ;
    wire  [159:0] in_ram5_rdat ;
    wire  [159:0] in_ram6_rdat ;
    wire  [159:0] in_ram7_rdat ;
    wire  [159:0] in_ram8_rdat ;
    wire  [159:0] coe_in_rdat1 ;
    wire  [159:0] coe_in_rdat2 ;
    wire  [159:0] coe_in_rdat3 ;
    wire  [159:0] coe_in_rdat4 ;
    wire  [159:0] coe_in_rdat5 ;
    wire  [159:0] coe_in_rdat6 ;
    wire  [159:0] coe_in_rdat7 ;
    wire  [159:0] coe_in_rdat8 ;
    wire  [9:0]   coe_in_adr;

//coe_in_wen                                98_7654_3210
//    (column[12:0] > 13'd4094)? //4096 0b0_0XXX_0000_0000
//    (column[12:0] > 13'd2046)? //2048 0b0_00XX_X000_0000
//    (column[12:0] > 13'd1022)? //1024 0b0_000X_XX00_0000
//    (column[12:0] > 13'd510 )? //512  0b0_0000_XXX0_0000

    wire [9:0] coe_in_wadrs_uni = (column[12:0] > 13'd4094)? {coe_in_wadrs[12:11], coe_in_wadrs[7:0]} :
                                  (column[12:0] > 13'd2046)? {coe_in_wadrs[12:10], coe_in_wadrs[6:0]} :
                                  (column[12:0] > 13'd1022)? {coe_in_wadrs[12:9],  coe_in_wadrs[5:0]} :
                                  (column[12:0] > 13'd510 )? {coe_in_wadrs[12:8],  coe_in_wadrs[4:0]} :
								                             10'd0 ;

    wire coe_in_wen1 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd0)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd0)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd0)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd0)):
					                              1'd0 ;
    wire coe_in_wen2 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd1)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd1)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd1)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd1)):
					                              1'd0 ;
    wire coe_in_wen3 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd2)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd2)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd2)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd2)):
					                              1'd0 ;
    wire coe_in_wen4 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd3)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd3)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd3)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd3)):
					                              1'd0 ;
    wire coe_in_wen5 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd4)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd4)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd4)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd4)):
					                              1'd0 ;
    wire coe_in_wen6 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd5)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd5)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd5)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd5)):
					                              1'd0 ;
    wire coe_in_wen7 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd6)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd6)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd6)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd6)):
					                              1'd0 ;
    wire coe_in_wen8 = (column[12:0] > 13'd4094)? (coe_in_wen & (coe_in_wadrs[10:8] == 3'd7)):
                       (column[12:0] > 13'd2046)? (coe_in_wen & (coe_in_wadrs[9:7]  == 3'd7)):
                       (column[12:0] > 13'd1022)? (coe_in_wen & (coe_in_wadrs[8:6]  == 3'd7)):
                       (column[12:0] > 13'd510 )? (coe_in_wen & (coe_in_wadrs[7:5]  == 3'd7)):
					                              1'd0 ;

    wire[159:0] in_ram1_wdat160 = { in_ram1_wdat[153:144], in_ram1_wdat[137:128], in_ram1_wdat[121:112], in_ram1_wdat[105:96], in_ram1_wdat[89:80],
	                                in_ram1_wdat[73:64],   in_ram1_wdat[57:48],   in_ram1_wdat[41:32],   in_ram1_wdat[25:16],  in_ram1_wdat[9:0]} ;
    wire[159:0] in_ram2_wdat160 = { in_ram2_wdat[153:144], in_ram2_wdat[137:128], in_ram2_wdat[121:112], in_ram2_wdat[105:96], in_ram2_wdat[89:80],
	                                in_ram2_wdat[73:64],   in_ram2_wdat[57:48],   in_ram2_wdat[41:32],   in_ram2_wdat[25:16],  in_ram2_wdat[9:0]} ;
    wire[159:0] in_ram3_wdat160 = { in_ram3_wdat[153:144], in_ram3_wdat[137:128], in_ram3_wdat[121:112], in_ram3_wdat[105:96], in_ram3_wdat[89:80],
	                                in_ram3_wdat[73:64],   in_ram3_wdat[57:48],   in_ram3_wdat[41:32],   in_ram3_wdat[25:16],  in_ram3_wdat[9:0]} ;
    wire[159:0] in_ram4_wdat160 = { in_ram4_wdat[153:144], in_ram4_wdat[137:128], in_ram4_wdat[121:112], in_ram4_wdat[105:96], in_ram4_wdat[89:80],
	                                in_ram4_wdat[73:64],   in_ram4_wdat[57:48],   in_ram4_wdat[41:32],   in_ram4_wdat[25:16],  in_ram4_wdat[9:0]} ;
    wire[159:0] in_ram5_wdat160 = { in_ram5_wdat[153:144], in_ram5_wdat[137:128], in_ram5_wdat[121:112], in_ram5_wdat[105:96], in_ram5_wdat[89:80],
	                                in_ram5_wdat[73:64],   in_ram5_wdat[57:48],   in_ram5_wdat[41:32],   in_ram5_wdat[25:16],  in_ram5_wdat[9:0]} ;
    wire[159:0] in_ram6_wdat160 = { in_ram6_wdat[153:144], in_ram6_wdat[137:128], in_ram6_wdat[121:112], in_ram6_wdat[105:96], in_ram6_wdat[89:80],
	                                in_ram6_wdat[73:64],   in_ram6_wdat[57:48],   in_ram6_wdat[41:32],   in_ram6_wdat[25:16],  in_ram6_wdat[9:0]} ;
    wire[159:0] in_ram7_wdat160 = { in_ram7_wdat[153:144], in_ram7_wdat[137:128], in_ram7_wdat[121:112], in_ram7_wdat[105:96], in_ram7_wdat[89:80],
	                                in_ram7_wdat[73:64],   in_ram7_wdat[57:48],   in_ram7_wdat[41:32],   in_ram7_wdat[25:16],  in_ram7_wdat[9:0]} ;
    wire[159:0] in_ram8_wdat160 = { in_ram8_wdat[153:144], in_ram8_wdat[137:128], in_ram8_wdat[121:112], in_ram8_wdat[105:96], in_ram8_wdat[89:80],
	                                in_ram8_wdat[73:64],   in_ram8_wdat[57:48],   in_ram8_wdat[41:32],   in_ram8_wdat[25:16],  in_ram8_wdat[9:0]} ;
    wire[159:0] coe_in_wdat160  = { coe_in_wdat[153:144],  coe_in_wdat[137:128],  coe_in_wdat[121:112],  coe_in_wdat[105:96],  coe_in_wdat[89:80],
	                                coe_in_wdat[73:64],    coe_in_wdat[57:48],    coe_in_wdat[41:32],    coe_in_wdat[25:16],   coe_in_wdat[9:0]} ;



    wire [255:0] in_ram_rdat   ;
	wire   [5:0] in_ram_radrs  ;
	
    wire         wire_en1_1, wire_en1_2, wire_en1_3, wire_en1_4,
                 wire_en2_1, wire_en2_2, wire_en2_3, wire_en2_4,
                 wire_en3_1, wire_en3_2, wire_en3_3, wire_en3_4,
                 wire_en4_1, wire_en4_2, wire_en4_3, wire_en4_4,
                 wire_en5_1, wire_en5_2, wire_en5_3, wire_en5_4,
                 wire_en6_1, wire_en6_2, wire_en6_3, wire_en6_4,
                 wire_en7_1, wire_en7_2, wire_en7_3, wire_en7_4,
                 wire_en8_1, wire_en8_2, wire_en8_3, wire_en8_4;

    wire [14:0]  wire_dat1_1, wire_dat1_2, wire_dat1_3, wire_dat1_4,
                 wire_dat2_1, wire_dat2_2, wire_dat2_3, wire_dat2_4,
                 wire_dat3_1, wire_dat3_2, wire_dat3_3, wire_dat3_4,
                 wire_dat4_1, wire_dat4_2, wire_dat4_3, wire_dat4_4,
                 wire_dat5_1, wire_dat5_2, wire_dat5_3, wire_dat5_4,
                 wire_dat6_1, wire_dat6_2, wire_dat6_3, wire_dat6_4,
                 wire_dat7_1, wire_dat7_2, wire_dat7_3, wire_dat7_4,
                 wire_dat8_1, wire_dat8_2, wire_dat8_3, wire_dat8_4;

    wire         div_en1_1, div_en1_2, div_en1_3, div_en1_4,
                 div_en2_1, div_en2_2, div_en2_3, div_en2_4,
                 div_en3_1, div_en3_2, div_en3_3, div_en3_4,
                 div_en4_1, div_en4_2, div_en4_3, div_en4_4,
                 div_en5_1, div_en5_2, div_en5_3, div_en5_4,
                 div_en6_1, div_en6_2, div_en6_3, div_en6_4,
                 div_en7_1, div_en7_2, div_en7_3, div_en7_4,
                 div_en8_1, div_en8_2, div_en8_3, div_en8_4;

    wire [23:0]  div_dat1_1, div_dat1_2, div_dat1_3, div_dat1_4,
                 div_dat2_1, div_dat2_2, div_dat2_3, div_dat2_4,
                 div_dat3_1, div_dat3_2, div_dat3_3, div_dat3_4,
                 div_dat4_1, div_dat4_2, div_dat4_3, div_dat4_4,
                 div_dat5_1, div_dat5_2, div_dat5_3, div_dat5_4,
                 div_dat6_1, div_dat6_2, div_dat6_3, div_dat6_4,
                 div_dat7_1, div_dat7_2, div_dat7_3, div_dat7_4,
                 div_dat8_1, div_dat8_2, div_dat8_3, div_dat8_4;

	in_ram in_ram1(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram1_wen        ),
        .waddr    (in_ram1_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram1_wdat160[159:0]),
        .rdat     (in_ram1_rdat[159:0])		
	);

	in_ram in_ram2(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram2_wen        ),
        .waddr    (in_ram2_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram2_wdat160[159:0]),
        .rdat     (in_ram2_rdat[159:0])		
	);
	
	in_ram in_ram3(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram3_wen        ),
        .waddr    (in_ram3_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram3_wdat160[159:0]),
        .rdat     (in_ram3_rdat[159:0])		
	);

	in_ram in_ram4(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram4_wen        ),
        .waddr    (in_ram4_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram4_wdat160[159:0]),
        .rdat     (in_ram4_rdat[159:0])		
	);

	in_ram in_ram5(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram5_wen        ),
        .waddr    (in_ram5_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram5_wdat160[159:0]),
        .rdat     (in_ram5_rdat[159:0])		
	);

	in_ram in_ram6(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram6_wen        ),
        .waddr    (in_ram6_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram6_wdat160[159:0]),
        .rdat     (in_ram6_rdat[159:0])		
	);

	in_ram in_ram7(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram7_wen        ),
        .waddr    (in_ram7_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram7_wdat160[159:0]),
        .rdat     (in_ram7_rdat[159:0])		
	);

	in_ram in_ram8(
	    .clk      (clk_250MHz         ),
	    .wen      (in_ram8_wen        ),
        .waddr    (in_ram8_wadrs[5:0] ),
        .raddr    (in_ram_radrs[5:0]  ),
        .wdat     (in_ram8_wdat160[159:0]),
        .rdat     (in_ram8_rdat[159:0])		
	);

	coe_in_ram coe_in_ram1(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen1         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat1[159:0] )		
	);

	coe_in_ram coe_in_ram2(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen2         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat2[159:0] )		
	);

	coe_in_ram coe_in_ram3(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen3         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat3[159:0] )		
	);

	coe_in_ram coe_in_ram4(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen4         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat4[159:0] )		
	);

	coe_in_ram coe_in_ram5(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen5         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat5[159:0] )		
	);

	coe_in_ram coe_in_ram6(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen6         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat6[159:0] )		
	);

	coe_in_ram coe_in_ram7(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen7         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat7[159:0] )		
	);

	coe_in_ram coe_in_ram8(
	    .clk      (clk_250MHz          ),
	    .wen      (coe_in_wen8         ),
        .waddr    (coe_in_wadrs_uni[9:0]),
        .raddr    (coe_in_adr[9:0]     ),
        .wdat     (coe_in_wdat160[159:0]),
        .rdat     (coe_in_rdat8[159:0] )		
	);

	
	matrix_dac matrix_dac(
		.clk        (clk_250MHz             ),
		.rst        (rst                    ),
		.trg        (trg                    ),
		.in_dat1    (in_ram1_rdat[159:0]    ),
		.in_dat2    (in_ram2_rdat[159:0]    ),
		.in_dat3    (in_ram3_rdat[159:0]    ),
		.in_dat4    (in_ram4_rdat[159:0]    ),
		.in_dat5    (in_ram5_rdat[159:0]    ),
		.in_dat6    (in_ram6_rdat[159:0]    ),
		.in_dat7    (in_ram7_rdat[159:0]    ),
		.in_dat8    (in_ram8_rdat[159:0]    ),
		.in_adr     (in_ram_radrs[5:0]      ),
		.coe_dat1   (coe_in_rdat1[159:0]    ),
		.coe_dat2   (coe_in_rdat2[159:0]    ),
		.coe_dat3   (coe_in_rdat3[159:0]    ),
		.coe_dat4   (coe_in_rdat4[159:0]    ),
		.coe_dat5   (coe_in_rdat5[159:0]    ),
		.coe_dat6   (coe_in_rdat6[159:0]    ),
		.coe_dat7   (coe_in_rdat7[159:0]    ),
		.coe_dat8   (coe_in_rdat8[159:0]    ),
		.coe_adr    (coe_in_adr[9:0]       ),
		.row1       (row1[4:0]              ),
		.column     (column[12:0]           ),
		.STATE      (STATE[3:0]             ),
        .out_en1_1  (wire_en1_1             ),
        .out_en1_2  (wire_en1_2             ),
        .out_en1_3  (wire_en1_3             ),
        .out_en1_4  (wire_en1_4             ),
        .out_dat1_1 (wire_dat1_1[14:0]      ),
        .out_dat1_2 (wire_dat1_2[14:0]      ),
        .out_dat1_3 (wire_dat1_3[14:0]      ),
        .out_dat1_4 (wire_dat1_4[14:0]      ),
        .out_en2_1  (wire_en2_1             ),
        .out_en2_2  (wire_en2_2             ),
        .out_en2_3  (wire_en2_3             ),
        .out_en2_4  (wire_en2_4             ),
        .out_dat2_1 (wire_dat2_1[14:0]      ),
        .out_dat2_2 (wire_dat2_2[14:0]      ),
        .out_dat2_3 (wire_dat2_3[14:0]      ),
        .out_dat2_4 (wire_dat2_4[14:0]      ),
        .out_en3_1  (wire_en3_1             ),
        .out_en3_2  (wire_en3_2             ),
        .out_en3_3  (wire_en3_3             ),
        .out_en3_4  (wire_en3_4             ),
        .out_dat3_1 (wire_dat3_1[14:0]      ),
        .out_dat3_2 (wire_dat3_2[14:0]      ),
        .out_dat3_3 (wire_dat3_3[14:0]      ),
        .out_dat3_4 (wire_dat3_4[14:0]      ),
        .out_en4_1  (wire_en4_1             ),
        .out_en4_2  (wire_en4_2             ),
        .out_en4_3  (wire_en4_3             ),
        .out_en4_4  (wire_en4_4             ),
        .out_dat4_1 (wire_dat4_1[14:0]      ),
        .out_dat4_2 (wire_dat4_2[14:0]      ),
        .out_dat4_3 (wire_dat4_3[14:0]      ),
        .out_dat4_4 (wire_dat4_4[14:0]      ),
        .out_en5_1  (wire_en5_1             ),
        .out_en5_2  (wire_en5_2             ),
        .out_en5_3  (wire_en5_3             ),
        .out_en5_4  (wire_en5_4             ),
        .out_dat5_1 (wire_dat5_1[14:0]      ),
        .out_dat5_2 (wire_dat5_2[14:0]      ),
        .out_dat5_3 (wire_dat5_3[14:0]      ),
        .out_dat5_4 (wire_dat5_4[14:0]      ),
        .out_en6_1  (wire_en6_1             ),
        .out_en6_2  (wire_en6_2             ),
        .out_en6_3  (wire_en6_3             ),
        .out_en6_4  (wire_en6_4             ),
        .out_dat6_1 (wire_dat6_1[14:0]      ),
        .out_dat6_2 (wire_dat6_2[14:0]      ),
        .out_dat6_3 (wire_dat6_3[14:0]      ),
        .out_dat6_4 (wire_dat6_4[14:0]      ),
        .out_en7_1  (wire_en7_1             ),
        .out_en7_2  (wire_en7_2             ),
        .out_en7_3  (wire_en7_3             ),
        .out_en7_4  (wire_en7_4             ),
        .out_dat7_1 (wire_dat7_1[14:0]      ),
        .out_dat7_2 (wire_dat7_2[14:0]      ),
        .out_dat7_3 (wire_dat7_3[14:0]      ),
        .out_dat7_4 (wire_dat7_4[14:0]      ),
        .out_en8_1  (wire_en8_1             ),
        .out_en8_2  (wire_en8_2             ),
        .out_en8_3  (wire_en8_3             ),
        .out_en8_4  (wire_en8_4             ),
        .out_dat8_1 (wire_dat8_1[14:0]      ),
        .out_dat8_2 (wire_dat8_2[14:0]      ),
        .out_dat8_3 (wire_dat8_3[14:0]      ),
        .out_dat8_4 (wire_dat8_4[14:0]      )
	);
	
    div_gen_dac div_gen1_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en1_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en1_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat1_1[14:0]}),
        .m_axis_dout_tvalid     (div_en1_1),
        .m_axis_dout_tdata      (div_dat1_1[23:0])
    );

    div_gen_dac div_gen1_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en1_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en1_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat1_2[14:0]}),
        .m_axis_dout_tvalid     (div_en1_2),
        .m_axis_dout_tdata      (div_dat1_2[23:0])
    );

    div_gen_dac div_gen1_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en1_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en1_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat1_3[14:0]}),
        .m_axis_dout_tvalid     (div_en1_3),
        .m_axis_dout_tdata      (div_dat1_3[23:0])
    );

    div_gen_dac div_gen1_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en1_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en1_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat1_4[14:0]}),
        .m_axis_dout_tvalid     (div_en1_4),
        .m_axis_dout_tdata      (div_dat1_4[23:0])
    );

    div_gen_dac div_gen2_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en2_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en2_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat2_1[14:0]}),
        .m_axis_dout_tvalid     (div_en2_1),
        .m_axis_dout_tdata      (div_dat2_1[23:0])
    );

    div_gen_dac div_gen2_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en2_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en2_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat2_2[14:0]}),
        .m_axis_dout_tvalid     (div_en2_2),
        .m_axis_dout_tdata      (div_dat2_2[23:0])
    );

    div_gen_dac div_gen2_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en2_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en2_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat2_3[14:0]}),
        .m_axis_dout_tvalid     (div_en2_3),
        .m_axis_dout_tdata      (div_dat2_3[23:0])
    );

    div_gen_dac div_gen2_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en2_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en2_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat2_4[14:0]}),
        .m_axis_dout_tvalid     (div_en2_4),
        .m_axis_dout_tdata      (div_dat2_4[23:0])
    );

    div_gen_dac div_gen3_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en3_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en3_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat3_1[14:0]}),
        .m_axis_dout_tvalid     (div_en3_1),
        .m_axis_dout_tdata      (div_dat3_1[23:0])
    );

    div_gen_dac div_gen3_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en3_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en3_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat3_2[14:0]}),
        .m_axis_dout_tvalid     (div_en3_2),
        .m_axis_dout_tdata      (div_dat3_2[23:0])
    );

    div_gen_dac div_gen3_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en3_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en3_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat3_3[14:0]}),
        .m_axis_dout_tvalid     (div_en3_3),
        .m_axis_dout_tdata      (div_dat3_3[23:0])
    );

    div_gen_dac div_gen3_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en3_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en3_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat3_4[14:0]}),
        .m_axis_dout_tvalid     (div_en3_4),
        .m_axis_dout_tdata      (div_dat3_4[23:0])
    );

    div_gen_dac div_gen4_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en4_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en4_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat4_1[14:0]}),
        .m_axis_dout_tvalid     (div_en4_1),
        .m_axis_dout_tdata      (div_dat4_1[23:0])
    );

    div_gen_dac div_gen4_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en4_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en4_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat4_2[14:0]}),
        .m_axis_dout_tvalid     (div_en4_2),
        .m_axis_dout_tdata      (div_dat4_2[23:0])
    );

    div_gen_dac div_gen4_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en4_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en4_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat4_3[14:0]}),
        .m_axis_dout_tvalid     (div_en4_3),
        .m_axis_dout_tdata      (div_dat4_3[23:0])
    );

    div_gen_dac div_gen4_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en4_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en4_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat4_4[14:0]}),
        .m_axis_dout_tvalid     (div_en4_4),
        .m_axis_dout_tdata      (div_dat4_4[23:0])
    );

    div_gen_dac div_gen5_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en5_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en5_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat5_1[14:0]}),
        .m_axis_dout_tvalid     (div_en5_1),
        .m_axis_dout_tdata      (div_dat5_1[23:0])
    );

    div_gen_dac div_gen5_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en5_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en5_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat5_2[14:0]}),
        .m_axis_dout_tvalid     (div_en5_2),
        .m_axis_dout_tdata      (div_dat5_2[23:0])
    );

    div_gen_dac div_gen5_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en5_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en5_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat5_3[14:0]}),
        .m_axis_dout_tvalid     (div_en5_3),
        .m_axis_dout_tdata      (div_dat5_3[23:0])
    );

    div_gen_dac div_gen5_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en5_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en5_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat5_4[14:0]}),
        .m_axis_dout_tvalid     (div_en5_4),
        .m_axis_dout_tdata      (div_dat5_4[23:0])
    );

    div_gen_dac div_gen6_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en6_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en6_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat6_1[14:0]}),
        .m_axis_dout_tvalid     (div_en6_1),
        .m_axis_dout_tdata      (div_dat6_1[23:0])
    );

    div_gen_dac div_gen6_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en6_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en6_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat6_2[14:0]}),
        .m_axis_dout_tvalid     (div_en6_2),
        .m_axis_dout_tdata      (div_dat6_2[23:0])
    );

    div_gen_dac div_gen6_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en6_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en6_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat6_3[14:0]}),
        .m_axis_dout_tvalid     (div_en6_3),
        .m_axis_dout_tdata      (div_dat6_3[23:0])
    );

    div_gen_dac div_gen6_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en6_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en6_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat6_4[14:0]}),
        .m_axis_dout_tvalid     (div_en6_4),
        .m_axis_dout_tdata      (div_dat6_4[23:0])
    );

    div_gen_dac div_gen7_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en7_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en7_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat7_1[14:0]}),
        .m_axis_dout_tvalid     (div_en7_1),
        .m_axis_dout_tdata      (div_dat7_1[23:0])
    );

    div_gen_dac div_gen7_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en7_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en7_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat7_2[14:0]}),
        .m_axis_dout_tvalid     (div_en7_2),
        .m_axis_dout_tdata      (div_dat7_2[23:0])
    );

    div_gen_dac div_gen7_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en7_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en7_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat7_3[14:0]}),
        .m_axis_dout_tvalid     (div_en7_3),
        .m_axis_dout_tdata      (div_dat7_3[23:0])
    );

    div_gen_dac div_gen7_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en7_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en7_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat7_4[14:0]}),
        .m_axis_dout_tvalid     (div_en7_4),
        .m_axis_dout_tdata      (div_dat7_4[23:0])
    );

    div_gen_dac div_gen8_1(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en8_1), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en8_1),
        .s_axis_dividend_tdata  ({1'd0, wire_dat8_1[14:0]}),
        .m_axis_dout_tvalid     (div_en8_1),
        .m_axis_dout_tdata      (div_dat8_1[23:0])
    );

    div_gen_dac div_gen8_2(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en8_2), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en8_2),
        .s_axis_dividend_tdata  ({1'd0, wire_dat8_2[14:0]}),
        .m_axis_dout_tvalid     (div_en8_2),
        .m_axis_dout_tdata      (div_dat8_2[23:0])
    );

    div_gen_dac div_gen8_3(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en8_3), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en8_3),
        .s_axis_dividend_tdata  ({1'd0, wire_dat8_3[14:0]}),
        .m_axis_dout_tvalid     (div_en8_3),
        .m_axis_dout_tdata      (div_dat8_3[23:0])
    );

    div_gen_dac div_gen8_4(
        .aclk                   (clk_250MHz),
        .s_axis_divisor_tvalid  (wire_en8_4), 
        .s_axis_divisor_tdata   ({2'd0, row2[4:0]}),
        .s_axis_dividend_tvalid (wire_en8_4),
        .s_axis_dividend_tdata  ({1'd0, wire_dat8_4[14:0]}),
        .m_axis_dout_tvalid     (div_en8_4),
        .m_axis_dout_tdata      (div_dat8_4[23:0])
    );

    assign dac_out_en1         = (div_en1_1 | div_en1_2 | div_en1_3 | div_en1_4) ;
    assign dac_out_dat1_1[9:0] = (div_dat1_1[23:8] > 16'd1023)? 10'd1023 : div_dat1_1[17:8] ;
    assign dac_out_dat1_2[9:0] = (div_dat1_2[23:8] > 16'd1023)? 10'd1023 : div_dat1_2[17:8] ;
    assign dac_out_dat1_3[9:0] = (div_dat1_3[23:8] > 16'd1023)? 10'd1023 : div_dat1_3[17:8] ;
    assign dac_out_dat1_4[9:0] = (div_dat1_4[23:8] > 16'd1023)? 10'd1023 : div_dat1_4[17:8] ;

    assign dac_out_en2         = (div_en2_1 | div_en2_2 | div_en2_3 | div_en2_4) ;
    assign dac_out_dat2_1[9:0] = (div_dat2_1[23:8] > 16'd1023)? 10'd1023 : div_dat2_1[17:8] ;
    assign dac_out_dat2_2[9:0] = (div_dat2_2[23:8] > 16'd1023)? 10'd1023 : div_dat2_2[17:8] ;
    assign dac_out_dat2_3[9:0] = (div_dat2_3[23:8] > 16'd1023)? 10'd1023 : div_dat2_3[17:8] ;
    assign dac_out_dat2_4[9:0] = (div_dat2_4[23:8] > 16'd1023)? 10'd1023 : div_dat2_4[17:8] ;

    assign dac_out_en3         = (div_en3_1 | div_en3_2 | div_en3_3 | div_en3_4) ;
    assign dac_out_dat3_1[9:0] = (div_dat3_1[23:8] > 16'd1023)? 10'd1023 : div_dat3_1[17:8] ;
    assign dac_out_dat3_2[9:0] = (div_dat3_2[23:8] > 16'd1023)? 10'd1023 : div_dat3_2[17:8] ;
    assign dac_out_dat3_3[9:0] = (div_dat3_3[23:8] > 16'd1023)? 10'd1023 : div_dat3_3[17:8] ;
    assign dac_out_dat3_4[9:0] = (div_dat3_4[23:8] > 16'd1023)? 10'd1023 : div_dat3_4[17:8] ;

    assign dac_out_en4         = (div_en4_1 | div_en4_2 | div_en4_3 | div_en4_4) ;
    assign dac_out_dat4_1[9:0] = (div_dat4_1[23:8] > 16'd1023)? 10'd1023 : div_dat4_1[17:8] ;
    assign dac_out_dat4_2[9:0] = (div_dat4_2[23:8] > 16'd1023)? 10'd1023 : div_dat4_2[17:8] ;
    assign dac_out_dat4_3[9:0] = (div_dat4_3[23:8] > 16'd1023)? 10'd1023 : div_dat4_3[17:8] ;
    assign dac_out_dat4_4[9:0] = (div_dat4_4[23:8] > 16'd1023)? 10'd1023 : div_dat4_4[17:8] ;

    assign dac_out_en5         = (div_en5_1 | div_en5_2 | div_en5_3 | div_en5_4) ;
    assign dac_out_dat5_1[9:0] = (div_dat5_1[23:8] > 16'd1023)? 10'd1023 : div_dat5_1[17:8] ;
    assign dac_out_dat5_2[9:0] = (div_dat5_2[23:8] > 16'd1023)? 10'd1023 : div_dat5_2[17:8] ;
    assign dac_out_dat5_3[9:0] = (div_dat5_3[23:8] > 16'd1023)? 10'd1023 : div_dat5_3[17:8] ;
    assign dac_out_dat5_4[9:0] = (div_dat5_4[23:8] > 16'd1023)? 10'd1023 : div_dat5_4[17:8] ;

    assign dac_out_en6         = (div_en6_1 | div_en6_2 | div_en6_3 | div_en6_4) ;
    assign dac_out_dat6_1[9:0] = (div_dat6_1[23:8] > 16'd1023)? 10'd1023 : div_dat6_1[17:8] ;
    assign dac_out_dat6_2[9:0] = (div_dat6_2[23:8] > 16'd1023)? 10'd1023 : div_dat6_2[17:8] ;
    assign dac_out_dat6_3[9:0] = (div_dat6_3[23:8] > 16'd1023)? 10'd1023 : div_dat6_3[17:8] ;
    assign dac_out_dat6_4[9:0] = (div_dat6_4[23:8] > 16'd1023)? 10'd1023 : div_dat6_4[17:8] ;

    assign dac_out_en7         = (div_en7_1 | div_en7_2 | div_en7_3 | div_en7_4) ;
    assign dac_out_dat7_1[9:0] = (div_dat7_1[23:8] > 16'd1023)? 10'd1023 : div_dat7_1[17:8] ;
    assign dac_out_dat7_2[9:0] = (div_dat7_2[23:8] > 16'd1023)? 10'd1023 : div_dat7_2[17:8] ;
    assign dac_out_dat7_3[9:0] = (div_dat7_3[23:8] > 16'd1023)? 10'd1023 : div_dat7_3[17:8] ;
    assign dac_out_dat7_4[9:0] = (div_dat7_4[23:8] > 16'd1023)? 10'd1023 : div_dat7_4[17:8] ;

    assign dac_out_en8         = (div_en8_1 | div_en8_2 | div_en8_3 | div_en8_4) ;
    assign dac_out_dat8_1[9:0] = (div_dat8_1[23:8] > 16'd1023)? 10'd1023 : div_dat8_1[17:8] ;
    assign dac_out_dat8_2[9:0] = (div_dat8_2[23:8] > 16'd1023)? 10'd1023 : div_dat8_2[17:8] ;
    assign dac_out_dat8_3[9:0] = (div_dat8_3[23:8] > 16'd1023)? 10'd1023 : div_dat8_3[17:8] ;
    assign dac_out_dat8_4[9:0] = (div_dat8_4[23:8] > 16'd1023)? 10'd1023 : div_dat8_4[17:8] ;

endmodule