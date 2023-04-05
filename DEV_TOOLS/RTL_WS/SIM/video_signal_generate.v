//////////////////////////////////////////////////////////////////////////////////
// -V SYNC-
//  V Branking   V Back porch   V active              V Front porch   V Branking
// ____________|==============|=====================|===============|____________
// 
// -H SYNC-
//  H Branking   H Back porch   H active              H Front porch   H Branking
// ____________|==============|=====================|===============|____________
//////////////////////////////////////////////////////////////////////////////////
module video_signal_generate(
    input clk,
	input rst,
	input enable,
	output VSYNC,
	output HSYNC
);

    parameter VBLK = 100 ;
	parameter HBLK = 20  ;
	parameter V_BP = 5 ;
	parameter V_FP = 5 ;
	parameter H_BP = 0 ;
	parameter H_FP = 0 ;
	
	parameter H_WIDTH = 2448 ;
	parameter V_WIDTH = 2048 ;
	parameter DLY = 0.1 ;
	
	reg [12:0] hcnt ;
	reg [12:0] vcnt ;
	
	always @ (posedge clk) begin
	    if(rst) begin
		    hcnt[12:0] <= #(DLY) 13'd0 ;
			vcnt[12:0] <= #(DLY) 13'd0 ;
		end else begin
		    if(~enable) begin
			    hcnt[12:0] <= #(DLY) 13'd0 ;
				vcnt[12:0] <= #(DLY) 13'd0 ;
			end else begin
			    if(hcnt[12:0] == (HBLK + H_BP + H_WIDTH + H_FP - 1)) begin
				    hcnt[12:0] <= #(DLY) 13'd0 ;
					if(vcnt[12:0] == (VBLK + V_BP + V_WIDTH + V_FP - 1)) begin
					    vcnt[12:0] <= #(DLY) 13'd0 ;
					end else begin
					    vcnt[12:0] <= #(DLY) vcnt[12:0] + 13'd1 ;
					end
				end else begin
				    hcnt[12:0] <= #(DLY) hcnt[12:0] + 13'd1 ;
				end
			end
		end
	end
	
	wire v_active = (((VBLK + V_BP - 1) < vcnt) & ((VBLK + V_BP + V_WIDTH - 1) >= vcnt));
	wire h_active = (v_active & (((HBLK + H_BP - 1) < hcnt) & ((HBLK + H_BP + H_WIDTH - 1) >= hcnt)));
    // 20 -> 2468

    reg h_active_hld, v_active_hld;
	always @ (posedge clk) begin
	    if(rst) begin
		    h_active_hld     <= #(DLY) 0 ;
		    v_active_hld     <= #(DLY) 0 ;
		end else begin
		    h_active_hld     <= #(DLY) h_active ;
		    v_active_hld     <= #(DLY) v_active ;
		end
	end

	assign HSYNC    = (enable)? h_active_hld     : 0 ;
	assign VSYNC    = (enable)? v_active_hld     : 0 ;
	
	
endmodule