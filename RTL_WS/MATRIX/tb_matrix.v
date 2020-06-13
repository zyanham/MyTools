`timescale 1ns/1ps
`define ADC tb_matrix_top.matrix_adc_top
`define DAC tb_matrix_top.matrix_dac_top
`define ADC_MEM_CH1 tb_matrix_top.adc_ram1
`define ADC_MEM_CH2 tb_matrix_top.adc_ram2
`define ADC_MEM_CH3 tb_matrix_top.adc_ram3
`define ADC_MEM_CH4 tb_matrix_top.adc_ram4
`define ADC_MEM_CH5 tb_matrix_top.adc_ram5
`define ADC_MEM_CH6 tb_matrix_top.adc_ram6
`define ADC_MEM_CH7 tb_matrix_top.adc_ram7
`define ADC_MEM_CH8 tb_matrix_top.adc_ram8
`define MATRIX tb_matrix_top


module tb_matrix();
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

  integer fp_adc_out_ch1,fp_adc_out_ch2,fp_adc_out_ch3,fp_adc_out_ch4,
          fp_adc_out_ch5,fp_adc_out_ch6,fp_adc_out_ch7,fp_adc_out_ch8 ;
  
  tb_matrix_top tb_matrix_top (
      .clk_250MHz (clk_250MHz  ),
      .rst        (reset       ),
      .STATE      (STATE[3:0]  ),	  
      .column     (column[12:0]),
      .column2    (column2[6:0]),
      .trg        (exec_trg    ),
      .row1       (row1[4:0]   ),
      .row2       (row2[4:0]   )
  );


  reg         dac_in_wen ;
  reg [5:0]   dac_in_ch1_raddr, dac_in_ch2_raddr, dac_in_ch3_raddr, dac_in_ch4_raddr,
              dac_in_ch5_raddr, dac_in_ch6_raddr, dac_in_ch7_raddr, dac_in_ch8_raddr;
  reg [255:0] dac_in_ch1_rdat,  dac_in_ch2_rdat,  dac_in_ch3_rdat,  dac_in_ch4_rdat,
              dac_in_ch5_rdat,  dac_in_ch6_rdat,  dac_in_ch7_rdat,  dac_in_ch8_rdat;
  reg [255:0] dac_in_ch1_mem [63:0];
  reg [255:0] dac_in_ch2_mem [63:0];
  reg [255:0] dac_in_ch3_mem [63:0];
  reg [255:0] dac_in_ch4_mem [63:0];
  reg [255:0] dac_in_ch5_mem [63:0];
  reg [255:0] dac_in_ch6_mem [63:0];
  reg [255:0] dac_in_ch7_mem [63:0];
  reg [255:0] dac_in_ch8_mem [63:0];
 
  initial begin
  	$readmemb("tst1_dac_out_32x4096_ch1.mem", `ADC_MEM_CH1.mem);
  	$readmemb("tst1_dac_out_32x4096_ch2.mem", `ADC_MEM_CH2.mem);
  	$readmemb("tst1_dac_out_32x4096_ch3.mem", `ADC_MEM_CH3.mem);
  	$readmemb("tst1_dac_out_32x4096_ch4.mem", `ADC_MEM_CH4.mem);
  	$readmemb("tst1_dac_out_32x4096_ch5.mem", `ADC_MEM_CH5.mem);
  	$readmemb("tst1_dac_out_32x4096_ch6.mem", `ADC_MEM_CH6.mem);
  	$readmemb("tst1_dac_out_32x4096_ch7.mem", `ADC_MEM_CH7.mem);
  	$readmemb("tst1_dac_out_32x4096_ch8.mem", `ADC_MEM_CH8.mem);
  	$readmemb("tst1_dac_in_32x32_ch1.mem", dac_in_ch1_mem);	
  	$readmemb("tst1_dac_in_32x32_ch2.mem", dac_in_ch2_mem);	
  	$readmemb("tst1_dac_in_32x32_ch3.mem", dac_in_ch3_mem);	
  	$readmemb("tst1_dac_in_32x32_ch4.mem", dac_in_ch4_mem);	
  	$readmemb("tst1_dac_in_32x32_ch5.mem", dac_in_ch5_mem);	
  	$readmemb("tst1_dac_in_32x32_ch6.mem", dac_in_ch6_mem);	
  	$readmemb("tst1_dac_in_32x32_ch7.mem", dac_in_ch7_mem);	
  	$readmemb("tst1_dac_in_32x32_ch8.mem", dac_in_ch8_mem);	
  end

  always @(posedge clk_250MHz)
  begin
  	  dac_in_ch1_rdat <= dac_in_ch1_mem[dac_in_ch1_raddr];
  	  dac_in_ch2_rdat <= dac_in_ch2_mem[dac_in_ch2_raddr];
  	  dac_in_ch3_rdat <= dac_in_ch3_mem[dac_in_ch3_raddr];
  	  dac_in_ch4_rdat <= dac_in_ch4_mem[dac_in_ch4_raddr];
  	  dac_in_ch5_rdat <= dac_in_ch5_mem[dac_in_ch5_raddr];
  	  dac_in_ch6_rdat <= dac_in_ch6_mem[dac_in_ch6_raddr];
  	  dac_in_ch7_rdat <= dac_in_ch7_mem[dac_in_ch7_raddr];
  	  dac_in_ch8_rdat <= dac_in_ch8_mem[dac_in_ch8_raddr];
  end

  reg         dac_coe_wen;
  reg [12:0]  dac_coe_raddr;
  reg [255:0] dac_coe_rdat;
  reg [255:0] dac_coe_mem [8191:0];
  initial begin
  	$readmemb("tst1_dac_coe_32x4096.mem", dac_coe_mem);	
  end

  always @(posedge clk_250MHz)
  begin
  	  dac_coe_rdat <= dac_coe_mem[dac_coe_raddr];
  end

  reg         adc_coe_wen;
  reg [14:0]  adc_coe_raddr;
  reg [255:0] adc_coe_rdat;
  reg [255:0] adc_coe_mem [32767:0];
  initial begin
  	$readmemb("tst1_adc_coe_4096x128.mem", adc_coe_mem);	
  end

  always @(posedge clk_250MHz)
  begin
  	  adc_coe_rdat <= adc_coe_mem[adc_coe_raddr];
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

    dac_in_wen            = 1'd0 ;
    dac_in_ch1_raddr[5:0] = 6'd0 ;
    dac_in_ch2_raddr[5:0] = 6'd0 ;
    dac_in_ch3_raddr[5:0] = 6'd0 ;
    dac_in_ch4_raddr[5:0] = 6'd0 ;
    dac_in_ch5_raddr[5:0] = 6'd0 ;
    dac_in_ch6_raddr[5:0] = 6'd0 ;
    dac_in_ch7_raddr[5:0] = 6'd0 ;
    dac_in_ch8_raddr[5:0] = 6'd0 ;
    
    force `MATRIX.in_ram1_wen = dac_in_wen   ;
    force `MATRIX.in_ram2_wen = dac_in_wen   ;
    force `MATRIX.in_ram3_wen = dac_in_wen   ;
    force `MATRIX.in_ram4_wen = dac_in_wen   ;
    force `MATRIX.in_ram5_wen = dac_in_wen   ;
    force `MATRIX.in_ram6_wen = dac_in_wen   ;
    force `MATRIX.in_ram7_wen = dac_in_wen   ;
    force `MATRIX.in_ram8_wen = dac_in_wen   ;
    force `MATRIX.in_ram1_wadrs[5:0] = dac_in_ch1_raddr[5:0] ;
    force `MATRIX.in_ram2_wadrs[5:0] = dac_in_ch2_raddr[5:0] ;
    force `MATRIX.in_ram3_wadrs[5:0] = dac_in_ch3_raddr[5:0] ;
    force `MATRIX.in_ram4_wadrs[5:0] = dac_in_ch4_raddr[5:0] ;
    force `MATRIX.in_ram5_wadrs[5:0] = dac_in_ch5_raddr[5:0] ;
    force `MATRIX.in_ram6_wadrs[5:0] = dac_in_ch6_raddr[5:0] ;
    force `MATRIX.in_ram7_wadrs[5:0] = dac_in_ch7_raddr[5:0] ;
    force `MATRIX.in_ram8_wadrs[5:0] = dac_in_ch8_raddr[5:0] ;
    force `MATRIX.in_ram1_wdat[255:0] = dac_in_ch1_rdat[255:0] ;
    force `MATRIX.in_ram2_wdat[255:0] = dac_in_ch2_rdat[255:0] ;
    force `MATRIX.in_ram3_wdat[255:0] = dac_in_ch3_rdat[255:0] ;
    force `MATRIX.in_ram4_wdat[255:0] = dac_in_ch4_rdat[255:0] ;
    force `MATRIX.in_ram5_wdat[255:0] = dac_in_ch5_rdat[255:0] ;
    force `MATRIX.in_ram6_wdat[255:0] = dac_in_ch6_rdat[255:0] ;
    force `MATRIX.in_ram7_wdat[255:0] = dac_in_ch7_rdat[255:0] ;
    force `MATRIX.in_ram8_wdat[255:0] = dac_in_ch8_rdat[255:0] ;
    
    dac_coe_wen         = 1'd0 ;
    dac_coe_raddr[12:0] = 13'd0 ;
    force `MATRIX.coe_in_wen = dac_coe_wen ;
    force `MATRIX.coe_in_wadrs[12:0] = dac_coe_raddr[12:0] ;
    force `MATRIX.coe_in_wdat[255:0] = dac_coe_rdat[255:0] ; 
    adc_coe_wen         = 1'd0 ;
    adc_coe_raddr[14:0] = 15'd0 ;
    force `MATRIX.coe_out_wen = adc_coe_wen ;
    force `MATRIX.coe_out_wadrs[14:0] = adc_coe_raddr[14:0] ;
    force `MATRIX.coe_out_wdat[255:0] = adc_coe_rdat[255:0] ;

	repeat(5) @ (posedge clk_250MHz) ;
	reset = 0 ;
/******************************************/
	repeat(10) @ (posedge clk_250MHz) ;
	dac_in_wen = 1'd1 ;
	repeat(63) @ (posedge clk_250MHz) begin
	    dac_in_ch1_raddr[5:0] = dac_in_ch1_raddr[5:0] + 6'd1 ;
		dac_in_ch2_raddr[5:0] = dac_in_ch2_raddr[5:0] + 6'd1 ;
		dac_in_ch3_raddr[5:0] = dac_in_ch3_raddr[5:0] + 6'd1 ;
		dac_in_ch4_raddr[5:0] = dac_in_ch4_raddr[5:0] + 6'd1 ;
		dac_in_ch5_raddr[5:0] = dac_in_ch5_raddr[5:0] + 6'd1 ;
		dac_in_ch6_raddr[5:0] = dac_in_ch6_raddr[5:0] + 6'd1 ;
		dac_in_ch7_raddr[5:0] = dac_in_ch7_raddr[5:0] + 6'd1 ;
		dac_in_ch8_raddr[5:0] = dac_in_ch8_raddr[5:0] + 6'd1 ;
    end
	repeat(1) @ (posedge clk_250MHz) ;
	dac_in_wen = 1'd0 ;
	repeat(100) @ (posedge clk_250MHz) ;
/******************************************/
	repeat(10) @ (posedge clk_250MHz) ;
	dac_coe_wen = 1'd1 ;
	repeat(8191) @ (posedge clk_250MHz) begin
	    dac_coe_raddr[12:0] = dac_coe_raddr[12:0] + 13'd1 ;
    end
	repeat(1) @ (posedge clk_250MHz) ;
	dac_coe_wen = 1'd0 ;
	repeat(100) @ (posedge clk_250MHz) ;
/******************************************/
	repeat(10) @ (posedge clk_250MHz) ;
	adc_coe_wen = 1'd1 ;
	repeat(32767) @ (posedge clk_250MHz) begin
	    adc_coe_raddr[14:0] = adc_coe_raddr[14:0] + 15'd1 ;
    end
	repeat(1) @ (posedge clk_250MHz) ;
	adc_coe_wen = 1'd0 ;
	repeat(100) @ (posedge clk_250MHz) ;
/******************************************/

	exec_trg = 1 ;
	repeat(1) @ (posedge clk_250MHz) ;
	exec_trg = 0 ;
	repeat(5000000) @ (posedge clk_250MHz) ;
	$stop();
  end

  wire ST_IDLE  = (STATE[3:0] == 4'd0) ;
  wire ST_LOAD  = (STATE[3:0] == 4'd1) ;
  wire ST_LOAD2 = (STATE[3:0] == 4'd2) ;
  wire ST_EXEC  = (STATE[3:0] == 4'd3) ;
  wire ST_JUDGE = (STATE[3:0] == 4'd4) ;

  initial begin
    fp_dac_out_ch1 = $fopen("dac_out_ch1.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en1) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_1[9:0]);
	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_2[9:0]);
	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_3[9:0]);
	    $fdisplay(fp_dac_out_ch1, "%d", `DAC.dac_out_dat1_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch1);
  end

  initial begin
    fp_dac_out_ch2 = $fopen("dac_out_ch2.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en2) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_1[9:0]);
	    $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_2[9:0]);
	    $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_3[9:0]);
	    $fdisplay(fp_dac_out_ch2, "%d", `DAC.dac_out_dat2_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch2);
  end

  initial begin
    fp_dac_out_ch3 = $fopen("dac_out_ch3.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en3) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_1[9:0]);
	    $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_2[9:0]);
	    $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_3[9:0]);
	    $fdisplay(fp_dac_out_ch3, "%d", `DAC.dac_out_dat3_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch3);
  end

  initial begin
    fp_dac_out_ch4 = $fopen("dac_out_ch4.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en4) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_1[9:0]);
	    $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_2[9:0]);
	    $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_3[9:0]);
	    $fdisplay(fp_dac_out_ch4, "%d", `DAC.dac_out_dat4_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch4);
  end

  initial begin
    fp_dac_out_ch5 = $fopen("dac_out_ch5.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en5) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_1[9:0]);
	    $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_2[9:0]);
	    $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_3[9:0]);
	    $fdisplay(fp_dac_out_ch5, "%d", `DAC.dac_out_dat5_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch5);
  end

  initial begin
    fp_dac_out_ch6 = $fopen("dac_out_ch6.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en6) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_1[9:0]);
	    $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_2[9:0]);
	    $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_3[9:0]);
	    $fdisplay(fp_dac_out_ch6, "%d", `DAC.dac_out_dat6_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch6);
  end

  initial begin
    fp_dac_out_ch7 = $fopen("dac_out_ch7.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en7) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_1[9:0]);
	    $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_2[9:0]);
	    $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_3[9:0]);
	    $fdisplay(fp_dac_out_ch7, "%d", `DAC.dac_out_dat7_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch7);
  end

  initial begin
    fp_dac_out_ch8 = $fopen("dac_out_ch8.txt") ;
    repeat(32768) @ (posedge `DAC.dac_out_en8) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_1[9:0]);
	    $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_2[9:0]);
	    $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_3[9:0]);
	    $fdisplay(fp_dac_out_ch8, "%d", `DAC.dac_out_dat8_4[9:0]);
		end
    end
	$fclose(fp_dac_out_ch8);
  end

  initial begin
    fp_adc_out_ch1 = $fopen("adc_out_ch1.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en1) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch1, "%d", `ADC.adc_out_dat1[9:0]);
		end
    end
	$fclose(fp_adc_out_ch1);
  end

  initial begin
    fp_adc_out_ch2 = $fopen("adc_out_ch2.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en2) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch2, "%d", `ADC.adc_out_dat2[9:0]);
		end
    end
	$fclose(fp_adc_out_ch2);
  end

  initial begin
    fp_adc_out_ch3 = $fopen("adc_out_ch3.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en3) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch3, "%d", `ADC.adc_out_dat3[9:0]);
		end
    end
	$fclose(fp_adc_out_ch3);
  end

  initial begin
    fp_adc_out_ch4 = $fopen("adc_out_ch4.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en4) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch4, "%d", `ADC.adc_out_dat4[9:0]);
		end
    end
	$fclose(fp_adc_out_ch4);
  end

  initial begin
    fp_adc_out_ch5 = $fopen("adc_out_ch5.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en5) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch5, "%d", `ADC.adc_out_dat5[9:0]);
		end
    end
	$fclose(fp_adc_out_ch5);
  end

  initial begin
    fp_adc_out_ch6 = $fopen("adc_out_ch6.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en6) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch6, "%d", `ADC.adc_out_dat6[9:0]);
		end
    end
	$fclose(fp_adc_out_ch6);
  end

  initial begin
    fp_adc_out_ch7 = $fopen("adc_out_ch7.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en7) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch7, "%d", `ADC.adc_out_dat7[9:0]);
		end
    end
	$fclose(fp_adc_out_ch7);
  end

  initial begin
    fp_adc_out_ch8 = $fopen("adc_out_ch8.txt") ;
    repeat(4096) @ (posedge `ADC.adc_out_en8) begin
        repeat(1) @ (negedge clk_250MHz) begin
	    $fdisplay(fp_adc_out_ch8, "%d", `ADC.adc_out_dat8[9:0]);
		end
    end
	$fclose(fp_adc_out_ch8);
  end
  
endmodule