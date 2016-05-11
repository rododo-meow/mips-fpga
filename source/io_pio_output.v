module io_pio_output(clk, resetn, addr, datain, we, pio);
parameter WIDTH = 0;
parameter GROUP = 1;

input clk, resetn, we;
input [7:0] addr;
input [31:0] datain;
output [(WIDTH-1):0] pio;

reg [(WIDTH-1):0] pio;

generate
	genvar i;
	for (i = 0; i < WIDTH / GROUP; i = i + 1) begin: group
		always @(posedge clk, negedge resetn) begin
			if (!resetn)
				pio[((i+1)*GROUP-1):(i*GROUP)] <= {GROUP{1'b0}};
			else if (we) begin
				if (addr[7:2] == i)
					pio[((i+1)*GROUP-1):(i*GROUP)] <= datain[(GROUP-1):0];
				else if (addr[7:2] == (WIDTH/GROUP) + i*GROUP/32)
					pio[((i+1)*GROUP-1):(i*GROUP)] <= datain[((i+1)*GROUP%32-1):(i*GROUP%32)];
			end
		end
	end
endgenerate

endmodule
