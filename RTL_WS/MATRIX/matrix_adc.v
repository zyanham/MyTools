module matrix_adc (
    input          clk, // 200MHz
	input          rst, // High_active
    input          trg, // High_active

    // INPUT DATA
    input  [159:0] adc_ram1_rdat,
    input  [159:0] adc_ram2_rdat,
    input  [159:0] adc_ram3_rdat,
    input  [159:0] adc_ram4_rdat,
    input  [159:0] adc_ram5_rdat,
    input  [159:0] adc_ram6_rdat,
    input  [159:0] adc_ram7_rdat,
    input  [159:0] adc_ram8_rdat,
	output  [12:0] adc_adr,  // (32,4096)*16bit=2097152bit/256bit=8192adrs(13bit)
	
	// COE DATA
	input  [159:0] coe_dat01,
	input  [159:0] coe_dat02,
	input  [159:0] coe_dat03,
	input  [159:0] coe_dat04,
	input  [159:0] coe_dat05,
	input  [159:0] coe_dat06,
	input  [159:0] coe_dat07,
	input  [159:0] coe_dat08,
	input  [159:0] coe_dat09,
	input  [159:0] coe_dat10,
	input  [159:0] coe_dat11,
	input  [159:0] coe_dat12,
	input  [159:0] coe_dat13,
	input  [159:0] coe_dat14,
	input  [159:0] coe_dat15,
	input  [159:0] coe_dat16,
	input  [159:0] coe_dat17,
	input  [159:0] coe_dat18,
	input  [159:0] coe_dat19,
	input  [159:0] coe_dat20,
	input  [159:0] coe_dat21,
	input  [159:0] coe_dat22,
	input  [159:0] coe_dat23,
	input  [159:0] coe_dat24,
	input  [159:0] coe_dat25,
	input  [159:0] coe_dat26,
	input  [159:0] coe_dat27,
	input  [159:0] coe_dat28,
	input  [159:0] coe_dat29,
	input  [159:0] coe_dat30,
	input  [159:0] coe_dat31,
	input  [159:0] coe_dat32,
	output   [9:0] coe_adr,  // (4096,128)*16bit=8388608/256bit=32768adrs(15bit)
//	output   [9:0] coe_adr01, coe_adr02, coe_adr03, coe_adr04, coe_adr05, coe_adr06, coe_adr07, coe_adr08,
//	               coe_adr09, coe_adr10, coe_adr11, coe_adr12, coe_adr13, coe_adr14, coe_adr15, coe_adr16,
//				   coe_adr17, coe_adr18, coe_adr19, coe_adr20, coe_adr21, coe_adr22, coe_adr23, coe_adr24,
//				   coe_adr25, coe_adr26, coe_adr27, coe_adr28, coe_adr29, coe_adr30, coe_adr31, coe_adr32,
	
	input    [4:0] row1,    // 0~31
	input    [4:0] row2,    //
	input   [12:0] column,  // 0~4096
    input    [6:0] column2, // 0~128
	
	output   [3:0] STATE,
	
	output         out_en1,
	output         out_en2,
	output         out_en3,
	output         out_en4,
	output         out_en5,
	output         out_en6,
	output         out_en7,
	output         out_en8,
    output  [17:0] out_dat1,
    output  [17:0] out_dat2,
    output  [17:0] out_dat3,
    output  [17:0] out_dat4,
    output  [17:0] out_dat5,
    output  [17:0] out_dat6,
    output  [17:0] out_dat7,
    output  [17:0] out_dat8
);

    parameter DLY=0.1;
    parameter ST_IDLE=4'd0;
	parameter ST_LOAD=4'd1;

    reg [3:0] STATE ;

	reg [4:0]  row1_hld; 
	reg [4:0]  row2_hld;
	reg [4:0]  row1_cnt;
	reg [4:0]  row_loop_hld;
    reg [4:0]  row_loop_cnt ;
	reg  [7:0] column_cnt;
    reg  [7:0] column_hld;
    
	reg [5:0]  cyc32_cnt;
    reg [12:0] adc_adr_reg ;
    reg [12:0] adc_adr_hld ;
    reg [9:0]  coe_adr_reg ;
	reg [9:0]  coe_adr_reg01, coe_adr_reg02, coe_adr_reg03, coe_adr_reg04, coe_adr_reg05, coe_adr_reg06, coe_adr_reg07, coe_adr_reg08,
	           coe_adr_reg09, coe_adr_reg10, coe_adr_reg11, coe_adr_reg12, coe_adr_reg13, coe_adr_reg14, coe_adr_reg15, coe_adr_reg16,
		       coe_adr_reg17, coe_adr_reg18, coe_adr_reg19, coe_adr_reg20, coe_adr_reg21, coe_adr_reg22, coe_adr_reg23, coe_adr_reg24,
			   coe_adr_reg25, coe_adr_reg26, coe_adr_reg27, coe_adr_reg28, coe_adr_reg29, coe_adr_reg30, coe_adr_reg31, coe_adr_reg32,  coe_adr_reg33;
	
	wire loop_flg = (row_loop_hld[4:0] == {row_loop_cnt[4:0] + 5'd1}) ;
	// STATE MACHINE(address counter)
	always @(posedge clk) begin
	    if(rst) begin
		    STATE[3:0]        <= #DLY 4'd0 ;
			row_loop_hld[4:0] <= #DLY 5'd0 ;
			row_loop_cnt[4:0] <= #DLY 5'd0 ;
			row1_hld[4:0]     <= #DLY 5'd0 ;
			row2_hld[4:0]     <= #DLY 5'd0 ;
			row1_cnt[4:0]     <= #DLY 5'd0 ;
			column_cnt[7:0]   <= #DLY 8'd0 ;
            column_hld[7:0]   <= #DLY 8'd0 ;
            adc_adr_reg[12:0] <= #DLY 13'd0 ;
            adc_adr_hld[12:0] <= #DLY 13'd0 ;
			coe_adr_reg[9:0]  <= #DLY 10'd0 ;
	        cyc32_cnt[5:0]    <= #DLY 6'd0 ;
		end else begin
		    case(STATE[3:0])
			    ST_IDLE : begin
				    if(trg) begin
					    STATE[3:0]        <= #DLY ST_LOAD ;
						row_loop_hld[4:0] <= #DLY ({1'd0, column[12:9]} + 5'd1) ;
						row_loop_cnt[4:0] <= #DLY 5'd0 ;
            			row1_cnt[4:0]     <= #DLY 5'd0 ;
						row1_hld[4:0]     <= #DLY row1[4:0] ;
						row2_hld[4:0]     <= #DLY row2[4:0] ;
                        column_hld[7:0]   <= #DLY ({1'd0, column2[6:0]} + 8'd1);
            			column_cnt[7:0]   <= #DLY 8'd0 ;
                        cyc32_cnt[5:0]    <= #DLY 6'd0  ;
                        adc_adr_reg[12:0] <= #DLY 13'd0 ;
                        adc_adr_hld[12:0] <= #DLY 13'd0 ;
            			coe_adr_reg[9:0]  <= #DLY 10'd0 ;
					end
				end
				ST_LOAD : begin // row columnどちらも更新
				    if(cyc32_cnt[5:0] == 6'd31) begin
					    cyc32_cnt[5:0] <= #DLY 6'd0 ;
					end else begin
					    cyc32_cnt[5:0]   <= #DLY cyc32_cnt[5:0] + 6'd1 ;
					end
					
					if(cyc32_cnt[5:0] == 6'd31) begin
					    if(row_loop_hld[4:0] == {row_loop_cnt[4:0] + 5'd1}) begin
    					    row_loop_cnt[4:0] <= #DLY 5'd0 ;
    					    if(column_hld[7:0] == (column_cnt[7:0] + 8'd32)) begin
    					        column_cnt[7:0]   <= #DLY 8'd0 ;
        					    adc_adr_reg[12:0] <= adc_adr_reg[12:0] + 13'd1 ;
								adc_adr_hld[12:0] <= adc_adr_reg[12:0] + 13'd1 ;
                    			coe_adr_reg[9:0]  <= #DLY 10'd0 ;
								if(row1_hld[4:0] == row1_cnt[4:0]) begin
								    STATE[3:0] <= #DLY ST_IDLE ;
								end else begin
								    row1_cnt[4:0] <= #DLY row1_cnt[4:0] + 5'd1 ;
								end
                            end	else begin
    						    column_cnt[7:0] <= #DLY column_cnt[7:0] + 8'd32 ;							
        					    adc_adr_reg[12:0] <= adc_adr_hld[12:0] ;
                    			coe_adr_reg[9:0]  <= #DLY coe_adr_reg[9:0] + 10'd1 ;
    						end							
    					end else begin
    					    row_loop_cnt[4:0] <= #DLY row_loop_cnt[4:0] + 5'd1 ;
    					    adc_adr_reg[12:0] <= adc_adr_reg[12:0] + 13'd1 ;
                			coe_adr_reg[9:0]  <= #DLY coe_adr_reg[9:0] + 10'd1 ;
    					end
					end else begin
					    adc_adr_reg[12:0] <= adc_adr_reg[12:0] + 13'd1 ;
            			coe_adr_reg[9:0]  <= #DLY coe_adr_reg[9:0] + 10'd1 ;
					end
				end
				default : begin
					STATE[3:0]        <= #DLY ST_IDLE ;
					adc_adr_reg[12:0] <= #DLY 13'd0 ;
					coe_adr_reg[9:0]  <= #DLY 10'd0 ;
				end
			endcase
		end
	end

	always @(posedge clk) begin
	    if(rst) begin
			coe_adr_reg01[9:0] <= #DLY 10'd0 ;
			coe_adr_reg02[9:0] <= #DLY 10'd0 ;
			coe_adr_reg03[9:0] <= #DLY 10'd0 ;
			coe_adr_reg04[9:0] <= #DLY 10'd0 ;
			coe_adr_reg05[9:0] <= #DLY 10'd0 ;
			coe_adr_reg06[9:0] <= #DLY 10'd0 ;
			coe_adr_reg07[9:0] <= #DLY 10'd0 ;
			coe_adr_reg08[9:0] <= #DLY 10'd0 ;
			coe_adr_reg09[9:0] <= #DLY 10'd0 ;
			coe_adr_reg10[9:0] <= #DLY 10'd0 ;
			coe_adr_reg11[9:0] <= #DLY 10'd0 ;
			coe_adr_reg12[9:0] <= #DLY 10'd0 ;
			coe_adr_reg13[9:0] <= #DLY 10'd0 ;
			coe_adr_reg14[9:0] <= #DLY 10'd0 ;
			coe_adr_reg15[9:0] <= #DLY 10'd0 ;
			coe_adr_reg16[9:0] <= #DLY 10'd0 ;
			coe_adr_reg17[9:0] <= #DLY 10'd0 ;
			coe_adr_reg18[9:0] <= #DLY 10'd0 ;
			coe_adr_reg19[9:0] <= #DLY 10'd0 ;
			coe_adr_reg20[9:0] <= #DLY 10'd0 ;
			coe_adr_reg21[9:0] <= #DLY 10'd0 ;
			coe_adr_reg22[9:0] <= #DLY 10'd0 ;
			coe_adr_reg23[9:0] <= #DLY 10'd0 ;
			coe_adr_reg24[9:0] <= #DLY 10'd0 ;
			coe_adr_reg25[9:0] <= #DLY 10'd0 ;
			coe_adr_reg26[9:0] <= #DLY 10'd0 ;
			coe_adr_reg27[9:0] <= #DLY 10'd0 ;
			coe_adr_reg28[9:0] <= #DLY 10'd0 ;
			coe_adr_reg29[9:0] <= #DLY 10'd0 ;
			coe_adr_reg30[9:0] <= #DLY 10'd0 ;
			coe_adr_reg31[9:0] <= #DLY 10'd0 ;
			coe_adr_reg32[9:0] <= #DLY 10'd0 ;
			coe_adr_reg33[9:0] <= #DLY 10'd0 ;
		end else begin
			coe_adr_reg01[9:0] <= #DLY coe_adr_reg[9:0] ;
			coe_adr_reg02[9:0] <= #DLY coe_adr_reg01[9:0] ;
			coe_adr_reg03[9:0] <= #DLY coe_adr_reg02[9:0] ;
			coe_adr_reg04[9:0] <= #DLY coe_adr_reg03[9:0] ;
			coe_adr_reg05[9:0] <= #DLY coe_adr_reg04[9:0] ;
			coe_adr_reg06[9:0] <= #DLY coe_adr_reg05[9:0] ;
			coe_adr_reg07[9:0] <= #DLY coe_adr_reg06[9:0] ;
			coe_adr_reg08[9:0] <= #DLY coe_adr_reg07[9:0] ;
			coe_adr_reg09[9:0] <= #DLY coe_adr_reg08[9:0] ;
			coe_adr_reg10[9:0] <= #DLY coe_adr_reg09[9:0] ;
			coe_adr_reg11[9:0] <= #DLY coe_adr_reg10[9:0] ;
			coe_adr_reg12[9:0] <= #DLY coe_adr_reg11[9:0] ;
			coe_adr_reg13[9:0] <= #DLY coe_adr_reg12[9:0] ;
			coe_adr_reg14[9:0] <= #DLY coe_adr_reg13[9:0] ;
			coe_adr_reg15[9:0] <= #DLY coe_adr_reg14[9:0] ;
			coe_adr_reg16[9:0] <= #DLY coe_adr_reg15[9:0] ;
			coe_adr_reg17[9:0] <= #DLY coe_adr_reg16[9:0] ;
			coe_adr_reg18[9:0] <= #DLY coe_adr_reg17[9:0] ;
			coe_adr_reg19[9:0] <= #DLY coe_adr_reg18[9:0] ;
			coe_adr_reg20[9:0] <= #DLY coe_adr_reg19[9:0] ;
			coe_adr_reg21[9:0] <= #DLY coe_adr_reg20[9:0] ;
			coe_adr_reg22[9:0] <= #DLY coe_adr_reg21[9:0] ;
			coe_adr_reg23[9:0] <= #DLY coe_adr_reg22[9:0] ;
			coe_adr_reg24[9:0] <= #DLY coe_adr_reg23[9:0] ;
			coe_adr_reg25[9:0] <= #DLY coe_adr_reg24[9:0] ;
			coe_adr_reg26[9:0] <= #DLY coe_adr_reg25[9:0] ;
			coe_adr_reg27[9:0] <= #DLY coe_adr_reg26[9:0] ;
			coe_adr_reg28[9:0] <= #DLY coe_adr_reg27[9:0] ;
			coe_adr_reg29[9:0] <= #DLY coe_adr_reg28[9:0] ;
			coe_adr_reg30[9:0] <= #DLY coe_adr_reg29[9:0] ;
			coe_adr_reg31[9:0] <= #DLY coe_adr_reg30[9:0] ;
			coe_adr_reg32[9:0] <= #DLY coe_adr_reg31[9:0] ;
			coe_adr_reg33[9:0] <= #DLY coe_adr_reg32[9:0] ;
		end
	end


    matrix_adc_pipe matrix_adc_pipe1 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram1_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en1              ),
		.out_dat    (out_dat1[17:0]       )
	);
	
    matrix_adc_pipe matrix_adc_pipe2 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram2_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en2              ),
		.out_dat    (out_dat2[17:0]       )
	);
	
    matrix_adc_pipe matrix_adc_pipe3 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram3_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en3              ),
		.out_dat    (out_dat3[17:0]       )
	);
	
    matrix_adc_pipe matrix_adc_pipe4 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram4_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en4              ),
		.out_dat    (out_dat4[17:0]       )
	);

    matrix_adc_pipe matrix_adc_pipe5 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram5_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en5              ),
		.out_dat    (out_dat5[17:0]       )
	);

    matrix_adc_pipe matrix_adc_pipe6 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram6_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en6              ),
		.out_dat    (out_dat6[17:0]       )
	);

    matrix_adc_pipe matrix_adc_pipe7 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram7_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
 		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en7              ),
		.out_dat    (out_dat7[17:0]       )
	);

    matrix_adc_pipe matrix_adc_pipe8 (
        .clk        (clk                  ),
	    .rst        (rst                  ),
        .in_dat     (adc_ram8_rdat[159:0] ),
        .coe_dat00  (coe_dat01[159:0]     ),
        .coe_dat01  (coe_dat02[159:0]     ),
        .coe_dat02  (coe_dat03[159:0]     ),
        .coe_dat03  (coe_dat04[159:0]     ),
        .coe_dat04  (coe_dat05[159:0]     ),
        .coe_dat05  (coe_dat06[159:0]     ),
        .coe_dat06  (coe_dat07[159:0]     ),
        .coe_dat07  (coe_dat08[159:0]     ),
        .coe_dat08  (coe_dat09[159:0]     ),
        .coe_dat09  (coe_dat10[159:0]     ),
        .coe_dat10  (coe_dat11[159:0]     ),
        .coe_dat11  (coe_dat12[159:0]     ),
        .coe_dat12  (coe_dat13[159:0]     ),
        .coe_dat13  (coe_dat14[159:0]     ),
        .coe_dat14  (coe_dat15[159:0]     ),
        .coe_dat15  (coe_dat16[159:0]     ),
        .coe_dat16  (coe_dat17[159:0]     ),
        .coe_dat17  (coe_dat18[159:0]     ),
        .coe_dat18  (coe_dat19[159:0]     ),
        .coe_dat19  (coe_dat20[159:0]     ),
        .coe_dat20  (coe_dat21[159:0]     ),
        .coe_dat21  (coe_dat22[159:0]     ),
        .coe_dat22  (coe_dat23[159:0]     ),
        .coe_dat23  (coe_dat24[159:0]     ),
        .coe_dat24  (coe_dat25[159:0]     ),
        .coe_dat25  (coe_dat26[159:0]     ),
        .coe_dat26  (coe_dat27[159:0]     ),
        .coe_dat27  (coe_dat28[159:0]     ),
        .coe_dat28  (coe_dat29[159:0]     ),
        .coe_dat29  (coe_dat30[159:0]     ),
        .coe_dat30  (coe_dat31[159:0]     ),
        .coe_dat31  (coe_dat32[159:0]     ),
		.cyc32_cnt  (cyc32_cnt[5:0]       ),
		.loop_flg   (loop_flg             ),
        .STATE      (STATE[3:0]           ),
        .row1_cnt   (row1_cnt[4:0]        ),
        .out_en     (out_en8              ),
		.out_dat    (out_dat8[17:0]       )
	);
  
	assign adc_adr[12:0] = adc_adr_reg[12:0] ;
//    assign coe_adr[9:0]  = coe_adr_reg[9:0] ;
    assign coe_adr[9:0]  = coe_adr_reg33[9:0] ;

endmodule