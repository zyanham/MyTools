module matrix_dac (
    input         clk, // 250MHz
	input         rst, // High_active
    input         trg, // High_active

    // INPUT DATA
    input  [159:0] in_dat1,
    input  [159:0] in_dat2,
    input  [159:0] in_dat3,
    input  [159:0] in_dat4,
    input  [159:0] in_dat5,
    input  [159:0] in_dat6,
    input  [159:0] in_dat7,
    input  [159:0] in_dat8,
	output   [5:0] in_adr,  // (32,32)*16=16384/256=64adrs->6bit
	
	// COE DATA
	input  [159:0] coe_dat1,
	input  [159:0] coe_dat2,
	input  [159:0] coe_dat3,
	input  [159:0] coe_dat4,
	input  [159:0] coe_dat5,
	input  [159:0] coe_dat6,
	input  [159:0] coe_dat7,
	input  [159:0] coe_dat8,
	output   [9:0] coe_adr, // (32,4096)*16bit=2097152bit/256bit=8192adrs->13bit
	
	input    [4:0] row1,    // 0~31
	input   [12:0] column,  // 0~4096
	
	output   [3:0] STATE,
	
	output         out_en1_1,
	output         out_en1_2,
	output         out_en1_3,
	output         out_en1_4,
    output  [15:0] out_dat1_1,
    output  [15:0] out_dat1_2,
    output  [15:0] out_dat1_3,
    output  [15:0] out_dat1_4,

	output         out_en2_1,
	output         out_en2_2,
	output         out_en2_3,
	output         out_en2_4,
    output  [15:0] out_dat2_1,
    output  [15:0] out_dat2_2,
    output  [15:0] out_dat2_3,
    output  [15:0] out_dat2_4,

	output         out_en3_1,
	output         out_en3_2,
	output         out_en3_3,
	output         out_en3_4,
    output  [15:0] out_dat3_1,
    output  [15:0] out_dat3_2,
    output  [15:0] out_dat3_3,
    output  [15:0] out_dat3_4,

	output         out_en4_1,
	output         out_en4_2,
	output         out_en4_3,
	output         out_en4_4,
    output  [15:0] out_dat4_1,
    output  [15:0] out_dat4_2,
    output  [15:0] out_dat4_3,
    output  [15:0] out_dat4_4,

	output         out_en5_1,
	output         out_en5_2,
	output         out_en5_3,
	output         out_en5_4,
    output  [15:0] out_dat5_1,
    output  [15:0] out_dat5_2,
    output  [15:0] out_dat5_3,
    output  [15:0] out_dat5_4,

	output         out_en6_1,
	output         out_en6_2,
	output         out_en6_3,
	output         out_en6_4,
    output  [15:0] out_dat6_1,
    output  [15:0] out_dat6_2,
    output  [15:0] out_dat6_3,
    output  [15:0] out_dat6_4,

	output         out_en7_1,
	output         out_en7_2,
	output         out_en7_3,
	output         out_en7_4,
    output  [15:0] out_dat7_1,
    output  [15:0] out_dat7_2,
    output  [15:0] out_dat7_3,
    output  [15:0] out_dat7_4,

	output         out_en8_1,
	output         out_en8_2,
	output         out_en8_3,
	output         out_en8_4,
    output  [15:0] out_dat8_1,
    output  [15:0] out_dat8_2,
    output  [15:0] out_dat8_3,
    output  [15:0] out_dat8_4
);

    reg  [5:0] in_adr_reg  ;
	reg  [9:0] coe_adr_reg ;
	
	reg [5:0]  row1_hld; 
	reg [13:0] column_hld;
	
	reg [13:0] column_cnt;
	reg [5:0]  row1_cnt;
	reg [5:0]  cyc8_cnt;
	reg [5:0]  cyc8_cnt_hld;
	

    parameter DLY=0.1;
    parameter ST_IDLE=4'd0;
	parameter ST_INIT=4'd1;
	parameter ST_LOAD=4'd2;
    reg [3:0] STATE ;
	
	// STATE MACHINE(address counter)
	always @(posedge clk) begin
	    if(rst) begin
		    STATE[3:0]        <= #DLY 4'd0 ;
			in_adr_reg[5:0]   <= #DLY 6'd0 ;
			coe_adr_reg[9:0]  <= #DLY 10'd0 ;
			row1_hld[5:0]     <= #DLY 6'd0 ;
			column_hld[13:0]  <= #DLY 11'd0 ;
			row1_cnt[5:0]     <= #DLY 6'd0;
			column_cnt[13:0]  <= #DLY 11'd0;
            cyc8_cnt[5:0]     <= #DLY 6'd0 ;
		end else begin
		    case(STATE[3:0])
			    ST_IDLE : begin
				    if(trg) begin
            			cyc8_cnt[5:0]    <= #DLY 6'd0 ;
					    STATE[3:0]       <= #DLY ST_LOAD ;
						in_adr_reg[5:0]  <= #DLY 6'd0 ;
						coe_adr_reg[9:0] <= #DLY 10'd0 ;
						row1_hld[5:0]    <= #DLY {1'd0, row1[4:0]} + 5'd1 ;
						column_hld[13:0] <= #DLY ({1'd0, column[12:0]} + 14'd1) ;
            			column_cnt[13:0] <= #DLY 14'd0 ;
						row1_cnt[5:0]    <= #DLY 6'd0 ;
					end
				end
				ST_LOAD : begin // row columnどちらも更新
				    if(cyc8_cnt[5:0] == 6'd7) begin
					    cyc8_cnt[5:0] <= #DLY 6'd0 ;
					end else begin
					    cyc8_cnt[5:0] <= #DLY cyc8_cnt[5:0] + 6'd1 ;
					end
					
                    if((column_cnt[13:0] == 14'd0) & (row1_cnt[1:0] == 2'd0)) begin
					    in_adr_reg[5:0] <= #DLY in_adr_reg[5:0] + 6'd1 ;
					end

                    if(cyc8_cnt[5:0] == 6'd7) begin
					    if (column_hld[13:0] == (column_cnt[13:0] + 14'd32)) begin
						    column_cnt[13:0] <= #DLY 14'd0 ;
    						coe_adr_reg[9:0] <= #DLY 10'd0 ;
							if(row1_hld[5:0] == (row1_cnt[5:0] + 6'd1)) begin
							    STATE[3:0] <= #DLY ST_IDLE ;
								row1_hld[5:0] <= #DLY 6'd0 ;
							end else begin
							    row1_cnt[5:0] <= #DLY row1_cnt[5:0] + 6'd1 ;
							end
						end else begin
						    column_cnt[13:0] <= #DLY column_cnt[13:0] + 14'd32 ;
    						coe_adr_reg[9:0] <= #DLY coe_adr_reg[9:0] + 10'd1 ;
						end
					end else begin
						coe_adr_reg[9:0] <= #DLY coe_adr_reg[9:0] + 10'd1 ;
					end
                end					
				default : begin
					STATE[3:0]        <= #DLY ST_IDLE ;
					in_adr_reg[5:0]   <= #DLY 6'd0 ;
					coe_adr_reg[9:0]  <= #DLY 10'd0 ;
				end
			endcase
		end
	end

	always @(posedge clk) begin
	    if(rst) begin
            cyc8_cnt_hld[5:0] <= #DLY 6'd0 ;
		end else begin
            cyc8_cnt_hld[5:0] <= #DLY cyc8_cnt[5:0] ;
		end
	end


    matrix_dac_pipe matrix_dac_pipe1 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat1[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en1_1         ),
        .out_en2      (out_en1_2         ),
        .out_en3      (out_en1_3         ),
        .out_en4      (out_en1_4         ),
		.out_dat1     (out_dat1_1[15:0]  ),
		.out_dat2     (out_dat1_2[15:0]  ),
		.out_dat3     (out_dat1_3[15:0]  ),
		.out_dat4     (out_dat1_4[15:0]  )
	);
	
    matrix_dac_pipe matrix_dac_pipe2 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat2[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en2_1         ),
        .out_en2      (out_en2_2         ),
        .out_en3      (out_en2_3         ),
        .out_en4      (out_en2_4         ),
		.out_dat1     (out_dat2_1[15:0]  ),
		.out_dat2     (out_dat2_2[15:0]  ),
		.out_dat3     (out_dat2_3[15:0]  ),
		.out_dat4     (out_dat2_4[15:0]  )
	);
	
    matrix_dac_pipe matrix_dac_pipe3 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat3[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en3_1         ),
        .out_en2      (out_en3_2         ),
        .out_en3      (out_en3_3         ),
        .out_en4      (out_en3_4         ),
		.out_dat1     (out_dat3_1[15:0]  ),
		.out_dat2     (out_dat3_2[15:0]  ),
		.out_dat3     (out_dat3_3[15:0]  ),
		.out_dat4     (out_dat3_4[15:0]  )
	);
	
    matrix_dac_pipe matrix_dac_pipe4 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat4[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en4_1         ),
        .out_en2      (out_en4_2         ),
        .out_en3      (out_en4_3         ),
        .out_en4      (out_en4_4         ),
		.out_dat1     (out_dat4_1[15:0]  ),
		.out_dat2     (out_dat4_2[15:0]  ),
		.out_dat3     (out_dat4_3[15:0]  ),
		.out_dat4     (out_dat4_4[15:0]  )
	);

    matrix_dac_pipe matrix_dac_pipe5 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat5[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en5_1         ),
        .out_en2      (out_en5_2         ),
        .out_en3      (out_en5_3         ),
        .out_en4      (out_en5_4         ),
		.out_dat1     (out_dat5_1[15:0]  ),
		.out_dat2     (out_dat5_2[15:0]  ),
		.out_dat3     (out_dat5_3[15:0]  ),
		.out_dat4     (out_dat5_4[15:0]  )
	);

    matrix_dac_pipe matrix_dac_pipe6 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat6[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en6_1         ),
        .out_en2      (out_en6_2         ),
        .out_en3      (out_en6_3         ),
        .out_en4      (out_en6_4         ),
		.out_dat1     (out_dat6_1[15:0]  ),
		.out_dat2     (out_dat6_2[15:0]  ),
		.out_dat3     (out_dat6_3[15:0]  ),
		.out_dat4     (out_dat6_4[15:0]  )
	);

    matrix_dac_pipe matrix_dac_pipe7 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat7[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en7_1         ),
        .out_en2      (out_en7_2         ),
        .out_en3      (out_en7_3         ),
        .out_en4      (out_en7_4         ),
		.out_dat1     (out_dat7_1[15:0]  ),
		.out_dat2     (out_dat7_2[15:0]  ),
		.out_dat3     (out_dat7_3[15:0]  ),
		.out_dat4     (out_dat7_4[15:0]  )
	);

    matrix_dac_pipe matrix_dac_pipe8 (
        .clk          (clk               ),
	    .rst          (rst               ),
        .in_dat       (in_dat8[159:0]    ),
        .coe_dat1     (coe_dat1[159:0]   ),
        .coe_dat2     (coe_dat2[159:0]   ),
        .coe_dat3     (coe_dat3[159:0]   ),
        .coe_dat4     (coe_dat4[159:0]   ),
        .coe_dat5     (coe_dat5[159:0]   ),
        .coe_dat6     (coe_dat6[159:0]   ),
        .coe_dat7     (coe_dat7[159:0]   ),
        .coe_dat8     (coe_dat8[159:0]   ),
        .row1         (row1[4:0]         ),
        .STATE        (STATE[3:0]        ),
        .column_cnt   (column_cnt[13:0]  ),
        .row1_cnt     (row1_cnt[4:0]     ),
        .cyc8_cnt     (cyc8_cnt[5:0]     ),
		.in_adr_reg   (in_adr_reg[5:0]   ),
        .out_en1      (out_en8_1         ),
        .out_en2      (out_en8_2         ),
        .out_en3      (out_en8_3         ),
        .out_en4      (out_en8_4         ),
		.out_dat1     (out_dat8_1[15:0]  ),
		.out_dat2     (out_dat8_2[15:0]  ),
		.out_dat3     (out_dat8_3[15:0]  ),
		.out_dat4     (out_dat8_4[15:0]  )
	);
    
	assign in_adr[5:0]   = in_adr_reg[5:0] ;
    assign coe_adr[9:0] = coe_adr_reg[9:0] ;

endmodule