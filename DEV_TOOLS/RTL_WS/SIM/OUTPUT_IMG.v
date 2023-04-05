module OUTPUT_IMG (
    input             clk, rst,
    input             inV,
    input             inH,
    input [11:0] inDATA
);

    parameter DLY = 0.1;
    parameter OUTFILE_NAME = "test01_out.txt" ;
    integer fp_out ;

    initial begin
        fp_out = $fopen(OUTFILE_NAME);
    end

    reg              inV_1d, inH_1d;
    reg [11:0] inDATA_1d;

    always @ (posedge clk) begin
        if(rst) begin
            inV_1d <=#(DLY) 1'd0;
            inH_1d <=#(DLY) 1'd0;
            inDATA_1d[11:0] <=#(DLY) 12'd0 ;
        end else begin
            inV_1d <=#(DLY) inV;
            inH_1d <=#(DLY) inH;
            inDATA_1d[11:0] <=#(DLY) inDATA ;
        end
    end

    reg [1:0] STATE ;
	always @ (posedge clk) begin
	    if(rst) begin
		    STATE[1:0] <= #(DLY) 2'd0 ;
		end else begin
		    case (STATE[1:0])
			    2'd0 : begin
				    if(inV& ~inV_1d) STATE[1:0] <=  #(DLY) 2'd1 ;
				end
				2'd1 : begin
				    if(inH_1d) $fdisplay(fp_out, "%h", inDATA_1d);
					if(~inV & inV_1d) STATE[1:0] <= #(DLY) 2'd2 ;
				end
				2'd2 : begin
				    $fclose(fp_out);
				    STATE[1:0] <= #(DLY) 2'd3 ;
				end
				2'd3 : begin
					STATE[1:0] <= #(DLY) STATE[1:0] ;
				end
				default : begin
					STATE[1:0] <= #(DLY) 2'd0 ;
				end
			endcase
		end
	end

endmodule