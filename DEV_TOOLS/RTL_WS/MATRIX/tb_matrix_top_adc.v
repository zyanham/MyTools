module tb_matrix_top_adc(
    input           clk_250MHz,
	input           rst,        // High_active
    input           trg,        // High_active

    output   [3:0]  STATE,
	input    [4:0]  row1,       // 0~31
	input    [4:0]  row2,       // 0~3
	input    [12:0] column,     // 0~4096
	input    [6:0]  column2     // 0~128
);
		
	//******************
	// ADC->OUTPUT Side
	//******************
	wire         adc_ram1_wen   ;
	wire [12:0]  adc_ram1_wadrs ;
	wire [255:0] adc_ram1_wdat  ;
	wire         adc_ram2_wen   ;
	wire [12:0]  adc_ram2_wadrs ;
	wire [255:0] adc_ram2_wdat  ;
	wire         adc_ram3_wen   ;
	wire [12:0]  adc_ram3_wadrs ;
	wire [255:0] adc_ram3_wdat  ;
	wire         adc_ram4_wen   ;
	wire [12:0]  adc_ram4_wadrs ;
	wire [255:0] adc_ram4_wdat  ;
	wire         adc_ram5_wen   ;
	wire [12:0]  adc_ram5_wadrs ;
	wire [255:0] adc_ram5_wdat  ;
	wire         adc_ram6_wen   ;
	wire [12:0]  adc_ram6_wadrs ;
	wire [255:0] adc_ram6_wdat  ;
	wire         adc_ram7_wen   ;
	wire [12:0]  adc_ram7_wadrs ;
	wire [255:0] adc_ram7_wdat  ;
	wire         adc_ram8_wen   ;
	wire [12:0]  adc_ram8_wadrs ;
	wire [255:0] adc_ram8_wdat  ;
    wire [159:0] adc_ram1_rdat  ;
    wire [159:0] adc_ram2_rdat  ;
    wire [159:0] adc_ram3_rdat  ;
    wire [159:0] adc_ram4_rdat  ;
    wire [159:0] adc_ram5_rdat  ;
    wire [159:0] adc_ram6_rdat  ;
    wire [159:0] adc_ram7_rdat  ;
    wire [159:0] adc_ram8_rdat  ;
	wire  [12:0] adc_adr        ;  // 32x4096x10=1310720bit 0~5119:addr->13bit
	wire         coe_out_wen    ;
	wire [12:0]  coe_out_wadrs  ;
	wire [255:0] coe_out_wdat   ;
	wire         adc_out_en1    ;
	wire         adc_out_en2    ;
	wire         adc_out_en3    ;
	wire         adc_out_en4    ;
	wire         adc_out_en5    ;
	wire         adc_out_en6    ;
	wire         adc_out_en7    ;
	wire         adc_out_en8    ;
	wire [9:0]   adc_out_dat1   ;
	wire [9:0]   adc_out_dat2   ;
	wire [9:0]   adc_out_dat3   ;
	wire [9:0]   adc_out_dat4   ;
	wire [9:0]   adc_out_dat5   ;
	wire [9:0]   adc_out_dat6   ;
	wire [9:0]   adc_out_dat7   ;
	wire [9:0]   adc_out_dat8   ;

    wire [3:0] STATE;

	wire[159:0] adc_ram1_wdat160 = { adc_ram1_wdat[153:144], adc_ram1_wdat[137:128], adc_ram1_wdat[121:112], adc_ram1_wdat[105:96], adc_ram1_wdat[89:80],
	                                 adc_ram1_wdat[73:64],   adc_ram1_wdat[57:48],   adc_ram1_wdat[41:32],   adc_ram1_wdat[25:16],  adc_ram1_wdat[9:0]} ;
    wire[159:0] adc_ram2_wdat160 = { adc_ram2_wdat[153:144], adc_ram2_wdat[137:128], adc_ram2_wdat[121:112], adc_ram2_wdat[105:96], adc_ram2_wdat[89:80],
	                                 adc_ram2_wdat[73:64],   adc_ram2_wdat[57:48],   adc_ram2_wdat[41:32],   adc_ram2_wdat[25:16],  adc_ram2_wdat[9:0]} ;
    wire[159:0] adc_ram3_wdat160 = { adc_ram3_wdat[153:144], adc_ram3_wdat[137:128], adc_ram3_wdat[121:112], adc_ram3_wdat[105:96], adc_ram3_wdat[89:80],
	                                 adc_ram3_wdat[73:64],   adc_ram3_wdat[57:48],   adc_ram3_wdat[41:32],   adc_ram3_wdat[25:16],  adc_ram3_wdat[9:0]} ;
    wire[159:0] adc_ram4_wdat160 = { adc_ram4_wdat[153:144], adc_ram4_wdat[137:128], adc_ram4_wdat[121:112], adc_ram4_wdat[105:96], adc_ram4_wdat[89:80],
	                                 adc_ram4_wdat[73:64],   adc_ram4_wdat[57:48],   adc_ram4_wdat[41:32],   adc_ram4_wdat[25:16],  adc_ram4_wdat[9:0]} ;
    wire[159:0] adc_ram5_wdat160 = { adc_ram5_wdat[153:144], adc_ram5_wdat[137:128], adc_ram5_wdat[121:112], adc_ram5_wdat[105:96], adc_ram5_wdat[89:80],
	                                 adc_ram5_wdat[73:64],   adc_ram5_wdat[57:48],   adc_ram5_wdat[41:32],   adc_ram5_wdat[25:16],  adc_ram5_wdat[9:0]} ;
    wire[159:0] adc_ram6_wdat160 = { adc_ram6_wdat[153:144], adc_ram6_wdat[137:128], adc_ram6_wdat[121:112], adc_ram6_wdat[105:96], adc_ram6_wdat[89:80],
	                                 adc_ram6_wdat[73:64],   adc_ram6_wdat[57:48],   adc_ram6_wdat[41:32],   adc_ram6_wdat[25:16],  adc_ram6_wdat[9:0]} ;
    wire[159:0] adc_ram7_wdat160 = { adc_ram7_wdat[153:144], adc_ram7_wdat[137:128], adc_ram7_wdat[121:112], adc_ram7_wdat[105:96], adc_ram7_wdat[89:80],
	                                 adc_ram7_wdat[73:64],   adc_ram7_wdat[57:48],   adc_ram7_wdat[41:32],   adc_ram7_wdat[25:16],  adc_ram7_wdat[9:0]} ;
    wire[159:0] adc_ram8_wdat160 = { adc_ram8_wdat[153:144], adc_ram8_wdat[137:128], adc_ram8_wdat[121:112], adc_ram8_wdat[105:96], adc_ram8_wdat[89:80],
	                                 adc_ram8_wdat[73:64],   adc_ram8_wdat[57:48],   adc_ram8_wdat[41:32],   adc_ram8_wdat[25:16],  adc_ram8_wdat[9:0]} ;

    matrix_adc_top matrix_adc_top (
	    .clk_250MHz      (clk_250MHz          ), //input
        .rst             (rst                 ), //input
		.trg             (trg                 ), //input
        .row1            (row1[4:0]           ), //input
        .row2            (row2[4:0]           ), //input
        .column          (column[12:0]        ), //input
        .column2         (column2[6:0]        ), //input
        .adc_ram1_rdat   (adc_ram1_rdat[255:0]),
        .adc_ram2_rdat   (adc_ram2_rdat[255:0]),
        .adc_ram3_rdat   (adc_ram3_rdat[255:0]),
        .adc_ram4_rdat   (adc_ram4_rdat[255:0]),
        .adc_ram5_rdat   (adc_ram5_rdat[255:0]),
        .adc_ram6_rdat   (adc_ram6_rdat[255:0]),
        .adc_ram7_rdat   (adc_ram7_rdat[255:0]),
        .adc_ram8_rdat   (adc_ram8_rdat[255:0]),
		.adc_adr         (adc_adr[12:0]       ),
        .coe_out_wen     (coe_out_wen         ), //input
        .coe_out_wadrs   (coe_out_wadrs [12:0]), //input
        .coe_out_wdat    (coe_out_wdat[255:0] ), //input
	    .adc_out_en1     (adc_out_en1         ), //output
	    .adc_out_en2     (adc_out_en2         ), //output
	    .adc_out_en3     (adc_out_en3         ), //output
	    .adc_out_en4     (adc_out_en4         ), //output
	    .adc_out_en5     (adc_out_en5         ), //output
	    .adc_out_en6     (adc_out_en6         ), //output
	    .adc_out_en7     (adc_out_en7         ), //output
	    .adc_out_en8     (adc_out_en8         ), //output
        .adc_out_dat1    (adc_out_dat1[9:0]   ), //output
        .adc_out_dat2    (adc_out_dat2[9:0]   ), //output
        .adc_out_dat3    (adc_out_dat3[9:0]   ), //output
        .adc_out_dat4    (adc_out_dat4[9:0]   ), //output
        .adc_out_dat5    (adc_out_dat5[9:0]   ), //output
        .adc_out_dat6    (adc_out_dat6[9:0]   ), //output
        .adc_out_dat7    (adc_out_dat7[9:0]   ), //output
        .adc_out_dat8    (adc_out_dat8[9:0]   )  //output
	);

    ADC ADC(
	    .clk         (clk_250MHz          ),
        .probe_out0  (coe_out_wen         ),
        .probe_out1  (coe_out_wadrs[12:0] ),
        .probe_out2  (coe_out_wdat[255:0] ),
        .probe_out3  (),
        .probe_out4  (),
        .probe_out5  (),
        .probe_out6  (),
        .probe_out7  (),
        .probe_out8  (),
        .probe_out9  (),
        .probe_out10 (),
        .probe_in0   (adc_out_en1         ),
        .probe_in1   (adc_out_en2         ),
        .probe_in2   (adc_out_en3         ),
        .probe_in3   (adc_out_en4         ),
        .probe_in4   (adc_out_en5         ),
        .probe_in5   (adc_out_en6         ),
        .probe_in6   (adc_out_en7         ),
        .probe_in7   (adc_out_en8         ),
        .probe_in8   (adc_out_dat1[9:0]   ),
        .probe_in9   (adc_out_dat2[9:0]   ),
        .probe_in10  (adc_out_dat3[9:0]   ),
        .probe_in11  (adc_out_dat4[9:0]   ),
        .probe_in12  (adc_out_dat5[9:0]   ),
        .probe_in13  (adc_out_dat6[9:0]   ),
        .probe_in14  (adc_out_dat7[9:0]   ),
        .probe_in15  (adc_out_dat8[9:0]   ),
		.probe_in16  ()
	);

	adc_ram adc_ram1(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram1_wen        ),
        .waddr    (adc_ram1_wadrs[12:0]),
        .raddr    (adc_adr[12:0]       ),
        .wdat     (adc_ram1_wdat160[159:0]),
        .rdat     (adc_ram1_rdat[159:0])		
	);

	adc_ram adc_ram2(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram2_wen        ),
        .waddr    (adc_ram2_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram2_wdat160[159:0]),
        .rdat     (adc_ram2_rdat[159:0])		
	);
	
	adc_ram adc_ram3(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram3_wen        ),
        .waddr    (adc_ram3_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram3_wdat160[159:0]),
        .rdat     (adc_ram3_rdat[159:0])		
	);

	adc_ram adc_ram4(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram4_wen        ),
        .waddr    (adc_ram4_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram4_wdat160[159:0]),
        .rdat     (adc_ram4_rdat[159:0])		
	);

	adc_ram adc_ram5(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram5_wen        ),
        .waddr    (adc_ram5_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram5_wdat160[159:0]),
        .rdat     (adc_ram5_rdat[159:0])		
	);

	adc_ram adc_ram6(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram6_wen        ),
        .waddr    (adc_ram6_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram6_wdat160[159:0]),
        .rdat     (adc_ram6_rdat[159:0])		
	);

	adc_ram adc_ram7(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram7_wen        ),
        .waddr    (adc_ram7_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram7_wdat160[159:0]),
        .rdat     (adc_ram7_rdat[159:0])		
	);

	adc_ram adc_ram8(
	    .clk      (clk_250MHz          ),
	    .wen      (adc_ram8_wen        ),
        .waddr    (adc_ram8_wadrs[12:0]),
        .raddr    (adc_adr[12:0] ),
        .wdat     (adc_ram8_wdat160[159:0]),
        .rdat     (adc_ram8_rdat[159:0])		
	);


endmodule