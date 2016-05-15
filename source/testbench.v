`timescale 1ns/1ps

module testbench;
localparam FREQ = 1000 * 1000;

reg clock, mem_clk, resetn;
reg [3:0] KEY;
reg [9:0] SW;
wire [31:0] pc, inst, aluout, memout;
wire imem_clk, dmem_clk;
wire [9:0] LED;
wire [6:0] SEG0, SEG1, SEG2, SEG3, SEG4, SEG5;

integer cycle;

sc_computer computer(resetn, clock,
	KEY, SW, SEG0, SEG1, SEG2, SEG3, SEG4, SEG5, LED);

initial begin
	resetn = 1;
	#(1000000000 / (FREQ * 2) * 4) resetn = 0;
	#(1000000000 / (FREQ * 2) * 12) resetn = 1;
end

initial begin
	clock = 1;
	forever
		#(1000000000 / (FREQ * 2)) clock = ~clock;
end

initial cycle = 0;

// Debug print

always @(negedge clock) begin
	if (!resetn) begin
		cycle = 0;
	end else begin
		$display("Cycle %d", cycle);
		$display("\tf_pc: 0x%08x", computer.cpu.f_pc);
		$display("\t=======================");
		$display("\td_pc: 0x%08x, d_inst: 0x%08x", computer.cpu.dbg_d_pc, computer.cpu.d_inst);
		$display("\td_wreg: %d, d_m2reg: %d, d_wmem: %d, d_jal: %d", computer.cpu.d_wreg, computer.cpu.d_m2reg, computer.cpu.d_wmem, computer.cpu.d_jal);
		$display("\td_aluc: %04b, d_aluimm: %d, d_shift: %d, d_regrt: %d", computer.cpu.d_aluc, computer.cpu.d_aluimm, computer.cpu.d_shift, computer.cpu.d_regrt);
		$display("\td_q1: 0x%08x, d_q2: 0x%08x, d_pcsource: %02b", computer.cpu.d_q1, computer.cpu.d_q2, computer.cpu.d_pcsource);
		$display("\t=======================");
		$display("\te_pc: 0x%08x, e_inst: 0x%08x", computer.cpu.dbg_e_pc, computer.cpu.dbg_e_inst);
		$display("\te_aluout: 0x%08x, e_data: 0x%08x, e_rn: %d", computer.cpu.e_aluout, computer.cpu.e_data, computer.cpu.e_rn);
		$display("\t=======================");
		$display("\tm_pc: 0x%08x, m_inst: 0x%08x", computer.cpu.dbg_m_pc, computer.cpu.dbg_m_inst);
		if (computer.cpu.m_m2reg == 1)
			$display("\tm_addr: 0x%08x, m_memout: 0x%08x", computer.cpu.m_data, computer.cpu.m_memout);
		else if (computer.cpu.m_wmem == 1)
			$display("\tm_addr: 0x%08x, m_memin: 0x%08x", computer.cpu.m_data, computer.cpu.m_memin);
		$display("\t=======================");
		$display("\tw_pc: 0x%08x, w_inst: 0x%08x", computer.cpu.dbg_w_pc, computer.cpu.dbg_w_inst);
		$display("\tw_d: 0x%08x, w_rn: 0x%08x", computer.cpu.w_d, computer.cpu.w_rn);
		$display("");
		cycle = cycle + 1;
	end
end

always @(SEG0, SEG1, SEG2, SEG3, SEG4, SEG5)
	$display("SEGS: %07b %07b %07b %07b %07b %07b", SEG5, SEG4, SEG3, SEG2, SEG1, SEG0);

always @(LED)
	$display("LED: %010b", LED);

// Stop condition

always @(cycle == 100)
	$stop;
	
// IO emulation

initial begin
	KEY <= 4'b1111;
	SW <= 10'd3;
end

always @(cycle == 30)
	KEY <= 4'b1101;
	
always @(cycle == 50)
	KEY <= 4'b1111;
	
always @(cycle == 70)
	SW <= 10'd5;
	
always @(cycle == 80)
	KEY <= 4'b1101;
	
always @(cycle == 90)
	KEY <= 4'b1111;

endmodule
