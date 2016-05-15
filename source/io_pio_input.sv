module io_pio_input(clk, resetn, addr, dataout, pio);
parameter WIDTH = 0;
parameter GROUP = 1;
localparam PADDING = (WIDTH % 32 == 0) ? 0 : (32 - WIDTH % 32);

input clk, resetn;
input [7:0] addr;
output [31:0] dataout;
input [(WIDTH-1):0] pio;

reg [31:0] dataout;
wire [(WIDTH+PADDING-1):0] padded_pio = { {PADDING{1'b0}}, pio };
wire [31:0] tmp[WIDTH / GROUP + (WIDTH - 1) / 32 + 1];

genvar i;
generate
	for (i = 0; i < WIDTH / GROUP; i = i + 1) begin: tmp_assign
		assign tmp[i] = pio[((i + 1) * GROUP - 1):(i * GROUP)];
	end
endgenerate

generate
	for (i = WIDTH / GROUP; i < WIDTH / GROUP + (WIDTH - 1) / 32 + 1; i = i + 1) begin: batch_assign
		assign tmp[i] = padded_pio[((i - WIDTH / GROUP + 1) * 32 - 1):((i - WIDTH / GROUP) * 32)];
	end
endgenerate

assign dataout = tmp[addr[7:2]];

endmodule
