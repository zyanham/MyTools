`timescale 1ns/1ps
`define DAC tb_matrix_top_dac.matrix_dac_top
`define IN_MEM_CH1 tb_matrix_top_dac.matrix_dac_top.in_ram1
`define IN_MEM_CH2 tb_matrix_top_dac.matrix_dac_top.in_ram2
`define IN_MEM_CH3 tb_matrix_top_dac.matrix_dac_top.in_ram3
`define IN_MEM_CH4 tb_matrix_top_dac.matrix_dac_top.in_ram4
`define IN_MEM_CH5 tb_matrix_top_dac.matrix_dac_top.in_ram5
`define IN_MEM_CH6 tb_matrix_top_dac.matrix_dac_top.in_ram6
`define IN_MEM_CH7 tb_matrix_top_dac.matrix_dac_top.in_ram7
`define IN_MEM_CH8 tb_matrix_top_dac.matrix_dac_top.in_ram8
`define COE_IN_MEM1 tb_matrix_top_dac.matrix_dac_top.coe_in_ram1
`define COE_IN_MEM2 tb_matrix_top_dac.matrix_dac_top.coe_in_ram2
`define COE_IN_MEM3 tb_matrix_top_dac.matrix_dac_top.coe_in_ram3
`define COE_IN_MEM4 tb_matrix_top_dac.matrix_dac_top.coe_in_ram4
`define COE_IN_MEM5 tb_matrix_top_dac.matrix_dac_top.coe_in_ram5
`define COE_IN_MEM6 tb_matrix_top_dac.matrix_dac_top.coe_in_ram6
`define COE_IN_MEM7 tb_matrix_top_dac.matrix_dac_top.coe_in_ram7
`define COE_IN_MEM8 tb_matrix_top_dac.matrix_dac_top.coe_in_ram8

module tb_matrix_dac();
  reg          clk_250MHz ;
  reg  [12:0]  column     ;
  reg  [6:0]   column2    ;
  reg          exec_trg   ;
  reg          reset      ;
  reg  [4:0]   row1       ;
  reg  [15:0]  row2       ;
  wire [3:0]   STATE      ;
  
  integer fp_dac_out_ch1,fp_dac_out_ch2,fp_dac_out_ch3,fp_dac_out_ch4,
          fp_dac_out_ch5,fp_dac_out_ch6,fp_dac_out_ch7,fp_dac_out_ch8 ;

  
  tb_matrix_top_dac tb_matrix_top_dac (
      .clk_250MHz (clk_250MHz  ),
      .rst        (reset       ),
      .STATE      (STATE[3:0]  ),	  
      .column     (column[12:0]),
      .column2    (column2[6:0]),
      .trg        (exec_trg    ),
      .row1       (row1[4:0]   ),
      .row2       (row2[4:0]   )
  );

  initial begin
    // INPUT DAC SIDE
  	$readmemb("tst2_in_32x32_ch1.mem",         `IN_MEM_CH1.mem);
  	$readmemb("tst2_in_32x32_ch2.mem",         `IN_MEM_CH2.mem);
  	$readmemb("tst2_in_32x32_ch3.mem",         `IN_MEM_CH3.mem);
  	$readmemb("tst2_in_32x32_ch4.mem",         `IN_MEM_CH4.mem);
  	$readmemb("tst2_in_32x32_ch5.mem",         `IN_MEM_CH5.mem);
  	$readmemb("tst2_in_32x32_ch6.mem",         `IN_MEM_CH6.mem);
  	$readmemb("tst2_in_32x32_ch7.mem",         `IN_MEM_CH7.mem);
  	$readmemb("tst2_in_32x32_ch8.mem",         `IN_MEM_CH8.mem);
  	$readmemb("tst2_dac_coefile1_32x4096.mem", `COE_IN_MEM1.mem);
  	$readmemb("tst2_dac_coefile2_32x4096.mem", `COE_IN_MEM2.mem);
  	$readmemb("tst2_dac_coefile3_32x4096.mem", `COE_IN_MEM3.mem);
  	$readmemb("tst2_dac_coefile4_32x4096.mem", `COE_IN_MEM4.mem);
  	$readmemb("tst2_dac_coefile5_32x4096.mem", `COE_IN_MEM5.mem);
  	$readmemb("tst2_dac_coefile6_32x4096.mem", `COE_IN_MEM6.mem);
  	$readmemb("tst2_dac_coefile7_32x4096.mem", `COE_IN_MEM7.mem);
  	$readmemb("tst2_dac_coefile8_32x4096.mem", `COE_IN_MEM8.mem);
  end


  initial begin
      clk_250MHz = 1 ;
      #2 clk_250MHz = 0 ;  
      forever #2 clk_250MHz = ~clk_250MHz ;
  end
  
  initial begin
	reset = 1 ;
	exec_trg = 0 ;
	row1[4:0] = 5'd31 ;
	row2[15:0] = 16'd7 ;
	column[12:0] = 13'd4095 ;
	column2[6:0] = 7'd127 ;
	repeat(5) @ (posedge clk_250MHz) ;
	reset = 0 ;
	repeat(5) @ (posedge clk_250MHz) ;
	exec_trg = 1 ;
	repeat(1) @ (posedge clk_250MHz) ;
	exec_trg = 0 ;
	repeat(5000000) @ (posedge clk_250MHz) ;
	$stop();
  end

  initial begin
    fp_dac_out_ch1 = $fopen("dac_out_ch1.txt") ;
    fp_dac_out_ch2 = $fopen("dac_out_ch2.txt") ;
    fp_dac_out_ch3 = $fopen("dac_out_ch3.txt") ;
    fp_dac_out_ch4 = $fopen("dac_out_ch4.txt") ;
    fp_dac_out_ch5 = $fopen("dac_out_ch5.txt") ;
    fp_dac_out_ch6 = $fopen("dac_out_ch6.txt") ;
    fp_dac_out_ch7 = $fopen("dac_out_ch7.txt") ;
    fp_dac_out_ch8 = $fopen("dac_out_ch8.txt") ;
    repeat(1) @ (posedge `DAC.dac_out_en1) ;
    repeat(1) @ (negedge `DAC.dac_out_en1) ;
    repeat(100) @ (negedge clk_250MHz) ;
	$fclose(fp_dac_out_ch1);
	$fclose(fp_dac_out_ch2);
	$fclose(fp_dac_out_ch3);
	$fclose(fp_dac_out_ch4);
	$fclose(fp_dac_out_ch5);
	$fclose(fp_dac_out_ch6);
	$fclose(fp_dac_out_ch7);
	$fclose(fp_dac_out_ch8);
  end

  always @ (negedge clk_250MHz) begin
        if(`DAC.dac_out_en1) begin
    	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_1[9:0]);
    	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_2[9:0]);
    	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_3[9:0]);
    	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_4[9:0]);
		end

        if(`DAC.dac_out_en2) begin
	        $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_1[9:0]);
	        $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_2[9:0]);
	        $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_3[9:0]);
	        $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_4[9:0]);
        end

        if(`DAC.dac_out_en3) begin
	        $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_1[9:0]);
	        $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_2[9:0]);
	        $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_3[9:0]);
	        $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_4[9:0]);
		end

        if(`DAC.dac_out_en4) begin
	        $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_1[9:0]);
	        $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_2[9:0]);
	        $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_3[9:0]);
	        $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_4[9:0]);
		end

        if(`DAC.dac_out_en5) begin
	        $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_1[9:0]);
	        $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_2[9:0]);
	        $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_3[9:0]);
	        $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_4[9:0]);
		end

        if(`DAC.dac_out_en6) begin
	        $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_1[9:0]);
	        $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_2[9:0]);
	        $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_3[9:0]);
	        $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_4[9:0]);
		end

        if(`DAC.dac_out_en7) begin
	        $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_1[9:0]);
	        $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_2[9:0]);
	        $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_3[9:0]);
	        $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_4[9:0]);
		end

        if(`DAC.dac_out_en8) begin
	        $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_1[9:0]);
	        $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_2[9:0]);
	        $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_3[9:0]);
	        $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_4[9:0]);
		end
  end


 
endmodule