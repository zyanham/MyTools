module matrix_top(
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
	// INPUT->DAC Side
	//******************
    wire         in_ram1_wen    ;
	wire[5:0]    in_ram1_wadrs  ;
	wire[255:0]  in_ram1_wdat   ;
    wire         in_ram2_wen    ;
	wire[5:0]    in_ram2_wadrs  ;
	wire[255:0]  in_ram2_wdat   ;
    wire         in_ram3_wen    ;
	wire[5:0]    in_ram3_wadrs  ;
	wire[255:0]  in_ram3_wdat   ;
    wire         in_ram4_wen    ;
	wire[5:0]    in_ram4_wadrs  ;
	wire[255:0]  in_ram4_wdat   ;
    wire         in_ram5_wen    ;
	wire[5:0]    in_ram5_wadrs  ;
	wire[255:0]  in_ram5_wdat   ;
    wire         in_ram6_wen    ;
	wire[5:0]    in_ram6_wadrs  ;
	wire[255:0]  in_ram6_wdat   ;
    wire         in_ram7_wen    ;
	wire[5:0]    in_ram7_wadrs  ;
	wire[255:0]  in_ram7_wdat   ;
    wire         in_ram8_wen    ;
	wire[5:0]    in_ram8_wadrs  ;
	wire[255:0]  in_ram8_wdat   ;
    wire         coe_in_wen     ;
	wire[12:0]   coe_in_wadrs   ;
	wire[255:0]  coe_in_wdat    ;
	wire         dac_out_en1    ;
	wire         dac_out_en2    ;
	wire         dac_out_en3    ;
	wire         dac_out_en4    ;
	wire         dac_out_en5    ;
	wire         dac_out_en6    ;
	wire         dac_out_en7    ;
	wire         dac_out_en8    ;
	wire [9:0]   dac_out_dat1_1 ;
	wire [9:0]   dac_out_dat1_2 ;
	wire [9:0]   dac_out_dat1_3 ;
	wire [9:0]   dac_out_dat1_4 ;
	wire [9:0]   dac_out_dat2_1 ;
	wire [9:0]   dac_out_dat2_2 ;
	wire [9:0]   dac_out_dat2_3 ;
	wire [9:0]   dac_out_dat2_4 ;
	wire [9:0]   dac_out_dat3_1 ;
	wire [9:0]   dac_out_dat3_2 ;
	wire [9:0]   dac_out_dat3_3 ;
	wire [9:0]   dac_out_dat3_4 ;
	wire [9:0]   dac_out_dat4_1 ;
	wire [9:0]   dac_out_dat4_2 ;
	wire [9:0]   dac_out_dat4_3 ;
	wire [9:0]   dac_out_dat4_4 ;
	wire [9:0]   dac_out_dat5_1 ;
	wire [9:0]   dac_out_dat5_2 ;
	wire [9:0]   dac_out_dat5_3 ;
	wire [9:0]   dac_out_dat5_4 ;
	wire [9:0]   dac_out_dat6_1 ;
	wire [9:0]   dac_out_dat6_2 ;
	wire [9:0]   dac_out_dat6_3 ;
	wire [9:0]   dac_out_dat6_4 ;
	wire [9:0]   dac_out_dat7_1 ;
	wire [9:0]   dac_out_dat7_2 ;
	wire [9:0]   dac_out_dat7_3 ;
	wire [9:0]   dac_out_dat7_4 ;
	wire [9:0]   dac_out_dat8_1 ;
	wire [9:0]   dac_out_dat8_2 ;
	wire [9:0]   dac_out_dat8_3 ;
	wire [9:0]   dac_out_dat8_4 ;
		
	//******************
	// ADC->OUTPUT Side
	//******************
    wire [255:0] adc_ram1_rdat  ;
    wire [255:0] adc_ram2_rdat  ;
    wire [255:0] adc_ram3_rdat  ;
    wire [255:0] adc_ram4_rdat  ;
    wire [255:0] adc_ram5_rdat  ;
    wire [255:0] adc_ram6_rdat  ;
    wire [255:0] adc_ram7_rdat  ;
    wire [255:0] adc_ram8_rdat  ;
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

    wire       out_en1, out_en2, out_en3, out_en4,
               out_en5, out_en6, out_en7, out_en8;
    wire [9:0] out_dat1_1, out_dat1_2, out_dat1_3, out_dat1_4,
               out_dat2_1, out_dat2_2, out_dat2_3, out_dat2_4,
               out_dat3_1, out_dat3_2, out_dat3_3, out_dat3_4,
               out_dat4_1, out_dat4_2, out_dat4_3, out_dat4_4,
               out_dat5_1, out_dat5_2, out_dat5_3, out_dat5_4,
               out_dat6_1, out_dat6_2, out_dat6_3, out_dat6_4,
               out_dat7_1, out_dat7_2, out_dat7_3, out_dat7_4,
               out_dat8_1, out_dat8_2, out_dat8_3, out_dat8_4;


    matrix_dac_top matrix_dac_top(
        .clk_250MHz     (clk_250MHz         ), //input 
	    .rst            (rst                ), //input 
        .trg            (trg                ), //input 
	    .row1           (row1[4:0]          ), //input 
	    .row2           (row2[4:0]          ), //input 
	    .column         (column[12:0]       ), //input 
        .in_ram1_wen    (in_ram1_wen        ), //input 
	    .in_ram1_wadrs  (in_ram1_wadrs[5:0] ), //input 
	    .in_ram1_wdat   (in_ram1_wdat[255:0]), //input 
        .in_ram2_wen    (in_ram2_wen        ), //input 
	    .in_ram2_wadrs  (in_ram2_wadrs[5:0] ), //input 
	    .in_ram2_wdat   (in_ram2_wdat[255:0]), //input 
        .in_ram3_wen    (in_ram3_wen        ), //input 
	    .in_ram3_wadrs  (in_ram3_wadrs[5:0] ), //input 
	    .in_ram3_wdat   (in_ram3_wdat[255:0]), //input 
        .in_ram4_wen    (in_ram4_wen        ), //input 
	    .in_ram4_wadrs  (in_ram4_wadrs[5:0] ), //input 
	    .in_ram4_wdat   (in_ram4_wdat[255:0]), //input 
        .in_ram5_wen    (in_ram5_wen        ), //input 
	    .in_ram5_wadrs  (in_ram5_wadrs[5:0] ), //input 
	    .in_ram5_wdat   (in_ram5_wdat[255:0]), //input 
        .in_ram6_wen    (in_ram6_wen        ), //input 
	    .in_ram6_wadrs  (in_ram6_wadrs[5:0] ), //input 
	    .in_ram6_wdat   (in_ram6_wdat[255:0]), //input 
        .in_ram7_wen    (in_ram7_wen        ), //input 
	    .in_ram7_wadrs  (in_ram7_wadrs[5:0] ), //input 
	    .in_ram7_wdat   (in_ram7_wdat[255:0]), //input 
        .in_ram8_wen    (in_ram8_wen        ), //input 
	    .in_ram8_wadrs  (in_ram8_wadrs[5:0] ), //input 
	    .in_ram8_wdat   (in_ram8_wdat[255:0]), //input 
        .coe_in_wen     (coe_in_wen         ), //input 
	    .coe_in_wadrs   (coe_in_wadrs[12:0] ), //input 
	    .coe_in_wdat    (coe_in_wdat[255:0] ), //input 
        .STATE          (STATE[3:0]         ), //output
	    .dac_out_en1    (dac_out_en1        ), //output
	    .dac_out_en2    (dac_out_en2        ), //output
	    .dac_out_en3    (dac_out_en3        ), //output
	    .dac_out_en4    (dac_out_en4        ), //output
	    .dac_out_en5    (dac_out_en5        ), //output
	    .dac_out_en6    (dac_out_en6        ), //output
	    .dac_out_en7    (dac_out_en7        ), //output
	    .dac_out_en8    (dac_out_en8        ), //output
        .dac_out_dat1_1 (dac_out_dat1_1[9:0]), //output
        .dac_out_dat1_2 (dac_out_dat1_2[9:0]), //output
        .dac_out_dat1_3 (dac_out_dat1_3[9:0]), //output
        .dac_out_dat1_4 (dac_out_dat1_4[9:0]), //output
        .dac_out_dat2_1 (dac_out_dat2_1[9:0]), //output
        .dac_out_dat2_2 (dac_out_dat2_2[9:0]), //output
        .dac_out_dat2_3 (dac_out_dat2_3[9:0]), //output
        .dac_out_dat2_4 (dac_out_dat2_4[9:0]), //output
        .dac_out_dat3_1 (dac_out_dat3_1[9:0]), //output
        .dac_out_dat3_2 (dac_out_dat3_2[9:0]), //output
        .dac_out_dat3_3 (dac_out_dat3_3[9:0]), //output
        .dac_out_dat3_4 (dac_out_dat3_4[9:0]), //output
        .dac_out_dat4_1 (dac_out_dat4_1[9:0]), //output
        .dac_out_dat4_2 (dac_out_dat4_2[9:0]), //output
        .dac_out_dat4_3 (dac_out_dat4_3[9:0]), //output
        .dac_out_dat4_4 (dac_out_dat4_4[9:0]), //output
        .dac_out_dat5_1 (dac_out_dat5_1[9:0]), //output
        .dac_out_dat5_2 (dac_out_dat5_2[9:0]), //output
        .dac_out_dat5_3 (dac_out_dat5_3[9:0]), //output
        .dac_out_dat5_4 (dac_out_dat5_4[9:0]), //output
        .dac_out_dat6_1 (dac_out_dat6_1[9:0]), //output
        .dac_out_dat6_2 (dac_out_dat6_2[9:0]), //output
        .dac_out_dat6_3 (dac_out_dat6_3[9:0]), //output
        .dac_out_dat6_4 (dac_out_dat6_4[9:0]), //output
        .dac_out_dat7_1 (dac_out_dat7_1[9:0]), //output
        .dac_out_dat7_2 (dac_out_dat7_2[9:0]), //output
        .dac_out_dat7_3 (dac_out_dat7_3[9:0]), //output
        .dac_out_dat7_4 (dac_out_dat7_4[9:0]), //output
        .dac_out_dat8_1 (dac_out_dat8_1[9:0]), //output
        .dac_out_dat8_2 (dac_out_dat8_2[9:0]), //output
        .dac_out_dat8_3 (dac_out_dat8_3[9:0]), //output
        .dac_out_dat8_4 (dac_out_dat8_4[9:0])  //output
    );

    DAC DAC(
	    .clk          (clk_250MHz          ),
        .probe_out0   (in_ram1_wen         ),
        .probe_out1   (in_ram1_wadrs[5:0]  ),
        .probe_out2   (in_ram1_wdat[255:0] ),
        .probe_out3   (in_ram2_wen         ),
        .probe_out4   (in_ram2_wadrs[5:0]  ),
        .probe_out5   (in_ram2_wdat[255:0] ),
        .probe_out6   (in_ram3_wen         ),
        .probe_out7   (in_ram3_wadrs[5:0]  ),
        .probe_out8   (in_ram3_wdat[255:0] ),
        .probe_out9   (in_ram4_wen         ),
        .probe_out10  (in_ram4_wadrs[5:0]  ),
        .probe_out11  (in_ram4_wdat[255:0] ),
        .probe_out12  (in_ram5_wen         ),
        .probe_out13  (in_ram5_wadrs[5:0]  ),
        .probe_out14  (in_ram5_wdat[255:0] ),
        .probe_out15  (in_ram6_wen         ),
        .probe_out16  (in_ram6_wadrs[5:0]  ),
        .probe_out17  (in_ram6_wdat[255:0] ),
        .probe_out18  (in_ram7_wen         ),
        .probe_out19  (in_ram7_wadrs[5:0]  ),
        .probe_out20  (in_ram7_wdat[255:0] ),
        .probe_out21  (in_ram8_wen         ),
        .probe_out22  (in_ram8_wadrs[5:0]  ),
        .probe_out23  (in_ram8_wdat[255:0] ),
        .probe_out24  (coe_in_wen          ),
        .probe_out25  (coe_in_wadrs[12:0]  ),
        .probe_out26  (coe_in_wdat[255:0]  ),
        .probe_in0    (dac_out_en1         ),
        .probe_in1    (dac_out_en2         ),
        .probe_in2    (dac_out_en3         ),
        .probe_in3    (dac_out_en4         ),
        .probe_in4    (dac_out_en5         ),
        .probe_in5    (dac_out_en6         ),
        .probe_in6    (dac_out_en7         ),
        .probe_in7    (dac_out_en8         ),
        .probe_in8    (dac_out_dat1_1[9:0] ),
        .probe_in9    (dac_out_dat1_2[9:0] ),
        .probe_in10   (dac_out_dat1_3[9:0] ),
        .probe_in11   (dac_out_dat1_4[9:0] ),
        .probe_in12   (dac_out_dat2_1[9:0] ),
        .probe_in13   (dac_out_dat2_2[9:0] ),
        .probe_in14   (dac_out_dat2_3[9:0] ),
        .probe_in15   (dac_out_dat2_4[9:0] ),
        .probe_in16   (dac_out_dat3_1[9:0] ),
        .probe_in17   (dac_out_dat3_2[9:0] ),
        .probe_in18   (dac_out_dat3_3[9:0] ),
        .probe_in19   (dac_out_dat3_4[9:0] ),
        .probe_in20   (dac_out_dat4_1[9:0] ),
        .probe_in21   (dac_out_dat4_2[9:0] ),
        .probe_in22   (dac_out_dat4_3[9:0] ),
        .probe_in23   (dac_out_dat4_4[9:0] ),
        .probe_in24   (dac_out_dat5_1[9:0] ),
        .probe_in25   (dac_out_dat5_2[9:0] ),
        .probe_in26   (dac_out_dat5_3[9:0] ),
        .probe_in27   (dac_out_dat5_4[9:0] ),
        .probe_in28   (dac_out_dat6_1[9:0] ),
        .probe_in29   (dac_out_dat6_2[9:0] ),
        .probe_in30   (dac_out_dat6_3[9:0] ),
        .probe_in31   (dac_out_dat6_4[9:0] ),
        .probe_in32   (dac_out_dat7_1[9:0] ),
        .probe_in33   (dac_out_dat7_2[9:0] ),
        .probe_in34   (dac_out_dat7_3[9:0] ),
        .probe_in35   (dac_out_dat7_4[9:0] ),
        .probe_in36   (dac_out_dat8_1[9:0] ),
        .probe_in37   (dac_out_dat8_2[9:0] ),
        .probe_in38   (dac_out_dat8_3[9:0] ),
        .probe_in39   (dac_out_dat8_4[9:0] )
	);

    matrix_adc_top matrix_adc_top (
	    .clk_250MHz      (clk_250MHz          ), //input
        .rst             (rst                 ), //input
		.trg             (trg                 ), //input
        .row1            (row1[4:0]           ), //input
        .row2            (row2[4:0]           ), //input
        .column          (column[12:0]        ), //input
        .column2         (column2[6:0]        ), //input
        .adc_ram1_rdat   (adc_ram1_rdat[255:0]), //input
        .adc_ram2_rdat   (adc_ram2_rdat[255:0]), //input
        .adc_ram3_rdat   (adc_ram3_rdat[255:0]), //input
        .adc_ram4_rdat   (adc_ram4_rdat[255:0]), //input
        .adc_ram5_rdat   (adc_ram5_rdat[255:0]), //input
        .adc_ram6_rdat   (adc_ram6_rdat[255:0]), //input
        .adc_ram7_rdat   (adc_ram7_rdat[255:0]), //input
        .adc_ram8_rdat   (adc_ram8_rdat[255:0]), //input
		.adc_adr         (adc_adr[12:0]       ), //input
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
        .probe_out3  (adc_ram1_rdat[255:0]),
        .probe_out4  (adc_ram2_rdat[255:0]),
        .probe_out5  (adc_ram3_rdat[255:0]),
        .probe_out6  (adc_ram4_rdat[255:0]),
        .probe_out7  (adc_ram5_rdat[255:0]),
        .probe_out8  (adc_ram6_rdat[255:0]),
        .probe_out9  (adc_ram7_rdat[255:0]),
        .probe_out10 (adc_ram8_rdat[255:0]),
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
		.probe_in16  (adc_adr[12:0]       )
	);

endmodule