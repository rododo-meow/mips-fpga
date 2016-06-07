module vga_cu(
	input vga_clk, resetn,
	input [7:0] vga_r, vga_g, vga_b,
	output [9:0] x, y,
	output [7:0] VGA_R, VGA_G, VGA_B,
	output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
parameter H_A = 128;
parameter H_B = 88;
parameter H_C = 800;
parameter H_D = 40;
parameter V_A = 4;
parameter V_B = 23;
parameter V_C = 600;
parameter V_D = 1;
	
reg [7:0] _vga_r, _vga_g, _vga_b;
assign VGA_R = _vga_r;
assign VGA_G = _vga_g;
assign VGA_B = _vga_b;
reg _vga_blank_n, _vga_hs, _vga_vs;
assign VGA_BLANK_N = _vga_blank_n;
assign VGA_HS = _vga_hs;
assign VGA_SYNC_N = 0;
assign VGA_VS = _vga_vs;
assign VGA_CLK = vga_clk;

reg [10:0] hcnt;
reg [9:0] vcnt;
reg [9:0] _x, _y;
assign x = _x;
assign y = _y;

always @(negedge vga_clk, negedge resetn) begin
	if (!resetn) begin
		hcnt <= 0;
		vcnt <= 0;
		_x <= 0;
		_y <= 0;
	end else begin
		if (hcnt <= (H_A + H_B + H_C + H_D)) begin
			hcnt <= hcnt + 11'd1;
			_x <= hcnt - (H_A + H_B - 10'd1);
		end else begin
			hcnt <= 0;
			if (vcnt <= (V_A + V_B + V_C + V_D)) begin
				vcnt <= vcnt + 10'd1;
				_y <= vcnt - (V_A + V_B - 10'd1);
			end else begin
				vcnt <= 0;
			end
		end
	end
end

always @(posedge vga_clk) begin
	_vga_hs <= ~(hcnt < V_A);
	_vga_vs <= ~(vcnt < V_B);
end

always @(negedge vga_clk) begin
	_vga_blank_n <= ~((hcnt < H_A + H_B) | (hcnt >= H_A + H_B + H_C) | (vcnt < V_A + V_B) | (vcnt >= V_A + V_B + V_C));
	_vga_r <= vga_r;
	_vga_g <= vga_g;
	_vga_b <= vga_b;
end

endmodule
