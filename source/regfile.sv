module regfile (rna,rnb,d,wn,we,clk,clrn,qa,qb);
   input [4:0] rna,rnb,wn;
   input [31:0] d;
   input we,clk,clrn;
   
   output [31:0] qa,qb;
   
   reg [31:0] register [32]; // r1 - r31
	wire [31:0] reg_we_arr[32];
	genvar i;
	generate
		for (i = 0; i < 32; i = i + 1) begin: reg_we_arr_assign
			assign reg_we_arr[i] = (32'b1 << i);
		end
	endgenerate
	wire [31:0] reg_we = we ? reg_we_arr[wn] : 0;
   
   assign qa = ((rna == wn) & we) ? d : register[rna]; // read
   assign qb = ((rnb == wn) & we) ? d : register[rnb]; // read

	initial register[0] <= 0;
	always @* register[0] <= 0;
	
	generate
		for (i = 1; i < 32; i = i + 1) begin: r
			always @(posedge clk or negedge clrn) begin
				if (clrn == 0)
					register[i] <= 0;
				else if (reg_we[i])
					register[i] <= d;
			end
		end
	endgenerate
   
endmodule
