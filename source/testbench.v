`timescale 1ns/1ps

//`define DEBUG

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
	#(1000000000 / (FREQ * 2) * 12 + 5) resetn = 1;
end

initial begin
	clock = 1;
	forever
		#(1000000000 / (FREQ * 2)) clock = ~clock;
end

initial cycle = 0;

always @(posedge clock)
	if (!resetn)
		cycle = 0;
	else
		cycle = cycle + 1;
		
// Debug print

`ifdef DEBUG
always @(negedge clock) #10 begin
	if (resetn) begin
		$display("Cycle %d.%d", cycle, clock);
		$display("\tf_stall: %b, f_output: %b", computer.cpu.f_stall, computer.cpu.f_output);
		$display("\tf_mode: %b", computer.cpu.f_mode);
		$display("\tf_pc: 0x%08x, f_next_inst_pc: 0x%08x", computer.cpu.f_pc, computer.cpu.f_next_inst_pc);
		$display("\tpc 0x%08x, instmem_dataout: 0x%02x, f_inst: 0x%012x", computer.instmem_addr, computer.cpu.instmem_dataout, computer.cpu.f_inst);
		if (computer.cpu.t_do_jmp == 1)
			$display("\tt_do_jmp: %b, t_target_pc: 0x%08x, t_target_mode: %b", computer.cpu.t_do_jmp, computer.cpu.t_target_pc, computer.cpu.t_target_mode);
		if (computer.cpu.d_do_jmp == 1)
			$display("\td_do_jmp: %b, d_target_pc: 0x%08x, d_target_mode: %b", computer.cpu.d_do_jmp, computer.cpu.d_target_pc, computer.cpu.d_target_mode);
		if (computer.cpu.m_do_jmp == 1)
			$display("\tm_do_jmp: %b, m_target_pc: 0x%08x, m_target_mode: %b", computer.cpu.m_do_jmp, computer.cpu.m_target_pc, computer.cpu.m_target_mode);
		$display("\t=======================");
		$display("\tt_stall: %b, t_bubble: %b, t_available: %b, t_output %b", computer.cpu.t_stall, computer.cpu.t_bubble, computer.cpu.t_available, computer.cpu.t_output);
		$display("\tt_mode: %b, t_pc: 0x%08x, t_next_inst_pc: 0x%08x", computer.cpu.t_mode, computer.cpu.dbg_t_pc, computer.cpu.t_next_inst_pc);
		$display("\tt_inst: 0x%012x, t_aluc: %04b, t_ra: %d, t_rb: %d, t_rn: %d, t_imm: 0x%08x", computer.cpu.t_inst, computer.cpu.t_aluc, computer.cpu.t_ra, computer.cpu.t_rb, computer.cpu.t_rn, computer.cpu.t_imm);
		$display("\tt_m2reg: %b, t_wreg: %b, t_wmem: %b", computer.cpu.t_m2reg, computer.cpu.t_wreg, computer.cpu.t_wmem);
		$display("\t=======================");
		$display("\td_stall: %b, d_bubble: %b, d_available: %b, d_output %b", computer.cpu.d_stall, computer.cpu.d_bubble, computer.cpu.d_available, computer.cpu.d_output);
		$display("\td_pc: 0x%08x, d_inst: 0x%012x", computer.cpu.dbg_d_pc, computer.cpu.dbg_d_inst);
		$display("\td_wreg: %b, d_m2reg: %b, d_wmem: %b, d_jmp: %x, d_do_jmp: %b", computer.cpu.d_wreg, computer.cpu.d_m2reg, computer.cpu.d_wmem, computer.cpu.d_jmp, computer.cpu.d_do_jmp);
		$display("\td_aluc: %04b, d_useimm: %b, d_rn: %d", computer.cpu.d_aluc, computer.cpu.d_useimm, computer.cpu.d_rn);
		$display("\td_ra: %d, _d_q1: 0x%08x, d_rb: %d, _d_q2: 0x%08x", computer.cpu.d_ra, computer.cpu._d_q1, computer.cpu.d_rb, computer.cpu._d_q2);
		$display("\td_q1: 0x%08x, d_q2: 0x%08x, d_imm: 0x%08x", computer.cpu.d_q1, computer.cpu.d_q2, computer.cpu.d_imm);
		$display("\t=======================");
		$display("\te_stall: %b, e_bubble: %b, e_available: %b, e_output %b", computer.cpu.e_stall, computer.cpu.e_bubble, computer.cpu.e_available, computer.cpu.e_output);
		$display("\te_pc: 0x%08x, e_inst: 0x%012x", computer.cpu.dbg_e_pc, computer.cpu.dbg_e_inst);
		$display("\te_aluout: 0x%08x, e_memin: 0x%08x, e_rn: %d", computer.cpu.e_aluout, computer.cpu.e_memin, computer.cpu.e_rn);
		$display("\tZF: %b, SF: %b, OF: %b", computer.cpu.cc[0], computer.cpu.cc[1], computer.cpu.cc[2]);
		$display("\t=======================");
		$display("\tm_stall: %b, m_bubble: %b, m_available: %b, m_output %b", computer.cpu.m_stall, computer.cpu.m_bubble, computer.cpu.m_available, computer.cpu.m_output);
		$display("\tm_pc: 0x%08x, m_inst: 0x%012x", computer.cpu.dbg_m_pc, computer.cpu.dbg_m_inst);
		if (computer.cpu.m_m2reg == 1 || computer.cpu.m_do_jmp == 1)
			$display("\tm_addr: 0x%08x, m_memout: 0x%08x", computer.cpu.m_memaddr, computer.cpu.m_memout);
		else if (computer.cpu.m_wmem == 1)
			$display("\tm_addr: 0x%08x, m_memin: 0x%08x", computer.cpu.m_memaddr, computer.cpu.m_memin);
		$display("\t=======================");
		$display("\tw_stall: %b, w_bubble: %b, w_available: %b, w_output %b", computer.cpu.w_stall, computer.cpu.w_bubble, computer.cpu.w_available, computer.cpu.w_output);
		$display("\tw_pc: 0x%08x, w_inst: 0x%012x", computer.cpu.dbg_w_pc, computer.cpu.dbg_w_inst);
		$display("\tw_d: 0x%08x, w_rn: %d", computer.cpu.w_d, computer.cpu.w_rn);
		$display("");
	end
end
`endif

always @(negedge resetn)
	$display("RESET");
	
always @(posedge resetn)
	$display("RESET release");

`ifdef DEBUG
always @(posedge clock)
	$display("Clock");
`endif
	
always @(SEG0, SEG1, SEG2, SEG3, SEG4, SEG5)
	$display("SEGS: %07b %07b %07b %07b %07b %07b", SEG5, SEG4, SEG3, SEG2, SEG1, SEG0);

always @(LED)
	$display("LED: %010b", LED);

always @(negedge clock)
	if (computer.aluout[31:24] == 8'hf4 && computer.cpu_wmem) begin
		if (computer.aluout[23:0] == 24'hfffffc)
			$display("VGA switch buf");
		else if (computer.data)
			$display("VGA write: set (%d,%d)", computer.aluout[9:0], computer.aluout[19:10]);
		else
			$display("VGA write: clear (%d,%d)", computer.aluout[9:0], computer.aluout[19:10]);
	end
		
// Stop condition

always @(posedge clock)
	if (cycle == 8000)
		$stop;
	
// IO emulation

initial begin
	KEY <= 4'b1111;
	SW <= 10'd3;
end

always @(cycle == 400)
	KEY <= 4'b1101;
	
always @(cycle == 600)
	KEY <= 4'b1111;

endmodule
