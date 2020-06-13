`timescale 1ns/1ps
`define ADC tb_matrix_top_adc.matrix_adc_top
`define ADC_MEM_CH1 tb_matrix_top_adc.adc_ram1
`define ADC_MEM_CH2 tb_matrix_top_adc.adc_ram2
`define ADC_MEM_CH3 tb_matrix_top_adc.adc_ram3
`define ADC_MEM_CH4 tb_matrix_top_adc.adc_ram4
`define ADC_MEM_CH5 tb_matrix_top_adc.adc_ram5
`define ADC_MEM_CH6 tb_matrix_top_adc.adc_ram6
`define ADC_MEM_CH7 tb_matrix_top_adc.adc_ram7
`define ADC_MEM_CH8 tb_matrix_top_adc.adc_ram8
`define COE_OUT_MEM1  tb_matrix_top_adc.matrix_adc_top.coe_out_ram01
`define COE_OUT_MEM2  tb_matrix_top_adc.matrix_adc_top.coe_out_ram02
`define COE_OUT_MEM3  tb_matrix_top_adc.matrix_adc_top.coe_out_ram03
`define COE_OUT_MEM4  tb_matrix_top_adc.matrix_adc_top.coe_out_ram04
`define COE_OUT_MEM5  tb_matrix_top_adc.matrix_adc_top.coe_out_ram05
`define COE_OUT_MEM6  tb_matrix_top_adc.matrix_adc_top.coe_out_ram06
`define COE_OUT_MEM7  tb_matrix_top_adc.matrix_adc_top.coe_out_ram07
`define COE_OUT_MEM8  tb_matrix_top_adc.matrix_adc_top.coe_out_ram08
`define COE_OUT_MEM9  tb_matrix_top_adc.matrix_adc_top.coe_out_ram09
`define COE_OUT_MEM10 tb_matrix_top_adc.matrix_adc_top.coe_out_ram10
`define COE_OUT_MEM11 tb_matrix_top_adc.matrix_adc_top.coe_out_ram11
`define COE_OUT_MEM12 tb_matrix_top_adc.matrix_adc_top.coe_out_ram12
`define COE_OUT_MEM13 tb_matrix_top_adc.matrix_adc_top.coe_out_ram13
`define COE_OUT_MEM14 tb_matrix_top_adc.matrix_adc_top.coe_out_ram14
`define COE_OUT_MEM15 tb_matrix_top_adc.matrix_adc_top.coe_out_ram15
`define COE_OUT_MEM16 tb_matrix_top_adc.matrix_adc_top.coe_out_ram16
`define COE_OUT_MEM17 tb_matrix_top_adc.matrix_adc_top.coe_out_ram17
`define COE_OUT_MEM18 tb_matrix_top_adc.matrix_adc_top.coe_out_ram18
`define COE_OUT_MEM19 tb_matrix_top_adc.matrix_adc_top.coe_out_ram19
`define COE_OUT_MEM20 tb_matrix_top_adc.matrix_adc_top.coe_out_ram20
`define COE_OUT_MEM21 tb_matrix_top_adc.matrix_adc_top.coe_out_ram21
`define COE_OUT_MEM22 tb_matrix_top_adc.matrix_adc_top.coe_out_ram22
`define COE_OUT_MEM23 tb_matrix_top_adc.matrix_adc_top.coe_out_ram23
`define COE_OUT_MEM24 tb_matrix_top_adc.matrix_adc_top.coe_out_ram24
`define COE_OUT_MEM25 tb_matrix_top_adc.matrix_adc_top.coe_out_ram25
`define COE_OUT_MEM26 tb_matrix_top_adc.matrix_adc_top.coe_out_ram26
`define COE_OUT_MEM27 tb_matrix_top_adc.matrix_adc_top.coe_out_ram27
`define COE_OUT_MEM28 tb_matrix_top_adc.matrix_adc_top.coe_out_ram28
`define COE_OUT_MEM29 tb_matrix_top_adc.matrix_adc_top.coe_out_ram29
`define COE_OUT_MEM30 tb_matrix_top_adc.matrix_adc_top.coe_out_ram30
`define COE_OUT_MEM31 tb_matrix_top_adc.matrix_adc_top.coe_out_ram31
`define COE_OUT_MEM32 tb_matrix_top_adc.matrix_adc_top.coe_out_ram32
`define COE_OUT_MEM tb_matrix_top_adc.matrix_adc_top.coe_out_ram
`define COE_OUT_MEM tb_matrix_top_adc.matrix_adc_top.coe_out_ram

module tb_matrix_adc();
  reg          clk_250MHz ;
  reg  [12:0]  column     ;
  reg  [6:0]   column2    ;
  reg          exec_trg   ;
  reg          reset      ;
  reg  [4:0]   row1       ;
  reg  [15:0]  row2       ;
  wire [3:0]   STATE      ;
  
  integer fp_adc_out_ch1,fp_adc_out_ch2,fp_adc_out_ch3,fp_adc_out_ch4,
          fp_adc_out_ch5,fp_adc_out_ch6,fp_adc_out_ch7,fp_adc_out_ch8 ;
  
  tb_matrix_top_adc tb_matrix_top_adc (
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
	// OUTPUT ADC SIDE
  	$readmemb("tst2_dac_outfile_32x4096_ch1.mem", `ADC_MEM_CH1.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch2.mem", `ADC_MEM_CH2.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch3.mem", `ADC_MEM_CH3.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch4.mem", `ADC_MEM_CH4.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch5.mem", `ADC_MEM_CH5.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch6.mem", `ADC_MEM_CH6.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch7.mem", `ADC_MEM_CH7.mem);
  	$readmemb("tst2_dac_outfile_32x4096_ch8.mem", `ADC_MEM_CH8.mem);
  	$readmemb("tst2_adc_coefile1_4096x128.mem",   `COE_OUT_MEM1.mem);	
  	$readmemb("tst2_adc_coefile2_4096x128.mem",   `COE_OUT_MEM2.mem);	
  	$readmemb("tst2_adc_coefile3_4096x128.mem",   `COE_OUT_MEM3.mem);	
  	$readmemb("tst2_adc_coefile4_4096x128.mem",   `COE_OUT_MEM4.mem);	
  	$readmemb("tst2_adc_coefile5_4096x128.mem",   `COE_OUT_MEM5.mem);	
  	$readmemb("tst2_adc_coefile6_4096x128.mem",   `COE_OUT_MEM6.mem);	
  	$readmemb("tst2_adc_coefile7_4096x128.mem",   `COE_OUT_MEM7.mem);	
  	$readmemb("tst2_adc_coefile8_4096x128.mem",   `COE_OUT_MEM8.mem);	
  	$readmemb("tst2_adc_coefile9_4096x128.mem",   `COE_OUT_MEM9.mem);	
  	$readmemb("tst2_adc_coefile10_4096x128.mem",  `COE_OUT_MEM10.mem);	
  	$readmemb("tst2_adc_coefile11_4096x128.mem",  `COE_OUT_MEM11.mem);	
  	$readmemb("tst2_adc_coefile12_4096x128.mem",  `COE_OUT_MEM12.mem);	
  	$readmemb("tst2_adc_coefile13_4096x128.mem",  `COE_OUT_MEM13.mem);	
  	$readmemb("tst2_adc_coefile14_4096x128.mem",  `COE_OUT_MEM14.mem);	
  	$readmemb("tst2_adc_coefile15_4096x128.mem",  `COE_OUT_MEM15.mem);	
  	$readmemb("tst2_adc_coefile16_4096x128.mem",  `COE_OUT_MEM16.mem);	
  	$readmemb("tst2_adc_coefile17_4096x128.mem",  `COE_OUT_MEM17.mem);	
  	$readmemb("tst2_adc_coefile18_4096x128.mem",  `COE_OUT_MEM18.mem);	
  	$readmemb("tst2_adc_coefile19_4096x128.mem",  `COE_OUT_MEM19.mem);	
  	$readmemb("tst2_adc_coefile20_4096x128.mem",  `COE_OUT_MEM20.mem);	
  	$readmemb("tst2_adc_coefile21_4096x128.mem",  `COE_OUT_MEM21.mem);	
  	$readmemb("tst2_adc_coefile22_4096x128.mem",  `COE_OUT_MEM22.mem);	
  	$readmemb("tst2_adc_coefile23_4096x128.mem",  `COE_OUT_MEM23.mem);	
  	$readmemb("tst2_adc_coefile24_4096x128.mem",  `COE_OUT_MEM24.mem);	
  	$readmemb("tst2_adc_coefile25_4096x128.mem",  `COE_OUT_MEM25.mem);	
  	$readmemb("tst2_adc_coefile26_4096x128.mem",  `COE_OUT_MEM26.mem);	
  	$readmemb("tst2_adc_coefile27_4096x128.mem",  `COE_OUT_MEM27.mem);	
  	$readmemb("tst2_adc_coefile28_4096x128.mem",  `COE_OUT_MEM28.mem);	
  	$readmemb("tst2_adc_coefile29_4096x128.mem",  `COE_OUT_MEM29.mem);	
  	$readmemb("tst2_adc_coefile30_4096x128.mem",  `COE_OUT_MEM30.mem);	
  	$readmemb("tst2_adc_coefile31_4096x128.mem",  `COE_OUT_MEM31.mem);	
  	$readmemb("tst2_adc_coefile32_4096x128.mem",  `COE_OUT_MEM32.mem);	
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
    fp_adc_out_ch1 = $fopen("adc_out_ch1.txt") ;
    fp_adc_out_ch2 = $fopen("adc_out_ch2.txt") ;
    fp_adc_out_ch3 = $fopen("adc_out_ch3.txt") ;
    fp_adc_out_ch4 = $fopen("adc_out_ch4.txt") ;
    fp_adc_out_ch5 = $fopen("adc_out_ch5.txt") ;
    fp_adc_out_ch6 = $fopen("adc_out_ch6.txt") ;
    fp_adc_out_ch7 = $fopen("adc_out_ch7.txt") ;
    fp_adc_out_ch8 = $fopen("adc_out_ch8.txt") ;
    repeat(129) @ (negedge `ADC.adc_out_en1) ;
    repeat(100) @ (negedge clk_250MHz) ;
	$fclose(fp_adc_out_ch1);
	$fclose(fp_adc_out_ch2);
	$fclose(fp_adc_out_ch3);
	$fclose(fp_adc_out_ch4);
	$fclose(fp_adc_out_ch5);
	$fclose(fp_adc_out_ch6);
	$fclose(fp_adc_out_ch7);
	$fclose(fp_adc_out_ch8);
  end

  always @ (negedge clk_250MHz) begin
      if(`ADC.adc_out_en1) begin
          $fdisplay(fp_adc_out_ch1, "%d", `ADC.adc_out_dat1[9:0]);
      end

      if(`ADC.adc_out_en2) begin
          $fdisplay(fp_adc_out_ch2, "%d", `ADC.adc_out_dat2[9:0]);
      end

      if(`ADC.adc_out_en3) begin
          $fdisplay(fp_adc_out_ch3, "%d", `ADC.adc_out_dat3[9:0]);
      end

      if(`ADC.adc_out_en4) begin
          $fdisplay(fp_adc_out_ch4, "%d", `ADC.adc_out_dat4[9:0]);
      end

      if(`ADC.adc_out_en5) begin
          $fdisplay(fp_adc_out_ch5, "%d", `ADC.adc_out_dat5[9:0]);
      end

      if(`ADC.adc_out_en6) begin
          $fdisplay(fp_adc_out_ch6, "%d", `ADC.adc_out_dat6[9:0]);
      end

      if(`ADC.adc_out_en7) begin
          $fdisplay(fp_adc_out_ch7, "%d", `ADC.adc_out_dat7[9:0]);    
      end

      if(`ADC.adc_out_en8) begin
          $fdisplay(fp_adc_out_ch8, "%d", `ADC.adc_out_dat8[9:0]);
      end

  end
  
endmodule