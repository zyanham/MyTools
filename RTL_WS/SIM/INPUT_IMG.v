module  INPUT_IMG (
    input                  clk, rst,
    input                  inV,
	input                  inH,
    output               outV,
    output               outH,
    output  [11:0] outDATA
);

    integer adrs ;
    reg [11:0] test_img [0:(2448*2048-1)] ;
    parameter DLY = 0.1 ;
    parameter INFILE_NAME = "test01_image.mem";

    initial begin
	   $readmemh(INFILE_NAME, test_img);
	end

    reg inV_1d, inV_2d ;
    reg inH_1d, inH_2d ;
	always @ (posedge clk) begin
	    if(rst) begin
            inV_1d <=#(DLY) 1'd0;
            inV_2d <=#(DLY) 1'd0;
            inH_1d <=#(DLY) 1'd0;
            inH_2d <=#(DLY) 1'd0;
        end else begin
            inV_1d <=#(DLY) inV;
            inH_1d <=#(DLY) inH;
            inV_2d <=#(DLY) inV_1d;
            inH_2d <=#(DLY) inH_1d;
        end
    end

    reg [11:0] pix_data ;
	always @ (posedge clk) begin
	    if(rst) begin
            adrs = #(DLY) 0 ;
        end else begin
            if(inV_1d & inH_1d) begin
                pix_data[11:0] <= #(DLY) test_img[adrs] ;
                adrs <= #(DLY) adrs + 1 ;
            end
        end
    end

    assign outV = inV_2d ;
    assign outH = inH_2d ;
    assign outDATA[11:0]=pix_data[11:0];

endmodule