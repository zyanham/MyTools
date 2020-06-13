module matrix_dac_pipe (
    input          clk,
	input          rst, // High_active

    // INPUT DATA
    input  [159:0] in_dat,
	
	// COE DATA
	input  [159:0] coe_dat1,
	input  [159:0] coe_dat2,
	input  [159:0] coe_dat3,
	input  [159:0] coe_dat4,
    input  [159:0] coe_dat5,
	input  [159:0] coe_dat6,
	input  [159:0] coe_dat7,
	input  [159:0] coe_dat8,
	
	input    [4:0] row1,    // 0~31
	
    input    [3:0] STATE,
    input   [12:0] column_cnt,
    input    [4:0] row1_cnt,
	input    [5:0] cyc8_cnt,
	output         out_en1,
	output         out_en2,
	output         out_en3,
	output         out_en4,
	output  [15:0] out_dat1,
	output  [15:0] out_dat2,
	output  [15:0] out_dat3,
	output  [15:0] out_dat4,
	input    [5:0] in_adr_reg
);

    parameter DLY=0.1;
    parameter ST_IDLE=4'd0;
	parameter ST_INIT=4'd1;
	parameter ST_LOAD=4'd2;
	
//**********************************************************
//**********************************************************
	// PIPELINE
    reg [19:0]  pipeline_cnt ;
    reg [159:0] in_dat_hld1,  in_dat_hld2,  in_dat_hld3,  in_dat_hld4,
	            in_dat_hld5,  in_dat_hld6,  in_dat_hld7,  in_dat_hld8;

    reg [159:0] coe_dat_hld1_1, coe_dat_hld1_2, coe_dat_hld1_3, coe_dat_hld1_4,
	            coe_dat_hld1_5, coe_dat_hld1_6, coe_dat_hld1_7, coe_dat_hld1_8;
    reg [159:0] coe_dat_hld2_1, coe_dat_hld2_2, coe_dat_hld2_3, coe_dat_hld2_4,
	            coe_dat_hld2_5, coe_dat_hld2_6, coe_dat_hld2_7, coe_dat_hld2_8;
    reg [159:0] coe_dat_hld3_1, coe_dat_hld3_2, coe_dat_hld3_3, coe_dat_hld3_4,
	            coe_dat_hld3_5, coe_dat_hld3_6, coe_dat_hld3_7, coe_dat_hld3_8;
    reg [159:0] coe_dat_hld4_1, coe_dat_hld4_2, coe_dat_hld4_3, coe_dat_hld4_4,
	            coe_dat_hld4_5, coe_dat_hld4_6, coe_dat_hld4_7, coe_dat_hld4_8;
    reg [159:0] coe_dat_hld5_1, coe_dat_hld5_2, coe_dat_hld5_3, coe_dat_hld5_4,
	            coe_dat_hld5_5, coe_dat_hld5_6, coe_dat_hld5_7, coe_dat_hld5_8;
    reg [159:0] coe_dat_hld6_1, coe_dat_hld6_2, coe_dat_hld6_3, coe_dat_hld6_4,
	            coe_dat_hld6_5, coe_dat_hld6_6, coe_dat_hld6_7, coe_dat_hld6_8;
    reg [159:0] coe_dat_hld7_1, coe_dat_hld7_2, coe_dat_hld7_3, coe_dat_hld7_4,
	            coe_dat_hld7_5, coe_dat_hld7_6, coe_dat_hld7_7, coe_dat_hld7_8;
    reg [159:0] coe_dat_hld8_1, coe_dat_hld8_2, coe_dat_hld8_3, coe_dat_hld8_4,
	            coe_dat_hld8_5, coe_dat_hld8_6, coe_dat_hld8_7, coe_dat_hld8_8;

    reg [5:0] cyc8_cnt_dd1, cyc8_cnt_dd2, cyc8_cnt_dd3, cyc8_cnt_dd4,
              cyc8_cnt_dd5, cyc8_cnt_dd6, cyc8_cnt_dd7, cyc8_cnt_dd8,
			  cyc8_cnt_dd9, cyc8_cnt_dd10;
			  
	reg [12:0] column_cnt_dd1, column_cnt_dd2;
	
	reg [5:0] in_adr_reg_hld ;

    wire in_adr_diff_flg = (in_adr_reg_hld[5:0] != in_adr_reg[5:0]) ;

    always @ (posedge clk) begin
		if(rst) begin
		    in_adr_reg_hld[5:0] <= #DLY 6'd0 ;
		end else begin
		    in_adr_reg_hld[5:0] <= #DLY in_adr_reg[5:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
		    column_cnt_dd1[12:0] <= #DLY 13'd0 ;
		    column_cnt_dd2[12:0] <= #DLY 13'd0 ;
		end else begin
		    column_cnt_dd1[12:0] <= #DLY column_cnt[12:0] ;
		    column_cnt_dd2[12:0] <= #DLY column_cnt_dd1[12:0] ;
		end
	end
			  
    always @ (posedge clk) begin
		if(rst) begin
            cyc8_cnt_dd1[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd2[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd3[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd4[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd5[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd6[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd7[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd8[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd9[5:0]  <= #DLY 6'd0 ;
            cyc8_cnt_dd10[5:0] <= #DLY 6'd0 ;
		end else begin
            cyc8_cnt_dd1[5:0]  <= #DLY cyc8_cnt[5:0] ;
            cyc8_cnt_dd2[5:0]  <= #DLY cyc8_cnt_dd1[5:0] ;
            cyc8_cnt_dd3[5:0]  <= #DLY cyc8_cnt_dd2[5:0] ;
            cyc8_cnt_dd4[5:0]  <= #DLY cyc8_cnt_dd3[5:0] ;
            cyc8_cnt_dd5[5:0]  <= #DLY cyc8_cnt_dd4[5:0] ;
            cyc8_cnt_dd6[5:0]  <= #DLY cyc8_cnt_dd5[5:0] ;
            cyc8_cnt_dd7[5:0]  <= #DLY cyc8_cnt_dd6[5:0] ;
            cyc8_cnt_dd8[5:0]  <= #DLY cyc8_cnt_dd7[5:0] ;
            cyc8_cnt_dd9[5:0]  <= #DLY cyc8_cnt_dd8[5:0] ;
            cyc8_cnt_dd10[5:0] <= #DLY cyc8_cnt_dd9[5:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
            pipeline_cnt[19:0] <= #DLY 20'd0 ;
		end else begin
            pipeline_cnt[19:0] <= #DLY {pipeline_cnt[18:0], (STATE[2:0] == ST_LOAD)} ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			in_dat_hld1[159:0] <= #DLY 160'd0 ;
			in_dat_hld2[159:0] <= #DLY 160'd0 ;
			in_dat_hld3[159:0] <= #DLY 160'd0 ;
			in_dat_hld4[159:0] <= #DLY 160'd0 ;
			in_dat_hld5[159:0] <= #DLY 160'd0 ;
			in_dat_hld5[159:0] <= #DLY 160'd0 ;
			in_dat_hld6[159:0] <= #DLY 160'd0 ;
			in_dat_hld7[159:0] <= #DLY 160'd0 ;
			in_dat_hld8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld1_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld2_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld3_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld4_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld5_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld6_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld7_8[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_1[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_2[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_3[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_4[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_5[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_6[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_7[159:0] <= #DLY 160'd0 ;
			coe_dat_hld8_8[159:0] <= #DLY 160'd0 ;
		end else begin
			coe_dat_hld1_1[159:0]  <= #DLY coe_dat1[159:0] ;
			coe_dat_hld1_2[159:0]  <= #DLY coe_dat_hld1_1[159:0] ;
			coe_dat_hld1_3[159:0]  <= #DLY coe_dat_hld1_2[159:0] ;
			coe_dat_hld1_4[159:0]  <= #DLY coe_dat_hld1_3[159:0] ;
			coe_dat_hld1_5[159:0]  <= #DLY coe_dat_hld1_4[159:0] ;
			coe_dat_hld1_6[159:0]  <= #DLY coe_dat_hld1_5[159:0] ;
			coe_dat_hld1_7[159:0]  <= #DLY coe_dat_hld1_6[159:0] ;
			coe_dat_hld1_8[159:0]  <= #DLY coe_dat_hld1_7[159:0] ;

			coe_dat_hld2_1[159:0]  <= #DLY coe_dat2[159:0] ;
			coe_dat_hld2_2[159:0]  <= #DLY coe_dat_hld2_1[159:0] ;
			coe_dat_hld2_3[159:0]  <= #DLY coe_dat_hld2_2[159:0] ;
			coe_dat_hld2_4[159:0]  <= #DLY coe_dat_hld2_3[159:0] ;
			coe_dat_hld2_5[159:0]  <= #DLY coe_dat_hld2_4[159:0] ;
			coe_dat_hld2_6[159:0]  <= #DLY coe_dat_hld2_5[159:0] ;
			coe_dat_hld2_7[159:0]  <= #DLY coe_dat_hld2_6[159:0] ;
			coe_dat_hld2_8[159:0]  <= #DLY coe_dat_hld2_7[159:0] ;

			coe_dat_hld3_1[159:0]  <= #DLY coe_dat3[159:0] ;
			coe_dat_hld3_2[159:0]  <= #DLY coe_dat_hld3_1[159:0] ;
			coe_dat_hld3_3[159:0]  <= #DLY coe_dat_hld3_2[159:0] ;
			coe_dat_hld3_4[159:0]  <= #DLY coe_dat_hld3_3[159:0] ;
			coe_dat_hld3_5[159:0]  <= #DLY coe_dat_hld3_4[159:0] ;
			coe_dat_hld3_6[159:0]  <= #DLY coe_dat_hld3_5[159:0] ;
			coe_dat_hld3_7[159:0]  <= #DLY coe_dat_hld3_6[159:0] ;
			coe_dat_hld3_8[159:0]  <= #DLY coe_dat_hld3_7[159:0] ;

			coe_dat_hld4_1[159:0]  <= #DLY coe_dat4[159:0] ;
			coe_dat_hld4_2[159:0]  <= #DLY coe_dat_hld4_1[159:0] ;
			coe_dat_hld4_3[159:0]  <= #DLY coe_dat_hld4_2[159:0] ;
			coe_dat_hld4_4[159:0]  <= #DLY coe_dat_hld4_3[159:0] ;
			coe_dat_hld4_5[159:0]  <= #DLY coe_dat_hld4_4[159:0] ;
			coe_dat_hld4_6[159:0]  <= #DLY coe_dat_hld4_5[159:0] ;
			coe_dat_hld4_7[159:0]  <= #DLY coe_dat_hld4_6[159:0] ;
			coe_dat_hld4_8[159:0]  <= #DLY coe_dat_hld4_7[159:0] ;

			coe_dat_hld5_1[159:0]  <= #DLY coe_dat5[159:0] ;
			coe_dat_hld5_2[159:0]  <= #DLY coe_dat_hld5_1[159:0] ;
			coe_dat_hld5_3[159:0]  <= #DLY coe_dat_hld5_2[159:0] ;
			coe_dat_hld5_4[159:0]  <= #DLY coe_dat_hld5_3[159:0] ;
			coe_dat_hld5_5[159:0]  <= #DLY coe_dat_hld5_4[159:0] ;
			coe_dat_hld5_6[159:0]  <= #DLY coe_dat_hld5_5[159:0] ;
			coe_dat_hld5_7[159:0]  <= #DLY coe_dat_hld5_6[159:0] ;
			coe_dat_hld5_8[159:0]  <= #DLY coe_dat_hld5_7[159:0] ;

			coe_dat_hld6_1[159:0]  <= #DLY coe_dat6[159:0] ;
			coe_dat_hld6_2[159:0]  <= #DLY coe_dat_hld6_1[159:0] ;
			coe_dat_hld6_3[159:0]  <= #DLY coe_dat_hld6_2[159:0] ;
			coe_dat_hld6_4[159:0]  <= #DLY coe_dat_hld6_3[159:0] ;
			coe_dat_hld6_5[159:0]  <= #DLY coe_dat_hld6_4[159:0] ;
			coe_dat_hld6_6[159:0]  <= #DLY coe_dat_hld6_5[159:0] ;
			coe_dat_hld6_7[159:0]  <= #DLY coe_dat_hld6_6[159:0] ;
			coe_dat_hld6_8[159:0]  <= #DLY coe_dat_hld6_7[159:0] ;

			coe_dat_hld7_1[159:0]  <= #DLY coe_dat7[159:0] ;
			coe_dat_hld7_2[159:0]  <= #DLY coe_dat_hld7_1[159:0] ;
			coe_dat_hld7_3[159:0]  <= #DLY coe_dat_hld7_2[159:0] ;
			coe_dat_hld7_4[159:0]  <= #DLY coe_dat_hld7_3[159:0] ;
			coe_dat_hld7_5[159:0]  <= #DLY coe_dat_hld7_4[159:0] ;
			coe_dat_hld7_6[159:0]  <= #DLY coe_dat_hld7_5[159:0] ;
			coe_dat_hld7_7[159:0]  <= #DLY coe_dat_hld7_6[159:0] ;
			coe_dat_hld7_8[159:0]  <= #DLY coe_dat_hld7_7[159:0] ;

			coe_dat_hld8_1[159:0]  <= #DLY coe_dat8[159:0] ;
			coe_dat_hld8_2[159:0]  <= #DLY coe_dat_hld8_1[159:0] ;
			coe_dat_hld8_3[159:0]  <= #DLY coe_dat_hld8_2[159:0] ;
			coe_dat_hld8_4[159:0]  <= #DLY coe_dat_hld8_3[159:0] ;
			coe_dat_hld8_5[159:0]  <= #DLY coe_dat_hld8_4[159:0] ;
			coe_dat_hld8_6[159:0]  <= #DLY coe_dat_hld8_5[159:0] ;
			coe_dat_hld8_7[159:0]  <= #DLY coe_dat_hld8_6[159:0] ;
			coe_dat_hld8_8[159:0]  <= #DLY coe_dat_hld8_7[159:0] ;

            if(in_adr_diff_flg) begin
    			in_dat_hld1[159:0] <= #DLY in_dat[159:0] ;
	    		in_dat_hld2[159:0] <= #DLY in_dat_hld1[159:0] ;
		    	in_dat_hld3[159:0] <= #DLY in_dat_hld2[159:0] ;
			    in_dat_hld4[159:0] <= #DLY in_dat_hld3[159:0] ;
			    in_dat_hld5[159:0] <= #DLY in_dat_hld4[159:0] ;
			    in_dat_hld6[159:0] <= #DLY in_dat_hld5[159:0] ;
			    in_dat_hld7[159:0] <= #DLY in_dat_hld6[159:0] ;
			    in_dat_hld8[159:0] <= #DLY in_dat_hld7[159:0] ;
			end
		end
	end

    wire [1279:0] in_dat_wire = {in_dat_hld8[159:0],in_dat_hld7[159:0],in_dat_hld6[159:0],in_dat_hld5[159:0],
	                             in_dat_hld4[159:0],in_dat_hld3[159:0],in_dat_hld2[159:0],in_dat_hld1[159:0]};

    wire [1279:0] coe_dat1_wire = {coe_dat_hld1_8[159:0],coe_dat_hld1_7[159:0],
	                               coe_dat_hld1_6[159:0],coe_dat_hld1_5[159:0],
	                               coe_dat_hld1_4[159:0],coe_dat_hld1_3[159:0],
								   coe_dat_hld1_2[159:0],coe_dat_hld1_1[159:0]};
    wire [1279:0] coe_dat2_wire = {coe_dat_hld2_8[159:0],coe_dat_hld2_7[159:0],
	                               coe_dat_hld2_6[159:0],coe_dat_hld2_5[159:0],
	                               coe_dat_hld2_4[159:0],coe_dat_hld2_3[159:0],
								   coe_dat_hld2_2[159:0],coe_dat_hld2_1[159:0]};
    wire [1279:0] coe_dat3_wire = {coe_dat_hld3_8[159:0],coe_dat_hld3_7[159:0],
	                               coe_dat_hld3_6[159:0],coe_dat_hld3_5[159:0],
	                               coe_dat_hld3_4[159:0],coe_dat_hld3_3[159:0],
								   coe_dat_hld3_2[159:0],coe_dat_hld3_1[159:0]};
    wire [1279:0] coe_dat4_wire = {coe_dat_hld4_8[159:0],coe_dat_hld4_7[159:0],
	                               coe_dat_hld4_6[159:0],coe_dat_hld4_5[159:0],
	                               coe_dat_hld4_4[159:0],coe_dat_hld4_3[159:0],
								   coe_dat_hld4_2[159:0],coe_dat_hld4_1[159:0]};
    wire [1279:0] coe_dat5_wire = {coe_dat_hld5_8[159:0],coe_dat_hld5_7[159:0],
	                               coe_dat_hld5_6[159:0],coe_dat_hld5_5[159:0],
	                               coe_dat_hld5_4[159:0],coe_dat_hld5_3[159:0],
								   coe_dat_hld5_2[159:0],coe_dat_hld5_1[159:0]};
    wire [1279:0] coe_dat6_wire = {coe_dat_hld6_8[159:0],coe_dat_hld6_7[159:0],
	                               coe_dat_hld6_6[159:0],coe_dat_hld6_5[159:0],
	                               coe_dat_hld6_4[159:0],coe_dat_hld6_3[159:0],
								   coe_dat_hld6_2[159:0],coe_dat_hld6_1[159:0]};
    wire [1279:0] coe_dat7_wire = {coe_dat_hld7_8[159:0],coe_dat_hld7_7[159:0],
	                               coe_dat_hld7_6[159:0],coe_dat_hld7_5[159:0],
	                               coe_dat_hld7_4[159:0],coe_dat_hld7_3[159:0],
								   coe_dat_hld7_2[159:0],coe_dat_hld7_1[159:0]};
    wire [1279:0] coe_dat8_wire = {coe_dat_hld8_8[159:0],coe_dat_hld8_7[159:0],
	                               coe_dat_hld8_6[159:0],coe_dat_hld8_5[159:0],
	                               coe_dat_hld8_4[159:0],coe_dat_hld8_3[159:0],
								   coe_dat_hld8_2[159:0],coe_dat_hld8_1[159:0]};

    wire [9:0] in_dat_wire01 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1279:1270] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[959:950]   :
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[639:630]   :
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[319:310]   : 10'd0 ;
    wire [9:0] in_dat_wire02 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1269:1260] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[949:940]   : 
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[629:620]   : 
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[309:300]   : 10'd0 ;
    wire [9:0] in_dat_wire03 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1259:1250] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[939:930]   : 
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[619:610]   : 
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[299:290]   : 10'd0 ;
    wire [9:0] in_dat_wire04 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1249:1240] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[929:920]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[609:600]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[289:280]   : 10'd0 ;
    wire [9:0] in_dat_wire05 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1239:1230] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[919:910]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[599:590]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[279:270]   : 10'd0 ;
    wire [9:0] in_dat_wire06 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1229:1220] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[909:900]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[589:580]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[269:260]   : 10'd0 ;
    wire [9:0] in_dat_wire07 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1219:1210] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[899:890]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[579:570]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[259:250]   : 10'd0 ;
    wire [9:0] in_dat_wire08 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1209:1200] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[889:880]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[569:560]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[249:240]   : 10'd0 ;
    wire [9:0] in_dat_wire09 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1199:1190] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[879:870]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[559:550]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[239:230]   : 10'd0 ;
    wire [9:0] in_dat_wire10 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1189:1180] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[869:860]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[549:540]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[229:220]   : 10'd0 ;
    wire [9:0] in_dat_wire11 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1179:1170] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[859:850]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[539:530]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[219:210]   : 10'd0 ;
    wire [9:0] in_dat_wire12 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1169:1160] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[849:840]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[529:520]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[209:200]   : 10'd0 ;
    wire [9:0] in_dat_wire13 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1159:1150] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[839:830]   :
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[519:510]   :
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[199:190]   : 10'd0 ;
    wire [9:0] in_dat_wire14 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1149:1140] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[829:820]   :
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[509:500]   :
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[189:180]   : 10'd0 ;
    wire [9:0] in_dat_wire15 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1139:1130] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[819:810]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[499:490]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[179:170]   : 10'd0 ;
    wire [9:0] in_dat_wire16 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1129:1120] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[809:800]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[489:480]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[169:160]   : 10'd0 ;
    wire [9:0] in_dat_wire17 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1119:1110] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[799:790]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[479:470]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[159:150]   : 10'd0 ;
    wire [9:0] in_dat_wire18 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1109:1100] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[789:780]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[469:460]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[149:140]   : 10'd0 ;
    wire [9:0] in_dat_wire19 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1099:1090] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[779:770]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[459:450]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[139:130]   : 10'd0 ;
    wire [9:0] in_dat_wire20 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1089:1080] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[769:760]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[449:440]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[129:120]   : 10'd0 ;
    wire [9:0] in_dat_wire21 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1079:1070] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[759:750]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[439:430]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[119:110]   : 10'd0 ;
    wire [9:0] in_dat_wire22 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1069:1060] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[749:740]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[429:420]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[109:100]   : 10'd0 ;
    wire [9:0] in_dat_wire23 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1059:1050] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[739:730]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[419:410]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[99:90]     : 10'd0 ;
    wire [9:0] in_dat_wire24 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1049:1040] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[729:720]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[409:400]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[89:80]     : 10'd0 ;
    wire [9:0] in_dat_wire25 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1039:1030] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[719:710]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[399:390]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[79:70]     : 10'd0 ;
    wire [9:0] in_dat_wire26 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1029:1020] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[709:700]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[389:380]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[69:60]     : 10'd0 ;
    wire [9:0] in_dat_wire27 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1019:1010] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[699:690]   :   
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[379:370]   :   
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[59:50]     : 10'd0 ;
    wire [9:0] in_dat_wire28 = (row1_cnt[1:0]==2'd0)? in_dat_wire[1009:1000] :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[689:680]   :  
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[369:360]   :  
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[49:40]     : 10'd0 ;
    wire [9:0] in_dat_wire29 = (row1_cnt[1:0]==2'd0)? in_dat_wire[999:990]   :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[679:670]   :
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[359:350]   :
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[39:30]     : 10'd0 ;
    wire [9:0] in_dat_wire30 = (row1_cnt[1:0]==2'd0)? in_dat_wire[989:980]   :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[669:660]   : 
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[349:340]   : 
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[29:20]     : 10'd0 ;
    wire [9:0] in_dat_wire31 = (row1_cnt[1:0]==2'd0)? in_dat_wire[979:970]   :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[659:650]   :
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[339:330]   :
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[19:10]     : 10'd0 ;
    wire [9:0] in_dat_wire32 = (row1_cnt[1:0]==2'd0)? in_dat_wire[969:960]   :
                               (row1_cnt[1:0]==2'd1)? in_dat_wire[649:640]   :
                               (row1_cnt[1:0]==2'd2)? in_dat_wire[329:320]   :
                               (row1_cnt[1:0]==2'd3)? in_dat_wire[9:0]       : 10'd0 ;

 
    wire [9:0] coe_dat1_wire_1_01 = coe_dat1_wire[1279:1270] ;
    wire [9:0] coe_dat1_wire_2_01 = coe_dat1_wire[959:950]   ;
    wire [9:0] coe_dat1_wire_3_01 = coe_dat1_wire[639:630]   ;
    wire [9:0] coe_dat1_wire_4_01 = coe_dat1_wire[319:310]   ;
    wire [9:0] coe_dat1_wire_1_02 = coe_dat1_wire[1269:1260] ;
    wire [9:0] coe_dat1_wire_2_02 = coe_dat1_wire[949:940]   ;
    wire [9:0] coe_dat1_wire_3_02 = coe_dat1_wire[629:620]   ;
    wire [9:0] coe_dat1_wire_4_02 = coe_dat1_wire[309:300]   ;
    wire [9:0] coe_dat1_wire_1_03 = coe_dat1_wire[1259:1250] ;
    wire [9:0] coe_dat1_wire_2_03 = coe_dat1_wire[939:930]   ;
    wire [9:0] coe_dat1_wire_3_03 = coe_dat1_wire[619:610]   ;
    wire [9:0] coe_dat1_wire_4_03 = coe_dat1_wire[299:290]   ;
    wire [9:0] coe_dat1_wire_1_04 = coe_dat1_wire[1249:1240] ;
    wire [9:0] coe_dat1_wire_2_04 = coe_dat1_wire[929:920]   ;
    wire [9:0] coe_dat1_wire_3_04 = coe_dat1_wire[609:600]   ;
    wire [9:0] coe_dat1_wire_4_04 = coe_dat1_wire[289:280]   ;
    wire [9:0] coe_dat1_wire_1_05 = coe_dat1_wire[1239:1230] ;
    wire [9:0] coe_dat1_wire_2_05 = coe_dat1_wire[919:910]   ;
    wire [9:0] coe_dat1_wire_3_05 = coe_dat1_wire[599:590]   ;
    wire [9:0] coe_dat1_wire_4_05 = coe_dat1_wire[279:270]   ;
    wire [9:0] coe_dat1_wire_1_06 = coe_dat1_wire[1229:1220] ;
    wire [9:0] coe_dat1_wire_2_06 = coe_dat1_wire[909:900]   ;
    wire [9:0] coe_dat1_wire_3_06 = coe_dat1_wire[589:580]   ;
    wire [9:0] coe_dat1_wire_4_06 = coe_dat1_wire[269:260]   ;
    wire [9:0] coe_dat1_wire_1_07 = coe_dat1_wire[1219:1210] ;
    wire [9:0] coe_dat1_wire_2_07 = coe_dat1_wire[899:890]   ;
    wire [9:0] coe_dat1_wire_3_07 = coe_dat1_wire[579:570]   ;
    wire [9:0] coe_dat1_wire_4_07 = coe_dat1_wire[259:250]   ;
    wire [9:0] coe_dat1_wire_1_08 = coe_dat1_wire[1209:1200] ;
    wire [9:0] coe_dat1_wire_2_08 = coe_dat1_wire[889:880]   ;
    wire [9:0] coe_dat1_wire_3_08 = coe_dat1_wire[569:560]   ;
    wire [9:0] coe_dat1_wire_4_08 = coe_dat1_wire[249:240]   ;
    wire [9:0] coe_dat1_wire_1_09 = coe_dat1_wire[1199:1190] ;
    wire [9:0] coe_dat1_wire_2_09 = coe_dat1_wire[879:870]   ;
    wire [9:0] coe_dat1_wire_3_09 = coe_dat1_wire[559:550]   ;
    wire [9:0] coe_dat1_wire_4_09 = coe_dat1_wire[239:230]   ;
    wire [9:0] coe_dat1_wire_1_10 = coe_dat1_wire[1189:1180] ;
    wire [9:0] coe_dat1_wire_2_10 = coe_dat1_wire[869:860]   ;
    wire [9:0] coe_dat1_wire_3_10 = coe_dat1_wire[549:540]   ;
    wire [9:0] coe_dat1_wire_4_10 = coe_dat1_wire[229:220]   ;
    wire [9:0] coe_dat1_wire_1_11 = coe_dat1_wire[1179:1170] ;
    wire [9:0] coe_dat1_wire_2_11 = coe_dat1_wire[859:850]   ;
    wire [9:0] coe_dat1_wire_3_11 = coe_dat1_wire[539:530]   ;
    wire [9:0] coe_dat1_wire_4_11 = coe_dat1_wire[219:210]   ;
    wire [9:0] coe_dat1_wire_1_12 = coe_dat1_wire[1169:1160] ;
    wire [9:0] coe_dat1_wire_2_12 = coe_dat1_wire[849:840]   ;
    wire [9:0] coe_dat1_wire_3_12 = coe_dat1_wire[529:520]   ;
    wire [9:0] coe_dat1_wire_4_12 = coe_dat1_wire[209:200]   ;
    wire [9:0] coe_dat1_wire_1_13 = coe_dat1_wire[1159:1150] ;
    wire [9:0] coe_dat1_wire_2_13 = coe_dat1_wire[839:830]   ;
    wire [9:0] coe_dat1_wire_3_13 = coe_dat1_wire[519:510]   ;
    wire [9:0] coe_dat1_wire_4_13 = coe_dat1_wire[199:190]   ;
    wire [9:0] coe_dat1_wire_1_14 = coe_dat1_wire[1149:1140] ;
    wire [9:0] coe_dat1_wire_2_14 = coe_dat1_wire[829:820]   ;
    wire [9:0] coe_dat1_wire_3_14 = coe_dat1_wire[509:500]   ;
    wire [9:0] coe_dat1_wire_4_14 = coe_dat1_wire[189:180]   ;
    wire [9:0] coe_dat1_wire_1_15 = coe_dat1_wire[1139:1130] ;
    wire [9:0] coe_dat1_wire_2_15 = coe_dat1_wire[819:810]   ;
    wire [9:0] coe_dat1_wire_3_15 = coe_dat1_wire[499:490]   ;
    wire [9:0] coe_dat1_wire_4_15 = coe_dat1_wire[179:170]   ;
    wire [9:0] coe_dat1_wire_1_16 = coe_dat1_wire[1129:1120] ;
    wire [9:0] coe_dat1_wire_2_16 = coe_dat1_wire[809:800]   ;
    wire [9:0] coe_dat1_wire_3_16 = coe_dat1_wire[489:480]   ;
    wire [9:0] coe_dat1_wire_4_16 = coe_dat1_wire[169:160]   ;
    wire [9:0] coe_dat1_wire_1_17 = coe_dat1_wire[1119:1110] ;
    wire [9:0] coe_dat1_wire_2_17 = coe_dat1_wire[799:790]   ;
    wire [9:0] coe_dat1_wire_3_17 = coe_dat1_wire[479:470]   ;
    wire [9:0] coe_dat1_wire_4_17 = coe_dat1_wire[159:150]   ;
    wire [9:0] coe_dat1_wire_1_18 = coe_dat1_wire[1109:1100] ;
    wire [9:0] coe_dat1_wire_2_18 = coe_dat1_wire[789:780]   ;
    wire [9:0] coe_dat1_wire_3_18 = coe_dat1_wire[469:460]   ;
    wire [9:0] coe_dat1_wire_4_18 = coe_dat1_wire[149:140]   ;
    wire [9:0] coe_dat1_wire_1_19 = coe_dat1_wire[1099:1090] ;
    wire [9:0] coe_dat1_wire_2_19 = coe_dat1_wire[779:770]   ;
    wire [9:0] coe_dat1_wire_3_19 = coe_dat1_wire[459:450]   ;
    wire [9:0] coe_dat1_wire_4_19 = coe_dat1_wire[139:130]   ;
    wire [9:0] coe_dat1_wire_1_20 = coe_dat1_wire[1089:1080] ;
    wire [9:0] coe_dat1_wire_2_20 = coe_dat1_wire[769:760]   ;
    wire [9:0] coe_dat1_wire_3_20 = coe_dat1_wire[449:440]   ;
    wire [9:0] coe_dat1_wire_4_20 = coe_dat1_wire[129:120]   ;
    wire [9:0] coe_dat1_wire_1_21 = coe_dat1_wire[1079:1070] ;
    wire [9:0] coe_dat1_wire_2_21 = coe_dat1_wire[759:750]   ;
    wire [9:0] coe_dat1_wire_3_21 = coe_dat1_wire[439:430]   ;
    wire [9:0] coe_dat1_wire_4_21 = coe_dat1_wire[119:110]   ;
    wire [9:0] coe_dat1_wire_1_22 = coe_dat1_wire[1069:1060] ;
    wire [9:0] coe_dat1_wire_2_22 = coe_dat1_wire[749:740]   ;
    wire [9:0] coe_dat1_wire_3_22 = coe_dat1_wire[429:420]   ;
    wire [9:0] coe_dat1_wire_4_22 = coe_dat1_wire[109:100]   ;
    wire [9:0] coe_dat1_wire_1_23 = coe_dat1_wire[1059:1050] ;
    wire [9:0] coe_dat1_wire_2_23 = coe_dat1_wire[739:730]   ;
    wire [9:0] coe_dat1_wire_3_23 = coe_dat1_wire[419:410]   ;
    wire [9:0] coe_dat1_wire_4_23 = coe_dat1_wire[99:90]     ;
    wire [9:0] coe_dat1_wire_1_24 = coe_dat1_wire[1049:1040] ;
    wire [9:0] coe_dat1_wire_2_24 = coe_dat1_wire[729:720]   ;
    wire [9:0] coe_dat1_wire_3_24 = coe_dat1_wire[409:400]   ;
    wire [9:0] coe_dat1_wire_4_24 = coe_dat1_wire[89:80]     ;
    wire [9:0] coe_dat1_wire_1_25 = coe_dat1_wire[1039:1030] ;
    wire [9:0] coe_dat1_wire_2_25 = coe_dat1_wire[719:710]   ;
    wire [9:0] coe_dat1_wire_3_25 = coe_dat1_wire[399:390]   ;
    wire [9:0] coe_dat1_wire_4_25 = coe_dat1_wire[79:70]     ;
    wire [9:0] coe_dat1_wire_1_26 = coe_dat1_wire[1029:1020] ;
    wire [9:0] coe_dat1_wire_2_26 = coe_dat1_wire[709:700]   ;
    wire [9:0] coe_dat1_wire_3_26 = coe_dat1_wire[389:380]   ;
    wire [9:0] coe_dat1_wire_4_26 = coe_dat1_wire[69:60]     ;
    wire [9:0] coe_dat1_wire_1_27 = coe_dat1_wire[1019:1010] ;
    wire [9:0] coe_dat1_wire_2_27 = coe_dat1_wire[699:690]   ;
    wire [9:0] coe_dat1_wire_3_27 = coe_dat1_wire[379:370]   ;
    wire [9:0] coe_dat1_wire_4_27 = coe_dat1_wire[59:50]     ;
    wire [9:0] coe_dat1_wire_1_28 = coe_dat1_wire[1009:1000] ;
    wire [9:0] coe_dat1_wire_2_28 = coe_dat1_wire[689:680]   ;
    wire [9:0] coe_dat1_wire_3_28 = coe_dat1_wire[369:360]   ;
    wire [9:0] coe_dat1_wire_4_28 = coe_dat1_wire[49:40]     ;
    wire [9:0] coe_dat1_wire_1_29 = coe_dat1_wire[999:990]   ;
    wire [9:0] coe_dat1_wire_2_29 = coe_dat1_wire[679:670]   ;
    wire [9:0] coe_dat1_wire_3_29 = coe_dat1_wire[359:350]   ;
    wire [9:0] coe_dat1_wire_4_29 = coe_dat1_wire[39:30]     ;
    wire [9:0] coe_dat1_wire_1_30 = coe_dat1_wire[989:980]   ;
    wire [9:0] coe_dat1_wire_2_30 = coe_dat1_wire[669:660]   ;
    wire [9:0] coe_dat1_wire_3_30 = coe_dat1_wire[349:340]   ;
    wire [9:0] coe_dat1_wire_4_30 = coe_dat1_wire[29:20]     ;
    wire [9:0] coe_dat1_wire_1_31 = coe_dat1_wire[979:970]   ;
    wire [9:0] coe_dat1_wire_2_31 = coe_dat1_wire[659:650]   ;
    wire [9:0] coe_dat1_wire_3_31 = coe_dat1_wire[339:330]   ;
    wire [9:0] coe_dat1_wire_4_31 = coe_dat1_wire[19:10]     ;
    wire [9:0] coe_dat1_wire_1_32 = coe_dat1_wire[969:960]   ;
    wire [9:0] coe_dat1_wire_2_32 = coe_dat1_wire[649:640]   ;
    wire [9:0] coe_dat1_wire_3_32 = coe_dat1_wire[329:320]   ;
    wire [9:0] coe_dat1_wire_4_32 = coe_dat1_wire[9:0]       ;

    wire [9:0] coe_dat2_wire_1_01 = coe_dat2_wire[1279:1270] ;
    wire [9:0] coe_dat2_wire_2_01 = coe_dat2_wire[959:950]   ;
    wire [9:0] coe_dat2_wire_3_01 = coe_dat2_wire[639:630]   ;
    wire [9:0] coe_dat2_wire_4_01 = coe_dat2_wire[319:310]   ;
    wire [9:0] coe_dat2_wire_1_02 = coe_dat2_wire[1269:1260] ;
    wire [9:0] coe_dat2_wire_2_02 = coe_dat2_wire[949:940]   ;
    wire [9:0] coe_dat2_wire_3_02 = coe_dat2_wire[629:620]   ;
    wire [9:0] coe_dat2_wire_4_02 = coe_dat2_wire[309:300]   ;
    wire [9:0] coe_dat2_wire_1_03 = coe_dat2_wire[1259:1250] ;
    wire [9:0] coe_dat2_wire_2_03 = coe_dat2_wire[939:930]   ;
    wire [9:0] coe_dat2_wire_3_03 = coe_dat2_wire[619:610]   ;
    wire [9:0] coe_dat2_wire_4_03 = coe_dat2_wire[299:290]   ;
    wire [9:0] coe_dat2_wire_1_04 = coe_dat2_wire[1249:1240] ;
    wire [9:0] coe_dat2_wire_2_04 = coe_dat2_wire[929:920]   ;
    wire [9:0] coe_dat2_wire_3_04 = coe_dat2_wire[609:600]   ;
    wire [9:0] coe_dat2_wire_4_04 = coe_dat2_wire[289:280]   ;
    wire [9:0] coe_dat2_wire_1_05 = coe_dat2_wire[1239:1230] ;
    wire [9:0] coe_dat2_wire_2_05 = coe_dat2_wire[919:910]   ;
    wire [9:0] coe_dat2_wire_3_05 = coe_dat2_wire[599:590]   ;
    wire [9:0] coe_dat2_wire_4_05 = coe_dat2_wire[279:270]   ;
    wire [9:0] coe_dat2_wire_1_06 = coe_dat2_wire[1229:1220] ;
    wire [9:0] coe_dat2_wire_2_06 = coe_dat2_wire[909:900]   ;
    wire [9:0] coe_dat2_wire_3_06 = coe_dat2_wire[589:580]   ;
    wire [9:0] coe_dat2_wire_4_06 = coe_dat2_wire[269:260]   ;
    wire [9:0] coe_dat2_wire_1_07 = coe_dat2_wire[1219:1210] ;
    wire [9:0] coe_dat2_wire_2_07 = coe_dat2_wire[899:890]   ;
    wire [9:0] coe_dat2_wire_3_07 = coe_dat2_wire[579:570]   ;
    wire [9:0] coe_dat2_wire_4_07 = coe_dat2_wire[259:250]   ;
    wire [9:0] coe_dat2_wire_1_08 = coe_dat2_wire[1209:1200] ;
    wire [9:0] coe_dat2_wire_2_08 = coe_dat2_wire[889:880]   ;
    wire [9:0] coe_dat2_wire_3_08 = coe_dat2_wire[569:560]   ;
    wire [9:0] coe_dat2_wire_4_08 = coe_dat2_wire[249:240]   ;
    wire [9:0] coe_dat2_wire_1_09 = coe_dat2_wire[1199:1190] ;
    wire [9:0] coe_dat2_wire_2_09 = coe_dat2_wire[879:870]   ;
    wire [9:0] coe_dat2_wire_3_09 = coe_dat2_wire[559:550]   ;
    wire [9:0] coe_dat2_wire_4_09 = coe_dat2_wire[239:230]   ;
    wire [9:0] coe_dat2_wire_1_10 = coe_dat2_wire[1189:1180] ;
    wire [9:0] coe_dat2_wire_2_10 = coe_dat2_wire[869:860]   ;
    wire [9:0] coe_dat2_wire_3_10 = coe_dat2_wire[549:540]   ;
    wire [9:0] coe_dat2_wire_4_10 = coe_dat2_wire[229:220]   ;
    wire [9:0] coe_dat2_wire_1_11 = coe_dat2_wire[1179:1170] ;
    wire [9:0] coe_dat2_wire_2_11 = coe_dat2_wire[859:850]   ;
    wire [9:0] coe_dat2_wire_3_11 = coe_dat2_wire[539:530]   ;
    wire [9:0] coe_dat2_wire_4_11 = coe_dat2_wire[219:210]   ;
    wire [9:0] coe_dat2_wire_1_12 = coe_dat2_wire[1169:1160] ;
    wire [9:0] coe_dat2_wire_2_12 = coe_dat2_wire[849:840]   ;
    wire [9:0] coe_dat2_wire_3_12 = coe_dat2_wire[529:520]   ;
    wire [9:0] coe_dat2_wire_4_12 = coe_dat2_wire[209:200]   ;
    wire [9:0] coe_dat2_wire_1_13 = coe_dat2_wire[1159:1150] ;
    wire [9:0] coe_dat2_wire_2_13 = coe_dat2_wire[839:830]   ;
    wire [9:0] coe_dat2_wire_3_13 = coe_dat2_wire[519:510]   ;
    wire [9:0] coe_dat2_wire_4_13 = coe_dat2_wire[199:190]   ;
    wire [9:0] coe_dat2_wire_1_14 = coe_dat2_wire[1149:1140] ;
    wire [9:0] coe_dat2_wire_2_14 = coe_dat2_wire[829:820]   ;
    wire [9:0] coe_dat2_wire_3_14 = coe_dat2_wire[509:500]   ;
    wire [9:0] coe_dat2_wire_4_14 = coe_dat2_wire[189:180]   ;
    wire [9:0] coe_dat2_wire_1_15 = coe_dat2_wire[1139:1130] ;
    wire [9:0] coe_dat2_wire_2_15 = coe_dat2_wire[819:810]   ;
    wire [9:0] coe_dat2_wire_3_15 = coe_dat2_wire[499:490]   ;
    wire [9:0] coe_dat2_wire_4_15 = coe_dat2_wire[179:170]   ;
    wire [9:0] coe_dat2_wire_1_16 = coe_dat2_wire[1129:1120] ;
    wire [9:0] coe_dat2_wire_2_16 = coe_dat2_wire[809:800]   ;
    wire [9:0] coe_dat2_wire_3_16 = coe_dat2_wire[489:480]   ;
    wire [9:0] coe_dat2_wire_4_16 = coe_dat2_wire[169:160]   ;
    wire [9:0] coe_dat2_wire_1_17 = coe_dat2_wire[1119:1110] ;
    wire [9:0] coe_dat2_wire_2_17 = coe_dat2_wire[799:790]   ;
    wire [9:0] coe_dat2_wire_3_17 = coe_dat2_wire[479:470]   ;
    wire [9:0] coe_dat2_wire_4_17 = coe_dat2_wire[159:150]   ;
    wire [9:0] coe_dat2_wire_1_18 = coe_dat2_wire[1109:1100] ;
    wire [9:0] coe_dat2_wire_2_18 = coe_dat2_wire[789:780]   ;
    wire [9:0] coe_dat2_wire_3_18 = coe_dat2_wire[469:460]   ;
    wire [9:0] coe_dat2_wire_4_18 = coe_dat2_wire[149:140]   ;
    wire [9:0] coe_dat2_wire_1_19 = coe_dat2_wire[1099:1090] ;
    wire [9:0] coe_dat2_wire_2_19 = coe_dat2_wire[779:770]   ;
    wire [9:0] coe_dat2_wire_3_19 = coe_dat2_wire[459:450]   ;
    wire [9:0] coe_dat2_wire_4_19 = coe_dat2_wire[139:130]   ;
    wire [9:0] coe_dat2_wire_1_20 = coe_dat2_wire[1089:1080] ;
    wire [9:0] coe_dat2_wire_2_20 = coe_dat2_wire[769:760]   ;
    wire [9:0] coe_dat2_wire_3_20 = coe_dat2_wire[449:440]   ;
    wire [9:0] coe_dat2_wire_4_20 = coe_dat2_wire[129:120]   ;
    wire [9:0] coe_dat2_wire_1_21 = coe_dat2_wire[1079:1070] ;
    wire [9:0] coe_dat2_wire_2_21 = coe_dat2_wire[759:750]   ;
    wire [9:0] coe_dat2_wire_3_21 = coe_dat2_wire[439:430]   ;
    wire [9:0] coe_dat2_wire_4_21 = coe_dat2_wire[119:110]   ;
    wire [9:0] coe_dat2_wire_1_22 = coe_dat2_wire[1069:1060] ;
    wire [9:0] coe_dat2_wire_2_22 = coe_dat2_wire[749:740]   ;
    wire [9:0] coe_dat2_wire_3_22 = coe_dat2_wire[429:420]   ;
    wire [9:0] coe_dat2_wire_4_22 = coe_dat2_wire[109:100]   ;
    wire [9:0] coe_dat2_wire_1_23 = coe_dat2_wire[1059:1050] ;
    wire [9:0] coe_dat2_wire_2_23 = coe_dat2_wire[739:730]   ;
    wire [9:0] coe_dat2_wire_3_23 = coe_dat2_wire[419:410]   ;
    wire [9:0] coe_dat2_wire_4_23 = coe_dat2_wire[99:90]     ;
    wire [9:0] coe_dat2_wire_1_24 = coe_dat2_wire[1049:1040] ;
    wire [9:0] coe_dat2_wire_2_24 = coe_dat2_wire[729:720]   ;
    wire [9:0] coe_dat2_wire_3_24 = coe_dat2_wire[409:400]   ;
    wire [9:0] coe_dat2_wire_4_24 = coe_dat2_wire[89:80]     ;
    wire [9:0] coe_dat2_wire_1_25 = coe_dat2_wire[1039:1030] ;
    wire [9:0] coe_dat2_wire_2_25 = coe_dat2_wire[719:710]   ;
    wire [9:0] coe_dat2_wire_3_25 = coe_dat2_wire[399:390]   ;
    wire [9:0] coe_dat2_wire_4_25 = coe_dat2_wire[79:70]     ;
    wire [9:0] coe_dat2_wire_1_26 = coe_dat2_wire[1029:1020] ;
    wire [9:0] coe_dat2_wire_2_26 = coe_dat2_wire[709:700]   ;
    wire [9:0] coe_dat2_wire_3_26 = coe_dat2_wire[389:380]   ;
    wire [9:0] coe_dat2_wire_4_26 = coe_dat2_wire[69:60]     ;
    wire [9:0] coe_dat2_wire_1_27 = coe_dat2_wire[1019:1010] ;
    wire [9:0] coe_dat2_wire_2_27 = coe_dat2_wire[699:690]   ;
    wire [9:0] coe_dat2_wire_3_27 = coe_dat2_wire[379:370]   ;
    wire [9:0] coe_dat2_wire_4_27 = coe_dat2_wire[59:50]     ;
    wire [9:0] coe_dat2_wire_1_28 = coe_dat2_wire[1009:1000] ;
    wire [9:0] coe_dat2_wire_2_28 = coe_dat2_wire[689:680]   ;
    wire [9:0] coe_dat2_wire_3_28 = coe_dat2_wire[369:360]   ;
    wire [9:0] coe_dat2_wire_4_28 = coe_dat2_wire[49:40]     ;
    wire [9:0] coe_dat2_wire_1_29 = coe_dat2_wire[999:990]   ;
    wire [9:0] coe_dat2_wire_2_29 = coe_dat2_wire[679:670]   ;
    wire [9:0] coe_dat2_wire_3_29 = coe_dat2_wire[359:350]   ;
    wire [9:0] coe_dat2_wire_4_29 = coe_dat2_wire[39:30]     ;
    wire [9:0] coe_dat2_wire_1_30 = coe_dat2_wire[989:980]   ;
    wire [9:0] coe_dat2_wire_2_30 = coe_dat2_wire[669:660]   ;
    wire [9:0] coe_dat2_wire_3_30 = coe_dat2_wire[349:340]   ;
    wire [9:0] coe_dat2_wire_4_30 = coe_dat2_wire[29:20]     ;
    wire [9:0] coe_dat2_wire_1_31 = coe_dat2_wire[979:970]   ;
    wire [9:0] coe_dat2_wire_2_31 = coe_dat2_wire[659:650]   ;
    wire [9:0] coe_dat2_wire_3_31 = coe_dat2_wire[339:330]   ;
    wire [9:0] coe_dat2_wire_4_31 = coe_dat2_wire[19:10]     ;
    wire [9:0] coe_dat2_wire_1_32 = coe_dat2_wire[969:960]   ;
    wire [9:0] coe_dat2_wire_2_32 = coe_dat2_wire[649:640]   ;
    wire [9:0] coe_dat2_wire_3_32 = coe_dat2_wire[329:320]   ;
    wire [9:0] coe_dat2_wire_4_32 = coe_dat2_wire[9:0]       ;
	
    wire [9:0] coe_dat3_wire_1_01 = coe_dat3_wire[1279:1270] ;
    wire [9:0] coe_dat3_wire_2_01 = coe_dat3_wire[959:950]   ;
    wire [9:0] coe_dat3_wire_3_01 = coe_dat3_wire[639:630]   ;
    wire [9:0] coe_dat3_wire_4_01 = coe_dat3_wire[319:310]   ;
    wire [9:0] coe_dat3_wire_1_02 = coe_dat3_wire[1269:1260] ;
    wire [9:0] coe_dat3_wire_2_02 = coe_dat3_wire[949:940]   ;
    wire [9:0] coe_dat3_wire_3_02 = coe_dat3_wire[629:620]   ;
    wire [9:0] coe_dat3_wire_4_02 = coe_dat3_wire[309:300]   ;
    wire [9:0] coe_dat3_wire_1_03 = coe_dat3_wire[1259:1250] ;
    wire [9:0] coe_dat3_wire_2_03 = coe_dat3_wire[939:930]   ;
    wire [9:0] coe_dat3_wire_3_03 = coe_dat3_wire[619:610]   ;
    wire [9:0] coe_dat3_wire_4_03 = coe_dat3_wire[299:290]   ;
    wire [9:0] coe_dat3_wire_1_04 = coe_dat3_wire[1249:1240] ;
    wire [9:0] coe_dat3_wire_2_04 = coe_dat3_wire[929:920]   ;
    wire [9:0] coe_dat3_wire_3_04 = coe_dat3_wire[609:600]   ;
    wire [9:0] coe_dat3_wire_4_04 = coe_dat3_wire[289:280]   ;
    wire [9:0] coe_dat3_wire_1_05 = coe_dat3_wire[1239:1230] ;
    wire [9:0] coe_dat3_wire_2_05 = coe_dat3_wire[919:910]   ;
    wire [9:0] coe_dat3_wire_3_05 = coe_dat3_wire[599:590]   ;
    wire [9:0] coe_dat3_wire_4_05 = coe_dat3_wire[279:270]   ;
    wire [9:0] coe_dat3_wire_1_06 = coe_dat3_wire[1229:1220] ;
    wire [9:0] coe_dat3_wire_2_06 = coe_dat3_wire[909:900]   ;
    wire [9:0] coe_dat3_wire_3_06 = coe_dat3_wire[589:580]   ;
    wire [9:0] coe_dat3_wire_4_06 = coe_dat3_wire[269:260]   ;
    wire [9:0] coe_dat3_wire_1_07 = coe_dat3_wire[1219:1210] ;
    wire [9:0] coe_dat3_wire_2_07 = coe_dat3_wire[899:890]   ;
    wire [9:0] coe_dat3_wire_3_07 = coe_dat3_wire[579:570]   ;
    wire [9:0] coe_dat3_wire_4_07 = coe_dat3_wire[259:250]   ;
    wire [9:0] coe_dat3_wire_1_08 = coe_dat3_wire[1209:1200] ;
    wire [9:0] coe_dat3_wire_2_08 = coe_dat3_wire[889:880]   ;
    wire [9:0] coe_dat3_wire_3_08 = coe_dat3_wire[569:560]   ;
    wire [9:0] coe_dat3_wire_4_08 = coe_dat3_wire[249:240]   ;
    wire [9:0] coe_dat3_wire_1_09 = coe_dat3_wire[1199:1190] ;
    wire [9:0] coe_dat3_wire_2_09 = coe_dat3_wire[879:870]   ;
    wire [9:0] coe_dat3_wire_3_09 = coe_dat3_wire[559:550]   ;
    wire [9:0] coe_dat3_wire_4_09 = coe_dat3_wire[239:230]   ;
    wire [9:0] coe_dat3_wire_1_10 = coe_dat3_wire[1189:1180] ;
    wire [9:0] coe_dat3_wire_2_10 = coe_dat3_wire[869:860]   ;
    wire [9:0] coe_dat3_wire_3_10 = coe_dat3_wire[549:540]   ;
    wire [9:0] coe_dat3_wire_4_10 = coe_dat3_wire[229:220]   ;
    wire [9:0] coe_dat3_wire_1_11 = coe_dat3_wire[1179:1170] ;
    wire [9:0] coe_dat3_wire_2_11 = coe_dat3_wire[859:850]   ;
    wire [9:0] coe_dat3_wire_3_11 = coe_dat3_wire[539:530]   ;
    wire [9:0] coe_dat3_wire_4_11 = coe_dat3_wire[219:210]   ;
    wire [9:0] coe_dat3_wire_1_12 = coe_dat3_wire[1169:1160] ;
    wire [9:0] coe_dat3_wire_2_12 = coe_dat3_wire[849:840]   ;
    wire [9:0] coe_dat3_wire_3_12 = coe_dat3_wire[529:520]   ;
    wire [9:0] coe_dat3_wire_4_12 = coe_dat3_wire[209:200]   ;
    wire [9:0] coe_dat3_wire_1_13 = coe_dat3_wire[1159:1150] ;
    wire [9:0] coe_dat3_wire_2_13 = coe_dat3_wire[839:830]   ;
    wire [9:0] coe_dat3_wire_3_13 = coe_dat3_wire[519:510]   ;
    wire [9:0] coe_dat3_wire_4_13 = coe_dat3_wire[199:190]   ;
    wire [9:0] coe_dat3_wire_1_14 = coe_dat3_wire[1149:1140] ;
    wire [9:0] coe_dat3_wire_2_14 = coe_dat3_wire[829:820]   ;
    wire [9:0] coe_dat3_wire_3_14 = coe_dat3_wire[509:500]   ;
    wire [9:0] coe_dat3_wire_4_14 = coe_dat3_wire[189:180]   ;
    wire [9:0] coe_dat3_wire_1_15 = coe_dat3_wire[1139:1130] ;
    wire [9:0] coe_dat3_wire_2_15 = coe_dat3_wire[819:810]   ;
    wire [9:0] coe_dat3_wire_3_15 = coe_dat3_wire[499:490]   ;
    wire [9:0] coe_dat3_wire_4_15 = coe_dat3_wire[179:170]   ;
    wire [9:0] coe_dat3_wire_1_16 = coe_dat3_wire[1129:1120] ;
    wire [9:0] coe_dat3_wire_2_16 = coe_dat3_wire[809:800]   ;
    wire [9:0] coe_dat3_wire_3_16 = coe_dat3_wire[489:480]   ;
    wire [9:0] coe_dat3_wire_4_16 = coe_dat3_wire[169:160]   ;
    wire [9:0] coe_dat3_wire_1_17 = coe_dat3_wire[1119:1110] ;
    wire [9:0] coe_dat3_wire_2_17 = coe_dat3_wire[799:790]   ;
    wire [9:0] coe_dat3_wire_3_17 = coe_dat3_wire[479:470]   ;
    wire [9:0] coe_dat3_wire_4_17 = coe_dat3_wire[159:150]   ;
    wire [9:0] coe_dat3_wire_1_18 = coe_dat3_wire[1109:1100] ;
    wire [9:0] coe_dat3_wire_2_18 = coe_dat3_wire[789:780]   ;
    wire [9:0] coe_dat3_wire_3_18 = coe_dat3_wire[469:460]   ;
    wire [9:0] coe_dat3_wire_4_18 = coe_dat3_wire[149:140]   ;
    wire [9:0] coe_dat3_wire_1_19 = coe_dat3_wire[1099:1090] ;
    wire [9:0] coe_dat3_wire_2_19 = coe_dat3_wire[779:770]   ;
    wire [9:0] coe_dat3_wire_3_19 = coe_dat3_wire[459:450]   ;
    wire [9:0] coe_dat3_wire_4_19 = coe_dat3_wire[139:130]   ;
    wire [9:0] coe_dat3_wire_1_20 = coe_dat3_wire[1089:1080] ;
    wire [9:0] coe_dat3_wire_2_20 = coe_dat3_wire[769:760]   ;
    wire [9:0] coe_dat3_wire_3_20 = coe_dat3_wire[449:440]   ;
    wire [9:0] coe_dat3_wire_4_20 = coe_dat3_wire[129:120]   ;
    wire [9:0] coe_dat3_wire_1_21 = coe_dat3_wire[1079:1070] ;
    wire [9:0] coe_dat3_wire_2_21 = coe_dat3_wire[759:750]   ;
    wire [9:0] coe_dat3_wire_3_21 = coe_dat3_wire[439:430]   ;
    wire [9:0] coe_dat3_wire_4_21 = coe_dat3_wire[119:110]   ;
    wire [9:0] coe_dat3_wire_1_22 = coe_dat3_wire[1069:1060] ;
    wire [9:0] coe_dat3_wire_2_22 = coe_dat3_wire[749:740]   ;
    wire [9:0] coe_dat3_wire_3_22 = coe_dat3_wire[429:420]   ;
    wire [9:0] coe_dat3_wire_4_22 = coe_dat3_wire[109:100]   ;
    wire [9:0] coe_dat3_wire_1_23 = coe_dat3_wire[1059:1050] ;
    wire [9:0] coe_dat3_wire_2_23 = coe_dat3_wire[739:730]   ;
    wire [9:0] coe_dat3_wire_3_23 = coe_dat3_wire[419:410]   ;
    wire [9:0] coe_dat3_wire_4_23 = coe_dat3_wire[99:90]     ;
    wire [9:0] coe_dat3_wire_1_24 = coe_dat3_wire[1049:1040] ;
    wire [9:0] coe_dat3_wire_2_24 = coe_dat3_wire[729:720]   ;
    wire [9:0] coe_dat3_wire_3_24 = coe_dat3_wire[409:400]   ;
    wire [9:0] coe_dat3_wire_4_24 = coe_dat3_wire[89:80]     ;
    wire [9:0] coe_dat3_wire_1_25 = coe_dat3_wire[1039:1030] ;
    wire [9:0] coe_dat3_wire_2_25 = coe_dat3_wire[719:710]   ;
    wire [9:0] coe_dat3_wire_3_25 = coe_dat3_wire[399:390]   ;
    wire [9:0] coe_dat3_wire_4_25 = coe_dat3_wire[79:70]     ;
    wire [9:0] coe_dat3_wire_1_26 = coe_dat3_wire[1029:1020] ;
    wire [9:0] coe_dat3_wire_2_26 = coe_dat3_wire[709:700]   ;
    wire [9:0] coe_dat3_wire_3_26 = coe_dat3_wire[389:380]   ;
    wire [9:0] coe_dat3_wire_4_26 = coe_dat3_wire[69:60]     ;
    wire [9:0] coe_dat3_wire_1_27 = coe_dat3_wire[1019:1010] ;
    wire [9:0] coe_dat3_wire_2_27 = coe_dat3_wire[699:690]   ;
    wire [9:0] coe_dat3_wire_3_27 = coe_dat3_wire[379:370]   ;
    wire [9:0] coe_dat3_wire_4_27 = coe_dat3_wire[59:50]     ;
    wire [9:0] coe_dat3_wire_1_28 = coe_dat3_wire[1009:1000] ;
    wire [9:0] coe_dat3_wire_2_28 = coe_dat3_wire[689:680]   ;
    wire [9:0] coe_dat3_wire_3_28 = coe_dat3_wire[369:360]   ;
    wire [9:0] coe_dat3_wire_4_28 = coe_dat3_wire[49:40]     ;
    wire [9:0] coe_dat3_wire_1_29 = coe_dat3_wire[999:990]   ;
    wire [9:0] coe_dat3_wire_2_29 = coe_dat3_wire[679:670]   ;
    wire [9:0] coe_dat3_wire_3_29 = coe_dat3_wire[359:350]   ;
    wire [9:0] coe_dat3_wire_4_29 = coe_dat3_wire[39:30]     ;
    wire [9:0] coe_dat3_wire_1_30 = coe_dat3_wire[989:980]   ;
    wire [9:0] coe_dat3_wire_2_30 = coe_dat3_wire[669:660]   ;
    wire [9:0] coe_dat3_wire_3_30 = coe_dat3_wire[349:340]   ;
    wire [9:0] coe_dat3_wire_4_30 = coe_dat3_wire[29:20]     ;
    wire [9:0] coe_dat3_wire_1_31 = coe_dat3_wire[979:970]   ;
    wire [9:0] coe_dat3_wire_2_31 = coe_dat3_wire[659:650]   ;
    wire [9:0] coe_dat3_wire_3_31 = coe_dat3_wire[339:330]   ;
    wire [9:0] coe_dat3_wire_4_31 = coe_dat3_wire[19:10]     ;
    wire [9:0] coe_dat3_wire_1_32 = coe_dat3_wire[969:960]   ;
    wire [9:0] coe_dat3_wire_2_32 = coe_dat3_wire[649:640]   ;
    wire [9:0] coe_dat3_wire_3_32 = coe_dat3_wire[329:320]   ;
    wire [9:0] coe_dat3_wire_4_32 = coe_dat3_wire[9:0]       ;

    wire [9:0] coe_dat4_wire_1_01 = coe_dat4_wire[1279:1270] ;
    wire [9:0] coe_dat4_wire_2_01 = coe_dat4_wire[959:950]   ;
    wire [9:0] coe_dat4_wire_3_01 = coe_dat4_wire[639:630]   ;
    wire [9:0] coe_dat4_wire_4_01 = coe_dat4_wire[319:310]   ;
    wire [9:0] coe_dat4_wire_1_02 = coe_dat4_wire[1269:1260] ;
    wire [9:0] coe_dat4_wire_2_02 = coe_dat4_wire[949:940]   ;
    wire [9:0] coe_dat4_wire_3_02 = coe_dat4_wire[629:620]   ;
    wire [9:0] coe_dat4_wire_4_02 = coe_dat4_wire[309:300]   ;
    wire [9:0] coe_dat4_wire_1_03 = coe_dat4_wire[1259:1250] ;
    wire [9:0] coe_dat4_wire_2_03 = coe_dat4_wire[939:930]   ;
    wire [9:0] coe_dat4_wire_3_03 = coe_dat4_wire[619:610]   ;
    wire [9:0] coe_dat4_wire_4_03 = coe_dat4_wire[299:290]   ;
    wire [9:0] coe_dat4_wire_1_04 = coe_dat4_wire[1249:1240] ;
    wire [9:0] coe_dat4_wire_2_04 = coe_dat4_wire[929:920]   ;
    wire [9:0] coe_dat4_wire_3_04 = coe_dat4_wire[609:600]   ;
    wire [9:0] coe_dat4_wire_4_04 = coe_dat4_wire[289:280]   ;
    wire [9:0] coe_dat4_wire_1_05 = coe_dat4_wire[1239:1230] ;
    wire [9:0] coe_dat4_wire_2_05 = coe_dat4_wire[919:910]   ;
    wire [9:0] coe_dat4_wire_3_05 = coe_dat4_wire[599:590]   ;
    wire [9:0] coe_dat4_wire_4_05 = coe_dat4_wire[279:270]   ;
    wire [9:0] coe_dat4_wire_1_06 = coe_dat4_wire[1229:1220] ;
    wire [9:0] coe_dat4_wire_2_06 = coe_dat4_wire[909:900]   ;
    wire [9:0] coe_dat4_wire_3_06 = coe_dat4_wire[589:580]   ;
    wire [9:0] coe_dat4_wire_4_06 = coe_dat4_wire[269:260]   ;
    wire [9:0] coe_dat4_wire_1_07 = coe_dat4_wire[1219:1210] ;
    wire [9:0] coe_dat4_wire_2_07 = coe_dat4_wire[899:890]   ;
    wire [9:0] coe_dat4_wire_3_07 = coe_dat4_wire[579:570]   ;
    wire [9:0] coe_dat4_wire_4_07 = coe_dat4_wire[259:250]   ;
    wire [9:0] coe_dat4_wire_1_08 = coe_dat4_wire[1209:1200] ;
    wire [9:0] coe_dat4_wire_2_08 = coe_dat4_wire[889:880]   ;
    wire [9:0] coe_dat4_wire_3_08 = coe_dat4_wire[569:560]   ;
    wire [9:0] coe_dat4_wire_4_08 = coe_dat4_wire[249:240]   ;
    wire [9:0] coe_dat4_wire_1_09 = coe_dat4_wire[1199:1190] ;
    wire [9:0] coe_dat4_wire_2_09 = coe_dat4_wire[879:870]   ;
    wire [9:0] coe_dat4_wire_3_09 = coe_dat4_wire[559:550]   ;
    wire [9:0] coe_dat4_wire_4_09 = coe_dat4_wire[239:230]   ;
    wire [9:0] coe_dat4_wire_1_10 = coe_dat4_wire[1189:1180] ;
    wire [9:0] coe_dat4_wire_2_10 = coe_dat4_wire[869:860]   ;
    wire [9:0] coe_dat4_wire_3_10 = coe_dat4_wire[549:540]   ;
    wire [9:0] coe_dat4_wire_4_10 = coe_dat4_wire[229:220]   ;
    wire [9:0] coe_dat4_wire_1_11 = coe_dat4_wire[1179:1170] ;
    wire [9:0] coe_dat4_wire_2_11 = coe_dat4_wire[859:850]   ;
    wire [9:0] coe_dat4_wire_3_11 = coe_dat4_wire[539:530]   ;
    wire [9:0] coe_dat4_wire_4_11 = coe_dat4_wire[219:210]   ;
    wire [9:0] coe_dat4_wire_1_12 = coe_dat4_wire[1169:1160] ;
    wire [9:0] coe_dat4_wire_2_12 = coe_dat4_wire[849:840]   ;
    wire [9:0] coe_dat4_wire_3_12 = coe_dat4_wire[529:520]   ;
    wire [9:0] coe_dat4_wire_4_12 = coe_dat4_wire[209:200]   ;
    wire [9:0] coe_dat4_wire_1_13 = coe_dat4_wire[1159:1150] ;
    wire [9:0] coe_dat4_wire_2_13 = coe_dat4_wire[839:830]   ;
    wire [9:0] coe_dat4_wire_3_13 = coe_dat4_wire[519:510]   ;
    wire [9:0] coe_dat4_wire_4_13 = coe_dat4_wire[199:190]   ;
    wire [9:0] coe_dat4_wire_1_14 = coe_dat4_wire[1149:1140] ;
    wire [9:0] coe_dat4_wire_2_14 = coe_dat4_wire[829:820]   ;
    wire [9:0] coe_dat4_wire_3_14 = coe_dat4_wire[509:500]   ;
    wire [9:0] coe_dat4_wire_4_14 = coe_dat4_wire[189:180]   ;
    wire [9:0] coe_dat4_wire_1_15 = coe_dat4_wire[1139:1130] ;
    wire [9:0] coe_dat4_wire_2_15 = coe_dat4_wire[819:810]   ;
    wire [9:0] coe_dat4_wire_3_15 = coe_dat4_wire[499:490]   ;
    wire [9:0] coe_dat4_wire_4_15 = coe_dat4_wire[179:170]   ;
    wire [9:0] coe_dat4_wire_1_16 = coe_dat4_wire[1129:1120] ;
    wire [9:0] coe_dat4_wire_2_16 = coe_dat4_wire[809:800]   ;
    wire [9:0] coe_dat4_wire_3_16 = coe_dat4_wire[489:480]   ;
    wire [9:0] coe_dat4_wire_4_16 = coe_dat4_wire[169:160]   ;
    wire [9:0] coe_dat4_wire_1_17 = coe_dat4_wire[1119:1110] ;
    wire [9:0] coe_dat4_wire_2_17 = coe_dat4_wire[799:790]   ;
    wire [9:0] coe_dat4_wire_3_17 = coe_dat4_wire[479:470]   ;
    wire [9:0] coe_dat4_wire_4_17 = coe_dat4_wire[159:150]   ;
    wire [9:0] coe_dat4_wire_1_18 = coe_dat4_wire[1109:1100] ;
    wire [9:0] coe_dat4_wire_2_18 = coe_dat4_wire[789:780]   ;
    wire [9:0] coe_dat4_wire_3_18 = coe_dat4_wire[469:460]   ;
    wire [9:0] coe_dat4_wire_4_18 = coe_dat4_wire[149:140]   ;
    wire [9:0] coe_dat4_wire_1_19 = coe_dat4_wire[1099:1090] ;
    wire [9:0] coe_dat4_wire_2_19 = coe_dat4_wire[779:770]   ;
    wire [9:0] coe_dat4_wire_3_19 = coe_dat4_wire[459:450]   ;
    wire [9:0] coe_dat4_wire_4_19 = coe_dat4_wire[139:130]   ;
    wire [9:0] coe_dat4_wire_1_20 = coe_dat4_wire[1089:1080] ;
    wire [9:0] coe_dat4_wire_2_20 = coe_dat4_wire[769:760]   ;
    wire [9:0] coe_dat4_wire_3_20 = coe_dat4_wire[449:440]   ;
    wire [9:0] coe_dat4_wire_4_20 = coe_dat4_wire[129:120]   ;
    wire [9:0] coe_dat4_wire_1_21 = coe_dat4_wire[1079:1070] ;
    wire [9:0] coe_dat4_wire_2_21 = coe_dat4_wire[759:750]   ;
    wire [9:0] coe_dat4_wire_3_21 = coe_dat4_wire[439:430]   ;
    wire [9:0] coe_dat4_wire_4_21 = coe_dat4_wire[119:110]   ;
    wire [9:0] coe_dat4_wire_1_22 = coe_dat4_wire[1069:1060] ;
    wire [9:0] coe_dat4_wire_2_22 = coe_dat4_wire[749:740]   ;
    wire [9:0] coe_dat4_wire_3_22 = coe_dat4_wire[429:420]   ;
    wire [9:0] coe_dat4_wire_4_22 = coe_dat4_wire[109:100]   ;
    wire [9:0] coe_dat4_wire_1_23 = coe_dat4_wire[1059:1050] ;
    wire [9:0] coe_dat4_wire_2_23 = coe_dat4_wire[739:730]   ;
    wire [9:0] coe_dat4_wire_3_23 = coe_dat4_wire[419:410]   ;
    wire [9:0] coe_dat4_wire_4_23 = coe_dat4_wire[99:90]     ;
    wire [9:0] coe_dat4_wire_1_24 = coe_dat4_wire[1049:1040] ;
    wire [9:0] coe_dat4_wire_2_24 = coe_dat4_wire[729:720]   ;
    wire [9:0] coe_dat4_wire_3_24 = coe_dat4_wire[409:400]   ;
    wire [9:0] coe_dat4_wire_4_24 = coe_dat4_wire[89:80]     ;
    wire [9:0] coe_dat4_wire_1_25 = coe_dat4_wire[1039:1030] ;
    wire [9:0] coe_dat4_wire_2_25 = coe_dat4_wire[719:710]   ;
    wire [9:0] coe_dat4_wire_3_25 = coe_dat4_wire[399:390]   ;
    wire [9:0] coe_dat4_wire_4_25 = coe_dat4_wire[79:70]     ;
    wire [9:0] coe_dat4_wire_1_26 = coe_dat4_wire[1029:1020] ;
    wire [9:0] coe_dat4_wire_2_26 = coe_dat4_wire[709:700]   ;
    wire [9:0] coe_dat4_wire_3_26 = coe_dat4_wire[389:380]   ;
    wire [9:0] coe_dat4_wire_4_26 = coe_dat4_wire[69:60]     ;
    wire [9:0] coe_dat4_wire_1_27 = coe_dat4_wire[1019:1010] ;
    wire [9:0] coe_dat4_wire_2_27 = coe_dat4_wire[699:690]   ;
    wire [9:0] coe_dat4_wire_3_27 = coe_dat4_wire[379:370]   ;
    wire [9:0] coe_dat4_wire_4_27 = coe_dat4_wire[59:50]     ;
    wire [9:0] coe_dat4_wire_1_28 = coe_dat4_wire[1009:1000] ;
    wire [9:0] coe_dat4_wire_2_28 = coe_dat4_wire[689:680]   ;
    wire [9:0] coe_dat4_wire_3_28 = coe_dat4_wire[369:360]   ;
    wire [9:0] coe_dat4_wire_4_28 = coe_dat4_wire[49:40]     ;
    wire [9:0] coe_dat4_wire_1_29 = coe_dat4_wire[999:990]   ;
    wire [9:0] coe_dat4_wire_2_29 = coe_dat4_wire[679:670]   ;
    wire [9:0] coe_dat4_wire_3_29 = coe_dat4_wire[359:350]   ;
    wire [9:0] coe_dat4_wire_4_29 = coe_dat4_wire[39:30]     ;
    wire [9:0] coe_dat4_wire_1_30 = coe_dat4_wire[989:980]   ;
    wire [9:0] coe_dat4_wire_2_30 = coe_dat4_wire[669:660]   ;
    wire [9:0] coe_dat4_wire_3_30 = coe_dat4_wire[349:340]   ;
    wire [9:0] coe_dat4_wire_4_30 = coe_dat4_wire[29:20]     ;
    wire [9:0] coe_dat4_wire_1_31 = coe_dat4_wire[979:970]   ;
    wire [9:0] coe_dat4_wire_2_31 = coe_dat4_wire[659:650]   ;
    wire [9:0] coe_dat4_wire_3_31 = coe_dat4_wire[339:330]   ;
    wire [9:0] coe_dat4_wire_4_31 = coe_dat4_wire[19:10]     ;
    wire [9:0] coe_dat4_wire_1_32 = coe_dat4_wire[969:960]   ;
    wire [9:0] coe_dat4_wire_2_32 = coe_dat4_wire[649:640]   ;
    wire [9:0] coe_dat4_wire_3_32 = coe_dat4_wire[329:320]   ;
    wire [9:0] coe_dat4_wire_4_32 = coe_dat4_wire[9:0]       ;

    wire [9:0] coe_dat5_wire_1_01 = coe_dat5_wire[1279:1270] ;
    wire [9:0] coe_dat5_wire_2_01 = coe_dat5_wire[959:950]   ;
    wire [9:0] coe_dat5_wire_3_01 = coe_dat5_wire[639:630]   ;
    wire [9:0] coe_dat5_wire_4_01 = coe_dat5_wire[319:310]   ;
    wire [9:0] coe_dat5_wire_1_02 = coe_dat5_wire[1269:1260] ;
    wire [9:0] coe_dat5_wire_2_02 = coe_dat5_wire[949:940]   ;
    wire [9:0] coe_dat5_wire_3_02 = coe_dat5_wire[629:620]   ;
    wire [9:0] coe_dat5_wire_4_02 = coe_dat5_wire[309:300]   ;
    wire [9:0] coe_dat5_wire_1_03 = coe_dat5_wire[1259:1250] ;
    wire [9:0] coe_dat5_wire_2_03 = coe_dat5_wire[939:930]   ;
    wire [9:0] coe_dat5_wire_3_03 = coe_dat5_wire[619:610]   ;
    wire [9:0] coe_dat5_wire_4_03 = coe_dat5_wire[299:290]   ;
    wire [9:0] coe_dat5_wire_1_04 = coe_dat5_wire[1249:1240] ;
    wire [9:0] coe_dat5_wire_2_04 = coe_dat5_wire[929:920]   ;
    wire [9:0] coe_dat5_wire_3_04 = coe_dat5_wire[609:600]   ;
    wire [9:0] coe_dat5_wire_4_04 = coe_dat5_wire[289:280]   ;
    wire [9:0] coe_dat5_wire_1_05 = coe_dat5_wire[1239:1230] ;
    wire [9:0] coe_dat5_wire_2_05 = coe_dat5_wire[919:910]   ;
    wire [9:0] coe_dat5_wire_3_05 = coe_dat5_wire[599:590]   ;
    wire [9:0] coe_dat5_wire_4_05 = coe_dat5_wire[279:270]   ;
    wire [9:0] coe_dat5_wire_1_06 = coe_dat5_wire[1229:1220] ;
    wire [9:0] coe_dat5_wire_2_06 = coe_dat5_wire[909:900]   ;
    wire [9:0] coe_dat5_wire_3_06 = coe_dat5_wire[589:580]   ;
    wire [9:0] coe_dat5_wire_4_06 = coe_dat5_wire[269:260]   ;
    wire [9:0] coe_dat5_wire_1_07 = coe_dat5_wire[1219:1210] ;
    wire [9:0] coe_dat5_wire_2_07 = coe_dat5_wire[899:890]   ;
    wire [9:0] coe_dat5_wire_3_07 = coe_dat5_wire[579:570]   ;
    wire [9:0] coe_dat5_wire_4_07 = coe_dat5_wire[259:250]   ;
    wire [9:0] coe_dat5_wire_1_08 = coe_dat5_wire[1209:1200] ;
    wire [9:0] coe_dat5_wire_2_08 = coe_dat5_wire[889:880]   ;
    wire [9:0] coe_dat5_wire_3_08 = coe_dat5_wire[569:560]   ;
    wire [9:0] coe_dat5_wire_4_08 = coe_dat5_wire[249:240]   ;
    wire [9:0] coe_dat5_wire_1_09 = coe_dat5_wire[1199:1190] ;
    wire [9:0] coe_dat5_wire_2_09 = coe_dat5_wire[879:870]   ;
    wire [9:0] coe_dat5_wire_3_09 = coe_dat5_wire[559:550]   ;
    wire [9:0] coe_dat5_wire_4_09 = coe_dat5_wire[239:230]   ;
    wire [9:0] coe_dat5_wire_1_10 = coe_dat5_wire[1189:1180] ;
    wire [9:0] coe_dat5_wire_2_10 = coe_dat5_wire[869:860]   ;
    wire [9:0] coe_dat5_wire_3_10 = coe_dat5_wire[549:540]   ;
    wire [9:0] coe_dat5_wire_4_10 = coe_dat5_wire[229:220]   ;
    wire [9:0] coe_dat5_wire_1_11 = coe_dat5_wire[1179:1170] ;
    wire [9:0] coe_dat5_wire_2_11 = coe_dat5_wire[859:850]   ;
    wire [9:0] coe_dat5_wire_3_11 = coe_dat5_wire[539:530]   ;
    wire [9:0] coe_dat5_wire_4_11 = coe_dat5_wire[219:210]   ;
    wire [9:0] coe_dat5_wire_1_12 = coe_dat5_wire[1169:1160] ;
    wire [9:0] coe_dat5_wire_2_12 = coe_dat5_wire[849:840]   ;
    wire [9:0] coe_dat5_wire_3_12 = coe_dat5_wire[529:520]   ;
    wire [9:0] coe_dat5_wire_4_12 = coe_dat5_wire[209:200]   ;
    wire [9:0] coe_dat5_wire_1_13 = coe_dat5_wire[1159:1150] ;
    wire [9:0] coe_dat5_wire_2_13 = coe_dat5_wire[839:830]   ;
    wire [9:0] coe_dat5_wire_3_13 = coe_dat5_wire[519:510]   ;
    wire [9:0] coe_dat5_wire_4_13 = coe_dat5_wire[199:190]   ;
    wire [9:0] coe_dat5_wire_1_14 = coe_dat5_wire[1149:1140] ;
    wire [9:0] coe_dat5_wire_2_14 = coe_dat5_wire[829:820]   ;
    wire [9:0] coe_dat5_wire_3_14 = coe_dat5_wire[509:500]   ;
    wire [9:0] coe_dat5_wire_4_14 = coe_dat5_wire[189:180]   ;
    wire [9:0] coe_dat5_wire_1_15 = coe_dat5_wire[1139:1130] ;
    wire [9:0] coe_dat5_wire_2_15 = coe_dat5_wire[819:810]   ;
    wire [9:0] coe_dat5_wire_3_15 = coe_dat5_wire[499:490]   ;
    wire [9:0] coe_dat5_wire_4_15 = coe_dat5_wire[179:170]   ;
    wire [9:0] coe_dat5_wire_1_16 = coe_dat5_wire[1129:1120] ;
    wire [9:0] coe_dat5_wire_2_16 = coe_dat5_wire[809:800]   ;
    wire [9:0] coe_dat5_wire_3_16 = coe_dat5_wire[489:480]   ;
    wire [9:0] coe_dat5_wire_4_16 = coe_dat5_wire[169:160]   ;
    wire [9:0] coe_dat5_wire_1_17 = coe_dat5_wire[1119:1110] ;
    wire [9:0] coe_dat5_wire_2_17 = coe_dat5_wire[799:790]   ;
    wire [9:0] coe_dat5_wire_3_17 = coe_dat5_wire[479:470]   ;
    wire [9:0] coe_dat5_wire_4_17 = coe_dat5_wire[159:150]   ;
    wire [9:0] coe_dat5_wire_1_18 = coe_dat5_wire[1109:1100] ;
    wire [9:0] coe_dat5_wire_2_18 = coe_dat5_wire[789:780]   ;
    wire [9:0] coe_dat5_wire_3_18 = coe_dat5_wire[469:460]   ;
    wire [9:0] coe_dat5_wire_4_18 = coe_dat5_wire[149:140]   ;
    wire [9:0] coe_dat5_wire_1_19 = coe_dat5_wire[1099:1090] ;
    wire [9:0] coe_dat5_wire_2_19 = coe_dat5_wire[779:770]   ;
    wire [9:0] coe_dat5_wire_3_19 = coe_dat5_wire[459:450]   ;
    wire [9:0] coe_dat5_wire_4_19 = coe_dat5_wire[139:130]   ;
    wire [9:0] coe_dat5_wire_1_20 = coe_dat5_wire[1089:1080] ;
    wire [9:0] coe_dat5_wire_2_20 = coe_dat5_wire[769:760]   ;
    wire [9:0] coe_dat5_wire_3_20 = coe_dat5_wire[449:440]   ;
    wire [9:0] coe_dat5_wire_4_20 = coe_dat5_wire[129:120]   ;
    wire [9:0] coe_dat5_wire_1_21 = coe_dat5_wire[1079:1070] ;
    wire [9:0] coe_dat5_wire_2_21 = coe_dat5_wire[759:750]   ;
    wire [9:0] coe_dat5_wire_3_21 = coe_dat5_wire[439:430]   ;
    wire [9:0] coe_dat5_wire_4_21 = coe_dat5_wire[119:110]   ;
    wire [9:0] coe_dat5_wire_1_22 = coe_dat5_wire[1069:1060] ;
    wire [9:0] coe_dat5_wire_2_22 = coe_dat5_wire[749:740]   ;
    wire [9:0] coe_dat5_wire_3_22 = coe_dat5_wire[429:420]   ;
    wire [9:0] coe_dat5_wire_4_22 = coe_dat5_wire[109:100]   ;
    wire [9:0] coe_dat5_wire_1_23 = coe_dat5_wire[1059:1050] ;
    wire [9:0] coe_dat5_wire_2_23 = coe_dat5_wire[739:730]   ;
    wire [9:0] coe_dat5_wire_3_23 = coe_dat5_wire[419:410]   ;
    wire [9:0] coe_dat5_wire_4_23 = coe_dat5_wire[99:90]     ;
    wire [9:0] coe_dat5_wire_1_24 = coe_dat5_wire[1049:1040] ;
    wire [9:0] coe_dat5_wire_2_24 = coe_dat5_wire[729:720]   ;
    wire [9:0] coe_dat5_wire_3_24 = coe_dat5_wire[409:400]   ;
    wire [9:0] coe_dat5_wire_4_24 = coe_dat5_wire[89:80]     ;
    wire [9:0] coe_dat5_wire_1_25 = coe_dat5_wire[1039:1030] ;
    wire [9:0] coe_dat5_wire_2_25 = coe_dat5_wire[719:710]   ;
    wire [9:0] coe_dat5_wire_3_25 = coe_dat5_wire[399:390]   ;
    wire [9:0] coe_dat5_wire_4_25 = coe_dat5_wire[79:70]     ;
    wire [9:0] coe_dat5_wire_1_26 = coe_dat5_wire[1029:1020] ;
    wire [9:0] coe_dat5_wire_2_26 = coe_dat5_wire[709:700]   ;
    wire [9:0] coe_dat5_wire_3_26 = coe_dat5_wire[389:380]   ;
    wire [9:0] coe_dat5_wire_4_26 = coe_dat5_wire[69:60]     ;
    wire [9:0] coe_dat5_wire_1_27 = coe_dat5_wire[1019:1010] ;
    wire [9:0] coe_dat5_wire_2_27 = coe_dat5_wire[699:690]   ;
    wire [9:0] coe_dat5_wire_3_27 = coe_dat5_wire[379:370]   ;
    wire [9:0] coe_dat5_wire_4_27 = coe_dat5_wire[59:50]     ;
    wire [9:0] coe_dat5_wire_1_28 = coe_dat5_wire[1009:1000] ;
    wire [9:0] coe_dat5_wire_2_28 = coe_dat5_wire[689:680]   ;
    wire [9:0] coe_dat5_wire_3_28 = coe_dat5_wire[369:360]   ;
    wire [9:0] coe_dat5_wire_4_28 = coe_dat5_wire[49:40]     ;
    wire [9:0] coe_dat5_wire_1_29 = coe_dat5_wire[999:990]   ;
    wire [9:0] coe_dat5_wire_2_29 = coe_dat5_wire[679:670]   ;
    wire [9:0] coe_dat5_wire_3_29 = coe_dat5_wire[359:350]   ;
    wire [9:0] coe_dat5_wire_4_29 = coe_dat5_wire[39:30]     ;
    wire [9:0] coe_dat5_wire_1_30 = coe_dat5_wire[989:980]   ;
    wire [9:0] coe_dat5_wire_2_30 = coe_dat5_wire[669:660]   ;
    wire [9:0] coe_dat5_wire_3_30 = coe_dat5_wire[349:340]   ;
    wire [9:0] coe_dat5_wire_4_30 = coe_dat5_wire[29:20]     ;
    wire [9:0] coe_dat5_wire_1_31 = coe_dat5_wire[979:970]   ;
    wire [9:0] coe_dat5_wire_2_31 = coe_dat5_wire[659:650]   ;
    wire [9:0] coe_dat5_wire_3_31 = coe_dat5_wire[339:330]   ;
    wire [9:0] coe_dat5_wire_4_31 = coe_dat5_wire[19:10]     ;
    wire [9:0] coe_dat5_wire_1_32 = coe_dat5_wire[969:960]   ;
    wire [9:0] coe_dat5_wire_2_32 = coe_dat5_wire[649:640]   ;
    wire [9:0] coe_dat5_wire_3_32 = coe_dat5_wire[329:320]   ;
    wire [9:0] coe_dat5_wire_4_32 = coe_dat5_wire[9:0]       ;

    wire [9:0] coe_dat6_wire_1_01 = coe_dat6_wire[1279:1270] ;
    wire [9:0] coe_dat6_wire_2_01 = coe_dat6_wire[959:950]   ;
    wire [9:0] coe_dat6_wire_3_01 = coe_dat6_wire[639:630]   ;
    wire [9:0] coe_dat6_wire_4_01 = coe_dat6_wire[319:310]   ;
    wire [9:0] coe_dat6_wire_1_02 = coe_dat6_wire[1269:1260] ;
    wire [9:0] coe_dat6_wire_2_02 = coe_dat6_wire[949:940]   ;
    wire [9:0] coe_dat6_wire_3_02 = coe_dat6_wire[629:620]   ;
    wire [9:0] coe_dat6_wire_4_02 = coe_dat6_wire[309:300]   ;
    wire [9:0] coe_dat6_wire_1_03 = coe_dat6_wire[1259:1250] ;
    wire [9:0] coe_dat6_wire_2_03 = coe_dat6_wire[939:930]   ;
    wire [9:0] coe_dat6_wire_3_03 = coe_dat6_wire[619:610]   ;
    wire [9:0] coe_dat6_wire_4_03 = coe_dat6_wire[299:290]   ;
    wire [9:0] coe_dat6_wire_1_04 = coe_dat6_wire[1249:1240] ;
    wire [9:0] coe_dat6_wire_2_04 = coe_dat6_wire[929:920]   ;
    wire [9:0] coe_dat6_wire_3_04 = coe_dat6_wire[609:600]   ;
    wire [9:0] coe_dat6_wire_4_04 = coe_dat6_wire[289:280]   ;
    wire [9:0] coe_dat6_wire_1_05 = coe_dat6_wire[1239:1230] ;
    wire [9:0] coe_dat6_wire_2_05 = coe_dat6_wire[919:910]   ;
    wire [9:0] coe_dat6_wire_3_05 = coe_dat6_wire[599:590]   ;
    wire [9:0] coe_dat6_wire_4_05 = coe_dat6_wire[279:270]   ;
    wire [9:0] coe_dat6_wire_1_06 = coe_dat6_wire[1229:1220] ;
    wire [9:0] coe_dat6_wire_2_06 = coe_dat6_wire[909:900]   ;
    wire [9:0] coe_dat6_wire_3_06 = coe_dat6_wire[589:580]   ;
    wire [9:0] coe_dat6_wire_4_06 = coe_dat6_wire[269:260]   ;
    wire [9:0] coe_dat6_wire_1_07 = coe_dat6_wire[1219:1210] ;
    wire [9:0] coe_dat6_wire_2_07 = coe_dat6_wire[899:890]   ;
    wire [9:0] coe_dat6_wire_3_07 = coe_dat6_wire[579:570]   ;
    wire [9:0] coe_dat6_wire_4_07 = coe_dat6_wire[259:250]   ;
    wire [9:0] coe_dat6_wire_1_08 = coe_dat6_wire[1209:1200] ;
    wire [9:0] coe_dat6_wire_2_08 = coe_dat6_wire[889:880]   ;
    wire [9:0] coe_dat6_wire_3_08 = coe_dat6_wire[569:560]   ;
    wire [9:0] coe_dat6_wire_4_08 = coe_dat6_wire[249:240]   ;
    wire [9:0] coe_dat6_wire_1_09 = coe_dat6_wire[1199:1190] ;
    wire [9:0] coe_dat6_wire_2_09 = coe_dat6_wire[879:870]   ;
    wire [9:0] coe_dat6_wire_3_09 = coe_dat6_wire[559:550]   ;
    wire [9:0] coe_dat6_wire_4_09 = coe_dat6_wire[239:230]   ;
    wire [9:0] coe_dat6_wire_1_10 = coe_dat6_wire[1189:1180] ;
    wire [9:0] coe_dat6_wire_2_10 = coe_dat6_wire[869:860]   ;
    wire [9:0] coe_dat6_wire_3_10 = coe_dat6_wire[549:540]   ;
    wire [9:0] coe_dat6_wire_4_10 = coe_dat6_wire[229:220]   ;
    wire [9:0] coe_dat6_wire_1_11 = coe_dat6_wire[1179:1170] ;
    wire [9:0] coe_dat6_wire_2_11 = coe_dat6_wire[859:850]   ;
    wire [9:0] coe_dat6_wire_3_11 = coe_dat6_wire[539:530]   ;
    wire [9:0] coe_dat6_wire_4_11 = coe_dat6_wire[219:210]   ;
    wire [9:0] coe_dat6_wire_1_12 = coe_dat6_wire[1169:1160] ;
    wire [9:0] coe_dat6_wire_2_12 = coe_dat6_wire[849:840]   ;
    wire [9:0] coe_dat6_wire_3_12 = coe_dat6_wire[529:520]   ;
    wire [9:0] coe_dat6_wire_4_12 = coe_dat6_wire[209:200]   ;
    wire [9:0] coe_dat6_wire_1_13 = coe_dat6_wire[1159:1150] ;
    wire [9:0] coe_dat6_wire_2_13 = coe_dat6_wire[839:830]   ;
    wire [9:0] coe_dat6_wire_3_13 = coe_dat6_wire[519:510]   ;
    wire [9:0] coe_dat6_wire_4_13 = coe_dat6_wire[199:190]   ;
    wire [9:0] coe_dat6_wire_1_14 = coe_dat6_wire[1149:1140] ;
    wire [9:0] coe_dat6_wire_2_14 = coe_dat6_wire[829:820]   ;
    wire [9:0] coe_dat6_wire_3_14 = coe_dat6_wire[509:500]   ;
    wire [9:0] coe_dat6_wire_4_14 = coe_dat6_wire[189:180]   ;
    wire [9:0] coe_dat6_wire_1_15 = coe_dat6_wire[1139:1130] ;
    wire [9:0] coe_dat6_wire_2_15 = coe_dat6_wire[819:810]   ;
    wire [9:0] coe_dat6_wire_3_15 = coe_dat6_wire[499:490]   ;
    wire [9:0] coe_dat6_wire_4_15 = coe_dat6_wire[179:170]   ;
    wire [9:0] coe_dat6_wire_1_16 = coe_dat6_wire[1129:1120] ;
    wire [9:0] coe_dat6_wire_2_16 = coe_dat6_wire[809:800]   ;
    wire [9:0] coe_dat6_wire_3_16 = coe_dat6_wire[489:480]   ;
    wire [9:0] coe_dat6_wire_4_16 = coe_dat6_wire[169:160]   ;
    wire [9:0] coe_dat6_wire_1_17 = coe_dat6_wire[1119:1110] ;
    wire [9:0] coe_dat6_wire_2_17 = coe_dat6_wire[799:790]   ;
    wire [9:0] coe_dat6_wire_3_17 = coe_dat6_wire[479:470]   ;
    wire [9:0] coe_dat6_wire_4_17 = coe_dat6_wire[159:150]   ;
    wire [9:0] coe_dat6_wire_1_18 = coe_dat6_wire[1109:1100] ;
    wire [9:0] coe_dat6_wire_2_18 = coe_dat6_wire[789:780]   ;
    wire [9:0] coe_dat6_wire_3_18 = coe_dat6_wire[469:460]   ;
    wire [9:0] coe_dat6_wire_4_18 = coe_dat6_wire[149:140]   ;
    wire [9:0] coe_dat6_wire_1_19 = coe_dat6_wire[1099:1090] ;
    wire [9:0] coe_dat6_wire_2_19 = coe_dat6_wire[779:770]   ;
    wire [9:0] coe_dat6_wire_3_19 = coe_dat6_wire[459:450]   ;
    wire [9:0] coe_dat6_wire_4_19 = coe_dat6_wire[139:130]   ;
    wire [9:0] coe_dat6_wire_1_20 = coe_dat6_wire[1089:1080] ;
    wire [9:0] coe_dat6_wire_2_20 = coe_dat6_wire[769:760]   ;
    wire [9:0] coe_dat6_wire_3_20 = coe_dat6_wire[449:440]   ;
    wire [9:0] coe_dat6_wire_4_20 = coe_dat6_wire[129:120]   ;
    wire [9:0] coe_dat6_wire_1_21 = coe_dat6_wire[1079:1070] ;
    wire [9:0] coe_dat6_wire_2_21 = coe_dat6_wire[759:750]   ;
    wire [9:0] coe_dat6_wire_3_21 = coe_dat6_wire[439:430]   ;
    wire [9:0] coe_dat6_wire_4_21 = coe_dat6_wire[119:110]   ;
    wire [9:0] coe_dat6_wire_1_22 = coe_dat6_wire[1069:1060] ;
    wire [9:0] coe_dat6_wire_2_22 = coe_dat6_wire[749:740]   ;
    wire [9:0] coe_dat6_wire_3_22 = coe_dat6_wire[429:420]   ;
    wire [9:0] coe_dat6_wire_4_22 = coe_dat6_wire[109:100]   ;
    wire [9:0] coe_dat6_wire_1_23 = coe_dat6_wire[1059:1050] ;
    wire [9:0] coe_dat6_wire_2_23 = coe_dat6_wire[739:730]   ;
    wire [9:0] coe_dat6_wire_3_23 = coe_dat6_wire[419:410]   ;
    wire [9:0] coe_dat6_wire_4_23 = coe_dat6_wire[99:90]     ;
    wire [9:0] coe_dat6_wire_1_24 = coe_dat6_wire[1049:1040] ;
    wire [9:0] coe_dat6_wire_2_24 = coe_dat6_wire[729:720]   ;
    wire [9:0] coe_dat6_wire_3_24 = coe_dat6_wire[409:400]   ;
    wire [9:0] coe_dat6_wire_4_24 = coe_dat6_wire[89:80]     ;
    wire [9:0] coe_dat6_wire_1_25 = coe_dat6_wire[1039:1030] ;
    wire [9:0] coe_dat6_wire_2_25 = coe_dat6_wire[719:710]   ;
    wire [9:0] coe_dat6_wire_3_25 = coe_dat6_wire[399:390]   ;
    wire [9:0] coe_dat6_wire_4_25 = coe_dat6_wire[79:70]     ;
    wire [9:0] coe_dat6_wire_1_26 = coe_dat6_wire[1029:1020] ;
    wire [9:0] coe_dat6_wire_2_26 = coe_dat6_wire[709:700]   ;
    wire [9:0] coe_dat6_wire_3_26 = coe_dat6_wire[389:380]   ;
    wire [9:0] coe_dat6_wire_4_26 = coe_dat6_wire[69:60]     ;
    wire [9:0] coe_dat6_wire_1_27 = coe_dat6_wire[1019:1010] ;
    wire [9:0] coe_dat6_wire_2_27 = coe_dat6_wire[699:690]   ;
    wire [9:0] coe_dat6_wire_3_27 = coe_dat6_wire[379:370]   ;
    wire [9:0] coe_dat6_wire_4_27 = coe_dat6_wire[59:50]     ;
    wire [9:0] coe_dat6_wire_1_28 = coe_dat6_wire[1009:1000] ;
    wire [9:0] coe_dat6_wire_2_28 = coe_dat6_wire[689:680]   ;
    wire [9:0] coe_dat6_wire_3_28 = coe_dat6_wire[369:360]   ;
    wire [9:0] coe_dat6_wire_4_28 = coe_dat6_wire[49:40]     ;
    wire [9:0] coe_dat6_wire_1_29 = coe_dat6_wire[999:990]   ;
    wire [9:0] coe_dat6_wire_2_29 = coe_dat6_wire[679:670]   ;
    wire [9:0] coe_dat6_wire_3_29 = coe_dat6_wire[359:350]   ;
    wire [9:0] coe_dat6_wire_4_29 = coe_dat6_wire[39:30]     ;
    wire [9:0] coe_dat6_wire_1_30 = coe_dat6_wire[989:980]   ;
    wire [9:0] coe_dat6_wire_2_30 = coe_dat6_wire[669:660]   ;
    wire [9:0] coe_dat6_wire_3_30 = coe_dat6_wire[349:340]   ;
    wire [9:0] coe_dat6_wire_4_30 = coe_dat6_wire[29:20]     ;
    wire [9:0] coe_dat6_wire_1_31 = coe_dat6_wire[979:970]   ;
    wire [9:0] coe_dat6_wire_2_31 = coe_dat6_wire[659:650]   ;
    wire [9:0] coe_dat6_wire_3_31 = coe_dat6_wire[339:330]   ;
    wire [9:0] coe_dat6_wire_4_31 = coe_dat6_wire[19:10]     ;
    wire [9:0] coe_dat6_wire_1_32 = coe_dat6_wire[969:960]   ;
    wire [9:0] coe_dat6_wire_2_32 = coe_dat6_wire[649:640]   ;
    wire [9:0] coe_dat6_wire_3_32 = coe_dat6_wire[329:320]   ;
    wire [9:0] coe_dat6_wire_4_32 = coe_dat6_wire[9:0]       ;
	
    wire [9:0] coe_dat7_wire_1_01 = coe_dat7_wire[1279:1270] ;
    wire [9:0] coe_dat7_wire_2_01 = coe_dat7_wire[959:950]   ;
    wire [9:0] coe_dat7_wire_3_01 = coe_dat7_wire[639:630]   ;
    wire [9:0] coe_dat7_wire_4_01 = coe_dat7_wire[319:310]   ;
    wire [9:0] coe_dat7_wire_1_02 = coe_dat7_wire[1269:1260] ;
    wire [9:0] coe_dat7_wire_2_02 = coe_dat7_wire[949:940]   ;
    wire [9:0] coe_dat7_wire_3_02 = coe_dat7_wire[629:620]   ;
    wire [9:0] coe_dat7_wire_4_02 = coe_dat7_wire[309:300]   ;
    wire [9:0] coe_dat7_wire_1_03 = coe_dat7_wire[1259:1250] ;
    wire [9:0] coe_dat7_wire_2_03 = coe_dat7_wire[939:930]   ;
    wire [9:0] coe_dat7_wire_3_03 = coe_dat7_wire[619:610]   ;
    wire [9:0] coe_dat7_wire_4_03 = coe_dat7_wire[299:290]   ;
    wire [9:0] coe_dat7_wire_1_04 = coe_dat7_wire[1249:1240] ;
    wire [9:0] coe_dat7_wire_2_04 = coe_dat7_wire[929:920]   ;
    wire [9:0] coe_dat7_wire_3_04 = coe_dat7_wire[609:600]   ;
    wire [9:0] coe_dat7_wire_4_04 = coe_dat7_wire[289:280]   ;
    wire [9:0] coe_dat7_wire_1_05 = coe_dat7_wire[1239:1230] ;
    wire [9:0] coe_dat7_wire_2_05 = coe_dat7_wire[919:910]   ;
    wire [9:0] coe_dat7_wire_3_05 = coe_dat7_wire[599:590]   ;
    wire [9:0] coe_dat7_wire_4_05 = coe_dat7_wire[279:270]   ;
    wire [9:0] coe_dat7_wire_1_06 = coe_dat7_wire[1229:1220] ;
    wire [9:0] coe_dat7_wire_2_06 = coe_dat7_wire[909:900]   ;
    wire [9:0] coe_dat7_wire_3_06 = coe_dat7_wire[589:580]   ;
    wire [9:0] coe_dat7_wire_4_06 = coe_dat7_wire[269:260]   ;
    wire [9:0] coe_dat7_wire_1_07 = coe_dat7_wire[1219:1210] ;
    wire [9:0] coe_dat7_wire_2_07 = coe_dat7_wire[899:890]   ;
    wire [9:0] coe_dat7_wire_3_07 = coe_dat7_wire[579:570]   ;
    wire [9:0] coe_dat7_wire_4_07 = coe_dat7_wire[259:250]   ;
    wire [9:0] coe_dat7_wire_1_08 = coe_dat7_wire[1209:1200] ;
    wire [9:0] coe_dat7_wire_2_08 = coe_dat7_wire[889:880]   ;
    wire [9:0] coe_dat7_wire_3_08 = coe_dat7_wire[569:560]   ;
    wire [9:0] coe_dat7_wire_4_08 = coe_dat7_wire[249:240]   ;
    wire [9:0] coe_dat7_wire_1_09 = coe_dat7_wire[1199:1190] ;
    wire [9:0] coe_dat7_wire_2_09 = coe_dat7_wire[879:870]   ;
    wire [9:0] coe_dat7_wire_3_09 = coe_dat7_wire[559:550]   ;
    wire [9:0] coe_dat7_wire_4_09 = coe_dat7_wire[239:230]   ;
    wire [9:0] coe_dat7_wire_1_10 = coe_dat7_wire[1189:1180] ;
    wire [9:0] coe_dat7_wire_2_10 = coe_dat7_wire[869:860]   ;
    wire [9:0] coe_dat7_wire_3_10 = coe_dat7_wire[549:540]   ;
    wire [9:0] coe_dat7_wire_4_10 = coe_dat7_wire[229:220]   ;
    wire [9:0] coe_dat7_wire_1_11 = coe_dat7_wire[1179:1170] ;
    wire [9:0] coe_dat7_wire_2_11 = coe_dat7_wire[859:850]   ;
    wire [9:0] coe_dat7_wire_3_11 = coe_dat7_wire[539:530]   ;
    wire [9:0] coe_dat7_wire_4_11 = coe_dat7_wire[219:210]   ;
    wire [9:0] coe_dat7_wire_1_12 = coe_dat7_wire[1169:1160] ;
    wire [9:0] coe_dat7_wire_2_12 = coe_dat7_wire[849:840]   ;
    wire [9:0] coe_dat7_wire_3_12 = coe_dat7_wire[529:520]   ;
    wire [9:0] coe_dat7_wire_4_12 = coe_dat7_wire[209:200]   ;
    wire [9:0] coe_dat7_wire_1_13 = coe_dat7_wire[1159:1150] ;
    wire [9:0] coe_dat7_wire_2_13 = coe_dat7_wire[839:830]   ;
    wire [9:0] coe_dat7_wire_3_13 = coe_dat7_wire[519:510]   ;
    wire [9:0] coe_dat7_wire_4_13 = coe_dat7_wire[199:190]   ;
    wire [9:0] coe_dat7_wire_1_14 = coe_dat7_wire[1149:1140] ;
    wire [9:0] coe_dat7_wire_2_14 = coe_dat7_wire[829:820]   ;
    wire [9:0] coe_dat7_wire_3_14 = coe_dat7_wire[509:500]   ;
    wire [9:0] coe_dat7_wire_4_14 = coe_dat7_wire[189:180]   ;
    wire [9:0] coe_dat7_wire_1_15 = coe_dat7_wire[1139:1130] ;
    wire [9:0] coe_dat7_wire_2_15 = coe_dat7_wire[819:810]   ;
    wire [9:0] coe_dat7_wire_3_15 = coe_dat7_wire[499:490]   ;
    wire [9:0] coe_dat7_wire_4_15 = coe_dat7_wire[179:170]   ;
    wire [9:0] coe_dat7_wire_1_16 = coe_dat7_wire[1129:1120] ;
    wire [9:0] coe_dat7_wire_2_16 = coe_dat7_wire[809:800]   ;
    wire [9:0] coe_dat7_wire_3_16 = coe_dat7_wire[489:480]   ;
    wire [9:0] coe_dat7_wire_4_16 = coe_dat7_wire[169:160]   ;
    wire [9:0] coe_dat7_wire_1_17 = coe_dat7_wire[1119:1110] ;
    wire [9:0] coe_dat7_wire_2_17 = coe_dat7_wire[799:790]   ;
    wire [9:0] coe_dat7_wire_3_17 = coe_dat7_wire[479:470]   ;
    wire [9:0] coe_dat7_wire_4_17 = coe_dat7_wire[159:150]   ;
    wire [9:0] coe_dat7_wire_1_18 = coe_dat7_wire[1109:1100] ;
    wire [9:0] coe_dat7_wire_2_18 = coe_dat7_wire[789:780]   ;
    wire [9:0] coe_dat7_wire_3_18 = coe_dat7_wire[469:460]   ;
    wire [9:0] coe_dat7_wire_4_18 = coe_dat7_wire[149:140]   ;
    wire [9:0] coe_dat7_wire_1_19 = coe_dat7_wire[1099:1090] ;
    wire [9:0] coe_dat7_wire_2_19 = coe_dat7_wire[779:770]   ;
    wire [9:0] coe_dat7_wire_3_19 = coe_dat7_wire[459:450]   ;
    wire [9:0] coe_dat7_wire_4_19 = coe_dat7_wire[139:130]   ;
    wire [9:0] coe_dat7_wire_1_20 = coe_dat7_wire[1089:1080] ;
    wire [9:0] coe_dat7_wire_2_20 = coe_dat7_wire[769:760]   ;
    wire [9:0] coe_dat7_wire_3_20 = coe_dat7_wire[449:440]   ;
    wire [9:0] coe_dat7_wire_4_20 = coe_dat7_wire[129:120]   ;
    wire [9:0] coe_dat7_wire_1_21 = coe_dat7_wire[1079:1070] ;
    wire [9:0] coe_dat7_wire_2_21 = coe_dat7_wire[759:750]   ;
    wire [9:0] coe_dat7_wire_3_21 = coe_dat7_wire[439:430]   ;
    wire [9:0] coe_dat7_wire_4_21 = coe_dat7_wire[119:110]   ;
    wire [9:0] coe_dat7_wire_1_22 = coe_dat7_wire[1069:1060] ;
    wire [9:0] coe_dat7_wire_2_22 = coe_dat7_wire[749:740]   ;
    wire [9:0] coe_dat7_wire_3_22 = coe_dat7_wire[429:420]   ;
    wire [9:0] coe_dat7_wire_4_22 = coe_dat7_wire[109:100]   ;
    wire [9:0] coe_dat7_wire_1_23 = coe_dat7_wire[1059:1050] ;
    wire [9:0] coe_dat7_wire_2_23 = coe_dat7_wire[739:730]   ;
    wire [9:0] coe_dat7_wire_3_23 = coe_dat7_wire[419:410]   ;
    wire [9:0] coe_dat7_wire_4_23 = coe_dat7_wire[99:90]     ;
    wire [9:0] coe_dat7_wire_1_24 = coe_dat7_wire[1049:1040] ;
    wire [9:0] coe_dat7_wire_2_24 = coe_dat7_wire[729:720]   ;
    wire [9:0] coe_dat7_wire_3_24 = coe_dat7_wire[409:400]   ;
    wire [9:0] coe_dat7_wire_4_24 = coe_dat7_wire[89:80]     ;
    wire [9:0] coe_dat7_wire_1_25 = coe_dat7_wire[1039:1030] ;
    wire [9:0] coe_dat7_wire_2_25 = coe_dat7_wire[719:710]   ;
    wire [9:0] coe_dat7_wire_3_25 = coe_dat7_wire[399:390]   ;
    wire [9:0] coe_dat7_wire_4_25 = coe_dat7_wire[79:70]     ;
    wire [9:0] coe_dat7_wire_1_26 = coe_dat7_wire[1029:1020] ;
    wire [9:0] coe_dat7_wire_2_26 = coe_dat7_wire[709:700]   ;
    wire [9:0] coe_dat7_wire_3_26 = coe_dat7_wire[389:380]   ;
    wire [9:0] coe_dat7_wire_4_26 = coe_dat7_wire[69:60]     ;
    wire [9:0] coe_dat7_wire_1_27 = coe_dat7_wire[1019:1010] ;
    wire [9:0] coe_dat7_wire_2_27 = coe_dat7_wire[699:690]   ;
    wire [9:0] coe_dat7_wire_3_27 = coe_dat7_wire[379:370]   ;
    wire [9:0] coe_dat7_wire_4_27 = coe_dat7_wire[59:50]     ;
    wire [9:0] coe_dat7_wire_1_28 = coe_dat7_wire[1009:1000] ;
    wire [9:0] coe_dat7_wire_2_28 = coe_dat7_wire[689:680]   ;
    wire [9:0] coe_dat7_wire_3_28 = coe_dat7_wire[369:360]   ;
    wire [9:0] coe_dat7_wire_4_28 = coe_dat7_wire[49:40]     ;
    wire [9:0] coe_dat7_wire_1_29 = coe_dat7_wire[999:990]   ;
    wire [9:0] coe_dat7_wire_2_29 = coe_dat7_wire[679:670]   ;
    wire [9:0] coe_dat7_wire_3_29 = coe_dat7_wire[359:350]   ;
    wire [9:0] coe_dat7_wire_4_29 = coe_dat7_wire[39:30]     ;
    wire [9:0] coe_dat7_wire_1_30 = coe_dat7_wire[989:980]   ;
    wire [9:0] coe_dat7_wire_2_30 = coe_dat7_wire[669:660]   ;
    wire [9:0] coe_dat7_wire_3_30 = coe_dat7_wire[349:340]   ;
    wire [9:0] coe_dat7_wire_4_30 = coe_dat7_wire[29:20]     ;
    wire [9:0] coe_dat7_wire_1_31 = coe_dat7_wire[979:970]   ;
    wire [9:0] coe_dat7_wire_2_31 = coe_dat7_wire[659:650]   ;
    wire [9:0] coe_dat7_wire_3_31 = coe_dat7_wire[339:330]   ;
    wire [9:0] coe_dat7_wire_4_31 = coe_dat7_wire[19:10]     ;
    wire [9:0] coe_dat7_wire_1_32 = coe_dat7_wire[969:960]   ;
    wire [9:0] coe_dat7_wire_2_32 = coe_dat7_wire[649:640]   ;
    wire [9:0] coe_dat7_wire_3_32 = coe_dat7_wire[329:320]   ;
    wire [9:0] coe_dat7_wire_4_32 = coe_dat7_wire[9:0]       ;
	
    wire [9:0] coe_dat8_wire_1_01 = coe_dat8_wire[1279:1270] ;
    wire [9:0] coe_dat8_wire_2_01 = coe_dat8_wire[959:950]   ;
    wire [9:0] coe_dat8_wire_3_01 = coe_dat8_wire[639:630]   ;
    wire [9:0] coe_dat8_wire_4_01 = coe_dat8_wire[319:310]   ;
    wire [9:0] coe_dat8_wire_1_02 = coe_dat8_wire[1269:1260] ;
    wire [9:0] coe_dat8_wire_2_02 = coe_dat8_wire[949:940]   ;
    wire [9:0] coe_dat8_wire_3_02 = coe_dat8_wire[629:620]   ;
    wire [9:0] coe_dat8_wire_4_02 = coe_dat8_wire[309:300]   ;
    wire [9:0] coe_dat8_wire_1_03 = coe_dat8_wire[1259:1250] ;
    wire [9:0] coe_dat8_wire_2_03 = coe_dat8_wire[939:930]   ;
    wire [9:0] coe_dat8_wire_3_03 = coe_dat8_wire[619:610]   ;
    wire [9:0] coe_dat8_wire_4_03 = coe_dat8_wire[299:290]   ;
    wire [9:0] coe_dat8_wire_1_04 = coe_dat8_wire[1249:1240] ;
    wire [9:0] coe_dat8_wire_2_04 = coe_dat8_wire[929:920]   ;
    wire [9:0] coe_dat8_wire_3_04 = coe_dat8_wire[609:600]   ;
    wire [9:0] coe_dat8_wire_4_04 = coe_dat8_wire[289:280]   ;
    wire [9:0] coe_dat8_wire_1_05 = coe_dat8_wire[1239:1230] ;
    wire [9:0] coe_dat8_wire_2_05 = coe_dat8_wire[919:910]   ;
    wire [9:0] coe_dat8_wire_3_05 = coe_dat8_wire[599:590]   ;
    wire [9:0] coe_dat8_wire_4_05 = coe_dat8_wire[279:270]   ;
    wire [9:0] coe_dat8_wire_1_06 = coe_dat8_wire[1229:1220] ;
    wire [9:0] coe_dat8_wire_2_06 = coe_dat8_wire[909:900]   ;
    wire [9:0] coe_dat8_wire_3_06 = coe_dat8_wire[589:580]   ;
    wire [9:0] coe_dat8_wire_4_06 = coe_dat8_wire[269:260]   ;
    wire [9:0] coe_dat8_wire_1_07 = coe_dat8_wire[1219:1210] ;
    wire [9:0] coe_dat8_wire_2_07 = coe_dat8_wire[899:890]   ;
    wire [9:0] coe_dat8_wire_3_07 = coe_dat8_wire[579:570]   ;
    wire [9:0] coe_dat8_wire_4_07 = coe_dat8_wire[259:250]   ;
    wire [9:0] coe_dat8_wire_1_08 = coe_dat8_wire[1209:1200] ;
    wire [9:0] coe_dat8_wire_2_08 = coe_dat8_wire[889:880]   ;
    wire [9:0] coe_dat8_wire_3_08 = coe_dat8_wire[569:560]   ;
    wire [9:0] coe_dat8_wire_4_08 = coe_dat8_wire[249:240]   ;
    wire [9:0] coe_dat8_wire_1_09 = coe_dat8_wire[1199:1190] ;
    wire [9:0] coe_dat8_wire_2_09 = coe_dat8_wire[879:870]   ;
    wire [9:0] coe_dat8_wire_3_09 = coe_dat8_wire[559:550]   ;
    wire [9:0] coe_dat8_wire_4_09 = coe_dat8_wire[239:230]   ;
    wire [9:0] coe_dat8_wire_1_10 = coe_dat8_wire[1189:1180] ;
    wire [9:0] coe_dat8_wire_2_10 = coe_dat8_wire[869:860]   ;
    wire [9:0] coe_dat8_wire_3_10 = coe_dat8_wire[549:540]   ;
    wire [9:0] coe_dat8_wire_4_10 = coe_dat8_wire[229:220]   ;
    wire [9:0] coe_dat8_wire_1_11 = coe_dat8_wire[1179:1170] ;
    wire [9:0] coe_dat8_wire_2_11 = coe_dat8_wire[859:850]   ;
    wire [9:0] coe_dat8_wire_3_11 = coe_dat8_wire[539:530]   ;
    wire [9:0] coe_dat8_wire_4_11 = coe_dat8_wire[219:210]   ;
    wire [9:0] coe_dat8_wire_1_12 = coe_dat8_wire[1169:1160] ;
    wire [9:0] coe_dat8_wire_2_12 = coe_dat8_wire[849:840]   ;
    wire [9:0] coe_dat8_wire_3_12 = coe_dat8_wire[529:520]   ;
    wire [9:0] coe_dat8_wire_4_12 = coe_dat8_wire[209:200]   ;
    wire [9:0] coe_dat8_wire_1_13 = coe_dat8_wire[1159:1150] ;
    wire [9:0] coe_dat8_wire_2_13 = coe_dat8_wire[839:830]   ;
    wire [9:0] coe_dat8_wire_3_13 = coe_dat8_wire[519:510]   ;
    wire [9:0] coe_dat8_wire_4_13 = coe_dat8_wire[199:190]   ;
    wire [9:0] coe_dat8_wire_1_14 = coe_dat8_wire[1149:1140] ;
    wire [9:0] coe_dat8_wire_2_14 = coe_dat8_wire[829:820]   ;
    wire [9:0] coe_dat8_wire_3_14 = coe_dat8_wire[509:500]   ;
    wire [9:0] coe_dat8_wire_4_14 = coe_dat8_wire[189:180]   ;
    wire [9:0] coe_dat8_wire_1_15 = coe_dat8_wire[1139:1130] ;
    wire [9:0] coe_dat8_wire_2_15 = coe_dat8_wire[819:810]   ;
    wire [9:0] coe_dat8_wire_3_15 = coe_dat8_wire[499:490]   ;
    wire [9:0] coe_dat8_wire_4_15 = coe_dat8_wire[179:170]   ;
    wire [9:0] coe_dat8_wire_1_16 = coe_dat8_wire[1129:1120] ;
    wire [9:0] coe_dat8_wire_2_16 = coe_dat8_wire[809:800]   ;
    wire [9:0] coe_dat8_wire_3_16 = coe_dat8_wire[489:480]   ;
    wire [9:0] coe_dat8_wire_4_16 = coe_dat8_wire[169:160]   ;
    wire [9:0] coe_dat8_wire_1_17 = coe_dat8_wire[1119:1110] ;
    wire [9:0] coe_dat8_wire_2_17 = coe_dat8_wire[799:790]   ;
    wire [9:0] coe_dat8_wire_3_17 = coe_dat8_wire[479:470]   ;
    wire [9:0] coe_dat8_wire_4_17 = coe_dat8_wire[159:150]   ;
    wire [9:0] coe_dat8_wire_1_18 = coe_dat8_wire[1109:1100] ;
    wire [9:0] coe_dat8_wire_2_18 = coe_dat8_wire[789:780]   ;
    wire [9:0] coe_dat8_wire_3_18 = coe_dat8_wire[469:460]   ;
    wire [9:0] coe_dat8_wire_4_18 = coe_dat8_wire[149:140]   ;
    wire [9:0] coe_dat8_wire_1_19 = coe_dat8_wire[1099:1090] ;
    wire [9:0] coe_dat8_wire_2_19 = coe_dat8_wire[779:770]   ;
    wire [9:0] coe_dat8_wire_3_19 = coe_dat8_wire[459:450]   ;
    wire [9:0] coe_dat8_wire_4_19 = coe_dat8_wire[139:130]   ;
    wire [9:0] coe_dat8_wire_1_20 = coe_dat8_wire[1089:1080] ;
    wire [9:0] coe_dat8_wire_2_20 = coe_dat8_wire[769:760]   ;
    wire [9:0] coe_dat8_wire_3_20 = coe_dat8_wire[449:440]   ;
    wire [9:0] coe_dat8_wire_4_20 = coe_dat8_wire[129:120]   ;
    wire [9:0] coe_dat8_wire_1_21 = coe_dat8_wire[1079:1070] ;
    wire [9:0] coe_dat8_wire_2_21 = coe_dat8_wire[759:750]   ;
    wire [9:0] coe_dat8_wire_3_21 = coe_dat8_wire[439:430]   ;
    wire [9:0] coe_dat8_wire_4_21 = coe_dat8_wire[119:110]   ;
    wire [9:0] coe_dat8_wire_1_22 = coe_dat8_wire[1069:1060] ;
    wire [9:0] coe_dat8_wire_2_22 = coe_dat8_wire[749:740]   ;
    wire [9:0] coe_dat8_wire_3_22 = coe_dat8_wire[429:420]   ;
    wire [9:0] coe_dat8_wire_4_22 = coe_dat8_wire[109:100]   ;
    wire [9:0] coe_dat8_wire_1_23 = coe_dat8_wire[1059:1050] ;
    wire [9:0] coe_dat8_wire_2_23 = coe_dat8_wire[739:730]   ;
    wire [9:0] coe_dat8_wire_3_23 = coe_dat8_wire[419:410]   ;
    wire [9:0] coe_dat8_wire_4_23 = coe_dat8_wire[99:90]     ;
    wire [9:0] coe_dat8_wire_1_24 = coe_dat8_wire[1049:1040] ;
    wire [9:0] coe_dat8_wire_2_24 = coe_dat8_wire[729:720]   ;
    wire [9:0] coe_dat8_wire_3_24 = coe_dat8_wire[409:400]   ;
    wire [9:0] coe_dat8_wire_4_24 = coe_dat8_wire[89:80]     ;
    wire [9:0] coe_dat8_wire_1_25 = coe_dat8_wire[1039:1030] ;
    wire [9:0] coe_dat8_wire_2_25 = coe_dat8_wire[719:710]   ;
    wire [9:0] coe_dat8_wire_3_25 = coe_dat8_wire[399:390]   ;
    wire [9:0] coe_dat8_wire_4_25 = coe_dat8_wire[79:70]     ;
    wire [9:0] coe_dat8_wire_1_26 = coe_dat8_wire[1029:1020] ;
    wire [9:0] coe_dat8_wire_2_26 = coe_dat8_wire[709:700]   ;
    wire [9:0] coe_dat8_wire_3_26 = coe_dat8_wire[389:380]   ;
    wire [9:0] coe_dat8_wire_4_26 = coe_dat8_wire[69:60]     ;
    wire [9:0] coe_dat8_wire_1_27 = coe_dat8_wire[1019:1010] ;
    wire [9:0] coe_dat8_wire_2_27 = coe_dat8_wire[699:690]   ;
    wire [9:0] coe_dat8_wire_3_27 = coe_dat8_wire[379:370]   ;
    wire [9:0] coe_dat8_wire_4_27 = coe_dat8_wire[59:50]     ;
    wire [9:0] coe_dat8_wire_1_28 = coe_dat8_wire[1009:1000] ;
    wire [9:0] coe_dat8_wire_2_28 = coe_dat8_wire[689:680]   ;
    wire [9:0] coe_dat8_wire_3_28 = coe_dat8_wire[369:360]   ;
    wire [9:0] coe_dat8_wire_4_28 = coe_dat8_wire[49:40]     ;
    wire [9:0] coe_dat8_wire_1_29 = coe_dat8_wire[999:990]   ;
    wire [9:0] coe_dat8_wire_2_29 = coe_dat8_wire[679:670]   ;
    wire [9:0] coe_dat8_wire_3_29 = coe_dat8_wire[359:350]   ;
    wire [9:0] coe_dat8_wire_4_29 = coe_dat8_wire[39:30]     ;
    wire [9:0] coe_dat8_wire_1_30 = coe_dat8_wire[989:980]   ;
    wire [9:0] coe_dat8_wire_2_30 = coe_dat8_wire[669:660]   ;
    wire [9:0] coe_dat8_wire_3_30 = coe_dat8_wire[349:340]   ;
    wire [9:0] coe_dat8_wire_4_30 = coe_dat8_wire[29:20]     ;
    wire [9:0] coe_dat8_wire_1_31 = coe_dat8_wire[979:970]   ;
    wire [9:0] coe_dat8_wire_2_31 = coe_dat8_wire[659:650]   ;
    wire [9:0] coe_dat8_wire_3_31 = coe_dat8_wire[339:330]   ;
    wire [9:0] coe_dat8_wire_4_31 = coe_dat8_wire[19:10]     ;
    wire [9:0] coe_dat8_wire_1_32 = coe_dat8_wire[969:960]   ;
    wire [9:0] coe_dat8_wire_2_32 = coe_dat8_wire[649:640]   ;
    wire [9:0] coe_dat8_wire_3_32 = coe_dat8_wire[329:320]   ;
    wire [9:0] coe_dat8_wire_4_32 = coe_dat8_wire[9:0]       ;
	
    /****************************
    // pipeline[1] active
    ****************************/
	reg [9:0] in_dat_hld01, in_dat_hld02, in_dat_hld03,
			  in_dat_hld04, in_dat_hld05, in_dat_hld06,
			  in_dat_hld07, in_dat_hld08, in_dat_hld09,
			  in_dat_hld10, in_dat_hld11, in_dat_hld12,
			  in_dat_hld13, in_dat_hld14, in_dat_hld15,
			  in_dat_hld16, in_dat_hld17, in_dat_hld18,
			  in_dat_hld19, in_dat_hld20, in_dat_hld21,
			  in_dat_hld22, in_dat_hld23, in_dat_hld24,
			  in_dat_hld25, in_dat_hld26, in_dat_hld27,
			  in_dat_hld28, in_dat_hld29, in_dat_hld30,
			  in_dat_hld31, in_dat_hld32;

	reg [9:0] coe_dat1_hld_1_01, coe_dat1_hld_1_02, coe_dat1_hld_1_03, coe_dat1_hld_1_04,
              coe_dat1_hld_1_05, coe_dat1_hld_1_06, coe_dat1_hld_1_07, coe_dat1_hld_1_08,
              coe_dat1_hld_1_09, coe_dat1_hld_1_10, coe_dat1_hld_1_11, coe_dat1_hld_1_12,
              coe_dat1_hld_1_13, coe_dat1_hld_1_14, coe_dat1_hld_1_15, coe_dat1_hld_1_16,
              coe_dat1_hld_1_17, coe_dat1_hld_1_18, coe_dat1_hld_1_19, coe_dat1_hld_1_20,
              coe_dat1_hld_1_21, coe_dat1_hld_1_22, coe_dat1_hld_1_23, coe_dat1_hld_1_24,
              coe_dat1_hld_1_25, coe_dat1_hld_1_26, coe_dat1_hld_1_27, coe_dat1_hld_1_28,
              coe_dat1_hld_1_29, coe_dat1_hld_1_30, coe_dat1_hld_1_31, coe_dat1_hld_1_32;
	reg [9:0] coe_dat1_hld_2_01, coe_dat1_hld_2_02, coe_dat1_hld_2_03, coe_dat1_hld_2_04,
              coe_dat1_hld_2_05, coe_dat1_hld_2_06, coe_dat1_hld_2_07, coe_dat1_hld_2_08,
              coe_dat1_hld_2_09, coe_dat1_hld_2_10, coe_dat1_hld_2_11, coe_dat1_hld_2_12,
              coe_dat1_hld_2_13, coe_dat1_hld_2_14, coe_dat1_hld_2_15, coe_dat1_hld_2_16,
              coe_dat1_hld_2_17, coe_dat1_hld_2_18, coe_dat1_hld_2_19, coe_dat1_hld_2_20,
              coe_dat1_hld_2_21, coe_dat1_hld_2_22, coe_dat1_hld_2_23, coe_dat1_hld_2_24,
              coe_dat1_hld_2_25, coe_dat1_hld_2_26, coe_dat1_hld_2_27, coe_dat1_hld_2_28,
              coe_dat1_hld_2_29, coe_dat1_hld_2_30, coe_dat1_hld_2_31, coe_dat1_hld_2_32;
	reg [9:0] coe_dat1_hld_3_01, coe_dat1_hld_3_02, coe_dat1_hld_3_03, coe_dat1_hld_3_04,
              coe_dat1_hld_3_05, coe_dat1_hld_3_06, coe_dat1_hld_3_07, coe_dat1_hld_3_08,
              coe_dat1_hld_3_09, coe_dat1_hld_3_10, coe_dat1_hld_3_11, coe_dat1_hld_3_12,
              coe_dat1_hld_3_13, coe_dat1_hld_3_14, coe_dat1_hld_3_15, coe_dat1_hld_3_16,
              coe_dat1_hld_3_17, coe_dat1_hld_3_18, coe_dat1_hld_3_19, coe_dat1_hld_3_20,
              coe_dat1_hld_3_21, coe_dat1_hld_3_22, coe_dat1_hld_3_23, coe_dat1_hld_3_24,
              coe_dat1_hld_3_25, coe_dat1_hld_3_26, coe_dat1_hld_3_27, coe_dat1_hld_3_28,
              coe_dat1_hld_3_29, coe_dat1_hld_3_30, coe_dat1_hld_3_31, coe_dat1_hld_3_32;
	reg [9:0] coe_dat1_hld_4_01, coe_dat1_hld_4_02, coe_dat1_hld_4_03, coe_dat1_hld_4_04,
              coe_dat1_hld_4_05, coe_dat1_hld_4_06, coe_dat1_hld_4_07, coe_dat1_hld_4_08,
              coe_dat1_hld_4_09, coe_dat1_hld_4_10, coe_dat1_hld_4_11, coe_dat1_hld_4_12,
              coe_dat1_hld_4_13, coe_dat1_hld_4_14, coe_dat1_hld_4_15, coe_dat1_hld_4_16,
              coe_dat1_hld_4_17, coe_dat1_hld_4_18, coe_dat1_hld_4_19, coe_dat1_hld_4_20,
              coe_dat1_hld_4_21, coe_dat1_hld_4_22, coe_dat1_hld_4_23, coe_dat1_hld_4_24,
              coe_dat1_hld_4_25, coe_dat1_hld_4_26, coe_dat1_hld_4_27, coe_dat1_hld_4_28,
              coe_dat1_hld_4_29, coe_dat1_hld_4_30, coe_dat1_hld_4_31, coe_dat1_hld_4_32;

	reg [9:0] coe_dat2_hld_1_01, coe_dat2_hld_1_02, coe_dat2_hld_1_03, coe_dat2_hld_1_04,
              coe_dat2_hld_1_05, coe_dat2_hld_1_06, coe_dat2_hld_1_07, coe_dat2_hld_1_08,
              coe_dat2_hld_1_09, coe_dat2_hld_1_10, coe_dat2_hld_1_11, coe_dat2_hld_1_12,
              coe_dat2_hld_1_13, coe_dat2_hld_1_14, coe_dat2_hld_1_15, coe_dat2_hld_1_16,
              coe_dat2_hld_1_17, coe_dat2_hld_1_18, coe_dat2_hld_1_19, coe_dat2_hld_1_20,
              coe_dat2_hld_1_21, coe_dat2_hld_1_22, coe_dat2_hld_1_23, coe_dat2_hld_1_24,
              coe_dat2_hld_1_25, coe_dat2_hld_1_26, coe_dat2_hld_1_27, coe_dat2_hld_1_28,
              coe_dat2_hld_1_29, coe_dat2_hld_1_30, coe_dat2_hld_1_31, coe_dat2_hld_1_32;
	reg [9:0] coe_dat2_hld_2_01, coe_dat2_hld_2_02, coe_dat2_hld_2_03, coe_dat2_hld_2_04,
              coe_dat2_hld_2_05, coe_dat2_hld_2_06, coe_dat2_hld_2_07, coe_dat2_hld_2_08,
              coe_dat2_hld_2_09, coe_dat2_hld_2_10, coe_dat2_hld_2_11, coe_dat2_hld_2_12,
              coe_dat2_hld_2_13, coe_dat2_hld_2_14, coe_dat2_hld_2_15, coe_dat2_hld_2_16,
              coe_dat2_hld_2_17, coe_dat2_hld_2_18, coe_dat2_hld_2_19, coe_dat2_hld_2_20,
              coe_dat2_hld_2_21, coe_dat2_hld_2_22, coe_dat2_hld_2_23, coe_dat2_hld_2_24,
              coe_dat2_hld_2_25, coe_dat2_hld_2_26, coe_dat2_hld_2_27, coe_dat2_hld_2_28,
              coe_dat2_hld_2_29, coe_dat2_hld_2_30, coe_dat2_hld_2_31, coe_dat2_hld_2_32;
	reg [9:0] coe_dat2_hld_3_01, coe_dat2_hld_3_02, coe_dat2_hld_3_03, coe_dat2_hld_3_04,
              coe_dat2_hld_3_05, coe_dat2_hld_3_06, coe_dat2_hld_3_07, coe_dat2_hld_3_08,
              coe_dat2_hld_3_09, coe_dat2_hld_3_10, coe_dat2_hld_3_11, coe_dat2_hld_3_12,
              coe_dat2_hld_3_13, coe_dat2_hld_3_14, coe_dat2_hld_3_15, coe_dat2_hld_3_16,
              coe_dat2_hld_3_17, coe_dat2_hld_3_18, coe_dat2_hld_3_19, coe_dat2_hld_3_20,
              coe_dat2_hld_3_21, coe_dat2_hld_3_22, coe_dat2_hld_3_23, coe_dat2_hld_3_24,
              coe_dat2_hld_3_25, coe_dat2_hld_3_26, coe_dat2_hld_3_27, coe_dat2_hld_3_28,
              coe_dat2_hld_3_29, coe_dat2_hld_3_30, coe_dat2_hld_3_31, coe_dat2_hld_3_32;
	reg [9:0] coe_dat2_hld_4_01, coe_dat2_hld_4_02, coe_dat2_hld_4_03, coe_dat2_hld_4_04,
              coe_dat2_hld_4_05, coe_dat2_hld_4_06, coe_dat2_hld_4_07, coe_dat2_hld_4_08,
              coe_dat2_hld_4_09, coe_dat2_hld_4_10, coe_dat2_hld_4_11, coe_dat2_hld_4_12,
              coe_dat2_hld_4_13, coe_dat2_hld_4_14, coe_dat2_hld_4_15, coe_dat2_hld_4_16,
              coe_dat2_hld_4_17, coe_dat2_hld_4_18, coe_dat2_hld_4_19, coe_dat2_hld_4_20,
              coe_dat2_hld_4_21, coe_dat2_hld_4_22, coe_dat2_hld_4_23, coe_dat2_hld_4_24,
              coe_dat2_hld_4_25, coe_dat2_hld_4_26, coe_dat2_hld_4_27, coe_dat2_hld_4_28,
              coe_dat2_hld_4_29, coe_dat2_hld_4_30, coe_dat2_hld_4_31, coe_dat2_hld_4_32;

	reg [9:0] coe_dat3_hld_1_01, coe_dat3_hld_1_02, coe_dat3_hld_1_03, coe_dat3_hld_1_04,
              coe_dat3_hld_1_05, coe_dat3_hld_1_06, coe_dat3_hld_1_07, coe_dat3_hld_1_08,
              coe_dat3_hld_1_09, coe_dat3_hld_1_10, coe_dat3_hld_1_11, coe_dat3_hld_1_12,
              coe_dat3_hld_1_13, coe_dat3_hld_1_14, coe_dat3_hld_1_15, coe_dat3_hld_1_16,
              coe_dat3_hld_1_17, coe_dat3_hld_1_18, coe_dat3_hld_1_19, coe_dat3_hld_1_20,
              coe_dat3_hld_1_21, coe_dat3_hld_1_22, coe_dat3_hld_1_23, coe_dat3_hld_1_24,
              coe_dat3_hld_1_25, coe_dat3_hld_1_26, coe_dat3_hld_1_27, coe_dat3_hld_1_28,
              coe_dat3_hld_1_29, coe_dat3_hld_1_30, coe_dat3_hld_1_31, coe_dat3_hld_1_32;
	reg [9:0] coe_dat3_hld_2_01, coe_dat3_hld_2_02, coe_dat3_hld_2_03, coe_dat3_hld_2_04,
              coe_dat3_hld_2_05, coe_dat3_hld_2_06, coe_dat3_hld_2_07, coe_dat3_hld_2_08,
              coe_dat3_hld_2_09, coe_dat3_hld_2_10, coe_dat3_hld_2_11, coe_dat3_hld_2_12,
              coe_dat3_hld_2_13, coe_dat3_hld_2_14, coe_dat3_hld_2_15, coe_dat3_hld_2_16,
              coe_dat3_hld_2_17, coe_dat3_hld_2_18, coe_dat3_hld_2_19, coe_dat3_hld_2_20,
              coe_dat3_hld_2_21, coe_dat3_hld_2_22, coe_dat3_hld_2_23, coe_dat3_hld_2_24,
              coe_dat3_hld_2_25, coe_dat3_hld_2_26, coe_dat3_hld_2_27, coe_dat3_hld_2_28,
              coe_dat3_hld_2_29, coe_dat3_hld_2_30, coe_dat3_hld_2_31, coe_dat3_hld_2_32;
	reg [9:0] coe_dat3_hld_3_01, coe_dat3_hld_3_02, coe_dat3_hld_3_03, coe_dat3_hld_3_04,
              coe_dat3_hld_3_05, coe_dat3_hld_3_06, coe_dat3_hld_3_07, coe_dat3_hld_3_08,
              coe_dat3_hld_3_09, coe_dat3_hld_3_10, coe_dat3_hld_3_11, coe_dat3_hld_3_12,
              coe_dat3_hld_3_13, coe_dat3_hld_3_14, coe_dat3_hld_3_15, coe_dat3_hld_3_16,
              coe_dat3_hld_3_17, coe_dat3_hld_3_18, coe_dat3_hld_3_19, coe_dat3_hld_3_20,
              coe_dat3_hld_3_21, coe_dat3_hld_3_22, coe_dat3_hld_3_23, coe_dat3_hld_3_24,
              coe_dat3_hld_3_25, coe_dat3_hld_3_26, coe_dat3_hld_3_27, coe_dat3_hld_3_28,
              coe_dat3_hld_3_29, coe_dat3_hld_3_30, coe_dat3_hld_3_31, coe_dat3_hld_3_32;
	reg [9:0] coe_dat3_hld_4_01, coe_dat3_hld_4_02, coe_dat3_hld_4_03, coe_dat3_hld_4_04,
              coe_dat3_hld_4_05, coe_dat3_hld_4_06, coe_dat3_hld_4_07, coe_dat3_hld_4_08,
              coe_dat3_hld_4_09, coe_dat3_hld_4_10, coe_dat3_hld_4_11, coe_dat3_hld_4_12,
              coe_dat3_hld_4_13, coe_dat3_hld_4_14, coe_dat3_hld_4_15, coe_dat3_hld_4_16,
              coe_dat3_hld_4_17, coe_dat3_hld_4_18, coe_dat3_hld_4_19, coe_dat3_hld_4_20,
              coe_dat3_hld_4_21, coe_dat3_hld_4_22, coe_dat3_hld_4_23, coe_dat3_hld_4_24,
              coe_dat3_hld_4_25, coe_dat3_hld_4_26, coe_dat3_hld_4_27, coe_dat3_hld_4_28,
              coe_dat3_hld_4_29, coe_dat3_hld_4_30, coe_dat3_hld_4_31, coe_dat3_hld_4_32;

	reg [9:0] coe_dat4_hld_1_01, coe_dat4_hld_1_02, coe_dat4_hld_1_03, coe_dat4_hld_1_04,
              coe_dat4_hld_1_05, coe_dat4_hld_1_06, coe_dat4_hld_1_07, coe_dat4_hld_1_08,
              coe_dat4_hld_1_09, coe_dat4_hld_1_10, coe_dat4_hld_1_11, coe_dat4_hld_1_12,
              coe_dat4_hld_1_13, coe_dat4_hld_1_14, coe_dat4_hld_1_15, coe_dat4_hld_1_16,
              coe_dat4_hld_1_17, coe_dat4_hld_1_18, coe_dat4_hld_1_19, coe_dat4_hld_1_20,
              coe_dat4_hld_1_21, coe_dat4_hld_1_22, coe_dat4_hld_1_23, coe_dat4_hld_1_24,
              coe_dat4_hld_1_25, coe_dat4_hld_1_26, coe_dat4_hld_1_27, coe_dat4_hld_1_28,
              coe_dat4_hld_1_29, coe_dat4_hld_1_30, coe_dat4_hld_1_31, coe_dat4_hld_1_32;
	reg [9:0] coe_dat4_hld_2_01, coe_dat4_hld_2_02, coe_dat4_hld_2_03, coe_dat4_hld_2_04,
              coe_dat4_hld_2_05, coe_dat4_hld_2_06, coe_dat4_hld_2_07, coe_dat4_hld_2_08,
              coe_dat4_hld_2_09, coe_dat4_hld_2_10, coe_dat4_hld_2_11, coe_dat4_hld_2_12,
              coe_dat4_hld_2_13, coe_dat4_hld_2_14, coe_dat4_hld_2_15, coe_dat4_hld_2_16,
              coe_dat4_hld_2_17, coe_dat4_hld_2_18, coe_dat4_hld_2_19, coe_dat4_hld_2_20,
              coe_dat4_hld_2_21, coe_dat4_hld_2_22, coe_dat4_hld_2_23, coe_dat4_hld_2_24,
              coe_dat4_hld_2_25, coe_dat4_hld_2_26, coe_dat4_hld_2_27, coe_dat4_hld_2_28,
              coe_dat4_hld_2_29, coe_dat4_hld_2_30, coe_dat4_hld_2_31, coe_dat4_hld_2_32;
	reg [9:0] coe_dat4_hld_3_01, coe_dat4_hld_3_02, coe_dat4_hld_3_03, coe_dat4_hld_3_04,
              coe_dat4_hld_3_05, coe_dat4_hld_3_06, coe_dat4_hld_3_07, coe_dat4_hld_3_08,
              coe_dat4_hld_3_09, coe_dat4_hld_3_10, coe_dat4_hld_3_11, coe_dat4_hld_3_12,
              coe_dat4_hld_3_13, coe_dat4_hld_3_14, coe_dat4_hld_3_15, coe_dat4_hld_3_16,
              coe_dat4_hld_3_17, coe_dat4_hld_3_18, coe_dat4_hld_3_19, coe_dat4_hld_3_20,
              coe_dat4_hld_3_21, coe_dat4_hld_3_22, coe_dat4_hld_3_23, coe_dat4_hld_3_24,
              coe_dat4_hld_3_25, coe_dat4_hld_3_26, coe_dat4_hld_3_27, coe_dat4_hld_3_28,
              coe_dat4_hld_3_29, coe_dat4_hld_3_30, coe_dat4_hld_3_31, coe_dat4_hld_3_32;
	reg [9:0] coe_dat4_hld_4_01, coe_dat4_hld_4_02, coe_dat4_hld_4_03, coe_dat4_hld_4_04,
              coe_dat4_hld_4_05, coe_dat4_hld_4_06, coe_dat4_hld_4_07, coe_dat4_hld_4_08,
              coe_dat4_hld_4_09, coe_dat4_hld_4_10, coe_dat4_hld_4_11, coe_dat4_hld_4_12,
              coe_dat4_hld_4_13, coe_dat4_hld_4_14, coe_dat4_hld_4_15, coe_dat4_hld_4_16,
              coe_dat4_hld_4_17, coe_dat4_hld_4_18, coe_dat4_hld_4_19, coe_dat4_hld_4_20,
              coe_dat4_hld_4_21, coe_dat4_hld_4_22, coe_dat4_hld_4_23, coe_dat4_hld_4_24,
              coe_dat4_hld_4_25, coe_dat4_hld_4_26, coe_dat4_hld_4_27, coe_dat4_hld_4_28,
              coe_dat4_hld_4_29, coe_dat4_hld_4_30, coe_dat4_hld_4_31, coe_dat4_hld_4_32;

	reg [9:0] coe_dat5_hld_1_01, coe_dat5_hld_1_02, coe_dat5_hld_1_03, coe_dat5_hld_1_04,
              coe_dat5_hld_1_05, coe_dat5_hld_1_06, coe_dat5_hld_1_07, coe_dat5_hld_1_08,
              coe_dat5_hld_1_09, coe_dat5_hld_1_10, coe_dat5_hld_1_11, coe_dat5_hld_1_12,
              coe_dat5_hld_1_13, coe_dat5_hld_1_14, coe_dat5_hld_1_15, coe_dat5_hld_1_16,
              coe_dat5_hld_1_17, coe_dat5_hld_1_18, coe_dat5_hld_1_19, coe_dat5_hld_1_20,
              coe_dat5_hld_1_21, coe_dat5_hld_1_22, coe_dat5_hld_1_23, coe_dat5_hld_1_24,
              coe_dat5_hld_1_25, coe_dat5_hld_1_26, coe_dat5_hld_1_27, coe_dat5_hld_1_28,
              coe_dat5_hld_1_29, coe_dat5_hld_1_30, coe_dat5_hld_1_31, coe_dat5_hld_1_32;
	reg [9:0] coe_dat5_hld_2_01, coe_dat5_hld_2_02, coe_dat5_hld_2_03, coe_dat5_hld_2_04,
              coe_dat5_hld_2_05, coe_dat5_hld_2_06, coe_dat5_hld_2_07, coe_dat5_hld_2_08,
              coe_dat5_hld_2_09, coe_dat5_hld_2_10, coe_dat5_hld_2_11, coe_dat5_hld_2_12,
              coe_dat5_hld_2_13, coe_dat5_hld_2_14, coe_dat5_hld_2_15, coe_dat5_hld_2_16,
              coe_dat5_hld_2_17, coe_dat5_hld_2_18, coe_dat5_hld_2_19, coe_dat5_hld_2_20,
              coe_dat5_hld_2_21, coe_dat5_hld_2_22, coe_dat5_hld_2_23, coe_dat5_hld_2_24,
              coe_dat5_hld_2_25, coe_dat5_hld_2_26, coe_dat5_hld_2_27, coe_dat5_hld_2_28,
              coe_dat5_hld_2_29, coe_dat5_hld_2_30, coe_dat5_hld_2_31, coe_dat5_hld_2_32;
	reg [9:0] coe_dat5_hld_3_01, coe_dat5_hld_3_02, coe_dat5_hld_3_03, coe_dat5_hld_3_04,
              coe_dat5_hld_3_05, coe_dat5_hld_3_06, coe_dat5_hld_3_07, coe_dat5_hld_3_08,
              coe_dat5_hld_3_09, coe_dat5_hld_3_10, coe_dat5_hld_3_11, coe_dat5_hld_3_12,
              coe_dat5_hld_3_13, coe_dat5_hld_3_14, coe_dat5_hld_3_15, coe_dat5_hld_3_16,
              coe_dat5_hld_3_17, coe_dat5_hld_3_18, coe_dat5_hld_3_19, coe_dat5_hld_3_20,
              coe_dat5_hld_3_21, coe_dat5_hld_3_22, coe_dat5_hld_3_23, coe_dat5_hld_3_24,
              coe_dat5_hld_3_25, coe_dat5_hld_3_26, coe_dat5_hld_3_27, coe_dat5_hld_3_28,
              coe_dat5_hld_3_29, coe_dat5_hld_3_30, coe_dat5_hld_3_31, coe_dat5_hld_3_32;
	reg [9:0] coe_dat5_hld_4_01, coe_dat5_hld_4_02, coe_dat5_hld_4_03, coe_dat5_hld_4_04,
              coe_dat5_hld_4_05, coe_dat5_hld_4_06, coe_dat5_hld_4_07, coe_dat5_hld_4_08,
              coe_dat5_hld_4_09, coe_dat5_hld_4_10, coe_dat5_hld_4_11, coe_dat5_hld_4_12,
              coe_dat5_hld_4_13, coe_dat5_hld_4_14, coe_dat5_hld_4_15, coe_dat5_hld_4_16,
              coe_dat5_hld_4_17, coe_dat5_hld_4_18, coe_dat5_hld_4_19, coe_dat5_hld_4_20,
              coe_dat5_hld_4_21, coe_dat5_hld_4_22, coe_dat5_hld_4_23, coe_dat5_hld_4_24,
              coe_dat5_hld_4_25, coe_dat5_hld_4_26, coe_dat5_hld_4_27, coe_dat5_hld_4_28,
              coe_dat5_hld_4_29, coe_dat5_hld_4_30, coe_dat5_hld_4_31, coe_dat5_hld_4_32;

	reg [9:0] coe_dat6_hld_1_01, coe_dat6_hld_1_02, coe_dat6_hld_1_03, coe_dat6_hld_1_04,
              coe_dat6_hld_1_05, coe_dat6_hld_1_06, coe_dat6_hld_1_07, coe_dat6_hld_1_08,
              coe_dat6_hld_1_09, coe_dat6_hld_1_10, coe_dat6_hld_1_11, coe_dat6_hld_1_12,
              coe_dat6_hld_1_13, coe_dat6_hld_1_14, coe_dat6_hld_1_15, coe_dat6_hld_1_16,
              coe_dat6_hld_1_17, coe_dat6_hld_1_18, coe_dat6_hld_1_19, coe_dat6_hld_1_20,
              coe_dat6_hld_1_21, coe_dat6_hld_1_22, coe_dat6_hld_1_23, coe_dat6_hld_1_24,
              coe_dat6_hld_1_25, coe_dat6_hld_1_26, coe_dat6_hld_1_27, coe_dat6_hld_1_28,
              coe_dat6_hld_1_29, coe_dat6_hld_1_30, coe_dat6_hld_1_31, coe_dat6_hld_1_32;
	reg [9:0] coe_dat6_hld_2_01, coe_dat6_hld_2_02, coe_dat6_hld_2_03, coe_dat6_hld_2_04,
              coe_dat6_hld_2_05, coe_dat6_hld_2_06, coe_dat6_hld_2_07, coe_dat6_hld_2_08,
              coe_dat6_hld_2_09, coe_dat6_hld_2_10, coe_dat6_hld_2_11, coe_dat6_hld_2_12,
              coe_dat6_hld_2_13, coe_dat6_hld_2_14, coe_dat6_hld_2_15, coe_dat6_hld_2_16,
              coe_dat6_hld_2_17, coe_dat6_hld_2_18, coe_dat6_hld_2_19, coe_dat6_hld_2_20,
              coe_dat6_hld_2_21, coe_dat6_hld_2_22, coe_dat6_hld_2_23, coe_dat6_hld_2_24,
              coe_dat6_hld_2_25, coe_dat6_hld_2_26, coe_dat6_hld_2_27, coe_dat6_hld_2_28,
              coe_dat6_hld_2_29, coe_dat6_hld_2_30, coe_dat6_hld_2_31, coe_dat6_hld_2_32;
	reg [9:0] coe_dat6_hld_3_01, coe_dat6_hld_3_02, coe_dat6_hld_3_03, coe_dat6_hld_3_04,
              coe_dat6_hld_3_05, coe_dat6_hld_3_06, coe_dat6_hld_3_07, coe_dat6_hld_3_08,
              coe_dat6_hld_3_09, coe_dat6_hld_3_10, coe_dat6_hld_3_11, coe_dat6_hld_3_12,
              coe_dat6_hld_3_13, coe_dat6_hld_3_14, coe_dat6_hld_3_15, coe_dat6_hld_3_16,
              coe_dat6_hld_3_17, coe_dat6_hld_3_18, coe_dat6_hld_3_19, coe_dat6_hld_3_20,
              coe_dat6_hld_3_21, coe_dat6_hld_3_22, coe_dat6_hld_3_23, coe_dat6_hld_3_24,
              coe_dat6_hld_3_25, coe_dat6_hld_3_26, coe_dat6_hld_3_27, coe_dat6_hld_3_28,
              coe_dat6_hld_3_29, coe_dat6_hld_3_30, coe_dat6_hld_3_31, coe_dat6_hld_3_32;
	reg [9:0] coe_dat6_hld_4_01, coe_dat6_hld_4_02, coe_dat6_hld_4_03, coe_dat6_hld_4_04,
              coe_dat6_hld_4_05, coe_dat6_hld_4_06, coe_dat6_hld_4_07, coe_dat6_hld_4_08,
              coe_dat6_hld_4_09, coe_dat6_hld_4_10, coe_dat6_hld_4_11, coe_dat6_hld_4_12,
              coe_dat6_hld_4_13, coe_dat6_hld_4_14, coe_dat6_hld_4_15, coe_dat6_hld_4_16,
              coe_dat6_hld_4_17, coe_dat6_hld_4_18, coe_dat6_hld_4_19, coe_dat6_hld_4_20,
              coe_dat6_hld_4_21, coe_dat6_hld_4_22, coe_dat6_hld_4_23, coe_dat6_hld_4_24,
              coe_dat6_hld_4_25, coe_dat6_hld_4_26, coe_dat6_hld_4_27, coe_dat6_hld_4_28,
              coe_dat6_hld_4_29, coe_dat6_hld_4_30, coe_dat6_hld_4_31, coe_dat6_hld_4_32;

	reg [9:0] coe_dat7_hld_1_01, coe_dat7_hld_1_02, coe_dat7_hld_1_03, coe_dat7_hld_1_04,
              coe_dat7_hld_1_05, coe_dat7_hld_1_06, coe_dat7_hld_1_07, coe_dat7_hld_1_08,
              coe_dat7_hld_1_09, coe_dat7_hld_1_10, coe_dat7_hld_1_11, coe_dat7_hld_1_12,
              coe_dat7_hld_1_13, coe_dat7_hld_1_14, coe_dat7_hld_1_15, coe_dat7_hld_1_16,
              coe_dat7_hld_1_17, coe_dat7_hld_1_18, coe_dat7_hld_1_19, coe_dat7_hld_1_20,
              coe_dat7_hld_1_21, coe_dat7_hld_1_22, coe_dat7_hld_1_23, coe_dat7_hld_1_24,
              coe_dat7_hld_1_25, coe_dat7_hld_1_26, coe_dat7_hld_1_27, coe_dat7_hld_1_28,
              coe_dat7_hld_1_29, coe_dat7_hld_1_30, coe_dat7_hld_1_31, coe_dat7_hld_1_32;
	reg [9:0] coe_dat7_hld_2_01, coe_dat7_hld_2_02, coe_dat7_hld_2_03, coe_dat7_hld_2_04,
              coe_dat7_hld_2_05, coe_dat7_hld_2_06, coe_dat7_hld_2_07, coe_dat7_hld_2_08,
              coe_dat7_hld_2_09, coe_dat7_hld_2_10, coe_dat7_hld_2_11, coe_dat7_hld_2_12,
              coe_dat7_hld_2_13, coe_dat7_hld_2_14, coe_dat7_hld_2_15, coe_dat7_hld_2_16,
              coe_dat7_hld_2_17, coe_dat7_hld_2_18, coe_dat7_hld_2_19, coe_dat7_hld_2_20,
              coe_dat7_hld_2_21, coe_dat7_hld_2_22, coe_dat7_hld_2_23, coe_dat7_hld_2_24,
              coe_dat7_hld_2_25, coe_dat7_hld_2_26, coe_dat7_hld_2_27, coe_dat7_hld_2_28,
              coe_dat7_hld_2_29, coe_dat7_hld_2_30, coe_dat7_hld_2_31, coe_dat7_hld_2_32;
	reg [9:0] coe_dat7_hld_3_01, coe_dat7_hld_3_02, coe_dat7_hld_3_03, coe_dat7_hld_3_04,
              coe_dat7_hld_3_05, coe_dat7_hld_3_06, coe_dat7_hld_3_07, coe_dat7_hld_3_08,
              coe_dat7_hld_3_09, coe_dat7_hld_3_10, coe_dat7_hld_3_11, coe_dat7_hld_3_12,
              coe_dat7_hld_3_13, coe_dat7_hld_3_14, coe_dat7_hld_3_15, coe_dat7_hld_3_16,
              coe_dat7_hld_3_17, coe_dat7_hld_3_18, coe_dat7_hld_3_19, coe_dat7_hld_3_20,
              coe_dat7_hld_3_21, coe_dat7_hld_3_22, coe_dat7_hld_3_23, coe_dat7_hld_3_24,
              coe_dat7_hld_3_25, coe_dat7_hld_3_26, coe_dat7_hld_3_27, coe_dat7_hld_3_28,
              coe_dat7_hld_3_29, coe_dat7_hld_3_30, coe_dat7_hld_3_31, coe_dat7_hld_3_32;
	reg [9:0] coe_dat7_hld_4_01, coe_dat7_hld_4_02, coe_dat7_hld_4_03, coe_dat7_hld_4_04,
              coe_dat7_hld_4_05, coe_dat7_hld_4_06, coe_dat7_hld_4_07, coe_dat7_hld_4_08,
              coe_dat7_hld_4_09, coe_dat7_hld_4_10, coe_dat7_hld_4_11, coe_dat7_hld_4_12,
              coe_dat7_hld_4_13, coe_dat7_hld_4_14, coe_dat7_hld_4_15, coe_dat7_hld_4_16,
              coe_dat7_hld_4_17, coe_dat7_hld_4_18, coe_dat7_hld_4_19, coe_dat7_hld_4_20,
              coe_dat7_hld_4_21, coe_dat7_hld_4_22, coe_dat7_hld_4_23, coe_dat7_hld_4_24,
              coe_dat7_hld_4_25, coe_dat7_hld_4_26, coe_dat7_hld_4_27, coe_dat7_hld_4_28,
              coe_dat7_hld_4_29, coe_dat7_hld_4_30, coe_dat7_hld_4_31, coe_dat7_hld_4_32;

	reg [9:0] coe_dat8_hld_1_01, coe_dat8_hld_1_02, coe_dat8_hld_1_03, coe_dat8_hld_1_04,
              coe_dat8_hld_1_05, coe_dat8_hld_1_06, coe_dat8_hld_1_07, coe_dat8_hld_1_08,
              coe_dat8_hld_1_09, coe_dat8_hld_1_10, coe_dat8_hld_1_11, coe_dat8_hld_1_12,
              coe_dat8_hld_1_13, coe_dat8_hld_1_14, coe_dat8_hld_1_15, coe_dat8_hld_1_16,
              coe_dat8_hld_1_17, coe_dat8_hld_1_18, coe_dat8_hld_1_19, coe_dat8_hld_1_20,
              coe_dat8_hld_1_21, coe_dat8_hld_1_22, coe_dat8_hld_1_23, coe_dat8_hld_1_24,
              coe_dat8_hld_1_25, coe_dat8_hld_1_26, coe_dat8_hld_1_27, coe_dat8_hld_1_28,
              coe_dat8_hld_1_29, coe_dat8_hld_1_30, coe_dat8_hld_1_31, coe_dat8_hld_1_32;
	reg [9:0] coe_dat8_hld_2_01, coe_dat8_hld_2_02, coe_dat8_hld_2_03, coe_dat8_hld_2_04,
              coe_dat8_hld_2_05, coe_dat8_hld_2_06, coe_dat8_hld_2_07, coe_dat8_hld_2_08,
              coe_dat8_hld_2_09, coe_dat8_hld_2_10, coe_dat8_hld_2_11, coe_dat8_hld_2_12,
              coe_dat8_hld_2_13, coe_dat8_hld_2_14, coe_dat8_hld_2_15, coe_dat8_hld_2_16,
              coe_dat8_hld_2_17, coe_dat8_hld_2_18, coe_dat8_hld_2_19, coe_dat8_hld_2_20,
              coe_dat8_hld_2_21, coe_dat8_hld_2_22, coe_dat8_hld_2_23, coe_dat8_hld_2_24,
              coe_dat8_hld_2_25, coe_dat8_hld_2_26, coe_dat8_hld_2_27, coe_dat8_hld_2_28,
              coe_dat8_hld_2_29, coe_dat8_hld_2_30, coe_dat8_hld_2_31, coe_dat8_hld_2_32;
	reg [9:0] coe_dat8_hld_3_01, coe_dat8_hld_3_02, coe_dat8_hld_3_03, coe_dat8_hld_3_04,
              coe_dat8_hld_3_05, coe_dat8_hld_3_06, coe_dat8_hld_3_07, coe_dat8_hld_3_08,
              coe_dat8_hld_3_09, coe_dat8_hld_3_10, coe_dat8_hld_3_11, coe_dat8_hld_3_12,
              coe_dat8_hld_3_13, coe_dat8_hld_3_14, coe_dat8_hld_3_15, coe_dat8_hld_3_16,
              coe_dat8_hld_3_17, coe_dat8_hld_3_18, coe_dat8_hld_3_19, coe_dat8_hld_3_20,
              coe_dat8_hld_3_21, coe_dat8_hld_3_22, coe_dat8_hld_3_23, coe_dat8_hld_3_24,
              coe_dat8_hld_3_25, coe_dat8_hld_3_26, coe_dat8_hld_3_27, coe_dat8_hld_3_28,
              coe_dat8_hld_3_29, coe_dat8_hld_3_30, coe_dat8_hld_3_31, coe_dat8_hld_3_32;
	reg [9:0] coe_dat8_hld_4_01, coe_dat8_hld_4_02, coe_dat8_hld_4_03, coe_dat8_hld_4_04,
              coe_dat8_hld_4_05, coe_dat8_hld_4_06, coe_dat8_hld_4_07, coe_dat8_hld_4_08,
              coe_dat8_hld_4_09, coe_dat8_hld_4_10, coe_dat8_hld_4_11, coe_dat8_hld_4_12,
              coe_dat8_hld_4_13, coe_dat8_hld_4_14, coe_dat8_hld_4_15, coe_dat8_hld_4_16,
              coe_dat8_hld_4_17, coe_dat8_hld_4_18, coe_dat8_hld_4_19, coe_dat8_hld_4_20,
              coe_dat8_hld_4_21, coe_dat8_hld_4_22, coe_dat8_hld_4_23, coe_dat8_hld_4_24,
              coe_dat8_hld_4_25, coe_dat8_hld_4_26, coe_dat8_hld_4_27, coe_dat8_hld_4_28,
              coe_dat8_hld_4_29, coe_dat8_hld_4_30, coe_dat8_hld_4_31, coe_dat8_hld_4_32;
			
    always @ (posedge clk) begin
		if(rst) begin
			in_dat_hld01[9:0] <= #DLY 10'd0 ;
			in_dat_hld02[9:0] <= #DLY 10'd0 ;
			in_dat_hld03[9:0] <= #DLY 10'd0 ;
			in_dat_hld04[9:0] <= #DLY 10'd0 ;
			in_dat_hld05[9:0] <= #DLY 10'd0 ;
			in_dat_hld06[9:0] <= #DLY 10'd0 ;
			in_dat_hld07[9:0] <= #DLY 10'd0 ;
			in_dat_hld08[9:0] <= #DLY 10'd0 ;
			in_dat_hld09[9:0] <= #DLY 10'd0 ;
			in_dat_hld10[9:0] <= #DLY 10'd0 ;
			in_dat_hld11[9:0] <= #DLY 10'd0 ;
			in_dat_hld12[9:0] <= #DLY 10'd0 ;
			in_dat_hld13[9:0] <= #DLY 10'd0 ;
			in_dat_hld14[9:0] <= #DLY 10'd0 ;
			in_dat_hld15[9:0] <= #DLY 10'd0 ;
			in_dat_hld16[9:0] <= #DLY 10'd0 ;
			in_dat_hld17[9:0] <= #DLY 10'd0 ;
			in_dat_hld18[9:0] <= #DLY 10'd0 ;
			in_dat_hld19[9:0] <= #DLY 10'd0 ;
			in_dat_hld20[9:0] <= #DLY 10'd0 ;
			in_dat_hld21[9:0] <= #DLY 10'd0 ;
			in_dat_hld22[9:0] <= #DLY 10'd0 ;
			in_dat_hld23[9:0] <= #DLY 10'd0 ;
			in_dat_hld24[9:0] <= #DLY 10'd0 ;
			in_dat_hld25[9:0] <= #DLY 10'd0 ;
			in_dat_hld26[9:0] <= #DLY 10'd0 ;
			in_dat_hld27[9:0] <= #DLY 10'd0 ;
			in_dat_hld28[9:0] <= #DLY 10'd0 ;
			in_dat_hld29[9:0] <= #DLY 10'd0 ;
			in_dat_hld30[9:0] <= #DLY 10'd0 ;
			in_dat_hld31[9:0] <= #DLY 10'd0 ;
			in_dat_hld32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7) & (column_cnt_dd2[12:0] == 13'd0)) begin
			in_dat_hld01[9:0] <= #DLY in_dat_wire01[9:0] ;
			in_dat_hld02[9:0] <= #DLY in_dat_wire02[9:0] ;
			in_dat_hld03[9:0] <= #DLY in_dat_wire03[9:0] ;
			in_dat_hld04[9:0] <= #DLY in_dat_wire04[9:0] ;
			in_dat_hld05[9:0] <= #DLY in_dat_wire05[9:0] ;
			in_dat_hld06[9:0] <= #DLY in_dat_wire06[9:0] ;
			in_dat_hld07[9:0] <= #DLY in_dat_wire07[9:0] ;
			in_dat_hld08[9:0] <= #DLY in_dat_wire08[9:0] ;
			in_dat_hld09[9:0] <= #DLY in_dat_wire09[9:0] ;
			in_dat_hld10[9:0] <= #DLY in_dat_wire10[9:0] ;
			in_dat_hld11[9:0] <= #DLY in_dat_wire11[9:0] ;
			in_dat_hld12[9:0] <= #DLY in_dat_wire12[9:0] ;
			in_dat_hld13[9:0] <= #DLY in_dat_wire13[9:0] ;
			in_dat_hld14[9:0] <= #DLY in_dat_wire14[9:0] ;
			in_dat_hld15[9:0] <= #DLY in_dat_wire15[9:0] ;
			in_dat_hld16[9:0] <= #DLY in_dat_wire16[9:0] ;
			in_dat_hld17[9:0] <= #DLY in_dat_wire17[9:0] ;
			in_dat_hld18[9:0] <= #DLY in_dat_wire18[9:0] ;
			in_dat_hld19[9:0] <= #DLY in_dat_wire19[9:0] ;
			in_dat_hld20[9:0] <= #DLY in_dat_wire20[9:0] ;
			in_dat_hld21[9:0] <= #DLY in_dat_wire21[9:0] ;
			in_dat_hld22[9:0] <= #DLY in_dat_wire22[9:0] ;
			in_dat_hld23[9:0] <= #DLY in_dat_wire23[9:0] ;
			in_dat_hld24[9:0] <= #DLY in_dat_wire24[9:0] ;
			in_dat_hld25[9:0] <= #DLY in_dat_wire25[9:0] ;
			in_dat_hld26[9:0] <= #DLY in_dat_wire26[9:0] ;
			in_dat_hld27[9:0] <= #DLY in_dat_wire27[9:0] ;
			in_dat_hld28[9:0] <= #DLY in_dat_wire28[9:0] ;
			in_dat_hld29[9:0] <= #DLY in_dat_wire29[9:0] ;
			in_dat_hld30[9:0] <= #DLY in_dat_wire30[9:0] ;
			in_dat_hld31[9:0] <= #DLY in_dat_wire31[9:0] ;
			in_dat_hld32[9:0] <= #DLY in_dat_wire32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat1_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat1_hld_1_01[9:0] <= #DLY coe_dat1_wire_1_01[9:0] ;
			coe_dat1_hld_1_02[9:0] <= #DLY coe_dat1_wire_1_02[9:0] ;
			coe_dat1_hld_1_03[9:0] <= #DLY coe_dat1_wire_1_03[9:0] ;
			coe_dat1_hld_1_04[9:0] <= #DLY coe_dat1_wire_1_04[9:0] ;
			coe_dat1_hld_1_05[9:0] <= #DLY coe_dat1_wire_1_05[9:0] ;
			coe_dat1_hld_1_06[9:0] <= #DLY coe_dat1_wire_1_06[9:0] ;
			coe_dat1_hld_1_07[9:0] <= #DLY coe_dat1_wire_1_07[9:0] ;
			coe_dat1_hld_1_08[9:0] <= #DLY coe_dat1_wire_1_08[9:0] ;
			coe_dat1_hld_1_09[9:0] <= #DLY coe_dat1_wire_1_09[9:0] ;
			coe_dat1_hld_1_10[9:0] <= #DLY coe_dat1_wire_1_10[9:0] ;
			coe_dat1_hld_1_11[9:0] <= #DLY coe_dat1_wire_1_11[9:0] ;
			coe_dat1_hld_1_12[9:0] <= #DLY coe_dat1_wire_1_12[9:0] ;
			coe_dat1_hld_1_13[9:0] <= #DLY coe_dat1_wire_1_13[9:0] ;
			coe_dat1_hld_1_14[9:0] <= #DLY coe_dat1_wire_1_14[9:0] ;
			coe_dat1_hld_1_15[9:0] <= #DLY coe_dat1_wire_1_15[9:0] ;
			coe_dat1_hld_1_16[9:0] <= #DLY coe_dat1_wire_1_16[9:0] ;
			coe_dat1_hld_1_17[9:0] <= #DLY coe_dat1_wire_1_17[9:0] ;
			coe_dat1_hld_1_18[9:0] <= #DLY coe_dat1_wire_1_18[9:0] ;
			coe_dat1_hld_1_19[9:0] <= #DLY coe_dat1_wire_1_19[9:0] ;
			coe_dat1_hld_1_20[9:0] <= #DLY coe_dat1_wire_1_20[9:0] ;
			coe_dat1_hld_1_21[9:0] <= #DLY coe_dat1_wire_1_21[9:0] ;
			coe_dat1_hld_1_22[9:0] <= #DLY coe_dat1_wire_1_22[9:0] ;
			coe_dat1_hld_1_23[9:0] <= #DLY coe_dat1_wire_1_23[9:0] ;
			coe_dat1_hld_1_24[9:0] <= #DLY coe_dat1_wire_1_24[9:0] ;
			coe_dat1_hld_1_25[9:0] <= #DLY coe_dat1_wire_1_25[9:0] ;
			coe_dat1_hld_1_26[9:0] <= #DLY coe_dat1_wire_1_26[9:0] ;
			coe_dat1_hld_1_27[9:0] <= #DLY coe_dat1_wire_1_27[9:0] ;
			coe_dat1_hld_1_28[9:0] <= #DLY coe_dat1_wire_1_28[9:0] ;
			coe_dat1_hld_1_29[9:0] <= #DLY coe_dat1_wire_1_29[9:0] ;
			coe_dat1_hld_1_30[9:0] <= #DLY coe_dat1_wire_1_30[9:0] ;
			coe_dat1_hld_1_31[9:0] <= #DLY coe_dat1_wire_1_31[9:0] ;
			coe_dat1_hld_1_32[9:0] <= #DLY coe_dat1_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat1_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat1_hld_2_01[9:0] <= #DLY coe_dat1_wire_2_01[9:0] ;
			coe_dat1_hld_2_02[9:0] <= #DLY coe_dat1_wire_2_02[9:0] ;
			coe_dat1_hld_2_03[9:0] <= #DLY coe_dat1_wire_2_03[9:0] ;
			coe_dat1_hld_2_04[9:0] <= #DLY coe_dat1_wire_2_04[9:0] ;
			coe_dat1_hld_2_05[9:0] <= #DLY coe_dat1_wire_2_05[9:0] ;
			coe_dat1_hld_2_06[9:0] <= #DLY coe_dat1_wire_2_06[9:0] ;
			coe_dat1_hld_2_07[9:0] <= #DLY coe_dat1_wire_2_07[9:0] ;
			coe_dat1_hld_2_08[9:0] <= #DLY coe_dat1_wire_2_08[9:0] ;
			coe_dat1_hld_2_09[9:0] <= #DLY coe_dat1_wire_2_09[9:0] ;
			coe_dat1_hld_2_10[9:0] <= #DLY coe_dat1_wire_2_10[9:0] ;
			coe_dat1_hld_2_11[9:0] <= #DLY coe_dat1_wire_2_11[9:0] ;
			coe_dat1_hld_2_12[9:0] <= #DLY coe_dat1_wire_2_12[9:0] ;
			coe_dat1_hld_2_13[9:0] <= #DLY coe_dat1_wire_2_13[9:0] ;
			coe_dat1_hld_2_14[9:0] <= #DLY coe_dat1_wire_2_14[9:0] ;
			coe_dat1_hld_2_15[9:0] <= #DLY coe_dat1_wire_2_15[9:0] ;
			coe_dat1_hld_2_16[9:0] <= #DLY coe_dat1_wire_2_16[9:0] ;
			coe_dat1_hld_2_17[9:0] <= #DLY coe_dat1_wire_2_17[9:0] ;
			coe_dat1_hld_2_18[9:0] <= #DLY coe_dat1_wire_2_18[9:0] ;
			coe_dat1_hld_2_19[9:0] <= #DLY coe_dat1_wire_2_19[9:0] ;
			coe_dat1_hld_2_20[9:0] <= #DLY coe_dat1_wire_2_20[9:0] ;
			coe_dat1_hld_2_21[9:0] <= #DLY coe_dat1_wire_2_21[9:0] ;
			coe_dat1_hld_2_22[9:0] <= #DLY coe_dat1_wire_2_22[9:0] ;
			coe_dat1_hld_2_23[9:0] <= #DLY coe_dat1_wire_2_23[9:0] ;
			coe_dat1_hld_2_24[9:0] <= #DLY coe_dat1_wire_2_24[9:0] ;
			coe_dat1_hld_2_25[9:0] <= #DLY coe_dat1_wire_2_25[9:0] ;
			coe_dat1_hld_2_26[9:0] <= #DLY coe_dat1_wire_2_26[9:0] ;
			coe_dat1_hld_2_27[9:0] <= #DLY coe_dat1_wire_2_27[9:0] ;
			coe_dat1_hld_2_28[9:0] <= #DLY coe_dat1_wire_2_28[9:0] ;
			coe_dat1_hld_2_29[9:0] <= #DLY coe_dat1_wire_2_29[9:0] ;
			coe_dat1_hld_2_30[9:0] <= #DLY coe_dat1_wire_2_30[9:0] ;
			coe_dat1_hld_2_31[9:0] <= #DLY coe_dat1_wire_2_31[9:0] ;
			coe_dat1_hld_2_32[9:0] <= #DLY coe_dat1_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat1_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat1_hld_3_01[9:0] <= #DLY coe_dat1_wire_3_01[9:0] ;
			coe_dat1_hld_3_02[9:0] <= #DLY coe_dat1_wire_3_02[9:0] ;
			coe_dat1_hld_3_03[9:0] <= #DLY coe_dat1_wire_3_03[9:0] ;
			coe_dat1_hld_3_04[9:0] <= #DLY coe_dat1_wire_3_04[9:0] ;
			coe_dat1_hld_3_05[9:0] <= #DLY coe_dat1_wire_3_05[9:0] ;
			coe_dat1_hld_3_06[9:0] <= #DLY coe_dat1_wire_3_06[9:0] ;
			coe_dat1_hld_3_07[9:0] <= #DLY coe_dat1_wire_3_07[9:0] ;
			coe_dat1_hld_3_08[9:0] <= #DLY coe_dat1_wire_3_08[9:0] ;
			coe_dat1_hld_3_09[9:0] <= #DLY coe_dat1_wire_3_09[9:0] ;
			coe_dat1_hld_3_10[9:0] <= #DLY coe_dat1_wire_3_10[9:0] ;
			coe_dat1_hld_3_11[9:0] <= #DLY coe_dat1_wire_3_11[9:0] ;
			coe_dat1_hld_3_12[9:0] <= #DLY coe_dat1_wire_3_12[9:0] ;
			coe_dat1_hld_3_13[9:0] <= #DLY coe_dat1_wire_3_13[9:0] ;
			coe_dat1_hld_3_14[9:0] <= #DLY coe_dat1_wire_3_14[9:0] ;
			coe_dat1_hld_3_15[9:0] <= #DLY coe_dat1_wire_3_15[9:0] ;
			coe_dat1_hld_3_16[9:0] <= #DLY coe_dat1_wire_3_16[9:0] ;
			coe_dat1_hld_3_17[9:0] <= #DLY coe_dat1_wire_3_17[9:0] ;
			coe_dat1_hld_3_18[9:0] <= #DLY coe_dat1_wire_3_18[9:0] ;
			coe_dat1_hld_3_19[9:0] <= #DLY coe_dat1_wire_3_19[9:0] ;
			coe_dat1_hld_3_20[9:0] <= #DLY coe_dat1_wire_3_20[9:0] ;
			coe_dat1_hld_3_21[9:0] <= #DLY coe_dat1_wire_3_21[9:0] ;
			coe_dat1_hld_3_22[9:0] <= #DLY coe_dat1_wire_3_22[9:0] ;
			coe_dat1_hld_3_23[9:0] <= #DLY coe_dat1_wire_3_23[9:0] ;
			coe_dat1_hld_3_24[9:0] <= #DLY coe_dat1_wire_3_24[9:0] ;
			coe_dat1_hld_3_25[9:0] <= #DLY coe_dat1_wire_3_25[9:0] ;
			coe_dat1_hld_3_26[9:0] <= #DLY coe_dat1_wire_3_26[9:0] ;
			coe_dat1_hld_3_27[9:0] <= #DLY coe_dat1_wire_3_27[9:0] ;
			coe_dat1_hld_3_28[9:0] <= #DLY coe_dat1_wire_3_28[9:0] ;
			coe_dat1_hld_3_29[9:0] <= #DLY coe_dat1_wire_3_29[9:0] ;
			coe_dat1_hld_3_30[9:0] <= #DLY coe_dat1_wire_3_30[9:0] ;
			coe_dat1_hld_3_31[9:0] <= #DLY coe_dat1_wire_3_31[9:0] ;
			coe_dat1_hld_3_32[9:0] <= #DLY coe_dat1_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat1_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat1_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat1_hld_4_01[9:0] <= #DLY coe_dat1_wire_4_01[9:0] ;
			coe_dat1_hld_4_02[9:0] <= #DLY coe_dat1_wire_4_02[9:0] ;
			coe_dat1_hld_4_03[9:0] <= #DLY coe_dat1_wire_4_03[9:0] ;
			coe_dat1_hld_4_04[9:0] <= #DLY coe_dat1_wire_4_04[9:0] ;
			coe_dat1_hld_4_05[9:0] <= #DLY coe_dat1_wire_4_05[9:0] ;
			coe_dat1_hld_4_06[9:0] <= #DLY coe_dat1_wire_4_06[9:0] ;
			coe_dat1_hld_4_07[9:0] <= #DLY coe_dat1_wire_4_07[9:0] ;
			coe_dat1_hld_4_08[9:0] <= #DLY coe_dat1_wire_4_08[9:0] ;
			coe_dat1_hld_4_09[9:0] <= #DLY coe_dat1_wire_4_09[9:0] ;
			coe_dat1_hld_4_10[9:0] <= #DLY coe_dat1_wire_4_10[9:0] ;
			coe_dat1_hld_4_11[9:0] <= #DLY coe_dat1_wire_4_11[9:0] ;
			coe_dat1_hld_4_12[9:0] <= #DLY coe_dat1_wire_4_12[9:0] ;
			coe_dat1_hld_4_13[9:0] <= #DLY coe_dat1_wire_4_13[9:0] ;
			coe_dat1_hld_4_14[9:0] <= #DLY coe_dat1_wire_4_14[9:0] ;
			coe_dat1_hld_4_15[9:0] <= #DLY coe_dat1_wire_4_15[9:0] ;
			coe_dat1_hld_4_16[9:0] <= #DLY coe_dat1_wire_4_16[9:0] ;
			coe_dat1_hld_4_17[9:0] <= #DLY coe_dat1_wire_4_17[9:0] ;
			coe_dat1_hld_4_18[9:0] <= #DLY coe_dat1_wire_4_18[9:0] ;
			coe_dat1_hld_4_19[9:0] <= #DLY coe_dat1_wire_4_19[9:0] ;
			coe_dat1_hld_4_20[9:0] <= #DLY coe_dat1_wire_4_20[9:0] ;
			coe_dat1_hld_4_21[9:0] <= #DLY coe_dat1_wire_4_21[9:0] ;
			coe_dat1_hld_4_22[9:0] <= #DLY coe_dat1_wire_4_22[9:0] ;
			coe_dat1_hld_4_23[9:0] <= #DLY coe_dat1_wire_4_23[9:0] ;
			coe_dat1_hld_4_24[9:0] <= #DLY coe_dat1_wire_4_24[9:0] ;
			coe_dat1_hld_4_25[9:0] <= #DLY coe_dat1_wire_4_25[9:0] ;
			coe_dat1_hld_4_26[9:0] <= #DLY coe_dat1_wire_4_26[9:0] ;
			coe_dat1_hld_4_27[9:0] <= #DLY coe_dat1_wire_4_27[9:0] ;
			coe_dat1_hld_4_28[9:0] <= #DLY coe_dat1_wire_4_28[9:0] ;
			coe_dat1_hld_4_29[9:0] <= #DLY coe_dat1_wire_4_29[9:0] ;
			coe_dat1_hld_4_30[9:0] <= #DLY coe_dat1_wire_4_30[9:0] ;
			coe_dat1_hld_4_31[9:0] <= #DLY coe_dat1_wire_4_31[9:0] ;
			coe_dat1_hld_4_32[9:0] <= #DLY coe_dat1_wire_4_32[9:0] ;
		end
	end
//2
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat2_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat2_hld_1_01[9:0] <= #DLY coe_dat2_wire_1_01[9:0] ;
			coe_dat2_hld_1_02[9:0] <= #DLY coe_dat2_wire_1_02[9:0] ;
			coe_dat2_hld_1_03[9:0] <= #DLY coe_dat2_wire_1_03[9:0] ;
			coe_dat2_hld_1_04[9:0] <= #DLY coe_dat2_wire_1_04[9:0] ;
			coe_dat2_hld_1_05[9:0] <= #DLY coe_dat2_wire_1_05[9:0] ;
			coe_dat2_hld_1_06[9:0] <= #DLY coe_dat2_wire_1_06[9:0] ;
			coe_dat2_hld_1_07[9:0] <= #DLY coe_dat2_wire_1_07[9:0] ;
			coe_dat2_hld_1_08[9:0] <= #DLY coe_dat2_wire_1_08[9:0] ;
			coe_dat2_hld_1_09[9:0] <= #DLY coe_dat2_wire_1_09[9:0] ;
			coe_dat2_hld_1_10[9:0] <= #DLY coe_dat2_wire_1_10[9:0] ;
			coe_dat2_hld_1_11[9:0] <= #DLY coe_dat2_wire_1_11[9:0] ;
			coe_dat2_hld_1_12[9:0] <= #DLY coe_dat2_wire_1_12[9:0] ;
			coe_dat2_hld_1_13[9:0] <= #DLY coe_dat2_wire_1_13[9:0] ;
			coe_dat2_hld_1_14[9:0] <= #DLY coe_dat2_wire_1_14[9:0] ;
			coe_dat2_hld_1_15[9:0] <= #DLY coe_dat2_wire_1_15[9:0] ;
			coe_dat2_hld_1_16[9:0] <= #DLY coe_dat2_wire_1_16[9:0] ;
			coe_dat2_hld_1_17[9:0] <= #DLY coe_dat2_wire_1_17[9:0] ;
			coe_dat2_hld_1_18[9:0] <= #DLY coe_dat2_wire_1_18[9:0] ;
			coe_dat2_hld_1_19[9:0] <= #DLY coe_dat2_wire_1_19[9:0] ;
			coe_dat2_hld_1_20[9:0] <= #DLY coe_dat2_wire_1_20[9:0] ;
			coe_dat2_hld_1_21[9:0] <= #DLY coe_dat2_wire_1_21[9:0] ;
			coe_dat2_hld_1_22[9:0] <= #DLY coe_dat2_wire_1_22[9:0] ;
			coe_dat2_hld_1_23[9:0] <= #DLY coe_dat2_wire_1_23[9:0] ;
			coe_dat2_hld_1_24[9:0] <= #DLY coe_dat2_wire_1_24[9:0] ;
			coe_dat2_hld_1_25[9:0] <= #DLY coe_dat2_wire_1_25[9:0] ;
			coe_dat2_hld_1_26[9:0] <= #DLY coe_dat2_wire_1_26[9:0] ;
			coe_dat2_hld_1_27[9:0] <= #DLY coe_dat2_wire_1_27[9:0] ;
			coe_dat2_hld_1_28[9:0] <= #DLY coe_dat2_wire_1_28[9:0] ;
			coe_dat2_hld_1_29[9:0] <= #DLY coe_dat2_wire_1_29[9:0] ;
			coe_dat2_hld_1_30[9:0] <= #DLY coe_dat2_wire_1_30[9:0] ;
			coe_dat2_hld_1_31[9:0] <= #DLY coe_dat2_wire_1_31[9:0] ;
			coe_dat2_hld_1_32[9:0] <= #DLY coe_dat2_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat2_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat2_hld_2_01[9:0] <= #DLY coe_dat2_wire_2_01[9:0] ;
			coe_dat2_hld_2_02[9:0] <= #DLY coe_dat2_wire_2_02[9:0] ;
			coe_dat2_hld_2_03[9:0] <= #DLY coe_dat2_wire_2_03[9:0] ;
			coe_dat2_hld_2_04[9:0] <= #DLY coe_dat2_wire_2_04[9:0] ;
			coe_dat2_hld_2_05[9:0] <= #DLY coe_dat2_wire_2_05[9:0] ;
			coe_dat2_hld_2_06[9:0] <= #DLY coe_dat2_wire_2_06[9:0] ;
			coe_dat2_hld_2_07[9:0] <= #DLY coe_dat2_wire_2_07[9:0] ;
			coe_dat2_hld_2_08[9:0] <= #DLY coe_dat2_wire_2_08[9:0] ;
			coe_dat2_hld_2_09[9:0] <= #DLY coe_dat2_wire_2_09[9:0] ;
			coe_dat2_hld_2_10[9:0] <= #DLY coe_dat2_wire_2_10[9:0] ;
			coe_dat2_hld_2_11[9:0] <= #DLY coe_dat2_wire_2_11[9:0] ;
			coe_dat2_hld_2_12[9:0] <= #DLY coe_dat2_wire_2_12[9:0] ;
			coe_dat2_hld_2_13[9:0] <= #DLY coe_dat2_wire_2_13[9:0] ;
			coe_dat2_hld_2_14[9:0] <= #DLY coe_dat2_wire_2_14[9:0] ;
			coe_dat2_hld_2_15[9:0] <= #DLY coe_dat2_wire_2_15[9:0] ;
			coe_dat2_hld_2_16[9:0] <= #DLY coe_dat2_wire_2_16[9:0] ;
			coe_dat2_hld_2_17[9:0] <= #DLY coe_dat2_wire_2_17[9:0] ;
			coe_dat2_hld_2_18[9:0] <= #DLY coe_dat2_wire_2_18[9:0] ;
			coe_dat2_hld_2_19[9:0] <= #DLY coe_dat2_wire_2_19[9:0] ;
			coe_dat2_hld_2_20[9:0] <= #DLY coe_dat2_wire_2_20[9:0] ;
			coe_dat2_hld_2_21[9:0] <= #DLY coe_dat2_wire_2_21[9:0] ;
			coe_dat2_hld_2_22[9:0] <= #DLY coe_dat2_wire_2_22[9:0] ;
			coe_dat2_hld_2_23[9:0] <= #DLY coe_dat2_wire_2_23[9:0] ;
			coe_dat2_hld_2_24[9:0] <= #DLY coe_dat2_wire_2_24[9:0] ;
			coe_dat2_hld_2_25[9:0] <= #DLY coe_dat2_wire_2_25[9:0] ;
			coe_dat2_hld_2_26[9:0] <= #DLY coe_dat2_wire_2_26[9:0] ;
			coe_dat2_hld_2_27[9:0] <= #DLY coe_dat2_wire_2_27[9:0] ;
			coe_dat2_hld_2_28[9:0] <= #DLY coe_dat2_wire_2_28[9:0] ;
			coe_dat2_hld_2_29[9:0] <= #DLY coe_dat2_wire_2_29[9:0] ;
			coe_dat2_hld_2_30[9:0] <= #DLY coe_dat2_wire_2_30[9:0] ;
			coe_dat2_hld_2_31[9:0] <= #DLY coe_dat2_wire_2_31[9:0] ;
			coe_dat2_hld_2_32[9:0] <= #DLY coe_dat2_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat2_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat2_hld_3_01[9:0] <= #DLY coe_dat2_wire_3_01[9:0] ;
			coe_dat2_hld_3_02[9:0] <= #DLY coe_dat2_wire_3_02[9:0] ;
			coe_dat2_hld_3_03[9:0] <= #DLY coe_dat2_wire_3_03[9:0] ;
			coe_dat2_hld_3_04[9:0] <= #DLY coe_dat2_wire_3_04[9:0] ;
			coe_dat2_hld_3_05[9:0] <= #DLY coe_dat2_wire_3_05[9:0] ;
			coe_dat2_hld_3_06[9:0] <= #DLY coe_dat2_wire_3_06[9:0] ;
			coe_dat2_hld_3_07[9:0] <= #DLY coe_dat2_wire_3_07[9:0] ;
			coe_dat2_hld_3_08[9:0] <= #DLY coe_dat2_wire_3_08[9:0] ;
			coe_dat2_hld_3_09[9:0] <= #DLY coe_dat2_wire_3_09[9:0] ;
			coe_dat2_hld_3_10[9:0] <= #DLY coe_dat2_wire_3_10[9:0] ;
			coe_dat2_hld_3_11[9:0] <= #DLY coe_dat2_wire_3_11[9:0] ;
			coe_dat2_hld_3_12[9:0] <= #DLY coe_dat2_wire_3_12[9:0] ;
			coe_dat2_hld_3_13[9:0] <= #DLY coe_dat2_wire_3_13[9:0] ;
			coe_dat2_hld_3_14[9:0] <= #DLY coe_dat2_wire_3_14[9:0] ;
			coe_dat2_hld_3_15[9:0] <= #DLY coe_dat2_wire_3_15[9:0] ;
			coe_dat2_hld_3_16[9:0] <= #DLY coe_dat2_wire_3_16[9:0] ;
			coe_dat2_hld_3_17[9:0] <= #DLY coe_dat2_wire_3_17[9:0] ;
			coe_dat2_hld_3_18[9:0] <= #DLY coe_dat2_wire_3_18[9:0] ;
			coe_dat2_hld_3_19[9:0] <= #DLY coe_dat2_wire_3_19[9:0] ;
			coe_dat2_hld_3_20[9:0] <= #DLY coe_dat2_wire_3_20[9:0] ;
			coe_dat2_hld_3_21[9:0] <= #DLY coe_dat2_wire_3_21[9:0] ;
			coe_dat2_hld_3_22[9:0] <= #DLY coe_dat2_wire_3_22[9:0] ;
			coe_dat2_hld_3_23[9:0] <= #DLY coe_dat2_wire_3_23[9:0] ;
			coe_dat2_hld_3_24[9:0] <= #DLY coe_dat2_wire_3_24[9:0] ;
			coe_dat2_hld_3_25[9:0] <= #DLY coe_dat2_wire_3_25[9:0] ;
			coe_dat2_hld_3_26[9:0] <= #DLY coe_dat2_wire_3_26[9:0] ;
			coe_dat2_hld_3_27[9:0] <= #DLY coe_dat2_wire_3_27[9:0] ;
			coe_dat2_hld_3_28[9:0] <= #DLY coe_dat2_wire_3_28[9:0] ;
			coe_dat2_hld_3_29[9:0] <= #DLY coe_dat2_wire_3_29[9:0] ;
			coe_dat2_hld_3_30[9:0] <= #DLY coe_dat2_wire_3_30[9:0] ;
			coe_dat2_hld_3_31[9:0] <= #DLY coe_dat2_wire_3_31[9:0] ;
			coe_dat2_hld_3_32[9:0] <= #DLY coe_dat2_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat2_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat2_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if (pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat2_hld_4_01[9:0] <= #DLY coe_dat2_wire_4_01[9:0] ;
			coe_dat2_hld_4_02[9:0] <= #DLY coe_dat2_wire_4_02[9:0] ;
			coe_dat2_hld_4_03[9:0] <= #DLY coe_dat2_wire_4_03[9:0] ;
			coe_dat2_hld_4_04[9:0] <= #DLY coe_dat2_wire_4_04[9:0] ;
			coe_dat2_hld_4_05[9:0] <= #DLY coe_dat2_wire_4_05[9:0] ;
			coe_dat2_hld_4_06[9:0] <= #DLY coe_dat2_wire_4_06[9:0] ;
			coe_dat2_hld_4_07[9:0] <= #DLY coe_dat2_wire_4_07[9:0] ;
			coe_dat2_hld_4_08[9:0] <= #DLY coe_dat2_wire_4_08[9:0] ;
			coe_dat2_hld_4_09[9:0] <= #DLY coe_dat2_wire_4_09[9:0] ;
			coe_dat2_hld_4_10[9:0] <= #DLY coe_dat2_wire_4_10[9:0] ;
			coe_dat2_hld_4_11[9:0] <= #DLY coe_dat2_wire_4_11[9:0] ;
			coe_dat2_hld_4_12[9:0] <= #DLY coe_dat2_wire_4_12[9:0] ;
			coe_dat2_hld_4_13[9:0] <= #DLY coe_dat2_wire_4_13[9:0] ;
			coe_dat2_hld_4_14[9:0] <= #DLY coe_dat2_wire_4_14[9:0] ;
			coe_dat2_hld_4_15[9:0] <= #DLY coe_dat2_wire_4_15[9:0] ;
			coe_dat2_hld_4_16[9:0] <= #DLY coe_dat2_wire_4_16[9:0] ;
			coe_dat2_hld_4_17[9:0] <= #DLY coe_dat2_wire_4_17[9:0] ;
			coe_dat2_hld_4_18[9:0] <= #DLY coe_dat2_wire_4_18[9:0] ;
			coe_dat2_hld_4_19[9:0] <= #DLY coe_dat2_wire_4_19[9:0] ;
			coe_dat2_hld_4_20[9:0] <= #DLY coe_dat2_wire_4_20[9:0] ;
			coe_dat2_hld_4_21[9:0] <= #DLY coe_dat2_wire_4_21[9:0] ;
			coe_dat2_hld_4_22[9:0] <= #DLY coe_dat2_wire_4_22[9:0] ;
			coe_dat2_hld_4_23[9:0] <= #DLY coe_dat2_wire_4_23[9:0] ;
			coe_dat2_hld_4_24[9:0] <= #DLY coe_dat2_wire_4_24[9:0] ;
			coe_dat2_hld_4_25[9:0] <= #DLY coe_dat2_wire_4_25[9:0] ;
			coe_dat2_hld_4_26[9:0] <= #DLY coe_dat2_wire_4_26[9:0] ;
			coe_dat2_hld_4_27[9:0] <= #DLY coe_dat2_wire_4_27[9:0] ;
			coe_dat2_hld_4_28[9:0] <= #DLY coe_dat2_wire_4_28[9:0] ;
			coe_dat2_hld_4_29[9:0] <= #DLY coe_dat2_wire_4_29[9:0] ;
			coe_dat2_hld_4_30[9:0] <= #DLY coe_dat2_wire_4_30[9:0] ;
			coe_dat2_hld_4_31[9:0] <= #DLY coe_dat2_wire_4_31[9:0] ;
			coe_dat2_hld_4_32[9:0] <= #DLY coe_dat2_wire_4_32[9:0] ;
		end
	end
//3
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat3_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat3_hld_1_01[9:0] <= #DLY coe_dat3_wire_1_01[9:0] ;
			coe_dat3_hld_1_02[9:0] <= #DLY coe_dat3_wire_1_02[9:0] ;
			coe_dat3_hld_1_03[9:0] <= #DLY coe_dat3_wire_1_03[9:0] ;
			coe_dat3_hld_1_04[9:0] <= #DLY coe_dat3_wire_1_04[9:0] ;
			coe_dat3_hld_1_05[9:0] <= #DLY coe_dat3_wire_1_05[9:0] ;
			coe_dat3_hld_1_06[9:0] <= #DLY coe_dat3_wire_1_06[9:0] ;
			coe_dat3_hld_1_07[9:0] <= #DLY coe_dat3_wire_1_07[9:0] ;
			coe_dat3_hld_1_08[9:0] <= #DLY coe_dat3_wire_1_08[9:0] ;
			coe_dat3_hld_1_09[9:0] <= #DLY coe_dat3_wire_1_09[9:0] ;
			coe_dat3_hld_1_10[9:0] <= #DLY coe_dat3_wire_1_10[9:0] ;
			coe_dat3_hld_1_11[9:0] <= #DLY coe_dat3_wire_1_11[9:0] ;
			coe_dat3_hld_1_12[9:0] <= #DLY coe_dat3_wire_1_12[9:0] ;
			coe_dat3_hld_1_13[9:0] <= #DLY coe_dat3_wire_1_13[9:0] ;
			coe_dat3_hld_1_14[9:0] <= #DLY coe_dat3_wire_1_14[9:0] ;
			coe_dat3_hld_1_15[9:0] <= #DLY coe_dat3_wire_1_15[9:0] ;
			coe_dat3_hld_1_16[9:0] <= #DLY coe_dat3_wire_1_16[9:0] ;
			coe_dat3_hld_1_17[9:0] <= #DLY coe_dat3_wire_1_17[9:0] ;
			coe_dat3_hld_1_18[9:0] <= #DLY coe_dat3_wire_1_18[9:0] ;
			coe_dat3_hld_1_19[9:0] <= #DLY coe_dat3_wire_1_19[9:0] ;
			coe_dat3_hld_1_20[9:0] <= #DLY coe_dat3_wire_1_20[9:0] ;
			coe_dat3_hld_1_21[9:0] <= #DLY coe_dat3_wire_1_21[9:0] ;
			coe_dat3_hld_1_22[9:0] <= #DLY coe_dat3_wire_1_22[9:0] ;
			coe_dat3_hld_1_23[9:0] <= #DLY coe_dat3_wire_1_23[9:0] ;
			coe_dat3_hld_1_24[9:0] <= #DLY coe_dat3_wire_1_24[9:0] ;
			coe_dat3_hld_1_25[9:0] <= #DLY coe_dat3_wire_1_25[9:0] ;
			coe_dat3_hld_1_26[9:0] <= #DLY coe_dat3_wire_1_26[9:0] ;
			coe_dat3_hld_1_27[9:0] <= #DLY coe_dat3_wire_1_27[9:0] ;
			coe_dat3_hld_1_28[9:0] <= #DLY coe_dat3_wire_1_28[9:0] ;
			coe_dat3_hld_1_29[9:0] <= #DLY coe_dat3_wire_1_29[9:0] ;
			coe_dat3_hld_1_30[9:0] <= #DLY coe_dat3_wire_1_30[9:0] ;
			coe_dat3_hld_1_31[9:0] <= #DLY coe_dat3_wire_1_31[9:0] ;
			coe_dat3_hld_1_32[9:0] <= #DLY coe_dat3_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat3_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat3_hld_2_01[9:0] <= #DLY coe_dat3_wire_2_01[9:0] ;
			coe_dat3_hld_2_02[9:0] <= #DLY coe_dat3_wire_2_02[9:0] ;
			coe_dat3_hld_2_03[9:0] <= #DLY coe_dat3_wire_2_03[9:0] ;
			coe_dat3_hld_2_04[9:0] <= #DLY coe_dat3_wire_2_04[9:0] ;
			coe_dat3_hld_2_05[9:0] <= #DLY coe_dat3_wire_2_05[9:0] ;
			coe_dat3_hld_2_06[9:0] <= #DLY coe_dat3_wire_2_06[9:0] ;
			coe_dat3_hld_2_07[9:0] <= #DLY coe_dat3_wire_2_07[9:0] ;
			coe_dat3_hld_2_08[9:0] <= #DLY coe_dat3_wire_2_08[9:0] ;
			coe_dat3_hld_2_09[9:0] <= #DLY coe_dat3_wire_2_09[9:0] ;
			coe_dat3_hld_2_10[9:0] <= #DLY coe_dat3_wire_2_10[9:0] ;
			coe_dat3_hld_2_11[9:0] <= #DLY coe_dat3_wire_2_11[9:0] ;
			coe_dat3_hld_2_12[9:0] <= #DLY coe_dat3_wire_2_12[9:0] ;
			coe_dat3_hld_2_13[9:0] <= #DLY coe_dat3_wire_2_13[9:0] ;
			coe_dat3_hld_2_14[9:0] <= #DLY coe_dat3_wire_2_14[9:0] ;
			coe_dat3_hld_2_15[9:0] <= #DLY coe_dat3_wire_2_15[9:0] ;
			coe_dat3_hld_2_16[9:0] <= #DLY coe_dat3_wire_2_16[9:0] ;
			coe_dat3_hld_2_17[9:0] <= #DLY coe_dat3_wire_2_17[9:0] ;
			coe_dat3_hld_2_18[9:0] <= #DLY coe_dat3_wire_2_18[9:0] ;
			coe_dat3_hld_2_19[9:0] <= #DLY coe_dat3_wire_2_19[9:0] ;
			coe_dat3_hld_2_20[9:0] <= #DLY coe_dat3_wire_2_20[9:0] ;
			coe_dat3_hld_2_21[9:0] <= #DLY coe_dat3_wire_2_21[9:0] ;
			coe_dat3_hld_2_22[9:0] <= #DLY coe_dat3_wire_2_22[9:0] ;
			coe_dat3_hld_2_23[9:0] <= #DLY coe_dat3_wire_2_23[9:0] ;
			coe_dat3_hld_2_24[9:0] <= #DLY coe_dat3_wire_2_24[9:0] ;
			coe_dat3_hld_2_25[9:0] <= #DLY coe_dat3_wire_2_25[9:0] ;
			coe_dat3_hld_2_26[9:0] <= #DLY coe_dat3_wire_2_26[9:0] ;
			coe_dat3_hld_2_27[9:0] <= #DLY coe_dat3_wire_2_27[9:0] ;
			coe_dat3_hld_2_28[9:0] <= #DLY coe_dat3_wire_2_28[9:0] ;
			coe_dat3_hld_2_29[9:0] <= #DLY coe_dat3_wire_2_29[9:0] ;
			coe_dat3_hld_2_30[9:0] <= #DLY coe_dat3_wire_2_30[9:0] ;
			coe_dat3_hld_2_31[9:0] <= #DLY coe_dat3_wire_2_31[9:0] ;
			coe_dat3_hld_2_32[9:0] <= #DLY coe_dat3_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat3_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat3_hld_3_01[9:0] <= #DLY coe_dat3_wire_3_01[9:0] ;
			coe_dat3_hld_3_02[9:0] <= #DLY coe_dat3_wire_3_02[9:0] ;
			coe_dat3_hld_3_03[9:0] <= #DLY coe_dat3_wire_3_03[9:0] ;
			coe_dat3_hld_3_04[9:0] <= #DLY coe_dat3_wire_3_04[9:0] ;
			coe_dat3_hld_3_05[9:0] <= #DLY coe_dat3_wire_3_05[9:0] ;
			coe_dat3_hld_3_06[9:0] <= #DLY coe_dat3_wire_3_06[9:0] ;
			coe_dat3_hld_3_07[9:0] <= #DLY coe_dat3_wire_3_07[9:0] ;
			coe_dat3_hld_3_08[9:0] <= #DLY coe_dat3_wire_3_08[9:0] ;
			coe_dat3_hld_3_09[9:0] <= #DLY coe_dat3_wire_3_09[9:0] ;
			coe_dat3_hld_3_10[9:0] <= #DLY coe_dat3_wire_3_10[9:0] ;
			coe_dat3_hld_3_11[9:0] <= #DLY coe_dat3_wire_3_11[9:0] ;
			coe_dat3_hld_3_12[9:0] <= #DLY coe_dat3_wire_3_12[9:0] ;
			coe_dat3_hld_3_13[9:0] <= #DLY coe_dat3_wire_3_13[9:0] ;
			coe_dat3_hld_3_14[9:0] <= #DLY coe_dat3_wire_3_14[9:0] ;
			coe_dat3_hld_3_15[9:0] <= #DLY coe_dat3_wire_3_15[9:0] ;
			coe_dat3_hld_3_16[9:0] <= #DLY coe_dat3_wire_3_16[9:0] ;
			coe_dat3_hld_3_17[9:0] <= #DLY coe_dat3_wire_3_17[9:0] ;
			coe_dat3_hld_3_18[9:0] <= #DLY coe_dat3_wire_3_18[9:0] ;
			coe_dat3_hld_3_19[9:0] <= #DLY coe_dat3_wire_3_19[9:0] ;
			coe_dat3_hld_3_20[9:0] <= #DLY coe_dat3_wire_3_20[9:0] ;
			coe_dat3_hld_3_21[9:0] <= #DLY coe_dat3_wire_3_21[9:0] ;
			coe_dat3_hld_3_22[9:0] <= #DLY coe_dat3_wire_3_22[9:0] ;
			coe_dat3_hld_3_23[9:0] <= #DLY coe_dat3_wire_3_23[9:0] ;
			coe_dat3_hld_3_24[9:0] <= #DLY coe_dat3_wire_3_24[9:0] ;
			coe_dat3_hld_3_25[9:0] <= #DLY coe_dat3_wire_3_25[9:0] ;
			coe_dat3_hld_3_26[9:0] <= #DLY coe_dat3_wire_3_26[9:0] ;
			coe_dat3_hld_3_27[9:0] <= #DLY coe_dat3_wire_3_27[9:0] ;
			coe_dat3_hld_3_28[9:0] <= #DLY coe_dat3_wire_3_28[9:0] ;
			coe_dat3_hld_3_29[9:0] <= #DLY coe_dat3_wire_3_29[9:0] ;
			coe_dat3_hld_3_30[9:0] <= #DLY coe_dat3_wire_3_30[9:0] ;
			coe_dat3_hld_3_31[9:0] <= #DLY coe_dat3_wire_3_31[9:0] ;
			coe_dat3_hld_3_32[9:0] <= #DLY coe_dat3_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat3_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat3_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat3_hld_4_01[9:0] <= #DLY coe_dat3_wire_4_01[9:0] ;
			coe_dat3_hld_4_02[9:0] <= #DLY coe_dat3_wire_4_02[9:0] ;
			coe_dat3_hld_4_03[9:0] <= #DLY coe_dat3_wire_4_03[9:0] ;
			coe_dat3_hld_4_04[9:0] <= #DLY coe_dat3_wire_4_04[9:0] ;
			coe_dat3_hld_4_05[9:0] <= #DLY coe_dat3_wire_4_05[9:0] ;
			coe_dat3_hld_4_06[9:0] <= #DLY coe_dat3_wire_4_06[9:0] ;
			coe_dat3_hld_4_07[9:0] <= #DLY coe_dat3_wire_4_07[9:0] ;
			coe_dat3_hld_4_08[9:0] <= #DLY coe_dat3_wire_4_08[9:0] ;
			coe_dat3_hld_4_09[9:0] <= #DLY coe_dat3_wire_4_09[9:0] ;
			coe_dat3_hld_4_10[9:0] <= #DLY coe_dat3_wire_4_10[9:0] ;
			coe_dat3_hld_4_11[9:0] <= #DLY coe_dat3_wire_4_11[9:0] ;
			coe_dat3_hld_4_12[9:0] <= #DLY coe_dat3_wire_4_12[9:0] ;
			coe_dat3_hld_4_13[9:0] <= #DLY coe_dat3_wire_4_13[9:0] ;
			coe_dat3_hld_4_14[9:0] <= #DLY coe_dat3_wire_4_14[9:0] ;
			coe_dat3_hld_4_15[9:0] <= #DLY coe_dat3_wire_4_15[9:0] ;
			coe_dat3_hld_4_16[9:0] <= #DLY coe_dat3_wire_4_16[9:0] ;
			coe_dat3_hld_4_17[9:0] <= #DLY coe_dat3_wire_4_17[9:0] ;
			coe_dat3_hld_4_18[9:0] <= #DLY coe_dat3_wire_4_18[9:0] ;
			coe_dat3_hld_4_19[9:0] <= #DLY coe_dat3_wire_4_19[9:0] ;
			coe_dat3_hld_4_20[9:0] <= #DLY coe_dat3_wire_4_20[9:0] ;
			coe_dat3_hld_4_21[9:0] <= #DLY coe_dat3_wire_4_21[9:0] ;
			coe_dat3_hld_4_22[9:0] <= #DLY coe_dat3_wire_4_22[9:0] ;
			coe_dat3_hld_4_23[9:0] <= #DLY coe_dat3_wire_4_23[9:0] ;
			coe_dat3_hld_4_24[9:0] <= #DLY coe_dat3_wire_4_24[9:0] ;
			coe_dat3_hld_4_25[9:0] <= #DLY coe_dat3_wire_4_25[9:0] ;
			coe_dat3_hld_4_26[9:0] <= #DLY coe_dat3_wire_4_26[9:0] ;
			coe_dat3_hld_4_27[9:0] <= #DLY coe_dat3_wire_4_27[9:0] ;
			coe_dat3_hld_4_28[9:0] <= #DLY coe_dat3_wire_4_28[9:0] ;
			coe_dat3_hld_4_29[9:0] <= #DLY coe_dat3_wire_4_29[9:0] ;
			coe_dat3_hld_4_30[9:0] <= #DLY coe_dat3_wire_4_30[9:0] ;
			coe_dat3_hld_4_31[9:0] <= #DLY coe_dat3_wire_4_31[9:0] ;
			coe_dat3_hld_4_32[9:0] <= #DLY coe_dat3_wire_4_32[9:0] ;
		end
	end
//4
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat4_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat4_hld_1_01[9:0] <= #DLY coe_dat4_wire_1_01[9:0] ;
			coe_dat4_hld_1_02[9:0] <= #DLY coe_dat4_wire_1_02[9:0] ;
			coe_dat4_hld_1_03[9:0] <= #DLY coe_dat4_wire_1_03[9:0] ;
			coe_dat4_hld_1_04[9:0] <= #DLY coe_dat4_wire_1_04[9:0] ;
			coe_dat4_hld_1_05[9:0] <= #DLY coe_dat4_wire_1_05[9:0] ;
			coe_dat4_hld_1_06[9:0] <= #DLY coe_dat4_wire_1_06[9:0] ;
			coe_dat4_hld_1_07[9:0] <= #DLY coe_dat4_wire_1_07[9:0] ;
			coe_dat4_hld_1_08[9:0] <= #DLY coe_dat4_wire_1_08[9:0] ;
			coe_dat4_hld_1_09[9:0] <= #DLY coe_dat4_wire_1_09[9:0] ;
			coe_dat4_hld_1_10[9:0] <= #DLY coe_dat4_wire_1_10[9:0] ;
			coe_dat4_hld_1_11[9:0] <= #DLY coe_dat4_wire_1_11[9:0] ;
			coe_dat4_hld_1_12[9:0] <= #DLY coe_dat4_wire_1_12[9:0] ;
			coe_dat4_hld_1_13[9:0] <= #DLY coe_dat4_wire_1_13[9:0] ;
			coe_dat4_hld_1_14[9:0] <= #DLY coe_dat4_wire_1_14[9:0] ;
			coe_dat4_hld_1_15[9:0] <= #DLY coe_dat4_wire_1_15[9:0] ;
			coe_dat4_hld_1_16[9:0] <= #DLY coe_dat4_wire_1_16[9:0] ;
			coe_dat4_hld_1_17[9:0] <= #DLY coe_dat4_wire_1_17[9:0] ;
			coe_dat4_hld_1_18[9:0] <= #DLY coe_dat4_wire_1_18[9:0] ;
			coe_dat4_hld_1_19[9:0] <= #DLY coe_dat4_wire_1_19[9:0] ;
			coe_dat4_hld_1_20[9:0] <= #DLY coe_dat4_wire_1_20[9:0] ;
			coe_dat4_hld_1_21[9:0] <= #DLY coe_dat4_wire_1_21[9:0] ;
			coe_dat4_hld_1_22[9:0] <= #DLY coe_dat4_wire_1_22[9:0] ;
			coe_dat4_hld_1_23[9:0] <= #DLY coe_dat4_wire_1_23[9:0] ;
			coe_dat4_hld_1_24[9:0] <= #DLY coe_dat4_wire_1_24[9:0] ;
			coe_dat4_hld_1_25[9:0] <= #DLY coe_dat4_wire_1_25[9:0] ;
			coe_dat4_hld_1_26[9:0] <= #DLY coe_dat4_wire_1_26[9:0] ;
			coe_dat4_hld_1_27[9:0] <= #DLY coe_dat4_wire_1_27[9:0] ;
			coe_dat4_hld_1_28[9:0] <= #DLY coe_dat4_wire_1_28[9:0] ;
			coe_dat4_hld_1_29[9:0] <= #DLY coe_dat4_wire_1_29[9:0] ;
			coe_dat4_hld_1_30[9:0] <= #DLY coe_dat4_wire_1_30[9:0] ;
			coe_dat4_hld_1_31[9:0] <= #DLY coe_dat4_wire_1_31[9:0] ;
			coe_dat4_hld_1_32[9:0] <= #DLY coe_dat4_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat4_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat4_hld_2_01[9:0] <= #DLY coe_dat4_wire_2_01[9:0] ;
			coe_dat4_hld_2_02[9:0] <= #DLY coe_dat4_wire_2_02[9:0] ;
			coe_dat4_hld_2_03[9:0] <= #DLY coe_dat4_wire_2_03[9:0] ;
			coe_dat4_hld_2_04[9:0] <= #DLY coe_dat4_wire_2_04[9:0] ;
			coe_dat4_hld_2_05[9:0] <= #DLY coe_dat4_wire_2_05[9:0] ;
			coe_dat4_hld_2_06[9:0] <= #DLY coe_dat4_wire_2_06[9:0] ;
			coe_dat4_hld_2_07[9:0] <= #DLY coe_dat4_wire_2_07[9:0] ;
			coe_dat4_hld_2_08[9:0] <= #DLY coe_dat4_wire_2_08[9:0] ;
			coe_dat4_hld_2_09[9:0] <= #DLY coe_dat4_wire_2_09[9:0] ;
			coe_dat4_hld_2_10[9:0] <= #DLY coe_dat4_wire_2_10[9:0] ;
			coe_dat4_hld_2_11[9:0] <= #DLY coe_dat4_wire_2_11[9:0] ;
			coe_dat4_hld_2_12[9:0] <= #DLY coe_dat4_wire_2_12[9:0] ;
			coe_dat4_hld_2_13[9:0] <= #DLY coe_dat4_wire_2_13[9:0] ;
			coe_dat4_hld_2_14[9:0] <= #DLY coe_dat4_wire_2_14[9:0] ;
			coe_dat4_hld_2_15[9:0] <= #DLY coe_dat4_wire_2_15[9:0] ;
			coe_dat4_hld_2_16[9:0] <= #DLY coe_dat4_wire_2_16[9:0] ;
			coe_dat4_hld_2_17[9:0] <= #DLY coe_dat4_wire_2_17[9:0] ;
			coe_dat4_hld_2_18[9:0] <= #DLY coe_dat4_wire_2_18[9:0] ;
			coe_dat4_hld_2_19[9:0] <= #DLY coe_dat4_wire_2_19[9:0] ;
			coe_dat4_hld_2_20[9:0] <= #DLY coe_dat4_wire_2_20[9:0] ;
			coe_dat4_hld_2_21[9:0] <= #DLY coe_dat4_wire_2_21[9:0] ;
			coe_dat4_hld_2_22[9:0] <= #DLY coe_dat4_wire_2_22[9:0] ;
			coe_dat4_hld_2_23[9:0] <= #DLY coe_dat4_wire_2_23[9:0] ;
			coe_dat4_hld_2_24[9:0] <= #DLY coe_dat4_wire_2_24[9:0] ;
			coe_dat4_hld_2_25[9:0] <= #DLY coe_dat4_wire_2_25[9:0] ;
			coe_dat4_hld_2_26[9:0] <= #DLY coe_dat4_wire_2_26[9:0] ;
			coe_dat4_hld_2_27[9:0] <= #DLY coe_dat4_wire_2_27[9:0] ;
			coe_dat4_hld_2_28[9:0] <= #DLY coe_dat4_wire_2_28[9:0] ;
			coe_dat4_hld_2_29[9:0] <= #DLY coe_dat4_wire_2_29[9:0] ;
			coe_dat4_hld_2_30[9:0] <= #DLY coe_dat4_wire_2_30[9:0] ;
			coe_dat4_hld_2_31[9:0] <= #DLY coe_dat4_wire_2_31[9:0] ;
			coe_dat4_hld_2_32[9:0] <= #DLY coe_dat4_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat4_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat4_hld_3_01[9:0] <= #DLY coe_dat4_wire_3_01[9:0] ;
			coe_dat4_hld_3_02[9:0] <= #DLY coe_dat4_wire_3_02[9:0] ;
			coe_dat4_hld_3_03[9:0] <= #DLY coe_dat4_wire_3_03[9:0] ;
			coe_dat4_hld_3_04[9:0] <= #DLY coe_dat4_wire_3_04[9:0] ;
			coe_dat4_hld_3_05[9:0] <= #DLY coe_dat4_wire_3_05[9:0] ;
			coe_dat4_hld_3_06[9:0] <= #DLY coe_dat4_wire_3_06[9:0] ;
			coe_dat4_hld_3_07[9:0] <= #DLY coe_dat4_wire_3_07[9:0] ;
			coe_dat4_hld_3_08[9:0] <= #DLY coe_dat4_wire_3_08[9:0] ;
			coe_dat4_hld_3_09[9:0] <= #DLY coe_dat4_wire_3_09[9:0] ;
			coe_dat4_hld_3_10[9:0] <= #DLY coe_dat4_wire_3_10[9:0] ;
			coe_dat4_hld_3_11[9:0] <= #DLY coe_dat4_wire_3_11[9:0] ;
			coe_dat4_hld_3_12[9:0] <= #DLY coe_dat4_wire_3_12[9:0] ;
			coe_dat4_hld_3_13[9:0] <= #DLY coe_dat4_wire_3_13[9:0] ;
			coe_dat4_hld_3_14[9:0] <= #DLY coe_dat4_wire_3_14[9:0] ;
			coe_dat4_hld_3_15[9:0] <= #DLY coe_dat4_wire_3_15[9:0] ;
			coe_dat4_hld_3_16[9:0] <= #DLY coe_dat4_wire_3_16[9:0] ;
			coe_dat4_hld_3_17[9:0] <= #DLY coe_dat4_wire_3_17[9:0] ;
			coe_dat4_hld_3_18[9:0] <= #DLY coe_dat4_wire_3_18[9:0] ;
			coe_dat4_hld_3_19[9:0] <= #DLY coe_dat4_wire_3_19[9:0] ;
			coe_dat4_hld_3_20[9:0] <= #DLY coe_dat4_wire_3_20[9:0] ;
			coe_dat4_hld_3_21[9:0] <= #DLY coe_dat4_wire_3_21[9:0] ;
			coe_dat4_hld_3_22[9:0] <= #DLY coe_dat4_wire_3_22[9:0] ;
			coe_dat4_hld_3_23[9:0] <= #DLY coe_dat4_wire_3_23[9:0] ;
			coe_dat4_hld_3_24[9:0] <= #DLY coe_dat4_wire_3_24[9:0] ;
			coe_dat4_hld_3_25[9:0] <= #DLY coe_dat4_wire_3_25[9:0] ;
			coe_dat4_hld_3_26[9:0] <= #DLY coe_dat4_wire_3_26[9:0] ;
			coe_dat4_hld_3_27[9:0] <= #DLY coe_dat4_wire_3_27[9:0] ;
			coe_dat4_hld_3_28[9:0] <= #DLY coe_dat4_wire_3_28[9:0] ;
			coe_dat4_hld_3_29[9:0] <= #DLY coe_dat4_wire_3_29[9:0] ;
			coe_dat4_hld_3_30[9:0] <= #DLY coe_dat4_wire_3_30[9:0] ;
			coe_dat4_hld_3_31[9:0] <= #DLY coe_dat4_wire_3_31[9:0] ;
			coe_dat4_hld_3_32[9:0] <= #DLY coe_dat4_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat4_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat4_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat4_hld_4_01[9:0] <= #DLY coe_dat4_wire_4_01[9:0] ;
			coe_dat4_hld_4_02[9:0] <= #DLY coe_dat4_wire_4_02[9:0] ;
			coe_dat4_hld_4_03[9:0] <= #DLY coe_dat4_wire_4_03[9:0] ;
			coe_dat4_hld_4_04[9:0] <= #DLY coe_dat4_wire_4_04[9:0] ;
			coe_dat4_hld_4_05[9:0] <= #DLY coe_dat4_wire_4_05[9:0] ;
			coe_dat4_hld_4_06[9:0] <= #DLY coe_dat4_wire_4_06[9:0] ;
			coe_dat4_hld_4_07[9:0] <= #DLY coe_dat4_wire_4_07[9:0] ;
			coe_dat4_hld_4_08[9:0] <= #DLY coe_dat4_wire_4_08[9:0] ;
			coe_dat4_hld_4_09[9:0] <= #DLY coe_dat4_wire_4_09[9:0] ;
			coe_dat4_hld_4_10[9:0] <= #DLY coe_dat4_wire_4_10[9:0] ;
			coe_dat4_hld_4_11[9:0] <= #DLY coe_dat4_wire_4_11[9:0] ;
			coe_dat4_hld_4_12[9:0] <= #DLY coe_dat4_wire_4_12[9:0] ;
			coe_dat4_hld_4_13[9:0] <= #DLY coe_dat4_wire_4_13[9:0] ;
			coe_dat4_hld_4_14[9:0] <= #DLY coe_dat4_wire_4_14[9:0] ;
			coe_dat4_hld_4_15[9:0] <= #DLY coe_dat4_wire_4_15[9:0] ;
			coe_dat4_hld_4_16[9:0] <= #DLY coe_dat4_wire_4_16[9:0] ;
			coe_dat4_hld_4_17[9:0] <= #DLY coe_dat4_wire_4_17[9:0] ;
			coe_dat4_hld_4_18[9:0] <= #DLY coe_dat4_wire_4_18[9:0] ;
			coe_dat4_hld_4_19[9:0] <= #DLY coe_dat4_wire_4_19[9:0] ;
			coe_dat4_hld_4_20[9:0] <= #DLY coe_dat4_wire_4_20[9:0] ;
			coe_dat4_hld_4_21[9:0] <= #DLY coe_dat4_wire_4_21[9:0] ;
			coe_dat4_hld_4_22[9:0] <= #DLY coe_dat4_wire_4_22[9:0] ;
			coe_dat4_hld_4_23[9:0] <= #DLY coe_dat4_wire_4_23[9:0] ;
			coe_dat4_hld_4_24[9:0] <= #DLY coe_dat4_wire_4_24[9:0] ;
			coe_dat4_hld_4_25[9:0] <= #DLY coe_dat4_wire_4_25[9:0] ;
			coe_dat4_hld_4_26[9:0] <= #DLY coe_dat4_wire_4_26[9:0] ;
			coe_dat4_hld_4_27[9:0] <= #DLY coe_dat4_wire_4_27[9:0] ;
			coe_dat4_hld_4_28[9:0] <= #DLY coe_dat4_wire_4_28[9:0] ;
			coe_dat4_hld_4_29[9:0] <= #DLY coe_dat4_wire_4_29[9:0] ;
			coe_dat4_hld_4_30[9:0] <= #DLY coe_dat4_wire_4_30[9:0] ;
			coe_dat4_hld_4_31[9:0] <= #DLY coe_dat4_wire_4_31[9:0] ;
			coe_dat4_hld_4_32[9:0] <= #DLY coe_dat4_wire_4_32[9:0] ;
		end
	end
//5
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat5_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat5_hld_1_01[9:0] <= #DLY coe_dat5_wire_1_01[9:0] ;
			coe_dat5_hld_1_02[9:0] <= #DLY coe_dat5_wire_1_02[9:0] ;
			coe_dat5_hld_1_03[9:0] <= #DLY coe_dat5_wire_1_03[9:0] ;
			coe_dat5_hld_1_04[9:0] <= #DLY coe_dat5_wire_1_04[9:0] ;
			coe_dat5_hld_1_05[9:0] <= #DLY coe_dat5_wire_1_05[9:0] ;
			coe_dat5_hld_1_06[9:0] <= #DLY coe_dat5_wire_1_06[9:0] ;
			coe_dat5_hld_1_07[9:0] <= #DLY coe_dat5_wire_1_07[9:0] ;
			coe_dat5_hld_1_08[9:0] <= #DLY coe_dat5_wire_1_08[9:0] ;
			coe_dat5_hld_1_09[9:0] <= #DLY coe_dat5_wire_1_09[9:0] ;
			coe_dat5_hld_1_10[9:0] <= #DLY coe_dat5_wire_1_10[9:0] ;
			coe_dat5_hld_1_11[9:0] <= #DLY coe_dat5_wire_1_11[9:0] ;
			coe_dat5_hld_1_12[9:0] <= #DLY coe_dat5_wire_1_12[9:0] ;
			coe_dat5_hld_1_13[9:0] <= #DLY coe_dat5_wire_1_13[9:0] ;
			coe_dat5_hld_1_14[9:0] <= #DLY coe_dat5_wire_1_14[9:0] ;
			coe_dat5_hld_1_15[9:0] <= #DLY coe_dat5_wire_1_15[9:0] ;
			coe_dat5_hld_1_16[9:0] <= #DLY coe_dat5_wire_1_16[9:0] ;
			coe_dat5_hld_1_17[9:0] <= #DLY coe_dat5_wire_1_17[9:0] ;
			coe_dat5_hld_1_18[9:0] <= #DLY coe_dat5_wire_1_18[9:0] ;
			coe_dat5_hld_1_19[9:0] <= #DLY coe_dat5_wire_1_19[9:0] ;
			coe_dat5_hld_1_20[9:0] <= #DLY coe_dat5_wire_1_20[9:0] ;
			coe_dat5_hld_1_21[9:0] <= #DLY coe_dat5_wire_1_21[9:0] ;
			coe_dat5_hld_1_22[9:0] <= #DLY coe_dat5_wire_1_22[9:0] ;
			coe_dat5_hld_1_23[9:0] <= #DLY coe_dat5_wire_1_23[9:0] ;
			coe_dat5_hld_1_24[9:0] <= #DLY coe_dat5_wire_1_24[9:0] ;
			coe_dat5_hld_1_25[9:0] <= #DLY coe_dat5_wire_1_25[9:0] ;
			coe_dat5_hld_1_26[9:0] <= #DLY coe_dat5_wire_1_26[9:0] ;
			coe_dat5_hld_1_27[9:0] <= #DLY coe_dat5_wire_1_27[9:0] ;
			coe_dat5_hld_1_28[9:0] <= #DLY coe_dat5_wire_1_28[9:0] ;
			coe_dat5_hld_1_29[9:0] <= #DLY coe_dat5_wire_1_29[9:0] ;
			coe_dat5_hld_1_30[9:0] <= #DLY coe_dat5_wire_1_30[9:0] ;
			coe_dat5_hld_1_31[9:0] <= #DLY coe_dat5_wire_1_31[9:0] ;
			coe_dat5_hld_1_32[9:0] <= #DLY coe_dat5_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat5_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat5_hld_2_01[9:0] <= #DLY coe_dat5_wire_2_01[9:0] ;
			coe_dat5_hld_2_02[9:0] <= #DLY coe_dat5_wire_2_02[9:0] ;
			coe_dat5_hld_2_03[9:0] <= #DLY coe_dat5_wire_2_03[9:0] ;
			coe_dat5_hld_2_04[9:0] <= #DLY coe_dat5_wire_2_04[9:0] ;
			coe_dat5_hld_2_05[9:0] <= #DLY coe_dat5_wire_2_05[9:0] ;
			coe_dat5_hld_2_06[9:0] <= #DLY coe_dat5_wire_2_06[9:0] ;
			coe_dat5_hld_2_07[9:0] <= #DLY coe_dat5_wire_2_07[9:0] ;
			coe_dat5_hld_2_08[9:0] <= #DLY coe_dat5_wire_2_08[9:0] ;
			coe_dat5_hld_2_09[9:0] <= #DLY coe_dat5_wire_2_09[9:0] ;
			coe_dat5_hld_2_10[9:0] <= #DLY coe_dat5_wire_2_10[9:0] ;
			coe_dat5_hld_2_11[9:0] <= #DLY coe_dat5_wire_2_11[9:0] ;
			coe_dat5_hld_2_12[9:0] <= #DLY coe_dat5_wire_2_12[9:0] ;
			coe_dat5_hld_2_13[9:0] <= #DLY coe_dat5_wire_2_13[9:0] ;
			coe_dat5_hld_2_14[9:0] <= #DLY coe_dat5_wire_2_14[9:0] ;
			coe_dat5_hld_2_15[9:0] <= #DLY coe_dat5_wire_2_15[9:0] ;
			coe_dat5_hld_2_16[9:0] <= #DLY coe_dat5_wire_2_16[9:0] ;
			coe_dat5_hld_2_17[9:0] <= #DLY coe_dat5_wire_2_17[9:0] ;
			coe_dat5_hld_2_18[9:0] <= #DLY coe_dat5_wire_2_18[9:0] ;
			coe_dat5_hld_2_19[9:0] <= #DLY coe_dat5_wire_2_19[9:0] ;
			coe_dat5_hld_2_20[9:0] <= #DLY coe_dat5_wire_2_20[9:0] ;
			coe_dat5_hld_2_21[9:0] <= #DLY coe_dat5_wire_2_21[9:0] ;
			coe_dat5_hld_2_22[9:0] <= #DLY coe_dat5_wire_2_22[9:0] ;
			coe_dat5_hld_2_23[9:0] <= #DLY coe_dat5_wire_2_23[9:0] ;
			coe_dat5_hld_2_24[9:0] <= #DLY coe_dat5_wire_2_24[9:0] ;
			coe_dat5_hld_2_25[9:0] <= #DLY coe_dat5_wire_2_25[9:0] ;
			coe_dat5_hld_2_26[9:0] <= #DLY coe_dat5_wire_2_26[9:0] ;
			coe_dat5_hld_2_27[9:0] <= #DLY coe_dat5_wire_2_27[9:0] ;
			coe_dat5_hld_2_28[9:0] <= #DLY coe_dat5_wire_2_28[9:0] ;
			coe_dat5_hld_2_29[9:0] <= #DLY coe_dat5_wire_2_29[9:0] ;
			coe_dat5_hld_2_30[9:0] <= #DLY coe_dat5_wire_2_30[9:0] ;
			coe_dat5_hld_2_31[9:0] <= #DLY coe_dat5_wire_2_31[9:0] ;
			coe_dat5_hld_2_32[9:0] <= #DLY coe_dat5_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat5_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat5_hld_3_01[9:0] <= #DLY coe_dat5_wire_3_01[9:0] ;
			coe_dat5_hld_3_02[9:0] <= #DLY coe_dat5_wire_3_02[9:0] ;
			coe_dat5_hld_3_03[9:0] <= #DLY coe_dat5_wire_3_03[9:0] ;
			coe_dat5_hld_3_04[9:0] <= #DLY coe_dat5_wire_3_04[9:0] ;
			coe_dat5_hld_3_05[9:0] <= #DLY coe_dat5_wire_3_05[9:0] ;
			coe_dat5_hld_3_06[9:0] <= #DLY coe_dat5_wire_3_06[9:0] ;
			coe_dat5_hld_3_07[9:0] <= #DLY coe_dat5_wire_3_07[9:0] ;
			coe_dat5_hld_3_08[9:0] <= #DLY coe_dat5_wire_3_08[9:0] ;
			coe_dat5_hld_3_09[9:0] <= #DLY coe_dat5_wire_3_09[9:0] ;
			coe_dat5_hld_3_10[9:0] <= #DLY coe_dat5_wire_3_10[9:0] ;
			coe_dat5_hld_3_11[9:0] <= #DLY coe_dat5_wire_3_11[9:0] ;
			coe_dat5_hld_3_12[9:0] <= #DLY coe_dat5_wire_3_12[9:0] ;
			coe_dat5_hld_3_13[9:0] <= #DLY coe_dat5_wire_3_13[9:0] ;
			coe_dat5_hld_3_14[9:0] <= #DLY coe_dat5_wire_3_14[9:0] ;
			coe_dat5_hld_3_15[9:0] <= #DLY coe_dat5_wire_3_15[9:0] ;
			coe_dat5_hld_3_16[9:0] <= #DLY coe_dat5_wire_3_16[9:0] ;
			coe_dat5_hld_3_17[9:0] <= #DLY coe_dat5_wire_3_17[9:0] ;
			coe_dat5_hld_3_18[9:0] <= #DLY coe_dat5_wire_3_18[9:0] ;
			coe_dat5_hld_3_19[9:0] <= #DLY coe_dat5_wire_3_19[9:0] ;
			coe_dat5_hld_3_20[9:0] <= #DLY coe_dat5_wire_3_20[9:0] ;
			coe_dat5_hld_3_21[9:0] <= #DLY coe_dat5_wire_3_21[9:0] ;
			coe_dat5_hld_3_22[9:0] <= #DLY coe_dat5_wire_3_22[9:0] ;
			coe_dat5_hld_3_23[9:0] <= #DLY coe_dat5_wire_3_23[9:0] ;
			coe_dat5_hld_3_24[9:0] <= #DLY coe_dat5_wire_3_24[9:0] ;
			coe_dat5_hld_3_25[9:0] <= #DLY coe_dat5_wire_3_25[9:0] ;
			coe_dat5_hld_3_26[9:0] <= #DLY coe_dat5_wire_3_26[9:0] ;
			coe_dat5_hld_3_27[9:0] <= #DLY coe_dat5_wire_3_27[9:0] ;
			coe_dat5_hld_3_28[9:0] <= #DLY coe_dat5_wire_3_28[9:0] ;
			coe_dat5_hld_3_29[9:0] <= #DLY coe_dat5_wire_3_29[9:0] ;
			coe_dat5_hld_3_30[9:0] <= #DLY coe_dat5_wire_3_30[9:0] ;
			coe_dat5_hld_3_31[9:0] <= #DLY coe_dat5_wire_3_31[9:0] ;
			coe_dat5_hld_3_32[9:0] <= #DLY coe_dat5_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat5_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat5_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat5_hld_4_01[9:0] <= #DLY coe_dat5_wire_4_01[9:0] ;
			coe_dat5_hld_4_02[9:0] <= #DLY coe_dat5_wire_4_02[9:0] ;
			coe_dat5_hld_4_03[9:0] <= #DLY coe_dat5_wire_4_03[9:0] ;
			coe_dat5_hld_4_04[9:0] <= #DLY coe_dat5_wire_4_04[9:0] ;
			coe_dat5_hld_4_05[9:0] <= #DLY coe_dat5_wire_4_05[9:0] ;
			coe_dat5_hld_4_06[9:0] <= #DLY coe_dat5_wire_4_06[9:0] ;
			coe_dat5_hld_4_07[9:0] <= #DLY coe_dat5_wire_4_07[9:0] ;
			coe_dat5_hld_4_08[9:0] <= #DLY coe_dat5_wire_4_08[9:0] ;
			coe_dat5_hld_4_09[9:0] <= #DLY coe_dat5_wire_4_09[9:0] ;
			coe_dat5_hld_4_10[9:0] <= #DLY coe_dat5_wire_4_10[9:0] ;
			coe_dat5_hld_4_11[9:0] <= #DLY coe_dat5_wire_4_11[9:0] ;
			coe_dat5_hld_4_12[9:0] <= #DLY coe_dat5_wire_4_12[9:0] ;
			coe_dat5_hld_4_13[9:0] <= #DLY coe_dat5_wire_4_13[9:0] ;
			coe_dat5_hld_4_14[9:0] <= #DLY coe_dat5_wire_4_14[9:0] ;
			coe_dat5_hld_4_15[9:0] <= #DLY coe_dat5_wire_4_15[9:0] ;
			coe_dat5_hld_4_16[9:0] <= #DLY coe_dat5_wire_4_16[9:0] ;
			coe_dat5_hld_4_17[9:0] <= #DLY coe_dat5_wire_4_17[9:0] ;
			coe_dat5_hld_4_18[9:0] <= #DLY coe_dat5_wire_4_18[9:0] ;
			coe_dat5_hld_4_19[9:0] <= #DLY coe_dat5_wire_4_19[9:0] ;
			coe_dat5_hld_4_20[9:0] <= #DLY coe_dat5_wire_4_20[9:0] ;
			coe_dat5_hld_4_21[9:0] <= #DLY coe_dat5_wire_4_21[9:0] ;
			coe_dat5_hld_4_22[9:0] <= #DLY coe_dat5_wire_4_22[9:0] ;
			coe_dat5_hld_4_23[9:0] <= #DLY coe_dat5_wire_4_23[9:0] ;
			coe_dat5_hld_4_24[9:0] <= #DLY coe_dat5_wire_4_24[9:0] ;
			coe_dat5_hld_4_25[9:0] <= #DLY coe_dat5_wire_4_25[9:0] ;
			coe_dat5_hld_4_26[9:0] <= #DLY coe_dat5_wire_4_26[9:0] ;
			coe_dat5_hld_4_27[9:0] <= #DLY coe_dat5_wire_4_27[9:0] ;
			coe_dat5_hld_4_28[9:0] <= #DLY coe_dat5_wire_4_28[9:0] ;
			coe_dat5_hld_4_29[9:0] <= #DLY coe_dat5_wire_4_29[9:0] ;
			coe_dat5_hld_4_30[9:0] <= #DLY coe_dat5_wire_4_30[9:0] ;
			coe_dat5_hld_4_31[9:0] <= #DLY coe_dat5_wire_4_31[9:0] ;
			coe_dat5_hld_4_32[9:0] <= #DLY coe_dat5_wire_4_32[9:0] ;
		end
	end
//6
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat6_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat6_hld_1_01[9:0] <= #DLY coe_dat6_wire_1_01[9:0] ;
			coe_dat6_hld_1_02[9:0] <= #DLY coe_dat6_wire_1_02[9:0] ;
			coe_dat6_hld_1_03[9:0] <= #DLY coe_dat6_wire_1_03[9:0] ;
			coe_dat6_hld_1_04[9:0] <= #DLY coe_dat6_wire_1_04[9:0] ;
			coe_dat6_hld_1_05[9:0] <= #DLY coe_dat6_wire_1_05[9:0] ;
			coe_dat6_hld_1_06[9:0] <= #DLY coe_dat6_wire_1_06[9:0] ;
			coe_dat6_hld_1_07[9:0] <= #DLY coe_dat6_wire_1_07[9:0] ;
			coe_dat6_hld_1_08[9:0] <= #DLY coe_dat6_wire_1_08[9:0] ;
			coe_dat6_hld_1_09[9:0] <= #DLY coe_dat6_wire_1_09[9:0] ;
			coe_dat6_hld_1_10[9:0] <= #DLY coe_dat6_wire_1_10[9:0] ;
			coe_dat6_hld_1_11[9:0] <= #DLY coe_dat6_wire_1_11[9:0] ;
			coe_dat6_hld_1_12[9:0] <= #DLY coe_dat6_wire_1_12[9:0] ;
			coe_dat6_hld_1_13[9:0] <= #DLY coe_dat6_wire_1_13[9:0] ;
			coe_dat6_hld_1_14[9:0] <= #DLY coe_dat6_wire_1_14[9:0] ;
			coe_dat6_hld_1_15[9:0] <= #DLY coe_dat6_wire_1_15[9:0] ;
			coe_dat6_hld_1_16[9:0] <= #DLY coe_dat6_wire_1_16[9:0] ;
			coe_dat6_hld_1_17[9:0] <= #DLY coe_dat6_wire_1_17[9:0] ;
			coe_dat6_hld_1_18[9:0] <= #DLY coe_dat6_wire_1_18[9:0] ;
			coe_dat6_hld_1_19[9:0] <= #DLY coe_dat6_wire_1_19[9:0] ;
			coe_dat6_hld_1_20[9:0] <= #DLY coe_dat6_wire_1_20[9:0] ;
			coe_dat6_hld_1_21[9:0] <= #DLY coe_dat6_wire_1_21[9:0] ;
			coe_dat6_hld_1_22[9:0] <= #DLY coe_dat6_wire_1_22[9:0] ;
			coe_dat6_hld_1_23[9:0] <= #DLY coe_dat6_wire_1_23[9:0] ;
			coe_dat6_hld_1_24[9:0] <= #DLY coe_dat6_wire_1_24[9:0] ;
			coe_dat6_hld_1_25[9:0] <= #DLY coe_dat6_wire_1_25[9:0] ;
			coe_dat6_hld_1_26[9:0] <= #DLY coe_dat6_wire_1_26[9:0] ;
			coe_dat6_hld_1_27[9:0] <= #DLY coe_dat6_wire_1_27[9:0] ;
			coe_dat6_hld_1_28[9:0] <= #DLY coe_dat6_wire_1_28[9:0] ;
			coe_dat6_hld_1_29[9:0] <= #DLY coe_dat6_wire_1_29[9:0] ;
			coe_dat6_hld_1_30[9:0] <= #DLY coe_dat6_wire_1_30[9:0] ;
			coe_dat6_hld_1_31[9:0] <= #DLY coe_dat6_wire_1_31[9:0] ;
			coe_dat6_hld_1_32[9:0] <= #DLY coe_dat6_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat6_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat6_hld_2_01[9:0] <= #DLY coe_dat6_wire_2_01[9:0] ;
			coe_dat6_hld_2_02[9:0] <= #DLY coe_dat6_wire_2_02[9:0] ;
			coe_dat6_hld_2_03[9:0] <= #DLY coe_dat6_wire_2_03[9:0] ;
			coe_dat6_hld_2_04[9:0] <= #DLY coe_dat6_wire_2_04[9:0] ;
			coe_dat6_hld_2_05[9:0] <= #DLY coe_dat6_wire_2_05[9:0] ;
			coe_dat6_hld_2_06[9:0] <= #DLY coe_dat6_wire_2_06[9:0] ;
			coe_dat6_hld_2_07[9:0] <= #DLY coe_dat6_wire_2_07[9:0] ;
			coe_dat6_hld_2_08[9:0] <= #DLY coe_dat6_wire_2_08[9:0] ;
			coe_dat6_hld_2_09[9:0] <= #DLY coe_dat6_wire_2_09[9:0] ;
			coe_dat6_hld_2_10[9:0] <= #DLY coe_dat6_wire_2_10[9:0] ;
			coe_dat6_hld_2_11[9:0] <= #DLY coe_dat6_wire_2_11[9:0] ;
			coe_dat6_hld_2_12[9:0] <= #DLY coe_dat6_wire_2_12[9:0] ;
			coe_dat6_hld_2_13[9:0] <= #DLY coe_dat6_wire_2_13[9:0] ;
			coe_dat6_hld_2_14[9:0] <= #DLY coe_dat6_wire_2_14[9:0] ;
			coe_dat6_hld_2_15[9:0] <= #DLY coe_dat6_wire_2_15[9:0] ;
			coe_dat6_hld_2_16[9:0] <= #DLY coe_dat6_wire_2_16[9:0] ;
			coe_dat6_hld_2_17[9:0] <= #DLY coe_dat6_wire_2_17[9:0] ;
			coe_dat6_hld_2_18[9:0] <= #DLY coe_dat6_wire_2_18[9:0] ;
			coe_dat6_hld_2_19[9:0] <= #DLY coe_dat6_wire_2_19[9:0] ;
			coe_dat6_hld_2_20[9:0] <= #DLY coe_dat6_wire_2_20[9:0] ;
			coe_dat6_hld_2_21[9:0] <= #DLY coe_dat6_wire_2_21[9:0] ;
			coe_dat6_hld_2_22[9:0] <= #DLY coe_dat6_wire_2_22[9:0] ;
			coe_dat6_hld_2_23[9:0] <= #DLY coe_dat6_wire_2_23[9:0] ;
			coe_dat6_hld_2_24[9:0] <= #DLY coe_dat6_wire_2_24[9:0] ;
			coe_dat6_hld_2_25[9:0] <= #DLY coe_dat6_wire_2_25[9:0] ;
			coe_dat6_hld_2_26[9:0] <= #DLY coe_dat6_wire_2_26[9:0] ;
			coe_dat6_hld_2_27[9:0] <= #DLY coe_dat6_wire_2_27[9:0] ;
			coe_dat6_hld_2_28[9:0] <= #DLY coe_dat6_wire_2_28[9:0] ;
			coe_dat6_hld_2_29[9:0] <= #DLY coe_dat6_wire_2_29[9:0] ;
			coe_dat6_hld_2_30[9:0] <= #DLY coe_dat6_wire_2_30[9:0] ;
			coe_dat6_hld_2_31[9:0] <= #DLY coe_dat6_wire_2_31[9:0] ;
			coe_dat6_hld_2_32[9:0] <= #DLY coe_dat6_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat6_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat6_hld_3_01[9:0] <= #DLY coe_dat6_wire_3_01[9:0] ;
			coe_dat6_hld_3_02[9:0] <= #DLY coe_dat6_wire_3_02[9:0] ;
			coe_dat6_hld_3_03[9:0] <= #DLY coe_dat6_wire_3_03[9:0] ;
			coe_dat6_hld_3_04[9:0] <= #DLY coe_dat6_wire_3_04[9:0] ;
			coe_dat6_hld_3_05[9:0] <= #DLY coe_dat6_wire_3_05[9:0] ;
			coe_dat6_hld_3_06[9:0] <= #DLY coe_dat6_wire_3_06[9:0] ;
			coe_dat6_hld_3_07[9:0] <= #DLY coe_dat6_wire_3_07[9:0] ;
			coe_dat6_hld_3_08[9:0] <= #DLY coe_dat6_wire_3_08[9:0] ;
			coe_dat6_hld_3_09[9:0] <= #DLY coe_dat6_wire_3_09[9:0] ;
			coe_dat6_hld_3_10[9:0] <= #DLY coe_dat6_wire_3_10[9:0] ;
			coe_dat6_hld_3_11[9:0] <= #DLY coe_dat6_wire_3_11[9:0] ;
			coe_dat6_hld_3_12[9:0] <= #DLY coe_dat6_wire_3_12[9:0] ;
			coe_dat6_hld_3_13[9:0] <= #DLY coe_dat6_wire_3_13[9:0] ;
			coe_dat6_hld_3_14[9:0] <= #DLY coe_dat6_wire_3_14[9:0] ;
			coe_dat6_hld_3_15[9:0] <= #DLY coe_dat6_wire_3_15[9:0] ;
			coe_dat6_hld_3_16[9:0] <= #DLY coe_dat6_wire_3_16[9:0] ;
			coe_dat6_hld_3_17[9:0] <= #DLY coe_dat6_wire_3_17[9:0] ;
			coe_dat6_hld_3_18[9:0] <= #DLY coe_dat6_wire_3_18[9:0] ;
			coe_dat6_hld_3_19[9:0] <= #DLY coe_dat6_wire_3_19[9:0] ;
			coe_dat6_hld_3_20[9:0] <= #DLY coe_dat6_wire_3_20[9:0] ;
			coe_dat6_hld_3_21[9:0] <= #DLY coe_dat6_wire_3_21[9:0] ;
			coe_dat6_hld_3_22[9:0] <= #DLY coe_dat6_wire_3_22[9:0] ;
			coe_dat6_hld_3_23[9:0] <= #DLY coe_dat6_wire_3_23[9:0] ;
			coe_dat6_hld_3_24[9:0] <= #DLY coe_dat6_wire_3_24[9:0] ;
			coe_dat6_hld_3_25[9:0] <= #DLY coe_dat6_wire_3_25[9:0] ;
			coe_dat6_hld_3_26[9:0] <= #DLY coe_dat6_wire_3_26[9:0] ;
			coe_dat6_hld_3_27[9:0] <= #DLY coe_dat6_wire_3_27[9:0] ;
			coe_dat6_hld_3_28[9:0] <= #DLY coe_dat6_wire_3_28[9:0] ;
			coe_dat6_hld_3_29[9:0] <= #DLY coe_dat6_wire_3_29[9:0] ;
			coe_dat6_hld_3_30[9:0] <= #DLY coe_dat6_wire_3_30[9:0] ;
			coe_dat6_hld_3_31[9:0] <= #DLY coe_dat6_wire_3_31[9:0] ;
			coe_dat6_hld_3_32[9:0] <= #DLY coe_dat6_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat6_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat6_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat6_hld_4_01[9:0] <= #DLY coe_dat6_wire_4_01[9:0] ;
			coe_dat6_hld_4_02[9:0] <= #DLY coe_dat6_wire_4_02[9:0] ;
			coe_dat6_hld_4_03[9:0] <= #DLY coe_dat6_wire_4_03[9:0] ;
			coe_dat6_hld_4_04[9:0] <= #DLY coe_dat6_wire_4_04[9:0] ;
			coe_dat6_hld_4_05[9:0] <= #DLY coe_dat6_wire_4_05[9:0] ;
			coe_dat6_hld_4_06[9:0] <= #DLY coe_dat6_wire_4_06[9:0] ;
			coe_dat6_hld_4_07[9:0] <= #DLY coe_dat6_wire_4_07[9:0] ;
			coe_dat6_hld_4_08[9:0] <= #DLY coe_dat6_wire_4_08[9:0] ;
			coe_dat6_hld_4_09[9:0] <= #DLY coe_dat6_wire_4_09[9:0] ;
			coe_dat6_hld_4_10[9:0] <= #DLY coe_dat6_wire_4_10[9:0] ;
			coe_dat6_hld_4_11[9:0] <= #DLY coe_dat6_wire_4_11[9:0] ;
			coe_dat6_hld_4_12[9:0] <= #DLY coe_dat6_wire_4_12[9:0] ;
			coe_dat6_hld_4_13[9:0] <= #DLY coe_dat6_wire_4_13[9:0] ;
			coe_dat6_hld_4_14[9:0] <= #DLY coe_dat6_wire_4_14[9:0] ;
			coe_dat6_hld_4_15[9:0] <= #DLY coe_dat6_wire_4_15[9:0] ;
			coe_dat6_hld_4_16[9:0] <= #DLY coe_dat6_wire_4_16[9:0] ;
			coe_dat6_hld_4_17[9:0] <= #DLY coe_dat6_wire_4_17[9:0] ;
			coe_dat6_hld_4_18[9:0] <= #DLY coe_dat6_wire_4_18[9:0] ;
			coe_dat6_hld_4_19[9:0] <= #DLY coe_dat6_wire_4_19[9:0] ;
			coe_dat6_hld_4_20[9:0] <= #DLY coe_dat6_wire_4_20[9:0] ;
			coe_dat6_hld_4_21[9:0] <= #DLY coe_dat6_wire_4_21[9:0] ;
			coe_dat6_hld_4_22[9:0] <= #DLY coe_dat6_wire_4_22[9:0] ;
			coe_dat6_hld_4_23[9:0] <= #DLY coe_dat6_wire_4_23[9:0] ;
			coe_dat6_hld_4_24[9:0] <= #DLY coe_dat6_wire_4_24[9:0] ;
			coe_dat6_hld_4_25[9:0] <= #DLY coe_dat6_wire_4_25[9:0] ;
			coe_dat6_hld_4_26[9:0] <= #DLY coe_dat6_wire_4_26[9:0] ;
			coe_dat6_hld_4_27[9:0] <= #DLY coe_dat6_wire_4_27[9:0] ;
			coe_dat6_hld_4_28[9:0] <= #DLY coe_dat6_wire_4_28[9:0] ;
			coe_dat6_hld_4_29[9:0] <= #DLY coe_dat6_wire_4_29[9:0] ;
			coe_dat6_hld_4_30[9:0] <= #DLY coe_dat6_wire_4_30[9:0] ;
			coe_dat6_hld_4_31[9:0] <= #DLY coe_dat6_wire_4_31[9:0] ;
			coe_dat6_hld_4_32[9:0] <= #DLY coe_dat6_wire_4_32[9:0] ;
		end
	end
//7
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat7_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat7_hld_1_01[9:0] <= #DLY coe_dat7_wire_1_01[9:0] ;
			coe_dat7_hld_1_02[9:0] <= #DLY coe_dat7_wire_1_02[9:0] ;
			coe_dat7_hld_1_03[9:0] <= #DLY coe_dat7_wire_1_03[9:0] ;
			coe_dat7_hld_1_04[9:0] <= #DLY coe_dat7_wire_1_04[9:0] ;
			coe_dat7_hld_1_05[9:0] <= #DLY coe_dat7_wire_1_05[9:0] ;
			coe_dat7_hld_1_06[9:0] <= #DLY coe_dat7_wire_1_06[9:0] ;
			coe_dat7_hld_1_07[9:0] <= #DLY coe_dat7_wire_1_07[9:0] ;
			coe_dat7_hld_1_08[9:0] <= #DLY coe_dat7_wire_1_08[9:0] ;
			coe_dat7_hld_1_09[9:0] <= #DLY coe_dat7_wire_1_09[9:0] ;
			coe_dat7_hld_1_10[9:0] <= #DLY coe_dat7_wire_1_10[9:0] ;
			coe_dat7_hld_1_11[9:0] <= #DLY coe_dat7_wire_1_11[9:0] ;
			coe_dat7_hld_1_12[9:0] <= #DLY coe_dat7_wire_1_12[9:0] ;
			coe_dat7_hld_1_13[9:0] <= #DLY coe_dat7_wire_1_13[9:0] ;
			coe_dat7_hld_1_14[9:0] <= #DLY coe_dat7_wire_1_14[9:0] ;
			coe_dat7_hld_1_15[9:0] <= #DLY coe_dat7_wire_1_15[9:0] ;
			coe_dat7_hld_1_16[9:0] <= #DLY coe_dat7_wire_1_16[9:0] ;
			coe_dat7_hld_1_17[9:0] <= #DLY coe_dat7_wire_1_17[9:0] ;
			coe_dat7_hld_1_18[9:0] <= #DLY coe_dat7_wire_1_18[9:0] ;
			coe_dat7_hld_1_19[9:0] <= #DLY coe_dat7_wire_1_19[9:0] ;
			coe_dat7_hld_1_20[9:0] <= #DLY coe_dat7_wire_1_20[9:0] ;
			coe_dat7_hld_1_21[9:0] <= #DLY coe_dat7_wire_1_21[9:0] ;
			coe_dat7_hld_1_22[9:0] <= #DLY coe_dat7_wire_1_22[9:0] ;
			coe_dat7_hld_1_23[9:0] <= #DLY coe_dat7_wire_1_23[9:0] ;
			coe_dat7_hld_1_24[9:0] <= #DLY coe_dat7_wire_1_24[9:0] ;
			coe_dat7_hld_1_25[9:0] <= #DLY coe_dat7_wire_1_25[9:0] ;
			coe_dat7_hld_1_26[9:0] <= #DLY coe_dat7_wire_1_26[9:0] ;
			coe_dat7_hld_1_27[9:0] <= #DLY coe_dat7_wire_1_27[9:0] ;
			coe_dat7_hld_1_28[9:0] <= #DLY coe_dat7_wire_1_28[9:0] ;
			coe_dat7_hld_1_29[9:0] <= #DLY coe_dat7_wire_1_29[9:0] ;
			coe_dat7_hld_1_30[9:0] <= #DLY coe_dat7_wire_1_30[9:0] ;
			coe_dat7_hld_1_31[9:0] <= #DLY coe_dat7_wire_1_31[9:0] ;
			coe_dat7_hld_1_32[9:0] <= #DLY coe_dat7_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat7_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat7_hld_2_01[9:0] <= #DLY coe_dat7_wire_2_01[9:0] ;
			coe_dat7_hld_2_02[9:0] <= #DLY coe_dat7_wire_2_02[9:0] ;
			coe_dat7_hld_2_03[9:0] <= #DLY coe_dat7_wire_2_03[9:0] ;
			coe_dat7_hld_2_04[9:0] <= #DLY coe_dat7_wire_2_04[9:0] ;
			coe_dat7_hld_2_05[9:0] <= #DLY coe_dat7_wire_2_05[9:0] ;
			coe_dat7_hld_2_06[9:0] <= #DLY coe_dat7_wire_2_06[9:0] ;
			coe_dat7_hld_2_07[9:0] <= #DLY coe_dat7_wire_2_07[9:0] ;
			coe_dat7_hld_2_08[9:0] <= #DLY coe_dat7_wire_2_08[9:0] ;
			coe_dat7_hld_2_09[9:0] <= #DLY coe_dat7_wire_2_09[9:0] ;
			coe_dat7_hld_2_10[9:0] <= #DLY coe_dat7_wire_2_10[9:0] ;
			coe_dat7_hld_2_11[9:0] <= #DLY coe_dat7_wire_2_11[9:0] ;
			coe_dat7_hld_2_12[9:0] <= #DLY coe_dat7_wire_2_12[9:0] ;
			coe_dat7_hld_2_13[9:0] <= #DLY coe_dat7_wire_2_13[9:0] ;
			coe_dat7_hld_2_14[9:0] <= #DLY coe_dat7_wire_2_14[9:0] ;
			coe_dat7_hld_2_15[9:0] <= #DLY coe_dat7_wire_2_15[9:0] ;
			coe_dat7_hld_2_16[9:0] <= #DLY coe_dat7_wire_2_16[9:0] ;
			coe_dat7_hld_2_17[9:0] <= #DLY coe_dat7_wire_2_17[9:0] ;
			coe_dat7_hld_2_18[9:0] <= #DLY coe_dat7_wire_2_18[9:0] ;
			coe_dat7_hld_2_19[9:0] <= #DLY coe_dat7_wire_2_19[9:0] ;
			coe_dat7_hld_2_20[9:0] <= #DLY coe_dat7_wire_2_20[9:0] ;
			coe_dat7_hld_2_21[9:0] <= #DLY coe_dat7_wire_2_21[9:0] ;
			coe_dat7_hld_2_22[9:0] <= #DLY coe_dat7_wire_2_22[9:0] ;
			coe_dat7_hld_2_23[9:0] <= #DLY coe_dat7_wire_2_23[9:0] ;
			coe_dat7_hld_2_24[9:0] <= #DLY coe_dat7_wire_2_24[9:0] ;
			coe_dat7_hld_2_25[9:0] <= #DLY coe_dat7_wire_2_25[9:0] ;
			coe_dat7_hld_2_26[9:0] <= #DLY coe_dat7_wire_2_26[9:0] ;
			coe_dat7_hld_2_27[9:0] <= #DLY coe_dat7_wire_2_27[9:0] ;
			coe_dat7_hld_2_28[9:0] <= #DLY coe_dat7_wire_2_28[9:0] ;
			coe_dat7_hld_2_29[9:0] <= #DLY coe_dat7_wire_2_29[9:0] ;
			coe_dat7_hld_2_30[9:0] <= #DLY coe_dat7_wire_2_30[9:0] ;
			coe_dat7_hld_2_31[9:0] <= #DLY coe_dat7_wire_2_31[9:0] ;
			coe_dat7_hld_2_32[9:0] <= #DLY coe_dat7_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat7_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat7_hld_3_01[9:0] <= #DLY coe_dat7_wire_3_01[9:0] ;
			coe_dat7_hld_3_02[9:0] <= #DLY coe_dat7_wire_3_02[9:0] ;
			coe_dat7_hld_3_03[9:0] <= #DLY coe_dat7_wire_3_03[9:0] ;
			coe_dat7_hld_3_04[9:0] <= #DLY coe_dat7_wire_3_04[9:0] ;
			coe_dat7_hld_3_05[9:0] <= #DLY coe_dat7_wire_3_05[9:0] ;
			coe_dat7_hld_3_06[9:0] <= #DLY coe_dat7_wire_3_06[9:0] ;
			coe_dat7_hld_3_07[9:0] <= #DLY coe_dat7_wire_3_07[9:0] ;
			coe_dat7_hld_3_08[9:0] <= #DLY coe_dat7_wire_3_08[9:0] ;
			coe_dat7_hld_3_09[9:0] <= #DLY coe_dat7_wire_3_09[9:0] ;
			coe_dat7_hld_3_10[9:0] <= #DLY coe_dat7_wire_3_10[9:0] ;
			coe_dat7_hld_3_11[9:0] <= #DLY coe_dat7_wire_3_11[9:0] ;
			coe_dat7_hld_3_12[9:0] <= #DLY coe_dat7_wire_3_12[9:0] ;
			coe_dat7_hld_3_13[9:0] <= #DLY coe_dat7_wire_3_13[9:0] ;
			coe_dat7_hld_3_14[9:0] <= #DLY coe_dat7_wire_3_14[9:0] ;
			coe_dat7_hld_3_15[9:0] <= #DLY coe_dat7_wire_3_15[9:0] ;
			coe_dat7_hld_3_16[9:0] <= #DLY coe_dat7_wire_3_16[9:0] ;
			coe_dat7_hld_3_17[9:0] <= #DLY coe_dat7_wire_3_17[9:0] ;
			coe_dat7_hld_3_18[9:0] <= #DLY coe_dat7_wire_3_18[9:0] ;
			coe_dat7_hld_3_19[9:0] <= #DLY coe_dat7_wire_3_19[9:0] ;
			coe_dat7_hld_3_20[9:0] <= #DLY coe_dat7_wire_3_20[9:0] ;
			coe_dat7_hld_3_21[9:0] <= #DLY coe_dat7_wire_3_21[9:0] ;
			coe_dat7_hld_3_22[9:0] <= #DLY coe_dat7_wire_3_22[9:0] ;
			coe_dat7_hld_3_23[9:0] <= #DLY coe_dat7_wire_3_23[9:0] ;
			coe_dat7_hld_3_24[9:0] <= #DLY coe_dat7_wire_3_24[9:0] ;
			coe_dat7_hld_3_25[9:0] <= #DLY coe_dat7_wire_3_25[9:0] ;
			coe_dat7_hld_3_26[9:0] <= #DLY coe_dat7_wire_3_26[9:0] ;
			coe_dat7_hld_3_27[9:0] <= #DLY coe_dat7_wire_3_27[9:0] ;
			coe_dat7_hld_3_28[9:0] <= #DLY coe_dat7_wire_3_28[9:0] ;
			coe_dat7_hld_3_29[9:0] <= #DLY coe_dat7_wire_3_29[9:0] ;
			coe_dat7_hld_3_30[9:0] <= #DLY coe_dat7_wire_3_30[9:0] ;
			coe_dat7_hld_3_31[9:0] <= #DLY coe_dat7_wire_3_31[9:0] ;
			coe_dat7_hld_3_32[9:0] <= #DLY coe_dat7_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat7_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat7_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat7_hld_4_01[9:0] <= #DLY coe_dat7_wire_4_01[9:0] ;
			coe_dat7_hld_4_02[9:0] <= #DLY coe_dat7_wire_4_02[9:0] ;
			coe_dat7_hld_4_03[9:0] <= #DLY coe_dat7_wire_4_03[9:0] ;
			coe_dat7_hld_4_04[9:0] <= #DLY coe_dat7_wire_4_04[9:0] ;
			coe_dat7_hld_4_05[9:0] <= #DLY coe_dat7_wire_4_05[9:0] ;
			coe_dat7_hld_4_06[9:0] <= #DLY coe_dat7_wire_4_06[9:0] ;
			coe_dat7_hld_4_07[9:0] <= #DLY coe_dat7_wire_4_07[9:0] ;
			coe_dat7_hld_4_08[9:0] <= #DLY coe_dat7_wire_4_08[9:0] ;
			coe_dat7_hld_4_09[9:0] <= #DLY coe_dat7_wire_4_09[9:0] ;
			coe_dat7_hld_4_10[9:0] <= #DLY coe_dat7_wire_4_10[9:0] ;
			coe_dat7_hld_4_11[9:0] <= #DLY coe_dat7_wire_4_11[9:0] ;
			coe_dat7_hld_4_12[9:0] <= #DLY coe_dat7_wire_4_12[9:0] ;
			coe_dat7_hld_4_13[9:0] <= #DLY coe_dat7_wire_4_13[9:0] ;
			coe_dat7_hld_4_14[9:0] <= #DLY coe_dat7_wire_4_14[9:0] ;
			coe_dat7_hld_4_15[9:0] <= #DLY coe_dat7_wire_4_15[9:0] ;
			coe_dat7_hld_4_16[9:0] <= #DLY coe_dat7_wire_4_16[9:0] ;
			coe_dat7_hld_4_17[9:0] <= #DLY coe_dat7_wire_4_17[9:0] ;
			coe_dat7_hld_4_18[9:0] <= #DLY coe_dat7_wire_4_18[9:0] ;
			coe_dat7_hld_4_19[9:0] <= #DLY coe_dat7_wire_4_19[9:0] ;
			coe_dat7_hld_4_20[9:0] <= #DLY coe_dat7_wire_4_20[9:0] ;
			coe_dat7_hld_4_21[9:0] <= #DLY coe_dat7_wire_4_21[9:0] ;
			coe_dat7_hld_4_22[9:0] <= #DLY coe_dat7_wire_4_22[9:0] ;
			coe_dat7_hld_4_23[9:0] <= #DLY coe_dat7_wire_4_23[9:0] ;
			coe_dat7_hld_4_24[9:0] <= #DLY coe_dat7_wire_4_24[9:0] ;
			coe_dat7_hld_4_25[9:0] <= #DLY coe_dat7_wire_4_25[9:0] ;
			coe_dat7_hld_4_26[9:0] <= #DLY coe_dat7_wire_4_26[9:0] ;
			coe_dat7_hld_4_27[9:0] <= #DLY coe_dat7_wire_4_27[9:0] ;
			coe_dat7_hld_4_28[9:0] <= #DLY coe_dat7_wire_4_28[9:0] ;
			coe_dat7_hld_4_29[9:0] <= #DLY coe_dat7_wire_4_29[9:0] ;
			coe_dat7_hld_4_30[9:0] <= #DLY coe_dat7_wire_4_30[9:0] ;
			coe_dat7_hld_4_31[9:0] <= #DLY coe_dat7_wire_4_31[9:0] ;
			coe_dat7_hld_4_32[9:0] <= #DLY coe_dat7_wire_4_32[9:0] ;
		end
	end
//8
    always @ (posedge clk) begin
		if(rst) begin
			coe_dat8_hld_1_01[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_02[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_03[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_04[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_05[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_06[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_07[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_08[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_09[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_10[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_11[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_12[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_13[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_14[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_15[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_16[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_17[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_18[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_19[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_20[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_21[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_22[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_23[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_24[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_25[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_26[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_27[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_28[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_29[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_30[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_31[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_1_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat8_hld_1_01[9:0] <= #DLY coe_dat8_wire_1_01[9:0] ;
			coe_dat8_hld_1_02[9:0] <= #DLY coe_dat8_wire_1_02[9:0] ;
			coe_dat8_hld_1_03[9:0] <= #DLY coe_dat8_wire_1_03[9:0] ;
			coe_dat8_hld_1_04[9:0] <= #DLY coe_dat8_wire_1_04[9:0] ;
			coe_dat8_hld_1_05[9:0] <= #DLY coe_dat8_wire_1_05[9:0] ;
			coe_dat8_hld_1_06[9:0] <= #DLY coe_dat8_wire_1_06[9:0] ;
			coe_dat8_hld_1_07[9:0] <= #DLY coe_dat8_wire_1_07[9:0] ;
			coe_dat8_hld_1_08[9:0] <= #DLY coe_dat8_wire_1_08[9:0] ;
			coe_dat8_hld_1_09[9:0] <= #DLY coe_dat8_wire_1_09[9:0] ;
			coe_dat8_hld_1_10[9:0] <= #DLY coe_dat8_wire_1_10[9:0] ;
			coe_dat8_hld_1_11[9:0] <= #DLY coe_dat8_wire_1_11[9:0] ;
			coe_dat8_hld_1_12[9:0] <= #DLY coe_dat8_wire_1_12[9:0] ;
			coe_dat8_hld_1_13[9:0] <= #DLY coe_dat8_wire_1_13[9:0] ;
			coe_dat8_hld_1_14[9:0] <= #DLY coe_dat8_wire_1_14[9:0] ;
			coe_dat8_hld_1_15[9:0] <= #DLY coe_dat8_wire_1_15[9:0] ;
			coe_dat8_hld_1_16[9:0] <= #DLY coe_dat8_wire_1_16[9:0] ;
			coe_dat8_hld_1_17[9:0] <= #DLY coe_dat8_wire_1_17[9:0] ;
			coe_dat8_hld_1_18[9:0] <= #DLY coe_dat8_wire_1_18[9:0] ;
			coe_dat8_hld_1_19[9:0] <= #DLY coe_dat8_wire_1_19[9:0] ;
			coe_dat8_hld_1_20[9:0] <= #DLY coe_dat8_wire_1_20[9:0] ;
			coe_dat8_hld_1_21[9:0] <= #DLY coe_dat8_wire_1_21[9:0] ;
			coe_dat8_hld_1_22[9:0] <= #DLY coe_dat8_wire_1_22[9:0] ;
			coe_dat8_hld_1_23[9:0] <= #DLY coe_dat8_wire_1_23[9:0] ;
			coe_dat8_hld_1_24[9:0] <= #DLY coe_dat8_wire_1_24[9:0] ;
			coe_dat8_hld_1_25[9:0] <= #DLY coe_dat8_wire_1_25[9:0] ;
			coe_dat8_hld_1_26[9:0] <= #DLY coe_dat8_wire_1_26[9:0] ;
			coe_dat8_hld_1_27[9:0] <= #DLY coe_dat8_wire_1_27[9:0] ;
			coe_dat8_hld_1_28[9:0] <= #DLY coe_dat8_wire_1_28[9:0] ;
			coe_dat8_hld_1_29[9:0] <= #DLY coe_dat8_wire_1_29[9:0] ;
			coe_dat8_hld_1_30[9:0] <= #DLY coe_dat8_wire_1_30[9:0] ;
			coe_dat8_hld_1_31[9:0] <= #DLY coe_dat8_wire_1_31[9:0] ;
			coe_dat8_hld_1_32[9:0] <= #DLY coe_dat8_wire_1_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat8_hld_2_01[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_02[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_03[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_04[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_05[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_06[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_07[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_08[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_09[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_10[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_11[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_12[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_13[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_14[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_15[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_16[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_17[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_18[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_19[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_20[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_21[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_22[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_23[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_24[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_25[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_26[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_27[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_28[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_29[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_30[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_31[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_2_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat8_hld_2_01[9:0] <= #DLY coe_dat8_wire_2_01[9:0] ;
			coe_dat8_hld_2_02[9:0] <= #DLY coe_dat8_wire_2_02[9:0] ;
			coe_dat8_hld_2_03[9:0] <= #DLY coe_dat8_wire_2_03[9:0] ;
			coe_dat8_hld_2_04[9:0] <= #DLY coe_dat8_wire_2_04[9:0] ;
			coe_dat8_hld_2_05[9:0] <= #DLY coe_dat8_wire_2_05[9:0] ;
			coe_dat8_hld_2_06[9:0] <= #DLY coe_dat8_wire_2_06[9:0] ;
			coe_dat8_hld_2_07[9:0] <= #DLY coe_dat8_wire_2_07[9:0] ;
			coe_dat8_hld_2_08[9:0] <= #DLY coe_dat8_wire_2_08[9:0] ;
			coe_dat8_hld_2_09[9:0] <= #DLY coe_dat8_wire_2_09[9:0] ;
			coe_dat8_hld_2_10[9:0] <= #DLY coe_dat8_wire_2_10[9:0] ;
			coe_dat8_hld_2_11[9:0] <= #DLY coe_dat8_wire_2_11[9:0] ;
			coe_dat8_hld_2_12[9:0] <= #DLY coe_dat8_wire_2_12[9:0] ;
			coe_dat8_hld_2_13[9:0] <= #DLY coe_dat8_wire_2_13[9:0] ;
			coe_dat8_hld_2_14[9:0] <= #DLY coe_dat8_wire_2_14[9:0] ;
			coe_dat8_hld_2_15[9:0] <= #DLY coe_dat8_wire_2_15[9:0] ;
			coe_dat8_hld_2_16[9:0] <= #DLY coe_dat8_wire_2_16[9:0] ;
			coe_dat8_hld_2_17[9:0] <= #DLY coe_dat8_wire_2_17[9:0] ;
			coe_dat8_hld_2_18[9:0] <= #DLY coe_dat8_wire_2_18[9:0] ;
			coe_dat8_hld_2_19[9:0] <= #DLY coe_dat8_wire_2_19[9:0] ;
			coe_dat8_hld_2_20[9:0] <= #DLY coe_dat8_wire_2_20[9:0] ;
			coe_dat8_hld_2_21[9:0] <= #DLY coe_dat8_wire_2_21[9:0] ;
			coe_dat8_hld_2_22[9:0] <= #DLY coe_dat8_wire_2_22[9:0] ;
			coe_dat8_hld_2_23[9:0] <= #DLY coe_dat8_wire_2_23[9:0] ;
			coe_dat8_hld_2_24[9:0] <= #DLY coe_dat8_wire_2_24[9:0] ;
			coe_dat8_hld_2_25[9:0] <= #DLY coe_dat8_wire_2_25[9:0] ;
			coe_dat8_hld_2_26[9:0] <= #DLY coe_dat8_wire_2_26[9:0] ;
			coe_dat8_hld_2_27[9:0] <= #DLY coe_dat8_wire_2_27[9:0] ;
			coe_dat8_hld_2_28[9:0] <= #DLY coe_dat8_wire_2_28[9:0] ;
			coe_dat8_hld_2_29[9:0] <= #DLY coe_dat8_wire_2_29[9:0] ;
			coe_dat8_hld_2_30[9:0] <= #DLY coe_dat8_wire_2_30[9:0] ;
			coe_dat8_hld_2_31[9:0] <= #DLY coe_dat8_wire_2_31[9:0] ;
			coe_dat8_hld_2_32[9:0] <= #DLY coe_dat8_wire_2_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat8_hld_3_01[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_02[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_03[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_04[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_05[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_06[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_07[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_08[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_09[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_10[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_11[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_12[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_13[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_14[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_15[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_16[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_17[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_18[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_19[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_20[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_21[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_22[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_23[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_24[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_25[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_26[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_27[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_28[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_29[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_30[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_31[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_3_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat8_hld_3_01[9:0] <= #DLY coe_dat8_wire_3_01[9:0] ;
			coe_dat8_hld_3_02[9:0] <= #DLY coe_dat8_wire_3_02[9:0] ;
			coe_dat8_hld_3_03[9:0] <= #DLY coe_dat8_wire_3_03[9:0] ;
			coe_dat8_hld_3_04[9:0] <= #DLY coe_dat8_wire_3_04[9:0] ;
			coe_dat8_hld_3_05[9:0] <= #DLY coe_dat8_wire_3_05[9:0] ;
			coe_dat8_hld_3_06[9:0] <= #DLY coe_dat8_wire_3_06[9:0] ;
			coe_dat8_hld_3_07[9:0] <= #DLY coe_dat8_wire_3_07[9:0] ;
			coe_dat8_hld_3_08[9:0] <= #DLY coe_dat8_wire_3_08[9:0] ;
			coe_dat8_hld_3_09[9:0] <= #DLY coe_dat8_wire_3_09[9:0] ;
			coe_dat8_hld_3_10[9:0] <= #DLY coe_dat8_wire_3_10[9:0] ;
			coe_dat8_hld_3_11[9:0] <= #DLY coe_dat8_wire_3_11[9:0] ;
			coe_dat8_hld_3_12[9:0] <= #DLY coe_dat8_wire_3_12[9:0] ;
			coe_dat8_hld_3_13[9:0] <= #DLY coe_dat8_wire_3_13[9:0] ;
			coe_dat8_hld_3_14[9:0] <= #DLY coe_dat8_wire_3_14[9:0] ;
			coe_dat8_hld_3_15[9:0] <= #DLY coe_dat8_wire_3_15[9:0] ;
			coe_dat8_hld_3_16[9:0] <= #DLY coe_dat8_wire_3_16[9:0] ;
			coe_dat8_hld_3_17[9:0] <= #DLY coe_dat8_wire_3_17[9:0] ;
			coe_dat8_hld_3_18[9:0] <= #DLY coe_dat8_wire_3_18[9:0] ;
			coe_dat8_hld_3_19[9:0] <= #DLY coe_dat8_wire_3_19[9:0] ;
			coe_dat8_hld_3_20[9:0] <= #DLY coe_dat8_wire_3_20[9:0] ;
			coe_dat8_hld_3_21[9:0] <= #DLY coe_dat8_wire_3_21[9:0] ;
			coe_dat8_hld_3_22[9:0] <= #DLY coe_dat8_wire_3_22[9:0] ;
			coe_dat8_hld_3_23[9:0] <= #DLY coe_dat8_wire_3_23[9:0] ;
			coe_dat8_hld_3_24[9:0] <= #DLY coe_dat8_wire_3_24[9:0] ;
			coe_dat8_hld_3_25[9:0] <= #DLY coe_dat8_wire_3_25[9:0] ;
			coe_dat8_hld_3_26[9:0] <= #DLY coe_dat8_wire_3_26[9:0] ;
			coe_dat8_hld_3_27[9:0] <= #DLY coe_dat8_wire_3_27[9:0] ;
			coe_dat8_hld_3_28[9:0] <= #DLY coe_dat8_wire_3_28[9:0] ;
			coe_dat8_hld_3_29[9:0] <= #DLY coe_dat8_wire_3_29[9:0] ;
			coe_dat8_hld_3_30[9:0] <= #DLY coe_dat8_wire_3_30[9:0] ;
			coe_dat8_hld_3_31[9:0] <= #DLY coe_dat8_wire_3_31[9:0] ;
			coe_dat8_hld_3_32[9:0] <= #DLY coe_dat8_wire_3_32[9:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			coe_dat8_hld_4_01[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_02[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_03[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_04[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_05[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_06[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_07[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_08[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_09[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_10[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_11[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_12[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_13[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_14[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_15[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_16[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_17[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_18[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_19[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_20[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_21[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_22[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_23[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_24[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_25[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_26[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_27[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_28[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_29[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_30[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_31[9:0] <= #DLY 10'd0 ;
			coe_dat8_hld_4_32[9:0] <= #DLY 10'd0 ;
		end else if(pipeline_cnt[8] & (cyc8_cnt_dd2[5:0] == 6'd7)) begin
			coe_dat8_hld_4_01[9:0] <= #DLY coe_dat8_wire_4_01[9:0] ;
			coe_dat8_hld_4_02[9:0] <= #DLY coe_dat8_wire_4_02[9:0] ;
			coe_dat8_hld_4_03[9:0] <= #DLY coe_dat8_wire_4_03[9:0] ;
			coe_dat8_hld_4_04[9:0] <= #DLY coe_dat8_wire_4_04[9:0] ;
			coe_dat8_hld_4_05[9:0] <= #DLY coe_dat8_wire_4_05[9:0] ;
			coe_dat8_hld_4_06[9:0] <= #DLY coe_dat8_wire_4_06[9:0] ;
			coe_dat8_hld_4_07[9:0] <= #DLY coe_dat8_wire_4_07[9:0] ;
			coe_dat8_hld_4_08[9:0] <= #DLY coe_dat8_wire_4_08[9:0] ;
			coe_dat8_hld_4_09[9:0] <= #DLY coe_dat8_wire_4_09[9:0] ;
			coe_dat8_hld_4_10[9:0] <= #DLY coe_dat8_wire_4_10[9:0] ;
			coe_dat8_hld_4_11[9:0] <= #DLY coe_dat8_wire_4_11[9:0] ;
			coe_dat8_hld_4_12[9:0] <= #DLY coe_dat8_wire_4_12[9:0] ;
			coe_dat8_hld_4_13[9:0] <= #DLY coe_dat8_wire_4_13[9:0] ;
			coe_dat8_hld_4_14[9:0] <= #DLY coe_dat8_wire_4_14[9:0] ;
			coe_dat8_hld_4_15[9:0] <= #DLY coe_dat8_wire_4_15[9:0] ;
			coe_dat8_hld_4_16[9:0] <= #DLY coe_dat8_wire_4_16[9:0] ;
			coe_dat8_hld_4_17[9:0] <= #DLY coe_dat8_wire_4_17[9:0] ;
			coe_dat8_hld_4_18[9:0] <= #DLY coe_dat8_wire_4_18[9:0] ;
			coe_dat8_hld_4_19[9:0] <= #DLY coe_dat8_wire_4_19[9:0] ;
			coe_dat8_hld_4_20[9:0] <= #DLY coe_dat8_wire_4_20[9:0] ;
			coe_dat8_hld_4_21[9:0] <= #DLY coe_dat8_wire_4_21[9:0] ;
			coe_dat8_hld_4_22[9:0] <= #DLY coe_dat8_wire_4_22[9:0] ;
			coe_dat8_hld_4_23[9:0] <= #DLY coe_dat8_wire_4_23[9:0] ;
			coe_dat8_hld_4_24[9:0] <= #DLY coe_dat8_wire_4_24[9:0] ;
			coe_dat8_hld_4_25[9:0] <= #DLY coe_dat8_wire_4_25[9:0] ;
			coe_dat8_hld_4_26[9:0] <= #DLY coe_dat8_wire_4_26[9:0] ;
			coe_dat8_hld_4_27[9:0] <= #DLY coe_dat8_wire_4_27[9:0] ;
			coe_dat8_hld_4_28[9:0] <= #DLY coe_dat8_wire_4_28[9:0] ;
			coe_dat8_hld_4_29[9:0] <= #DLY coe_dat8_wire_4_29[9:0] ;
			coe_dat8_hld_4_30[9:0] <= #DLY coe_dat8_wire_4_30[9:0] ;
			coe_dat8_hld_4_31[9:0] <= #DLY coe_dat8_wire_4_31[9:0] ;
			coe_dat8_hld_4_32[9:0] <= #DLY coe_dat8_wire_4_32[9:0] ;
		end
	end

    /****************************
    // pipeline[9] Active
    ****************************/
    wire [9:0] coe_dat_hld_1_01  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_01 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_02  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_02 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_03  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_03 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_04  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_04 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_05  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_05 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_06  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_06 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_07  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_07 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_08  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_08 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_09  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_09 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_10  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_10 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_11  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_11 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_12  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_12 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_13  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_13 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_14  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_14 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_15  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_15 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_16  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_16 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_17  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_17 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_18  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_18 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_19  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_19 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_20  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_20 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_21  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_21 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_22  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_22 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_23  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_23 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_24  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_24 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_25  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_25 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_26  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_26 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_27  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_27 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_28  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_28 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_29  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_29 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_30  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_30 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_31  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_31 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_1_32  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_1_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_1_32 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_01  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_01 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_02  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_02 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_03  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_03 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_04  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_04 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_05  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_05 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_06  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_06 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_07  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_07 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_08  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_08 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_09  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_09 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_10  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_10 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_11  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_11 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_12  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_12 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_13  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_13 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_14  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_14 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_15  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_15 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_16  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_16 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_17  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_17 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_18  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_18 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_19  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_19 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_20  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_20 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_21  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_21 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_22  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_22 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_23  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_23 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_24  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_24 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_25  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_25 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_26  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_26 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_27  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_27 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_28  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_28 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_29  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_29 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_30  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_30 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_31  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_31 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_2_32  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_2_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_2_32 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_01  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_01 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_02  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_02 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_03  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_03 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_04  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_04 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_05  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_05 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_06  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_06 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_07  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_07 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_08  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_08 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_09  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_09 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_10  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_10 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_11  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_11 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_12  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_12 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_13  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_13 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_14  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_14 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_15  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_15 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_16  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_16 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_17  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_17 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_18  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_18 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_19  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_19 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_20  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_20 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_21  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_21 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_22  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_22 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_23  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_23 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_24  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_24 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_25  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_25 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_26  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_26 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_27  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_27 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_28  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_28 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_29  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_29 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_30  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_30 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_31  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_31 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_3_32  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_3_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_3_32 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_01  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_01 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_01 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_02  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_02 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_02 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_03  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_03 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_03 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_04  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_04 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_04 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_05  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_05 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_05 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_06  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_06 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_06 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_07  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_07 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_07 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_08  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_08 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_08 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_09  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_09 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_09 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_10  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_10 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_10 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_11  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_11 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_11 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_12  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_12 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_12 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_13  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_13 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_13 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_14  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_14 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_14 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_15  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_15 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_15 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_16  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_16 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_16 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_17  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_17 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_17 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_18  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_18 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_18 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_19  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_19 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_19 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_20  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_20 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_20 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_21  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_21 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_21 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_22  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_22 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_22 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_23  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_23 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_23 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_24  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_24 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_24 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_25  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_25 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_25 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_26  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_26 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_26 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_27  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_27 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_27 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_28  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_28 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_28 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_29  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_29 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_29 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_30  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_30 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_30 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_31  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_31 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_31 :
                                    10'd0 ;
    wire [9:0] coe_dat_hld_4_32  = (cyc8_cnt_dd10[5:0] == 6'd0)? coe_dat1_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd1)? coe_dat2_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd2)? coe_dat3_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd3)? coe_dat4_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd4)? coe_dat5_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd5)? coe_dat6_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd6)? coe_dat7_hld_4_32 :
                                   (cyc8_cnt_dd10[5:0] == 6'd7)? coe_dat8_hld_4_32 :
                                    10'd0 ;

    wire [19:0] mult_wire_1_01 = coe_dat_hld_1_01[9:0] * in_dat_hld01[9:0] ;
    wire [19:0] mult_wire_1_02 = coe_dat_hld_1_02[9:0] * in_dat_hld02[9:0] ;
    wire [19:0] mult_wire_1_03 = coe_dat_hld_1_03[9:0] * in_dat_hld03[9:0] ;
    wire [19:0] mult_wire_1_04 = coe_dat_hld_1_04[9:0] * in_dat_hld04[9:0] ;
    wire [19:0] mult_wire_1_05 = coe_dat_hld_1_05[9:0] * in_dat_hld05[9:0] ;
    wire [19:0] mult_wire_1_06 = coe_dat_hld_1_06[9:0] * in_dat_hld06[9:0] ;
    wire [19:0] mult_wire_1_07 = coe_dat_hld_1_07[9:0] * in_dat_hld07[9:0] ;
    wire [19:0] mult_wire_1_08 = coe_dat_hld_1_08[9:0] * in_dat_hld08[9:0] ;
    wire [19:0] mult_wire_1_09 = coe_dat_hld_1_09[9:0] * in_dat_hld09[9:0] ;
    wire [19:0] mult_wire_1_10 = coe_dat_hld_1_10[9:0] * in_dat_hld10[9:0] ;
    wire [19:0] mult_wire_1_11 = coe_dat_hld_1_11[9:0] * in_dat_hld11[9:0] ;
    wire [19:0] mult_wire_1_12 = coe_dat_hld_1_12[9:0] * in_dat_hld12[9:0] ;
    wire [19:0] mult_wire_1_13 = coe_dat_hld_1_13[9:0] * in_dat_hld13[9:0] ;
    wire [19:0] mult_wire_1_14 = coe_dat_hld_1_14[9:0] * in_dat_hld14[9:0] ;
    wire [19:0] mult_wire_1_15 = coe_dat_hld_1_15[9:0] * in_dat_hld15[9:0] ;
    wire [19:0] mult_wire_1_16 = coe_dat_hld_1_16[9:0] * in_dat_hld16[9:0] ;
    wire [19:0] mult_wire_1_17 = coe_dat_hld_1_17[9:0] * in_dat_hld17[9:0] ;
    wire [19:0] mult_wire_1_18 = coe_dat_hld_1_18[9:0] * in_dat_hld18[9:0] ;
    wire [19:0] mult_wire_1_19 = coe_dat_hld_1_19[9:0] * in_dat_hld19[9:0] ;
    wire [19:0] mult_wire_1_20 = coe_dat_hld_1_20[9:0] * in_dat_hld20[9:0] ;
    wire [19:0] mult_wire_1_21 = coe_dat_hld_1_21[9:0] * in_dat_hld21[9:0] ;
    wire [19:0] mult_wire_1_22 = coe_dat_hld_1_22[9:0] * in_dat_hld22[9:0] ;
    wire [19:0] mult_wire_1_23 = coe_dat_hld_1_23[9:0] * in_dat_hld23[9:0] ;
    wire [19:0] mult_wire_1_24 = coe_dat_hld_1_24[9:0] * in_dat_hld24[9:0] ;
    wire [19:0] mult_wire_1_25 = coe_dat_hld_1_25[9:0] * in_dat_hld25[9:0] ;
    wire [19:0] mult_wire_1_26 = coe_dat_hld_1_26[9:0] * in_dat_hld26[9:0] ;
    wire [19:0] mult_wire_1_27 = coe_dat_hld_1_27[9:0] * in_dat_hld27[9:0] ;
    wire [19:0] mult_wire_1_28 = coe_dat_hld_1_28[9:0] * in_dat_hld28[9:0] ;
    wire [19:0] mult_wire_1_29 = coe_dat_hld_1_29[9:0] * in_dat_hld29[9:0] ;
    wire [19:0] mult_wire_1_30 = coe_dat_hld_1_30[9:0] * in_dat_hld30[9:0] ;
    wire [19:0] mult_wire_1_31 = coe_dat_hld_1_31[9:0] * in_dat_hld31[9:0] ;
    wire [19:0] mult_wire_1_32 = coe_dat_hld_1_32[9:0] * in_dat_hld32[9:0] ;

    wire [19:0] mult_wire_2_01 = coe_dat_hld_2_01[9:0] * in_dat_hld01[9:0] ;
    wire [19:0] mult_wire_2_02 = coe_dat_hld_2_02[9:0] * in_dat_hld02[9:0] ;
    wire [19:0] mult_wire_2_03 = coe_dat_hld_2_03[9:0] * in_dat_hld03[9:0] ;
    wire [19:0] mult_wire_2_04 = coe_dat_hld_2_04[9:0] * in_dat_hld04[9:0] ;
    wire [19:0] mult_wire_2_05 = coe_dat_hld_2_05[9:0] * in_dat_hld05[9:0] ;
    wire [19:0] mult_wire_2_06 = coe_dat_hld_2_06[9:0] * in_dat_hld06[9:0] ;
    wire [19:0] mult_wire_2_07 = coe_dat_hld_2_07[9:0] * in_dat_hld07[9:0] ;
    wire [19:0] mult_wire_2_08 = coe_dat_hld_2_08[9:0] * in_dat_hld08[9:0] ;
    wire [19:0] mult_wire_2_09 = coe_dat_hld_2_09[9:0] * in_dat_hld09[9:0] ;
    wire [19:0] mult_wire_2_10 = coe_dat_hld_2_10[9:0] * in_dat_hld10[9:0] ;
    wire [19:0] mult_wire_2_11 = coe_dat_hld_2_11[9:0] * in_dat_hld11[9:0] ;
    wire [19:0] mult_wire_2_12 = coe_dat_hld_2_12[9:0] * in_dat_hld12[9:0] ;
    wire [19:0] mult_wire_2_13 = coe_dat_hld_2_13[9:0] * in_dat_hld13[9:0] ;
    wire [19:0] mult_wire_2_14 = coe_dat_hld_2_14[9:0] * in_dat_hld14[9:0] ;
    wire [19:0] mult_wire_2_15 = coe_dat_hld_2_15[9:0] * in_dat_hld15[9:0] ;
    wire [19:0] mult_wire_2_16 = coe_dat_hld_2_16[9:0] * in_dat_hld16[9:0] ;
    wire [19:0] mult_wire_2_17 = coe_dat_hld_2_17[9:0] * in_dat_hld17[9:0] ;
    wire [19:0] mult_wire_2_18 = coe_dat_hld_2_18[9:0] * in_dat_hld18[9:0] ;
    wire [19:0] mult_wire_2_19 = coe_dat_hld_2_19[9:0] * in_dat_hld19[9:0] ;
    wire [19:0] mult_wire_2_20 = coe_dat_hld_2_20[9:0] * in_dat_hld20[9:0] ;
    wire [19:0] mult_wire_2_21 = coe_dat_hld_2_21[9:0] * in_dat_hld21[9:0] ;
    wire [19:0] mult_wire_2_22 = coe_dat_hld_2_22[9:0] * in_dat_hld22[9:0] ;
    wire [19:0] mult_wire_2_23 = coe_dat_hld_2_23[9:0] * in_dat_hld23[9:0] ;
    wire [19:0] mult_wire_2_24 = coe_dat_hld_2_24[9:0] * in_dat_hld24[9:0] ;
    wire [19:0] mult_wire_2_25 = coe_dat_hld_2_25[9:0] * in_dat_hld25[9:0] ;
    wire [19:0] mult_wire_2_26 = coe_dat_hld_2_26[9:0] * in_dat_hld26[9:0] ;
    wire [19:0] mult_wire_2_27 = coe_dat_hld_2_27[9:0] * in_dat_hld27[9:0] ;
    wire [19:0] mult_wire_2_28 = coe_dat_hld_2_28[9:0] * in_dat_hld28[9:0] ;
    wire [19:0] mult_wire_2_29 = coe_dat_hld_2_29[9:0] * in_dat_hld29[9:0] ;
    wire [19:0] mult_wire_2_30 = coe_dat_hld_2_30[9:0] * in_dat_hld30[9:0] ;
    wire [19:0] mult_wire_2_31 = coe_dat_hld_2_31[9:0] * in_dat_hld31[9:0] ;
    wire [19:0] mult_wire_2_32 = coe_dat_hld_2_32[9:0] * in_dat_hld32[9:0] ;

    wire [19:0] mult_wire_3_01 = coe_dat_hld_3_01[9:0] * in_dat_hld01[9:0] ;
    wire [19:0] mult_wire_3_02 = coe_dat_hld_3_02[9:0] * in_dat_hld02[9:0] ;
    wire [19:0] mult_wire_3_03 = coe_dat_hld_3_03[9:0] * in_dat_hld03[9:0] ;
    wire [19:0] mult_wire_3_04 = coe_dat_hld_3_04[9:0] * in_dat_hld04[9:0] ;
    wire [19:0] mult_wire_3_05 = coe_dat_hld_3_05[9:0] * in_dat_hld05[9:0] ;
    wire [19:0] mult_wire_3_06 = coe_dat_hld_3_06[9:0] * in_dat_hld06[9:0] ;
    wire [19:0] mult_wire_3_07 = coe_dat_hld_3_07[9:0] * in_dat_hld07[9:0] ;
    wire [19:0] mult_wire_3_08 = coe_dat_hld_3_08[9:0] * in_dat_hld08[9:0] ;
    wire [19:0] mult_wire_3_09 = coe_dat_hld_3_09[9:0] * in_dat_hld09[9:0] ;
    wire [19:0] mult_wire_3_10 = coe_dat_hld_3_10[9:0] * in_dat_hld10[9:0] ;
    wire [19:0] mult_wire_3_11 = coe_dat_hld_3_11[9:0] * in_dat_hld11[9:0] ;
    wire [19:0] mult_wire_3_12 = coe_dat_hld_3_12[9:0] * in_dat_hld12[9:0] ;
    wire [19:0] mult_wire_3_13 = coe_dat_hld_3_13[9:0] * in_dat_hld13[9:0] ;
    wire [19:0] mult_wire_3_14 = coe_dat_hld_3_14[9:0] * in_dat_hld14[9:0] ;
    wire [19:0] mult_wire_3_15 = coe_dat_hld_3_15[9:0] * in_dat_hld15[9:0] ;
    wire [19:0] mult_wire_3_16 = coe_dat_hld_3_16[9:0] * in_dat_hld16[9:0] ;
    wire [19:0] mult_wire_3_17 = coe_dat_hld_3_17[9:0] * in_dat_hld17[9:0] ;
    wire [19:0] mult_wire_3_18 = coe_dat_hld_3_18[9:0] * in_dat_hld18[9:0] ;
    wire [19:0] mult_wire_3_19 = coe_dat_hld_3_19[9:0] * in_dat_hld19[9:0] ;
    wire [19:0] mult_wire_3_20 = coe_dat_hld_3_20[9:0] * in_dat_hld20[9:0] ;
    wire [19:0] mult_wire_3_21 = coe_dat_hld_3_21[9:0] * in_dat_hld21[9:0] ;
    wire [19:0] mult_wire_3_22 = coe_dat_hld_3_22[9:0] * in_dat_hld22[9:0] ;
    wire [19:0] mult_wire_3_23 = coe_dat_hld_3_23[9:0] * in_dat_hld23[9:0] ;
    wire [19:0] mult_wire_3_24 = coe_dat_hld_3_24[9:0] * in_dat_hld24[9:0] ;
    wire [19:0] mult_wire_3_25 = coe_dat_hld_3_25[9:0] * in_dat_hld25[9:0] ;
    wire [19:0] mult_wire_3_26 = coe_dat_hld_3_26[9:0] * in_dat_hld26[9:0] ;
    wire [19:0] mult_wire_3_27 = coe_dat_hld_3_27[9:0] * in_dat_hld27[9:0] ;
    wire [19:0] mult_wire_3_28 = coe_dat_hld_3_28[9:0] * in_dat_hld28[9:0] ;
    wire [19:0] mult_wire_3_29 = coe_dat_hld_3_29[9:0] * in_dat_hld29[9:0] ;
    wire [19:0] mult_wire_3_30 = coe_dat_hld_3_30[9:0] * in_dat_hld30[9:0] ;
    wire [19:0] mult_wire_3_31 = coe_dat_hld_3_31[9:0] * in_dat_hld31[9:0] ;
    wire [19:0] mult_wire_3_32 = coe_dat_hld_3_32[9:0] * in_dat_hld32[9:0] ;

    wire [19:0] mult_wire_4_01 = coe_dat_hld_4_01[9:0] * in_dat_hld01[9:0] ;
    wire [19:0] mult_wire_4_02 = coe_dat_hld_4_02[9:0] * in_dat_hld02[9:0] ;
    wire [19:0] mult_wire_4_03 = coe_dat_hld_4_03[9:0] * in_dat_hld03[9:0] ;
    wire [19:0] mult_wire_4_04 = coe_dat_hld_4_04[9:0] * in_dat_hld04[9:0] ;
    wire [19:0] mult_wire_4_05 = coe_dat_hld_4_05[9:0] * in_dat_hld05[9:0] ;
    wire [19:0] mult_wire_4_06 = coe_dat_hld_4_06[9:0] * in_dat_hld06[9:0] ;
    wire [19:0] mult_wire_4_07 = coe_dat_hld_4_07[9:0] * in_dat_hld07[9:0] ;
    wire [19:0] mult_wire_4_08 = coe_dat_hld_4_08[9:0] * in_dat_hld08[9:0] ;
    wire [19:0] mult_wire_4_09 = coe_dat_hld_4_09[9:0] * in_dat_hld09[9:0] ;
    wire [19:0] mult_wire_4_10 = coe_dat_hld_4_10[9:0] * in_dat_hld10[9:0] ;
    wire [19:0] mult_wire_4_11 = coe_dat_hld_4_11[9:0] * in_dat_hld11[9:0] ;
    wire [19:0] mult_wire_4_12 = coe_dat_hld_4_12[9:0] * in_dat_hld12[9:0] ;
    wire [19:0] mult_wire_4_13 = coe_dat_hld_4_13[9:0] * in_dat_hld13[9:0] ;
    wire [19:0] mult_wire_4_14 = coe_dat_hld_4_14[9:0] * in_dat_hld14[9:0] ;
    wire [19:0] mult_wire_4_15 = coe_dat_hld_4_15[9:0] * in_dat_hld15[9:0] ;
    wire [19:0] mult_wire_4_16 = coe_dat_hld_4_16[9:0] * in_dat_hld16[9:0] ;
    wire [19:0] mult_wire_4_17 = coe_dat_hld_4_17[9:0] * in_dat_hld17[9:0] ;
    wire [19:0] mult_wire_4_18 = coe_dat_hld_4_18[9:0] * in_dat_hld18[9:0] ;
    wire [19:0] mult_wire_4_19 = coe_dat_hld_4_19[9:0] * in_dat_hld19[9:0] ;
    wire [19:0] mult_wire_4_20 = coe_dat_hld_4_20[9:0] * in_dat_hld20[9:0] ;
    wire [19:0] mult_wire_4_21 = coe_dat_hld_4_21[9:0] * in_dat_hld21[9:0] ;
    wire [19:0] mult_wire_4_22 = coe_dat_hld_4_22[9:0] * in_dat_hld22[9:0] ;
    wire [19:0] mult_wire_4_23 = coe_dat_hld_4_23[9:0] * in_dat_hld23[9:0] ;
    wire [19:0] mult_wire_4_24 = coe_dat_hld_4_24[9:0] * in_dat_hld24[9:0] ;
    wire [19:0] mult_wire_4_25 = coe_dat_hld_4_25[9:0] * in_dat_hld25[9:0] ;
    wire [19:0] mult_wire_4_26 = coe_dat_hld_4_26[9:0] * in_dat_hld26[9:0] ;
    wire [19:0] mult_wire_4_27 = coe_dat_hld_4_27[9:0] * in_dat_hld27[9:0] ;
    wire [19:0] mult_wire_4_28 = coe_dat_hld_4_28[9:0] * in_dat_hld28[9:0] ;
    wire [19:0] mult_wire_4_29 = coe_dat_hld_4_29[9:0] * in_dat_hld29[9:0] ;
    wire [19:0] mult_wire_4_30 = coe_dat_hld_4_30[9:0] * in_dat_hld30[9:0] ;
    wire [19:0] mult_wire_4_31 = coe_dat_hld_4_31[9:0] * in_dat_hld31[9:0] ;
    wire [19:0] mult_wire_4_32 = coe_dat_hld_4_32[9:0] * in_dat_hld32[9:0] ;

    reg [19:0] mult_reg_1_01, mult_reg_1_02, mult_reg_1_03, mult_reg_1_04,
               mult_reg_1_05, mult_reg_1_06, mult_reg_1_07, mult_reg_1_08,
               mult_reg_1_09, mult_reg_1_10, mult_reg_1_11, mult_reg_1_12,
			   mult_reg_1_13, mult_reg_1_14, mult_reg_1_15, mult_reg_1_16,
               mult_reg_1_17, mult_reg_1_18, mult_reg_1_19, mult_reg_1_20,
               mult_reg_1_21, mult_reg_1_22, mult_reg_1_23, mult_reg_1_24,
               mult_reg_1_25, mult_reg_1_26, mult_reg_1_27, mult_reg_1_28,
               mult_reg_1_29, mult_reg_1_30, mult_reg_1_31, mult_reg_1_32 ;

    reg [19:0] mult_reg_2_01, mult_reg_2_02, mult_reg_2_03, mult_reg_2_04,
               mult_reg_2_05, mult_reg_2_06, mult_reg_2_07, mult_reg_2_08,
               mult_reg_2_09, mult_reg_2_10, mult_reg_2_11, mult_reg_2_12,
			   mult_reg_2_13, mult_reg_2_14, mult_reg_2_15, mult_reg_2_16,
               mult_reg_2_17, mult_reg_2_18, mult_reg_2_19, mult_reg_2_20,
               mult_reg_2_21, mult_reg_2_22, mult_reg_2_23, mult_reg_2_24,
               mult_reg_2_25, mult_reg_2_26, mult_reg_2_27, mult_reg_2_28,
               mult_reg_2_29, mult_reg_2_30, mult_reg_2_31, mult_reg_2_32 ;

    reg [19:0] mult_reg_3_01, mult_reg_3_02, mult_reg_3_03, mult_reg_3_04,
               mult_reg_3_05, mult_reg_3_06, mult_reg_3_07, mult_reg_3_08,
               mult_reg_3_09, mult_reg_3_10, mult_reg_3_11, mult_reg_3_12,
			   mult_reg_3_13, mult_reg_3_14, mult_reg_3_15, mult_reg_3_16,
               mult_reg_3_17, mult_reg_3_18, mult_reg_3_19, mult_reg_3_20,
               mult_reg_3_21, mult_reg_3_22, mult_reg_3_23, mult_reg_3_24,
               mult_reg_3_25, mult_reg_3_26, mult_reg_3_27, mult_reg_3_28,
               mult_reg_3_29, mult_reg_3_30, mult_reg_3_31, mult_reg_3_32 ;

    reg [19:0] mult_reg_4_01, mult_reg_4_02, mult_reg_4_03, mult_reg_4_04,
               mult_reg_4_05, mult_reg_4_06, mult_reg_4_07, mult_reg_4_08,
               mult_reg_4_09, mult_reg_4_10, mult_reg_4_11, mult_reg_4_12,
			   mult_reg_4_13, mult_reg_4_14, mult_reg_4_15, mult_reg_4_16,
               mult_reg_4_17, mult_reg_4_18, mult_reg_4_19, mult_reg_4_20,
               mult_reg_4_21, mult_reg_4_22, mult_reg_4_23, mult_reg_4_24,
               mult_reg_4_25, mult_reg_4_26, mult_reg_4_27, mult_reg_4_28,
               mult_reg_4_29, mult_reg_4_30, mult_reg_4_31, mult_reg_4_32 ;

    always @ (posedge clk) begin
		if(rst) begin
			mult_reg_1_01[19:0] <= #DLY 20'd0 ;
			mult_reg_1_02[19:0] <= #DLY 20'd0 ;
			mult_reg_1_03[19:0] <= #DLY 20'd0 ;
			mult_reg_1_04[19:0] <= #DLY 20'd0 ;
			mult_reg_1_05[19:0] <= #DLY 20'd0 ;
			mult_reg_1_06[19:0] <= #DLY 20'd0 ;
			mult_reg_1_07[19:0] <= #DLY 20'd0 ;
			mult_reg_1_08[19:0] <= #DLY 20'd0 ;
			mult_reg_1_09[19:0] <= #DLY 20'd0 ;
			mult_reg_1_10[19:0] <= #DLY 20'd0 ;
			mult_reg_1_11[19:0] <= #DLY 20'd0 ;
			mult_reg_1_12[19:0] <= #DLY 20'd0 ;
			mult_reg_1_13[19:0] <= #DLY 20'd0 ;
			mult_reg_1_14[19:0] <= #DLY 20'd0 ;
			mult_reg_1_15[19:0] <= #DLY 20'd0 ;
			mult_reg_1_16[19:0] <= #DLY 20'd0 ;
			mult_reg_1_17[19:0] <= #DLY 20'd0 ;
			mult_reg_1_18[19:0] <= #DLY 20'd0 ;
			mult_reg_1_19[19:0] <= #DLY 20'd0 ;
			mult_reg_1_20[19:0] <= #DLY 20'd0 ;
			mult_reg_1_21[19:0] <= #DLY 20'd0 ;
			mult_reg_1_22[19:0] <= #DLY 20'd0 ;
			mult_reg_1_23[19:0] <= #DLY 20'd0 ;
			mult_reg_1_24[19:0] <= #DLY 20'd0 ;
			mult_reg_1_25[19:0] <= #DLY 20'd0 ;
			mult_reg_1_26[19:0] <= #DLY 20'd0 ;
			mult_reg_1_27[19:0] <= #DLY 20'd0 ;
			mult_reg_1_28[19:0] <= #DLY 20'd0 ;
			mult_reg_1_29[19:0] <= #DLY 20'd0 ;
			mult_reg_1_30[19:0] <= #DLY 20'd0 ;
			mult_reg_1_31[19:0] <= #DLY 20'd0 ;
			mult_reg_1_32[19:0] <= #DLY 20'd0 ;
		end else begin
			mult_reg_1_01[19:0] <= #DLY mult_wire_1_01[19:0] ;
			mult_reg_1_02[19:0] <= #DLY mult_wire_1_02[19:0] ;
			mult_reg_1_03[19:0] <= #DLY mult_wire_1_03[19:0] ;
			mult_reg_1_04[19:0] <= #DLY mult_wire_1_04[19:0] ;
			mult_reg_1_05[19:0] <= #DLY mult_wire_1_05[19:0] ;
			mult_reg_1_06[19:0] <= #DLY mult_wire_1_06[19:0] ;
			mult_reg_1_07[19:0] <= #DLY mult_wire_1_07[19:0] ;
			mult_reg_1_08[19:0] <= #DLY mult_wire_1_08[19:0] ;
			mult_reg_1_09[19:0] <= #DLY mult_wire_1_09[19:0] ;
			mult_reg_1_10[19:0] <= #DLY mult_wire_1_10[19:0] ;
			mult_reg_1_11[19:0] <= #DLY mult_wire_1_11[19:0] ;
			mult_reg_1_12[19:0] <= #DLY mult_wire_1_12[19:0] ;
			mult_reg_1_13[19:0] <= #DLY mult_wire_1_13[19:0] ;
			mult_reg_1_14[19:0] <= #DLY mult_wire_1_14[19:0] ;
			mult_reg_1_15[19:0] <= #DLY mult_wire_1_15[19:0] ;
			mult_reg_1_16[19:0] <= #DLY mult_wire_1_16[19:0] ;
			mult_reg_1_17[19:0] <= #DLY mult_wire_1_17[19:0] ;
			mult_reg_1_18[19:0] <= #DLY mult_wire_1_18[19:0] ;
			mult_reg_1_19[19:0] <= #DLY mult_wire_1_19[19:0] ;
			mult_reg_1_20[19:0] <= #DLY mult_wire_1_20[19:0] ;
			mult_reg_1_21[19:0] <= #DLY mult_wire_1_21[19:0] ;
			mult_reg_1_22[19:0] <= #DLY mult_wire_1_22[19:0] ;
			mult_reg_1_23[19:0] <= #DLY mult_wire_1_23[19:0] ;
			mult_reg_1_24[19:0] <= #DLY mult_wire_1_24[19:0] ;
			mult_reg_1_25[19:0] <= #DLY mult_wire_1_25[19:0] ;
			mult_reg_1_26[19:0] <= #DLY mult_wire_1_26[19:0] ;
			mult_reg_1_27[19:0] <= #DLY mult_wire_1_27[19:0] ;
			mult_reg_1_28[19:0] <= #DLY mult_wire_1_28[19:0] ;
			mult_reg_1_29[19:0] <= #DLY mult_wire_1_29[19:0] ;
			mult_reg_1_30[19:0] <= #DLY mult_wire_1_30[19:0] ;
			mult_reg_1_31[19:0] <= #DLY mult_wire_1_31[19:0] ;
			mult_reg_1_32[19:0] <= #DLY mult_wire_1_32[19:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			mult_reg_2_01[19:0] <= #DLY 20'd0 ;
			mult_reg_2_02[19:0] <= #DLY 20'd0 ;
			mult_reg_2_03[19:0] <= #DLY 20'd0 ;
			mult_reg_2_04[19:0] <= #DLY 20'd0 ;
			mult_reg_2_05[19:0] <= #DLY 20'd0 ;
			mult_reg_2_06[19:0] <= #DLY 20'd0 ;
			mult_reg_2_07[19:0] <= #DLY 20'd0 ;
			mult_reg_2_08[19:0] <= #DLY 20'd0 ;
			mult_reg_2_09[19:0] <= #DLY 20'd0 ;
			mult_reg_2_10[19:0] <= #DLY 20'd0 ;
			mult_reg_2_11[19:0] <= #DLY 20'd0 ;
			mult_reg_2_12[19:0] <= #DLY 20'd0 ;
			mult_reg_2_13[19:0] <= #DLY 20'd0 ;
			mult_reg_2_14[19:0] <= #DLY 20'd0 ;
			mult_reg_2_15[19:0] <= #DLY 20'd0 ;
			mult_reg_2_16[19:0] <= #DLY 20'd0 ;
			mult_reg_2_17[19:0] <= #DLY 20'd0 ;
			mult_reg_2_18[19:0] <= #DLY 20'd0 ;
			mult_reg_2_19[19:0] <= #DLY 20'd0 ;
			mult_reg_2_20[19:0] <= #DLY 20'd0 ;
			mult_reg_2_21[19:0] <= #DLY 20'd0 ;
			mult_reg_2_22[19:0] <= #DLY 20'd0 ;
			mult_reg_2_23[19:0] <= #DLY 20'd0 ;
			mult_reg_2_24[19:0] <= #DLY 20'd0 ;
			mult_reg_2_25[19:0] <= #DLY 20'd0 ;
			mult_reg_2_26[19:0] <= #DLY 20'd0 ;
			mult_reg_2_27[19:0] <= #DLY 20'd0 ;
			mult_reg_2_28[19:0] <= #DLY 20'd0 ;
			mult_reg_2_29[19:0] <= #DLY 20'd0 ;
			mult_reg_2_30[19:0] <= #DLY 20'd0 ;
			mult_reg_2_31[19:0] <= #DLY 20'd0 ;
			mult_reg_2_32[19:0] <= #DLY 20'd0 ;
		end else begin
			mult_reg_2_01[19:0] <= #DLY mult_wire_2_01[19:0] ;
			mult_reg_2_02[19:0] <= #DLY mult_wire_2_02[19:0] ;
			mult_reg_2_03[19:0] <= #DLY mult_wire_2_03[19:0] ;
			mult_reg_2_04[19:0] <= #DLY mult_wire_2_04[19:0] ;
			mult_reg_2_05[19:0] <= #DLY mult_wire_2_05[19:0] ;
			mult_reg_2_06[19:0] <= #DLY mult_wire_2_06[19:0] ;
			mult_reg_2_07[19:0] <= #DLY mult_wire_2_07[19:0] ;
			mult_reg_2_08[19:0] <= #DLY mult_wire_2_08[19:0] ;
			mult_reg_2_09[19:0] <= #DLY mult_wire_2_09[19:0] ;
			mult_reg_2_10[19:0] <= #DLY mult_wire_2_10[19:0] ;
			mult_reg_2_11[19:0] <= #DLY mult_wire_2_11[19:0] ;
			mult_reg_2_12[19:0] <= #DLY mult_wire_2_12[19:0] ;
			mult_reg_2_13[19:0] <= #DLY mult_wire_2_13[19:0] ;
			mult_reg_2_14[19:0] <= #DLY mult_wire_2_14[19:0] ;
			mult_reg_2_15[19:0] <= #DLY mult_wire_2_15[19:0] ;
			mult_reg_2_16[19:0] <= #DLY mult_wire_2_16[19:0] ;
			mult_reg_2_17[19:0] <= #DLY mult_wire_2_17[19:0] ;
			mult_reg_2_18[19:0] <= #DLY mult_wire_2_18[19:0] ;
			mult_reg_2_19[19:0] <= #DLY mult_wire_2_19[19:0] ;
			mult_reg_2_20[19:0] <= #DLY mult_wire_2_20[19:0] ;
			mult_reg_2_21[19:0] <= #DLY mult_wire_2_21[19:0] ;
			mult_reg_2_22[19:0] <= #DLY mult_wire_2_22[19:0] ;
			mult_reg_2_23[19:0] <= #DLY mult_wire_2_23[19:0] ;
			mult_reg_2_24[19:0] <= #DLY mult_wire_2_24[19:0] ;
			mult_reg_2_25[19:0] <= #DLY mult_wire_2_25[19:0] ;
			mult_reg_2_26[19:0] <= #DLY mult_wire_2_26[19:0] ;
			mult_reg_2_27[19:0] <= #DLY mult_wire_2_27[19:0] ;
			mult_reg_2_28[19:0] <= #DLY mult_wire_2_28[19:0] ;
			mult_reg_2_29[19:0] <= #DLY mult_wire_2_29[19:0] ;
			mult_reg_2_30[19:0] <= #DLY mult_wire_2_30[19:0] ;
			mult_reg_2_31[19:0] <= #DLY mult_wire_2_31[19:0] ;
			mult_reg_2_32[19:0] <= #DLY mult_wire_2_32[19:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			mult_reg_3_01[19:0] <= #DLY 20'd0 ;
			mult_reg_3_02[19:0] <= #DLY 20'd0 ;
			mult_reg_3_03[19:0] <= #DLY 20'd0 ;
			mult_reg_3_04[19:0] <= #DLY 20'd0 ;
			mult_reg_3_05[19:0] <= #DLY 20'd0 ;
			mult_reg_3_06[19:0] <= #DLY 20'd0 ;
			mult_reg_3_07[19:0] <= #DLY 20'd0 ;
			mult_reg_3_08[19:0] <= #DLY 20'd0 ;
			mult_reg_3_09[19:0] <= #DLY 20'd0 ;
			mult_reg_3_10[19:0] <= #DLY 20'd0 ;
			mult_reg_3_11[19:0] <= #DLY 20'd0 ;
			mult_reg_3_12[19:0] <= #DLY 20'd0 ;
			mult_reg_3_13[19:0] <= #DLY 20'd0 ;
			mult_reg_3_14[19:0] <= #DLY 20'd0 ;
			mult_reg_3_15[19:0] <= #DLY 20'd0 ;
			mult_reg_3_16[19:0] <= #DLY 20'd0 ;
			mult_reg_3_17[19:0] <= #DLY 20'd0 ;
			mult_reg_3_18[19:0] <= #DLY 20'd0 ;
			mult_reg_3_19[19:0] <= #DLY 20'd0 ;
			mult_reg_3_20[19:0] <= #DLY 20'd0 ;
			mult_reg_3_21[19:0] <= #DLY 20'd0 ;
			mult_reg_3_22[19:0] <= #DLY 20'd0 ;
			mult_reg_3_23[19:0] <= #DLY 20'd0 ;
			mult_reg_3_24[19:0] <= #DLY 20'd0 ;
			mult_reg_3_25[19:0] <= #DLY 20'd0 ;
			mult_reg_3_26[19:0] <= #DLY 20'd0 ;
			mult_reg_3_27[19:0] <= #DLY 20'd0 ;
			mult_reg_3_28[19:0] <= #DLY 20'd0 ;
			mult_reg_3_29[19:0] <= #DLY 20'd0 ;
			mult_reg_3_30[19:0] <= #DLY 20'd0 ;
			mult_reg_3_31[19:0] <= #DLY 20'd0 ;
			mult_reg_3_32[19:0] <= #DLY 20'd0 ;
		end else begin
			mult_reg_3_01[19:0] <= #DLY mult_wire_3_01[19:0] ;
			mult_reg_3_02[19:0] <= #DLY mult_wire_3_02[19:0] ;
			mult_reg_3_03[19:0] <= #DLY mult_wire_3_03[19:0] ;
			mult_reg_3_04[19:0] <= #DLY mult_wire_3_04[19:0] ;
			mult_reg_3_05[19:0] <= #DLY mult_wire_3_05[19:0] ;
			mult_reg_3_06[19:0] <= #DLY mult_wire_3_06[19:0] ;
			mult_reg_3_07[19:0] <= #DLY mult_wire_3_07[19:0] ;
			mult_reg_3_08[19:0] <= #DLY mult_wire_3_08[19:0] ;
			mult_reg_3_09[19:0] <= #DLY mult_wire_3_09[19:0] ;
			mult_reg_3_10[19:0] <= #DLY mult_wire_3_10[19:0] ;
			mult_reg_3_11[19:0] <= #DLY mult_wire_3_11[19:0] ;
			mult_reg_3_12[19:0] <= #DLY mult_wire_3_12[19:0] ;
			mult_reg_3_13[19:0] <= #DLY mult_wire_3_13[19:0] ;
			mult_reg_3_14[19:0] <= #DLY mult_wire_3_14[19:0] ;
			mult_reg_3_15[19:0] <= #DLY mult_wire_3_15[19:0] ;
			mult_reg_3_16[19:0] <= #DLY mult_wire_3_16[19:0] ;
			mult_reg_3_17[19:0] <= #DLY mult_wire_3_17[19:0] ;
			mult_reg_3_18[19:0] <= #DLY mult_wire_3_18[19:0] ;
			mult_reg_3_19[19:0] <= #DLY mult_wire_3_19[19:0] ;
			mult_reg_3_20[19:0] <= #DLY mult_wire_3_20[19:0] ;
			mult_reg_3_21[19:0] <= #DLY mult_wire_3_21[19:0] ;
			mult_reg_3_22[19:0] <= #DLY mult_wire_3_22[19:0] ;
			mult_reg_3_23[19:0] <= #DLY mult_wire_3_23[19:0] ;
			mult_reg_3_24[19:0] <= #DLY mult_wire_3_24[19:0] ;
			mult_reg_3_25[19:0] <= #DLY mult_wire_3_25[19:0] ;
			mult_reg_3_26[19:0] <= #DLY mult_wire_3_26[19:0] ;
			mult_reg_3_27[19:0] <= #DLY mult_wire_3_27[19:0] ;
			mult_reg_3_28[19:0] <= #DLY mult_wire_3_28[19:0] ;
			mult_reg_3_29[19:0] <= #DLY mult_wire_3_29[19:0] ;
			mult_reg_3_30[19:0] <= #DLY mult_wire_3_30[19:0] ;
			mult_reg_3_31[19:0] <= #DLY mult_wire_3_31[19:0] ;
			mult_reg_3_32[19:0] <= #DLY mult_wire_3_32[19:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			mult_reg_4_01[19:0] <= #DLY 20'd0 ;
			mult_reg_4_02[19:0] <= #DLY 20'd0 ;
			mult_reg_4_03[19:0] <= #DLY 20'd0 ;
			mult_reg_4_04[19:0] <= #DLY 20'd0 ;
			mult_reg_4_05[19:0] <= #DLY 20'd0 ;
			mult_reg_4_06[19:0] <= #DLY 20'd0 ;
			mult_reg_4_07[19:0] <= #DLY 20'd0 ;
			mult_reg_4_08[19:0] <= #DLY 20'd0 ;
			mult_reg_4_09[19:0] <= #DLY 20'd0 ;
			mult_reg_4_10[19:0] <= #DLY 20'd0 ;
			mult_reg_4_11[19:0] <= #DLY 20'd0 ;
			mult_reg_4_12[19:0] <= #DLY 20'd0 ;
			mult_reg_4_13[19:0] <= #DLY 20'd0 ;
			mult_reg_4_14[19:0] <= #DLY 20'd0 ;
			mult_reg_4_15[19:0] <= #DLY 20'd0 ;
			mult_reg_4_16[19:0] <= #DLY 20'd0 ;
			mult_reg_4_17[19:0] <= #DLY 20'd0 ;
			mult_reg_4_18[19:0] <= #DLY 20'd0 ;
			mult_reg_4_19[19:0] <= #DLY 20'd0 ;
			mult_reg_4_20[19:0] <= #DLY 20'd0 ;
			mult_reg_4_21[19:0] <= #DLY 20'd0 ;
			mult_reg_4_22[19:0] <= #DLY 20'd0 ;
			mult_reg_4_23[19:0] <= #DLY 20'd0 ;
			mult_reg_4_24[19:0] <= #DLY 20'd0 ;
			mult_reg_4_25[19:0] <= #DLY 20'd0 ;
			mult_reg_4_26[19:0] <= #DLY 20'd0 ;
			mult_reg_4_27[19:0] <= #DLY 20'd0 ;
			mult_reg_4_28[19:0] <= #DLY 20'd0 ;
			mult_reg_4_29[19:0] <= #DLY 20'd0 ;
			mult_reg_4_30[19:0] <= #DLY 20'd0 ;
			mult_reg_4_31[19:0] <= #DLY 20'd0 ;
			mult_reg_4_32[19:0] <= #DLY 20'd0 ;
		end else begin
			mult_reg_4_01[19:0] <= #DLY mult_wire_4_01[19:0] ;
			mult_reg_4_02[19:0] <= #DLY mult_wire_4_02[19:0] ;
			mult_reg_4_03[19:0] <= #DLY mult_wire_4_03[19:0] ;
			mult_reg_4_04[19:0] <= #DLY mult_wire_4_04[19:0] ;
			mult_reg_4_05[19:0] <= #DLY mult_wire_4_05[19:0] ;
			mult_reg_4_06[19:0] <= #DLY mult_wire_4_06[19:0] ;
			mult_reg_4_07[19:0] <= #DLY mult_wire_4_07[19:0] ;
			mult_reg_4_08[19:0] <= #DLY mult_wire_4_08[19:0] ;
			mult_reg_4_09[19:0] <= #DLY mult_wire_4_09[19:0] ;
			mult_reg_4_10[19:0] <= #DLY mult_wire_4_10[19:0] ;
			mult_reg_4_11[19:0] <= #DLY mult_wire_4_11[19:0] ;
			mult_reg_4_12[19:0] <= #DLY mult_wire_4_12[19:0] ;
			mult_reg_4_13[19:0] <= #DLY mult_wire_4_13[19:0] ;
			mult_reg_4_14[19:0] <= #DLY mult_wire_4_14[19:0] ;
			mult_reg_4_15[19:0] <= #DLY mult_wire_4_15[19:0] ;
			mult_reg_4_16[19:0] <= #DLY mult_wire_4_16[19:0] ;
			mult_reg_4_17[19:0] <= #DLY mult_wire_4_17[19:0] ;
			mult_reg_4_18[19:0] <= #DLY mult_wire_4_18[19:0] ;
			mult_reg_4_19[19:0] <= #DLY mult_wire_4_19[19:0] ;
			mult_reg_4_20[19:0] <= #DLY mult_wire_4_20[19:0] ;
			mult_reg_4_21[19:0] <= #DLY mult_wire_4_21[19:0] ;
			mult_reg_4_22[19:0] <= #DLY mult_wire_4_22[19:0] ;
			mult_reg_4_23[19:0] <= #DLY mult_wire_4_23[19:0] ;
			mult_reg_4_24[19:0] <= #DLY mult_wire_4_24[19:0] ;
			mult_reg_4_25[19:0] <= #DLY mult_wire_4_25[19:0] ;
			mult_reg_4_26[19:0] <= #DLY mult_wire_4_26[19:0] ;
			mult_reg_4_27[19:0] <= #DLY mult_wire_4_27[19:0] ;
			mult_reg_4_28[19:0] <= #DLY mult_wire_4_28[19:0] ;
			mult_reg_4_29[19:0] <= #DLY mult_wire_4_29[19:0] ;
			mult_reg_4_30[19:0] <= #DLY mult_wire_4_30[19:0] ;
			mult_reg_4_31[19:0] <= #DLY mult_wire_4_31[19:0] ;
			mult_reg_4_32[19:0] <= #DLY mult_wire_4_32[19:0] ;
		end
	end

    /****************************
    // pipeline[10] Active
    ****************************/	
    wire [20:0] sum32_16_wire_1_01 = { 1'd0, mult_reg_1_01[19:0]} + { 1'd0, mult_reg_1_02[19:0]} ;
	wire [20:0] sum32_16_wire_1_02 = { 1'd0, mult_reg_1_03[19:0]} + { 1'd0, mult_reg_1_04[19:0]} ;
	wire [20:0] sum32_16_wire_1_03 = { 1'd0, mult_reg_1_05[19:0]} + { 1'd0, mult_reg_1_06[19:0]} ;
	wire [20:0] sum32_16_wire_1_04 = { 1'd0, mult_reg_1_07[19:0]} + { 1'd0, mult_reg_1_08[19:0]} ;
    wire [20:0] sum32_16_wire_1_05 = { 1'd0, mult_reg_1_09[19:0]} + { 1'd0, mult_reg_1_10[19:0]} ;
	wire [20:0] sum32_16_wire_1_06 = { 1'd0, mult_reg_1_11[19:0]} + { 1'd0, mult_reg_1_12[19:0]} ;
	wire [20:0] sum32_16_wire_1_07 = { 1'd0, mult_reg_1_13[19:0]} + { 1'd0, mult_reg_1_14[19:0]} ;
	wire [20:0] sum32_16_wire_1_08 = { 1'd0, mult_reg_1_15[19:0]} + { 1'd0, mult_reg_1_16[19:0]} ;
    wire [20:0] sum32_16_wire_1_09 = { 1'd0, mult_reg_1_17[19:0]} + { 1'd0, mult_reg_1_18[19:0]} ;
	wire [20:0] sum32_16_wire_1_10 = { 1'd0, mult_reg_1_19[19:0]} + { 1'd0, mult_reg_1_20[19:0]} ;
	wire [20:0] sum32_16_wire_1_11 = { 1'd0, mult_reg_1_21[19:0]} + { 1'd0, mult_reg_1_22[19:0]} ;
	wire [20:0] sum32_16_wire_1_12 = { 1'd0, mult_reg_1_23[19:0]} + { 1'd0, mult_reg_1_24[19:0]} ;
    wire [20:0] sum32_16_wire_1_13 = { 1'd0, mult_reg_1_25[19:0]} + { 1'd0, mult_reg_1_26[19:0]} ;
	wire [20:0] sum32_16_wire_1_14 = { 1'd0, mult_reg_1_27[19:0]} + { 1'd0, mult_reg_1_28[19:0]} ;
	wire [20:0] sum32_16_wire_1_15 = { 1'd0, mult_reg_1_29[19:0]} + { 1'd0, mult_reg_1_30[19:0]} ;
	wire [20:0] sum32_16_wire_1_16 = { 1'd0, mult_reg_1_31[19:0]} + { 1'd0, mult_reg_1_32[19:0]} ;

    wire [20:0] sum32_16_wire_2_01 = { 1'd0, mult_reg_2_01[19:0]} + { 1'd0, mult_reg_2_02[19:0]} ;
	wire [20:0] sum32_16_wire_2_02 = { 1'd0, mult_reg_2_03[19:0]} + { 1'd0, mult_reg_2_04[19:0]} ;
	wire [20:0] sum32_16_wire_2_03 = { 1'd0, mult_reg_2_05[19:0]} + { 1'd0, mult_reg_2_06[19:0]} ;
	wire [20:0] sum32_16_wire_2_04 = { 1'd0, mult_reg_2_07[19:0]} + { 1'd0, mult_reg_2_08[19:0]} ;
    wire [20:0] sum32_16_wire_2_05 = { 1'd0, mult_reg_2_09[19:0]} + { 1'd0, mult_reg_2_10[19:0]} ;
	wire [20:0] sum32_16_wire_2_06 = { 1'd0, mult_reg_2_11[19:0]} + { 1'd0, mult_reg_2_12[19:0]} ;
	wire [20:0] sum32_16_wire_2_07 = { 1'd0, mult_reg_2_13[19:0]} + { 1'd0, mult_reg_2_14[19:0]} ;
	wire [20:0] sum32_16_wire_2_08 = { 1'd0, mult_reg_2_15[19:0]} + { 1'd0, mult_reg_2_16[19:0]} ;
    wire [20:0] sum32_16_wire_2_09 = { 1'd0, mult_reg_2_17[19:0]} + { 1'd0, mult_reg_2_18[19:0]} ;
	wire [20:0] sum32_16_wire_2_10 = { 1'd0, mult_reg_2_19[19:0]} + { 1'd0, mult_reg_2_20[19:0]} ;
	wire [20:0] sum32_16_wire_2_11 = { 1'd0, mult_reg_2_21[19:0]} + { 1'd0, mult_reg_2_22[19:0]} ;
	wire [20:0] sum32_16_wire_2_12 = { 1'd0, mult_reg_2_23[19:0]} + { 1'd0, mult_reg_2_24[19:0]} ;
    wire [20:0] sum32_16_wire_2_13 = { 1'd0, mult_reg_2_25[19:0]} + { 1'd0, mult_reg_2_26[19:0]} ;
	wire [20:0] sum32_16_wire_2_14 = { 1'd0, mult_reg_2_27[19:0]} + { 1'd0, mult_reg_2_28[19:0]} ;
	wire [20:0] sum32_16_wire_2_15 = { 1'd0, mult_reg_2_29[19:0]} + { 1'd0, mult_reg_2_30[19:0]} ;
	wire [20:0] sum32_16_wire_2_16 = { 1'd0, mult_reg_2_31[19:0]} + { 1'd0, mult_reg_2_32[19:0]} ;

    wire [20:0] sum32_16_wire_3_01 = { 1'd0, mult_reg_3_01[19:0]} + { 1'd0, mult_reg_3_02[19:0]} ;
	wire [20:0] sum32_16_wire_3_02 = { 1'd0, mult_reg_3_03[19:0]} + { 1'd0, mult_reg_3_04[19:0]} ;
	wire [20:0] sum32_16_wire_3_03 = { 1'd0, mult_reg_3_05[19:0]} + { 1'd0, mult_reg_3_06[19:0]} ;
	wire [20:0] sum32_16_wire_3_04 = { 1'd0, mult_reg_3_07[19:0]} + { 1'd0, mult_reg_3_08[19:0]} ;
    wire [20:0] sum32_16_wire_3_05 = { 1'd0, mult_reg_3_09[19:0]} + { 1'd0, mult_reg_3_10[19:0]} ;
	wire [20:0] sum32_16_wire_3_06 = { 1'd0, mult_reg_3_11[19:0]} + { 1'd0, mult_reg_3_12[19:0]} ;
	wire [20:0] sum32_16_wire_3_07 = { 1'd0, mult_reg_3_13[19:0]} + { 1'd0, mult_reg_3_14[19:0]} ;
	wire [20:0] sum32_16_wire_3_08 = { 1'd0, mult_reg_3_15[19:0]} + { 1'd0, mult_reg_3_16[19:0]} ;
    wire [20:0] sum32_16_wire_3_09 = { 1'd0, mult_reg_3_17[19:0]} + { 1'd0, mult_reg_3_18[19:0]} ;
	wire [20:0] sum32_16_wire_3_10 = { 1'd0, mult_reg_3_19[19:0]} + { 1'd0, mult_reg_3_20[19:0]} ;
	wire [20:0] sum32_16_wire_3_11 = { 1'd0, mult_reg_3_21[19:0]} + { 1'd0, mult_reg_3_22[19:0]} ;
	wire [20:0] sum32_16_wire_3_12 = { 1'd0, mult_reg_3_23[19:0]} + { 1'd0, mult_reg_3_24[19:0]} ;
    wire [20:0] sum32_16_wire_3_13 = { 1'd0, mult_reg_3_25[19:0]} + { 1'd0, mult_reg_3_26[19:0]} ;
	wire [20:0] sum32_16_wire_3_14 = { 1'd0, mult_reg_3_27[19:0]} + { 1'd0, mult_reg_3_28[19:0]} ;
	wire [20:0] sum32_16_wire_3_15 = { 1'd0, mult_reg_3_29[19:0]} + { 1'd0, mult_reg_3_30[19:0]} ;
	wire [20:0] sum32_16_wire_3_16 = { 1'd0, mult_reg_3_31[19:0]} + { 1'd0, mult_reg_3_32[19:0]} ;

    wire [20:0] sum32_16_wire_4_01 = { 1'd0, mult_reg_4_01[19:0]} + { 1'd0, mult_reg_4_02[19:0]} ;
	wire [20:0] sum32_16_wire_4_02 = { 1'd0, mult_reg_4_03[19:0]} + { 1'd0, mult_reg_4_04[19:0]} ;
	wire [20:0] sum32_16_wire_4_03 = { 1'd0, mult_reg_4_05[19:0]} + { 1'd0, mult_reg_4_06[19:0]} ;
	wire [20:0] sum32_16_wire_4_04 = { 1'd0, mult_reg_4_07[19:0]} + { 1'd0, mult_reg_4_08[19:0]} ;
    wire [20:0] sum32_16_wire_4_05 = { 1'd0, mult_reg_4_09[19:0]} + { 1'd0, mult_reg_4_10[19:0]} ;
	wire [20:0] sum32_16_wire_4_06 = { 1'd0, mult_reg_4_11[19:0]} + { 1'd0, mult_reg_4_12[19:0]} ;
	wire [20:0] sum32_16_wire_4_07 = { 1'd0, mult_reg_4_13[19:0]} + { 1'd0, mult_reg_4_14[19:0]} ;
	wire [20:0] sum32_16_wire_4_08 = { 1'd0, mult_reg_4_15[19:0]} + { 1'd0, mult_reg_4_16[19:0]} ;
    wire [20:0] sum32_16_wire_4_09 = { 1'd0, mult_reg_4_17[19:0]} + { 1'd0, mult_reg_4_18[19:0]} ;
	wire [20:0] sum32_16_wire_4_10 = { 1'd0, mult_reg_4_19[19:0]} + { 1'd0, mult_reg_4_20[19:0]} ;
	wire [20:0] sum32_16_wire_4_11 = { 1'd0, mult_reg_4_21[19:0]} + { 1'd0, mult_reg_4_22[19:0]} ;
	wire [20:0] sum32_16_wire_4_12 = { 1'd0, mult_reg_4_23[19:0]} + { 1'd0, mult_reg_4_24[19:0]} ;
    wire [20:0] sum32_16_wire_4_13 = { 1'd0, mult_reg_4_25[19:0]} + { 1'd0, mult_reg_4_26[19:0]} ;
	wire [20:0] sum32_16_wire_4_14 = { 1'd0, mult_reg_4_27[19:0]} + { 1'd0, mult_reg_4_28[19:0]} ;
	wire [20:0] sum32_16_wire_4_15 = { 1'd0, mult_reg_4_29[19:0]} + { 1'd0, mult_reg_4_30[19:0]} ;
	wire [20:0] sum32_16_wire_4_16 = { 1'd0, mult_reg_4_31[19:0]} + { 1'd0, mult_reg_4_32[19:0]} ;

    reg [20:0] sum32_16_reg_1_01, sum32_16_reg_1_02, sum32_16_reg_1_03, sum32_16_reg_1_04,
	           sum32_16_reg_1_05, sum32_16_reg_1_06, sum32_16_reg_1_07, sum32_16_reg_1_08,
			   sum32_16_reg_1_09, sum32_16_reg_1_10, sum32_16_reg_1_11, sum32_16_reg_1_12,
			   sum32_16_reg_1_13, sum32_16_reg_1_14, sum32_16_reg_1_15, sum32_16_reg_1_16;

    reg [20:0] sum32_16_reg_2_01, sum32_16_reg_2_02, sum32_16_reg_2_03, sum32_16_reg_2_04,
	           sum32_16_reg_2_05, sum32_16_reg_2_06, sum32_16_reg_2_07, sum32_16_reg_2_08,
			   sum32_16_reg_2_09, sum32_16_reg_2_10, sum32_16_reg_2_11, sum32_16_reg_2_12,
			   sum32_16_reg_2_13, sum32_16_reg_2_14, sum32_16_reg_2_15, sum32_16_reg_2_16;

    reg [20:0] sum32_16_reg_3_01, sum32_16_reg_3_02, sum32_16_reg_3_03, sum32_16_reg_3_04,
	           sum32_16_reg_3_05, sum32_16_reg_3_06, sum32_16_reg_3_07, sum32_16_reg_3_08,
			   sum32_16_reg_3_09, sum32_16_reg_3_10, sum32_16_reg_3_11, sum32_16_reg_3_12,
			   sum32_16_reg_3_13, sum32_16_reg_3_14, sum32_16_reg_3_15, sum32_16_reg_3_16;

    reg [20:0] sum32_16_reg_4_01, sum32_16_reg_4_02, sum32_16_reg_4_03, sum32_16_reg_4_04,
	           sum32_16_reg_4_05, sum32_16_reg_4_06, sum32_16_reg_4_07, sum32_16_reg_4_08,
			   sum32_16_reg_4_09, sum32_16_reg_4_10, sum32_16_reg_4_11, sum32_16_reg_4_12,
			   sum32_16_reg_4_13, sum32_16_reg_4_14, sum32_16_reg_4_15, sum32_16_reg_4_16;

    always @ (posedge clk) begin
		if(rst) begin
			sum32_16_reg_1_01[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_02[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_03[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_04[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_05[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_06[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_07[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_08[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_09[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_10[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_11[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_12[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_13[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_14[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_15[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_1_16[20:0] <= #DLY 21'd0 ;
		end else begin
			sum32_16_reg_1_01[20:0] <= #DLY sum32_16_wire_1_01[19:0] ;
			sum32_16_reg_1_02[20:0] <= #DLY sum32_16_wire_1_02[19:0] ;
			sum32_16_reg_1_03[20:0] <= #DLY sum32_16_wire_1_03[19:0] ;
			sum32_16_reg_1_04[20:0] <= #DLY sum32_16_wire_1_04[19:0] ;
			sum32_16_reg_1_05[20:0] <= #DLY sum32_16_wire_1_05[19:0] ;
			sum32_16_reg_1_06[20:0] <= #DLY sum32_16_wire_1_06[19:0] ;
			sum32_16_reg_1_07[20:0] <= #DLY sum32_16_wire_1_07[19:0] ;
			sum32_16_reg_1_08[20:0] <= #DLY sum32_16_wire_1_08[19:0] ;
			sum32_16_reg_1_09[20:0] <= #DLY sum32_16_wire_1_09[19:0] ;
			sum32_16_reg_1_10[20:0] <= #DLY sum32_16_wire_1_10[19:0] ;
			sum32_16_reg_1_11[20:0] <= #DLY sum32_16_wire_1_11[19:0] ;
			sum32_16_reg_1_12[20:0] <= #DLY sum32_16_wire_1_12[19:0] ;
			sum32_16_reg_1_13[20:0] <= #DLY sum32_16_wire_1_13[19:0] ;
			sum32_16_reg_1_14[20:0] <= #DLY sum32_16_wire_1_14[19:0] ;
			sum32_16_reg_1_15[20:0] <= #DLY sum32_16_wire_1_15[19:0] ;
			sum32_16_reg_1_16[20:0] <= #DLY sum32_16_wire_1_16[19:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum32_16_reg_2_01[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_02[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_03[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_04[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_05[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_06[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_07[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_08[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_09[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_10[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_11[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_12[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_13[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_14[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_15[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_2_16[20:0] <= #DLY 21'd0 ;
		end else begin
			sum32_16_reg_2_01[20:0] <= #DLY sum32_16_wire_2_01[19:0] ;
			sum32_16_reg_2_02[20:0] <= #DLY sum32_16_wire_2_02[19:0] ;
			sum32_16_reg_2_03[20:0] <= #DLY sum32_16_wire_2_03[19:0] ;
			sum32_16_reg_2_04[20:0] <= #DLY sum32_16_wire_2_04[19:0] ;
			sum32_16_reg_2_05[20:0] <= #DLY sum32_16_wire_2_05[19:0] ;
			sum32_16_reg_2_06[20:0] <= #DLY sum32_16_wire_2_06[19:0] ;
			sum32_16_reg_2_07[20:0] <= #DLY sum32_16_wire_2_07[19:0] ;
			sum32_16_reg_2_08[20:0] <= #DLY sum32_16_wire_2_08[19:0] ;
			sum32_16_reg_2_09[20:0] <= #DLY sum32_16_wire_2_09[19:0] ;
			sum32_16_reg_2_10[20:0] <= #DLY sum32_16_wire_2_10[19:0] ;
			sum32_16_reg_2_11[20:0] <= #DLY sum32_16_wire_2_11[19:0] ;
			sum32_16_reg_2_12[20:0] <= #DLY sum32_16_wire_2_12[19:0] ;
			sum32_16_reg_2_13[20:0] <= #DLY sum32_16_wire_2_13[19:0] ;
			sum32_16_reg_2_14[20:0] <= #DLY sum32_16_wire_2_14[19:0] ;
			sum32_16_reg_2_15[20:0] <= #DLY sum32_16_wire_2_15[19:0] ;
			sum32_16_reg_2_16[20:0] <= #DLY sum32_16_wire_2_16[19:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum32_16_reg_3_01[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_02[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_03[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_04[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_05[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_06[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_07[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_08[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_09[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_10[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_11[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_12[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_13[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_14[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_15[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_3_16[20:0] <= #DLY 21'd0 ;
		end else begin
			sum32_16_reg_3_01[20:0] <= #DLY sum32_16_wire_3_01[19:0] ;
			sum32_16_reg_3_02[20:0] <= #DLY sum32_16_wire_3_02[19:0] ;
			sum32_16_reg_3_03[20:0] <= #DLY sum32_16_wire_3_03[19:0] ;
			sum32_16_reg_3_04[20:0] <= #DLY sum32_16_wire_3_04[19:0] ;
			sum32_16_reg_3_05[20:0] <= #DLY sum32_16_wire_3_05[19:0] ;
			sum32_16_reg_3_06[20:0] <= #DLY sum32_16_wire_3_06[19:0] ;
			sum32_16_reg_3_07[20:0] <= #DLY sum32_16_wire_3_07[19:0] ;
			sum32_16_reg_3_08[20:0] <= #DLY sum32_16_wire_3_08[19:0] ;
			sum32_16_reg_3_09[20:0] <= #DLY sum32_16_wire_3_09[19:0] ;
			sum32_16_reg_3_10[20:0] <= #DLY sum32_16_wire_3_10[19:0] ;
			sum32_16_reg_3_11[20:0] <= #DLY sum32_16_wire_3_11[19:0] ;
			sum32_16_reg_3_12[20:0] <= #DLY sum32_16_wire_3_12[19:0] ;
			sum32_16_reg_3_13[20:0] <= #DLY sum32_16_wire_3_13[19:0] ;
			sum32_16_reg_3_14[20:0] <= #DLY sum32_16_wire_3_14[19:0] ;
			sum32_16_reg_3_15[20:0] <= #DLY sum32_16_wire_3_15[19:0] ;
			sum32_16_reg_3_16[20:0] <= #DLY sum32_16_wire_3_16[19:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum32_16_reg_4_01[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_02[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_03[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_04[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_05[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_06[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_07[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_08[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_09[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_10[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_11[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_12[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_13[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_14[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_15[20:0] <= #DLY 21'd0 ;
			sum32_16_reg_4_16[20:0] <= #DLY 21'd0 ;
		end else begin
			sum32_16_reg_4_01[20:0] <= #DLY sum32_16_wire_4_01[19:0] ;
			sum32_16_reg_4_02[20:0] <= #DLY sum32_16_wire_4_02[19:0] ;
			sum32_16_reg_4_03[20:0] <= #DLY sum32_16_wire_4_03[19:0] ;
			sum32_16_reg_4_04[20:0] <= #DLY sum32_16_wire_4_04[19:0] ;
			sum32_16_reg_4_05[20:0] <= #DLY sum32_16_wire_4_05[19:0] ;
			sum32_16_reg_4_06[20:0] <= #DLY sum32_16_wire_4_06[19:0] ;
			sum32_16_reg_4_07[20:0] <= #DLY sum32_16_wire_4_07[19:0] ;
			sum32_16_reg_4_08[20:0] <= #DLY sum32_16_wire_4_08[19:0] ;
			sum32_16_reg_4_09[20:0] <= #DLY sum32_16_wire_4_09[19:0] ;
			sum32_16_reg_4_10[20:0] <= #DLY sum32_16_wire_4_10[19:0] ;
			sum32_16_reg_4_11[20:0] <= #DLY sum32_16_wire_4_11[19:0] ;
			sum32_16_reg_4_12[20:0] <= #DLY sum32_16_wire_4_12[19:0] ;
			sum32_16_reg_4_13[20:0] <= #DLY sum32_16_wire_4_13[19:0] ;
			sum32_16_reg_4_14[20:0] <= #DLY sum32_16_wire_4_14[19:0] ;
			sum32_16_reg_4_15[20:0] <= #DLY sum32_16_wire_4_15[19:0] ;
			sum32_16_reg_4_16[20:0] <= #DLY sum32_16_wire_4_16[19:0] ;
		end
	end

    /****************************
    // pipeline[11] Active
    ****************************/	
    wire [21:0] sum16_8_wire_1_01 = { 1'd0, sum32_16_reg_1_01[20:0]} + { 1'd0, sum32_16_reg_1_02[20:0]} ;
	wire [21:0] sum16_8_wire_1_02 = { 1'd0, sum32_16_reg_1_03[20:0]} + { 1'd0, sum32_16_reg_1_04[20:0]} ;
	wire [21:0] sum16_8_wire_1_03 = { 1'd0, sum32_16_reg_1_05[20:0]} + { 1'd0, sum32_16_reg_1_06[20:0]} ;
	wire [21:0] sum16_8_wire_1_04 = { 1'd0, sum32_16_reg_1_07[20:0]} + { 1'd0, sum32_16_reg_1_08[20:0]} ;
    wire [21:0] sum16_8_wire_1_05 = { 1'd0, sum32_16_reg_1_09[20:0]} + { 1'd0, sum32_16_reg_1_10[20:0]} ;
	wire [21:0] sum16_8_wire_1_06 = { 1'd0, sum32_16_reg_1_11[20:0]} + { 1'd0, sum32_16_reg_1_12[20:0]} ;
	wire [21:0] sum16_8_wire_1_07 = { 1'd0, sum32_16_reg_1_13[20:0]} + { 1'd0, sum32_16_reg_1_14[20:0]} ;
	wire [21:0] sum16_8_wire_1_08 = { 1'd0, sum32_16_reg_1_15[20:0]} + { 1'd0, sum32_16_reg_1_16[20:0]} ;

    wire [21:0] sum16_8_wire_2_01 = { 1'd0, sum32_16_reg_2_01[20:0]} + { 1'd0, sum32_16_reg_2_02[20:0]} ;
	wire [21:0] sum16_8_wire_2_02 = { 1'd0, sum32_16_reg_2_03[20:0]} + { 1'd0, sum32_16_reg_2_04[20:0]} ;
	wire [21:0] sum16_8_wire_2_03 = { 1'd0, sum32_16_reg_2_05[20:0]} + { 1'd0, sum32_16_reg_2_06[20:0]} ;
	wire [21:0] sum16_8_wire_2_04 = { 1'd0, sum32_16_reg_2_07[20:0]} + { 1'd0, sum32_16_reg_2_08[20:0]} ;
    wire [21:0] sum16_8_wire_2_05 = { 1'd0, sum32_16_reg_2_09[20:0]} + { 1'd0, sum32_16_reg_2_10[20:0]} ;
	wire [21:0] sum16_8_wire_2_06 = { 1'd0, sum32_16_reg_2_11[20:0]} + { 1'd0, sum32_16_reg_2_12[20:0]} ;
	wire [21:0] sum16_8_wire_2_07 = { 1'd0, sum32_16_reg_2_13[20:0]} + { 1'd0, sum32_16_reg_2_14[20:0]} ;
	wire [21:0] sum16_8_wire_2_08 = { 1'd0, sum32_16_reg_2_15[20:0]} + { 1'd0, sum32_16_reg_2_16[20:0]} ;

    wire [21:0] sum16_8_wire_3_01 = { 1'd0, sum32_16_reg_3_01[20:0]} + { 1'd0, sum32_16_reg_3_02[20:0]} ;
	wire [21:0] sum16_8_wire_3_02 = { 1'd0, sum32_16_reg_3_03[20:0]} + { 1'd0, sum32_16_reg_3_04[20:0]} ;
	wire [21:0] sum16_8_wire_3_03 = { 1'd0, sum32_16_reg_3_05[20:0]} + { 1'd0, sum32_16_reg_3_06[20:0]} ;
	wire [21:0] sum16_8_wire_3_04 = { 1'd0, sum32_16_reg_3_07[20:0]} + { 1'd0, sum32_16_reg_3_08[20:0]} ;
    wire [21:0] sum16_8_wire_3_05 = { 1'd0, sum32_16_reg_3_09[20:0]} + { 1'd0, sum32_16_reg_3_10[20:0]} ;
	wire [21:0] sum16_8_wire_3_06 = { 1'd0, sum32_16_reg_3_11[20:0]} + { 1'd0, sum32_16_reg_3_12[20:0]} ;
	wire [21:0] sum16_8_wire_3_07 = { 1'd0, sum32_16_reg_3_13[20:0]} + { 1'd0, sum32_16_reg_3_14[20:0]} ;
	wire [21:0] sum16_8_wire_3_08 = { 1'd0, sum32_16_reg_3_15[20:0]} + { 1'd0, sum32_16_reg_3_16[20:0]} ;

    wire [21:0] sum16_8_wire_4_01 = { 1'd0, sum32_16_reg_4_01[20:0]} + { 1'd0, sum32_16_reg_4_02[20:0]} ;
	wire [21:0] sum16_8_wire_4_02 = { 1'd0, sum32_16_reg_4_03[20:0]} + { 1'd0, sum32_16_reg_4_04[20:0]} ;
	wire [21:0] sum16_8_wire_4_03 = { 1'd0, sum32_16_reg_4_05[20:0]} + { 1'd0, sum32_16_reg_4_06[20:0]} ;
	wire [21:0] sum16_8_wire_4_04 = { 1'd0, sum32_16_reg_4_07[20:0]} + { 1'd0, sum32_16_reg_4_08[20:0]} ;
    wire [21:0] sum16_8_wire_4_05 = { 1'd0, sum32_16_reg_4_09[20:0]} + { 1'd0, sum32_16_reg_4_10[20:0]} ;
	wire [21:0] sum16_8_wire_4_06 = { 1'd0, sum32_16_reg_4_11[20:0]} + { 1'd0, sum32_16_reg_4_12[20:0]} ;
	wire [21:0] sum16_8_wire_4_07 = { 1'd0, sum32_16_reg_4_13[20:0]} + { 1'd0, sum32_16_reg_4_14[20:0]} ;
	wire [21:0] sum16_8_wire_4_08 = { 1'd0, sum32_16_reg_4_15[20:0]} + { 1'd0, sum32_16_reg_4_16[20:0]} ;

    reg [21:0] sum16_8_reg_1_01, sum16_8_reg_1_02, sum16_8_reg_1_03, sum16_8_reg_1_04,
	           sum16_8_reg_1_05, sum16_8_reg_1_06, sum16_8_reg_1_07, sum16_8_reg_1_08;

    reg [21:0] sum16_8_reg_2_01, sum16_8_reg_2_02, sum16_8_reg_2_03, sum16_8_reg_2_04,
	           sum16_8_reg_2_05, sum16_8_reg_2_06, sum16_8_reg_2_07, sum16_8_reg_2_08;

    reg [21:0] sum16_8_reg_3_01, sum16_8_reg_3_02, sum16_8_reg_3_03, sum16_8_reg_3_04,
	           sum16_8_reg_3_05, sum16_8_reg_3_06, sum16_8_reg_3_07, sum16_8_reg_3_08;

    reg [21:0] sum16_8_reg_4_01, sum16_8_reg_4_02, sum16_8_reg_4_03, sum16_8_reg_4_04,
	           sum16_8_reg_4_05, sum16_8_reg_4_06, sum16_8_reg_4_07, sum16_8_reg_4_08;
	
    always @ (posedge clk) begin
		if(rst) begin
			sum16_8_reg_1_01[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_02[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_03[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_04[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_05[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_06[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_07[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_1_08[21:0] <= #DLY 22'd0 ;
		end else begin
			sum16_8_reg_1_01[21:0] <= #DLY sum16_8_wire_1_01[21:0] ;
			sum16_8_reg_1_02[21:0] <= #DLY sum16_8_wire_1_02[21:0] ;
			sum16_8_reg_1_03[21:0] <= #DLY sum16_8_wire_1_03[21:0] ;
			sum16_8_reg_1_04[21:0] <= #DLY sum16_8_wire_1_04[21:0] ;
			sum16_8_reg_1_05[21:0] <= #DLY sum16_8_wire_1_05[21:0] ;
			sum16_8_reg_1_06[21:0] <= #DLY sum16_8_wire_1_06[21:0] ;
			sum16_8_reg_1_07[21:0] <= #DLY sum16_8_wire_1_07[21:0] ;
			sum16_8_reg_1_08[21:0] <= #DLY sum16_8_wire_1_08[21:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum16_8_reg_2_01[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_02[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_03[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_04[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_05[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_06[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_07[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_2_08[21:0] <= #DLY 22'd0 ;
		end else begin
			sum16_8_reg_2_01[21:0] <= #DLY sum16_8_wire_2_01[21:0] ;
			sum16_8_reg_2_02[21:0] <= #DLY sum16_8_wire_2_02[21:0] ;
			sum16_8_reg_2_03[21:0] <= #DLY sum16_8_wire_2_03[21:0] ;
			sum16_8_reg_2_04[21:0] <= #DLY sum16_8_wire_2_04[21:0] ;
			sum16_8_reg_2_05[21:0] <= #DLY sum16_8_wire_2_05[21:0] ;
			sum16_8_reg_2_06[21:0] <= #DLY sum16_8_wire_2_06[21:0] ;
			sum16_8_reg_2_07[21:0] <= #DLY sum16_8_wire_2_07[21:0] ;
			sum16_8_reg_2_08[21:0] <= #DLY sum16_8_wire_2_08[21:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum16_8_reg_3_01[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_02[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_03[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_04[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_05[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_06[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_07[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_3_08[21:0] <= #DLY 22'd0 ;
		end else begin
			sum16_8_reg_3_01[21:0] <= #DLY sum16_8_wire_3_01[21:0] ;
			sum16_8_reg_3_02[21:0] <= #DLY sum16_8_wire_3_02[21:0] ;
			sum16_8_reg_3_03[21:0] <= #DLY sum16_8_wire_3_03[21:0] ;
			sum16_8_reg_3_04[21:0] <= #DLY sum16_8_wire_3_04[21:0] ;
			sum16_8_reg_3_05[21:0] <= #DLY sum16_8_wire_3_05[21:0] ;
			sum16_8_reg_3_06[21:0] <= #DLY sum16_8_wire_3_06[21:0] ;
			sum16_8_reg_3_07[21:0] <= #DLY sum16_8_wire_3_07[21:0] ;
			sum16_8_reg_3_08[21:0] <= #DLY sum16_8_wire_3_08[21:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum16_8_reg_4_01[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_02[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_03[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_04[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_05[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_06[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_07[21:0] <= #DLY 22'd0 ;
			sum16_8_reg_4_08[21:0] <= #DLY 22'd0 ;
		end else begin
			sum16_8_reg_4_01[21:0] <= #DLY sum16_8_wire_4_01[21:0] ;
			sum16_8_reg_4_02[21:0] <= #DLY sum16_8_wire_4_02[21:0] ;
			sum16_8_reg_4_03[21:0] <= #DLY sum16_8_wire_4_03[21:0] ;
			sum16_8_reg_4_04[21:0] <= #DLY sum16_8_wire_4_04[21:0] ;
			sum16_8_reg_4_05[21:0] <= #DLY sum16_8_wire_4_05[21:0] ;
			sum16_8_reg_4_06[21:0] <= #DLY sum16_8_wire_4_06[21:0] ;
			sum16_8_reg_4_07[21:0] <= #DLY sum16_8_wire_4_07[21:0] ;
			sum16_8_reg_4_08[21:0] <= #DLY sum16_8_wire_4_08[21:0] ;
		end
	end

    /****************************
    // pipeline[12] Active
    ****************************/
    wire [22:0] sum8_4_wire_1_01 = { 1'd0, sum16_8_reg_1_01[21:0]} + { 1'd0, sum16_8_reg_1_02[21:0]} ;
	wire [22:0] sum8_4_wire_1_02 = { 1'd0, sum16_8_reg_1_03[21:0]} + { 1'd0, sum16_8_reg_1_04[21:0]} ;
	wire [22:0] sum8_4_wire_1_03 = { 1'd0, sum16_8_reg_1_05[21:0]} + { 1'd0, sum16_8_reg_1_06[21:0]} ;
	wire [22:0] sum8_4_wire_1_04 = { 1'd0, sum16_8_reg_1_07[21:0]} + { 1'd0, sum16_8_reg_1_08[21:0]} ;

    wire [22:0] sum8_4_wire_2_01 = { 1'd0, sum16_8_reg_2_01[21:0]} + { 1'd0, sum16_8_reg_2_02[21:0]} ;
	wire [22:0] sum8_4_wire_2_02 = { 1'd0, sum16_8_reg_2_03[21:0]} + { 1'd0, sum16_8_reg_2_04[21:0]} ;
	wire [22:0] sum8_4_wire_2_03 = { 1'd0, sum16_8_reg_2_05[21:0]} + { 1'd0, sum16_8_reg_2_06[21:0]} ;
	wire [22:0] sum8_4_wire_2_04 = { 1'd0, sum16_8_reg_2_07[21:0]} + { 1'd0, sum16_8_reg_2_08[21:0]} ;

    wire [22:0] sum8_4_wire_3_01 = { 1'd0, sum16_8_reg_3_01[21:0]} + { 1'd0, sum16_8_reg_3_02[21:0]} ;
	wire [22:0] sum8_4_wire_3_02 = { 1'd0, sum16_8_reg_3_03[21:0]} + { 1'd0, sum16_8_reg_3_04[21:0]} ;
	wire [22:0] sum8_4_wire_3_03 = { 1'd0, sum16_8_reg_3_05[21:0]} + { 1'd0, sum16_8_reg_3_06[21:0]} ;
	wire [22:0] sum8_4_wire_3_04 = { 1'd0, sum16_8_reg_3_07[21:0]} + { 1'd0, sum16_8_reg_3_08[21:0]} ;

    wire [22:0] sum8_4_wire_4_01 = { 1'd0, sum16_8_reg_4_01[21:0]} + { 1'd0, sum16_8_reg_4_02[21:0]} ;
	wire [22:0] sum8_4_wire_4_02 = { 1'd0, sum16_8_reg_4_03[21:0]} + { 1'd0, sum16_8_reg_4_04[21:0]} ;
	wire [22:0] sum8_4_wire_4_03 = { 1'd0, sum16_8_reg_4_05[21:0]} + { 1'd0, sum16_8_reg_4_06[21:0]} ;
	wire [22:0] sum8_4_wire_4_04 = { 1'd0, sum16_8_reg_4_07[21:0]} + { 1'd0, sum16_8_reg_4_08[21:0]} ;

    reg [22:0] sum8_4_reg_1_01, sum8_4_reg_1_02, sum8_4_reg_1_03, sum8_4_reg_1_04;
    reg [22:0] sum8_4_reg_2_01, sum8_4_reg_2_02, sum8_4_reg_2_03, sum8_4_reg_2_04;
    reg [22:0] sum8_4_reg_3_01, sum8_4_reg_3_02, sum8_4_reg_3_03, sum8_4_reg_3_04;
    reg [22:0] sum8_4_reg_4_01, sum8_4_reg_4_02, sum8_4_reg_4_03, sum8_4_reg_4_04;

    always @ (posedge clk) begin
		if(rst) begin
			sum8_4_reg_1_01[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_1_02[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_1_03[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_1_04[22:0] <= #DLY 23'd0 ;
		end else begin
			sum8_4_reg_1_01[22:0] <= #DLY sum8_4_wire_1_01[22:0] ;
			sum8_4_reg_1_02[22:0] <= #DLY sum8_4_wire_1_02[22:0] ;
			sum8_4_reg_1_03[22:0] <= #DLY sum8_4_wire_1_03[22:0] ;
			sum8_4_reg_1_04[22:0] <= #DLY sum8_4_wire_1_04[22:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum8_4_reg_2_01[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_2_02[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_2_03[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_2_04[22:0] <= #DLY 23'd0 ;
		end else begin
			sum8_4_reg_2_01[22:0] <= #DLY sum8_4_wire_2_01[22:0] ;
			sum8_4_reg_2_02[22:0] <= #DLY sum8_4_wire_2_02[22:0] ;
			sum8_4_reg_2_03[22:0] <= #DLY sum8_4_wire_2_03[22:0] ;
			sum8_4_reg_2_04[22:0] <= #DLY sum8_4_wire_2_04[22:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum8_4_reg_3_01[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_3_02[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_3_03[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_3_04[22:0] <= #DLY 23'd0 ;
		end else begin
			sum8_4_reg_3_01[22:0] <= #DLY sum8_4_wire_3_01[22:0] ;
			sum8_4_reg_3_02[22:0] <= #DLY sum8_4_wire_3_02[22:0] ;
			sum8_4_reg_3_03[22:0] <= #DLY sum8_4_wire_3_03[22:0] ;
			sum8_4_reg_3_04[22:0] <= #DLY sum8_4_wire_3_04[22:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum8_4_reg_4_01[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_4_02[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_4_03[22:0] <= #DLY 23'd0 ;
			sum8_4_reg_4_04[22:0] <= #DLY 23'd0 ;
		end else begin
			sum8_4_reg_4_01[22:0] <= #DLY sum8_4_wire_4_01[22:0] ;
			sum8_4_reg_4_02[22:0] <= #DLY sum8_4_wire_4_02[22:0] ;
			sum8_4_reg_4_03[22:0] <= #DLY sum8_4_wire_4_03[22:0] ;
			sum8_4_reg_4_04[22:0] <= #DLY sum8_4_wire_4_04[22:0] ;
		end
	end
  
    /****************************
    // pipeline[13] Active
    ****************************/
    wire [23:0] sum4_2_wire_1_01 = { 1'd0, sum8_4_reg_1_01[22:0]} + { 1'd0, sum8_4_reg_1_02[22:0]} ;
	wire [23:0] sum4_2_wire_1_02 = { 1'd0, sum8_4_reg_1_03[22:0]} + { 1'd0, sum8_4_reg_1_04[22:0]} ;
    wire [23:0] sum4_2_wire_2_01 = { 1'd0, sum8_4_reg_2_01[22:0]} + { 1'd0, sum8_4_reg_2_02[22:0]} ;
	wire [23:0] sum4_2_wire_2_02 = { 1'd0, sum8_4_reg_2_03[22:0]} + { 1'd0, sum8_4_reg_2_04[22:0]} ;
    wire [23:0] sum4_2_wire_3_01 = { 1'd0, sum8_4_reg_3_01[22:0]} + { 1'd0, sum8_4_reg_3_02[22:0]} ;
	wire [23:0] sum4_2_wire_3_02 = { 1'd0, sum8_4_reg_3_03[22:0]} + { 1'd0, sum8_4_reg_3_04[22:0]} ;
    wire [23:0] sum4_2_wire_4_01 = { 1'd0, sum8_4_reg_4_01[22:0]} + { 1'd0, sum8_4_reg_4_02[22:0]} ;
	wire [23:0] sum4_2_wire_4_02 = { 1'd0, sum8_4_reg_4_03[22:0]} + { 1'd0, sum8_4_reg_4_04[22:0]} ;

    reg [23:0] sum4_2_reg_1_01, sum4_2_reg_1_02;
    reg [23:0] sum4_2_reg_2_01, sum4_2_reg_2_02;
    reg [23:0] sum4_2_reg_3_01, sum4_2_reg_3_02;
    reg [23:0] sum4_2_reg_4_01, sum4_2_reg_4_02;

    always @ (posedge clk) begin
		if(rst) begin
			sum4_2_reg_1_01[23:0] <= #DLY 24'd0 ;
			sum4_2_reg_1_02[23:0] <= #DLY 24'd0 ;
		end else begin
			sum4_2_reg_1_01[23:0] <= #DLY sum4_2_wire_1_01[23:0] ;
			sum4_2_reg_1_02[23:0] <= #DLY sum4_2_wire_1_02[23:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum4_2_reg_2_01[23:0] <= #DLY 24'd0 ;
			sum4_2_reg_2_02[23:0] <= #DLY 24'd0 ;
		end else begin
			sum4_2_reg_2_01[23:0] <= #DLY sum4_2_wire_2_01[23:0] ;
			sum4_2_reg_2_02[23:0] <= #DLY sum4_2_wire_2_02[23:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum4_2_reg_3_01[23:0] <= #DLY 24'd0 ;
			sum4_2_reg_3_02[23:0] <= #DLY 24'd0 ;
		end else begin
			sum4_2_reg_3_01[23:0] <= #DLY sum4_2_wire_3_01[23:0] ;
			sum4_2_reg_3_02[23:0] <= #DLY sum4_2_wire_3_02[23:0] ;
		end
	end

    always @ (posedge clk) begin
		if(rst) begin
			sum4_2_reg_4_01[23:0] <= #DLY 24'd0 ;
			sum4_2_reg_4_02[23:0] <= #DLY 24'd0 ;
		end else begin
			sum4_2_reg_4_01[23:0] <= #DLY sum4_2_wire_4_01[23:0] ;
			sum4_2_reg_4_02[23:0] <= #DLY sum4_2_wire_4_02[23:0] ;
		end
	end
  
    /****************************
    // pipeline[14] Active
    ****************************/
    wire [24:0] sum_wire1 = { 1'd0, sum4_2_reg_1_01[23:0]} + { 1'd0, sum4_2_reg_1_02[23:0]} ;
    wire [24:0] sum_wire2 = { 1'd0, sum4_2_reg_2_01[23:0]} + { 1'd0, sum4_2_reg_2_02[23:0]} ;
    wire [24:0] sum_wire3 = { 1'd0, sum4_2_reg_3_01[23:0]} + { 1'd0, sum4_2_reg_3_02[23:0]} ;
    wire [24:0] sum_wire4 = { 1'd0, sum4_2_reg_4_01[23:0]} + { 1'd0, sum4_2_reg_4_02[23:0]} ;

    reg [24:0] sum_reg1;
    reg [24:0] sum_reg2;
    reg [24:0] sum_reg3;
    reg [24:0] sum_reg4;

    always @ (posedge clk) begin
		if(rst) begin
			sum_reg1[24:0] <= #DLY 25'd0 ;
			sum_reg2[24:0] <= #DLY 25'd0 ;
			sum_reg3[24:0] <= #DLY 25'd0 ;
			sum_reg4[24:0] <= #DLY 25'd0 ;
		end else begin
			sum_reg1[24:0] <= #DLY sum_wire1[24:0] ;
			sum_reg2[24:0] <= #DLY sum_wire2[24:0] ;
			sum_reg3[24:0] <= #DLY sum_wire3[24:0] ;
			sum_reg4[24:0] <= #DLY sum_wire4[24:0] ;
		end
	end
	
    /****************************
    // pipeline[15] Active
    ****************************/
	assign out_en1  = pipeline_cnt[15] ;
	assign out_en2  = pipeline_cnt[15] ;
	assign out_en3  = pipeline_cnt[15] ;
	assign out_en4  = pipeline_cnt[15] ;
	assign out_dat1[15:0] = {1'd0, sum_reg1[24:10]} ;
	assign out_dat2[15:0] = {1'd0, sum_reg2[24:10]} ;
	assign out_dat3[15:0] = {1'd0, sum_reg3[24:10]} ;
	assign out_dat4[15:0] = {1'd0, sum_reg4[24:10]} ;

endmodule