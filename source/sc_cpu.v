`include "common.v"
module sc_cpu (clock,resetn,mem_dataout,wmem,mem_addr,mem_datain,instmem_addr,instmem_dataout);
input [31:0] mem_dataout;
input [7:0] instmem_dataout;
input clock,resetn;
output [31:0] mem_datain,instmem_addr,mem_addr;
output wmem;
  
wire [31:0] f_pc, next_pc, f_next_inst_pc;
wire [47:0] f_inst;
wire f_stall, f_mode, next_mode, f_output, f_available;

wire [31:0] t_next_inst_pc, dbg_t_pc, t_imm, t_target_pc;
wire [47:0] t_inst;
wire t_stall, t_bubble, t_mode, t_wmem, t_wreg, t_m2reg, t_useimm, t_need_ra, t_need_rb, t_available, t_output, t_setcond, t_do_jmp, t_target_mode, t_imm2m, t_alua2memaddr;
wire [3:0] t_aluc, t_jmp;
wire [4:0] t_ra, t_rb, t_rn;
wire [1:0] t_target_sel;

wire [31:0] d_q1, d_q2, _d_q1, _d_q2, dbg_d_pc, d_imm, d_target_pc;
wire d_stall, d_bubble, d_wmem, d_wreg, d_m2reg, d_useimm, d_need_ra, d_need_rb, d_target_mode, d_available, d_output, d_do_jmp, d_setcond, d_do_jmp_in_m, d_mode, d_imm2m,  d_alua2memaddr;
wire [3:0] d_aluc, d_jmp;
wire [4:0] d_ra, d_rb, d_rn;
wire [47:0] dbg_d_inst;
reg _d_do_jmp;
assign d_do_jmp = _d_do_jmp;
wire [1:0] d_target_sel;

wire e_wreg, e_m2reg, e_wmem, e_stall, e_bubble, e_available, e_output, e_setcond, e_do_jmp_in_m, e_mode, e_imm2m, e_alua2memaddr;
wire [3:0] e_aluc;
wire [31:0] e_next_inst_pc, e_alua, e_alub, e_aluout, e_memin, dbg_e_pc, e_q2, e_imm, e_memaddr;
wire [4:0] e_rn;
wire [47:0] dbg_e_inst;
reg [2:0] cc;

wire m_stall, m_bubble, m_wreg, m_m2reg, m_wmem, m_available, m_output, m_target_mode, m_do_jmp;
wire [31:0] m_memin, m_memaddr, m_memout, dbg_m_pc, m_target_pc, m_aluout;
wire [4:0] m_rn;
wire [47:0] dbg_m_inst;

wire w_wreg, w_m2reg, w_stall, w_bubble, w_available, w_output;
wire [31:0] w_aluout, w_memout, w_d, dbg_w_pc;
wire [4:0] w_rn;
wire [47:0] dbg_w_inst;

wire [1:0] forward_d_q1, forward_d_q2;

pipeline_cu pipeline_cu(
	.f_available(f_available), .f_output(f_output),
	.t_available(t_available), .t_output(t_output),
	.d_available(d_available), .d_output(d_output),
	.e_available(e_available), .e_output(e_output),
	.m_available(m_available), .m_output(m_output),
	.w_available(w_available), .w_output(w_output),
	.d_do_jmp(d_do_jmp), .m_do_jmp(m_do_jmp), .t_do_jmp(t_do_jmp),
	.f_stall(f_stall),
	.t_stall(t_stall), .t_bubble(t_bubble),
	.d_stall(d_stall), .d_bubble(d_bubble),
	.e_stall(e_stall), .e_bubble(e_bubble),
	.m_stall(m_stall), .m_bubble(m_bubble),
	.w_stall(w_stall), .w_bubble(w_bubble)
);

// ================= IF =================
pipeline_F F(
	.clk(clock),
	.resetn(resetn),
	.f_stall(f_stall),
	.next_pc(next_pc), .f_pc(f_pc),
	.next_mode(next_mode), .f_mode(f_mode)
);

fetch_cu fetch_cu(
	.clk(clock), .resetn(resetn),
	.f_pc(f_pc), .next_pc(next_pc), .f_next_inst_pc(f_next_inst_pc), .instmem_addr(instmem_addr),
	.instmem_dataout(instmem_dataout), .f_inst(f_inst),
	.f_mode(f_mode), .next_mode(next_mode),
	.d_do_jmp(d_do_jmp), .d_target_pc(d_target_pc), .d_target_mode(d_target_mode),
	.f_output(f_output), .f_available(f_available),
	.t_do_jmp(t_do_jmp), .t_target_pc(t_target_pc), .t_target_mode(t_target_mode),
	.m_do_jmp(m_do_jmp), .m_target_pc(m_target_pc), .m_target_mode(m_target_mode)
);

// =============== TRANS ================
pipeline_T T(
	.clk(clock),
	.resetn(resetn),
	.t_stall(t_stall), .t_bubble(t_bubble),
	.f_inst(f_inst), .t_inst(t_inst),
	.f_mode(f_mode), .t_mode(t_mode),
	.f_next_inst_pc(f_next_inst_pc), .t_next_inst_pc(t_next_inst_pc),
	.dbg_f_pc(f_pc), .dbg_t_pc(dbg_t_pc)
);
translate_cu translate_cu(
	.clk(clock), .resetn(resetn),
	.mode(t_mode), .inst(t_inst), .next_inst_pc(t_next_inst_pc),
	.aluc(t_aluc), .imm(t_imm), .ra(t_ra), .rb(t_rb), .rn(t_rn),
	.m2reg(t_m2reg), .wmem(t_wmem), .wreg(t_wreg), .useimm(t_useimm), .jmp(t_jmp), .imm2m(t_imm2m), .alua2memaddr(t_alua2memaddr),
	.available(t_available), ._output(t_output),
	.need_ra(t_need_ra), .need_rb(t_need_rb),
	.setcond(t_setcond),
	.do_jmp(t_do_jmp), .target_pc(t_target_pc), .target_mode(t_target_mode),
	.target_sel(t_target_sel)
);
	
// ================= ID =================
pipeline_D D(
	.clk(clock),
	.resetn(resetn),
	.d_stall(d_stall),
	.d_bubble(d_bubble),
	.t_aluc(t_aluc), .d_aluc(d_aluc),
	.t_imm(t_imm), .d_imm(d_imm),
	.t_ra(t_ra), .d_ra(d_ra),
	.t_rb(t_rb), .d_rb(d_rb),
	.t_rn(t_rn), .d_rn(d_rn),
	.t_m2reg(t_m2reg), .d_m2reg(d_m2reg),
	.t_wmem(t_wmem), .d_wmem(d_wmem),
	.t_wreg(t_wreg), .d_wreg(d_wreg),
	.t_useimm(t_useimm), .d_useimm(d_useimm),
	.t_jmp(t_jmp), .d_jmp(d_jmp),
	.t_need_ra(t_need_ra), .d_need_ra(d_need_ra),
	.t_need_rb(t_need_rb), .d_need_rb(d_need_rb),
	.dbg_t_inst(t_inst), .dbg_d_inst(dbg_d_inst),
	.dbg_t_pc(dbg_t_pc), .dbg_d_pc(dbg_d_pc),
	.t_setcond(t_setcond), .d_setcond(d_setcond),
	.t_target_sel(t_target_sel), .d_target_sel(d_target_sel),
	.t_imm2m(t_imm2m), .d_imm2m(d_imm2m),
	.t_alua2memaddr(t_alua2memaddr), .d_alua2memaddr(d_alua2memaddr),
	.t_mode(t_mode), .d_mode(d_mode)
);
assign d_output = 1;
always @(*) begin
	if (!d_available)
		_d_do_jmp <= 0;
	else begin
		case (d_jmp)
		`JMP_NEVER: _d_do_jmp <= 0;
		`JMP_ALWAYS: _d_do_jmp <= (d_target_sel == `TARGET_IMM) || (d_target_sel == `TARGET_Q1);
		`JMP_E: _d_do_jmp <= cc[0];
		`JMP_LE: _d_do_jmp <= (cc[1] ^ cc[2]) | cc[0];
		`JMP_G: _d_do_jmp <= ~((cc[1] ^ cc[2]) | cc[0]);
		`JMP_GE: _d_do_jmp <= ~(cc[1] ^ cc[2]);
		`JMP_NE: _d_do_jmp <= ~cc[0];
		`JMP_L: _d_do_jmp <= cc[1] ^ cc[2];
		`JMP_MIPS_E: _d_do_jmp <= _d_q1 == _d_q2;
		`JMP_MIPS_NE: _d_do_jmp <= _d_q1 != _d_q2;
		default: _d_do_jmp <= 0;
		endcase
	end
end

assign d_do_jmp_in_m = (d_target_sel == `TARGET_MEM) && (d_jmp == `JMP_ALWAYS);
assign d_target_pc = (d_target_sel == `TARGET_IMM) ? d_imm : _d_q1;
assign d_target_mode = d_mode;

hazard_cu hazard_cu(
	.d_available(d_available),
	.d_ra(d_ra), .d_rb(d_rb), .e_rn(e_rn), .m_rn(m_rn),
	.forward_d_q1(forward_d_q1), .forward_d_q2(forward_d_q2),
	.e_m2reg(e_m2reg), .e_wreg(e_wreg),
	.d_need_ra(d_need_ra), .d_need_rb(d_need_rb),
	.m_m2reg(m_m2reg), .m_wreg(m_wreg),
	.d_jmp(d_jmp), .e_setcond(e_setcond)
);
regfile rf(
	.rna(d_ra),
	.rnb(d_rb),
	.d(w_d),
	.wn(w_rn),
	.we(w_wreg),
	.clk(~clock),
	.clrn(resetn),
	.qa(_d_q1),
	.qb(_d_q2)
);
mux4x32 d_mux_q1(
	.a0(_d_q1),
	.a1(e_aluout),
	.a2(m_memout),
	.a3(m_aluout),
	.s(forward_d_q1),
	.y(d_q1)
);
mux4x32 d_mux_q2(
	.a0(_d_q2),
	.a1(e_aluout),
	.a2(m_memout),
	.a3(m_aluout),
	.s(forward_d_q2),
	.y(d_q2)
);

// ================ EXE =================
pipeline_E E(
	.clk(clock),
	.resetn(resetn),
	.e_stall(e_stall),
	.e_bubble(e_bubble),
	.d_wreg(d_wreg), .e_wreg(e_wreg),
	.d_m2reg(d_m2reg), .e_m2reg(e_m2reg),
	.d_wmem(d_wmem), .e_wmem(e_wmem),
	.d_aluc(d_aluc), .e_aluc(e_aluc),
	.d_alua(d_q1), .e_alua(e_alua),
	.d_alub(d_useimm ? d_imm : d_q2), .e_alub(e_alub),
	.d_q2(d_q2), .e_q2(e_q2),
	.d_rn(d_rn), .e_rn(e_rn),
	.dbg_d_pc(dbg_d_pc), .dbg_e_pc(dbg_e_pc),
	.dbg_d_inst(dbg_d_inst), .dbg_e_inst(dbg_e_inst),
	.d_setcond(d_setcond), .e_setcond(e_setcond),
	.d_do_jmp_in_m(d_do_jmp_in_m), .e_do_jmp_in_m(e_do_jmp_in_m),
	.d_mode(d_mode), .e_mode(e_mode),
	.d_imm2m(d_imm2m), .e_imm2m(e_imm2m),
	.d_imm(d_imm), .e_imm(e_imm),
	.d_alua2memaddr(d_alua2memaddr), .e_alua2memaddr(e_alua2memaddr)
);

alu e_alu(
	.a(e_alua),
	.b(e_alub),
	.aluc(e_aluc),
	.s(e_aluout)
);
always @(posedge clock, negedge resetn) begin
	if (!resetn)
		cc <= 3'b000;
	else if (e_setcond) begin
		cc[0] <= e_aluout == 32'b0;
		cc[1] <= e_aluout[31];
		case (e_aluc)
		`ALU_ADD: cc[2] <= ~(e_alua[31] ^ e_alub[31]) & (e_alua[31] != e_aluout[31]);
		`ALU_SUB: cc[2] <= (e_alua[31] ^ e_alub[31]) & (e_alua[31] != e_aluout[31]);
		default: cc[2] <= 0;
		endcase
	end
end
assign e_available = 1;
assign e_output = e_wmem | e_wreg;
assign e_memin = e_imm2m ? e_imm : e_q2;
assign e_memaddr = e_alua2memaddr ? e_alua : e_aluout;

// ================ MEM =================
pipeline_M M(
	.clk(clock),
	.resetn(resetn),
	.m_stall(m_stall), .m_bubble(m_bubble),
	.e_wreg(e_wreg), .m_wreg(m_wreg),
	.e_m2reg(e_m2reg), .m_m2reg(m_m2reg),
	.e_wmem(e_wmem), .m_wmem(m_wmem),
	.e_memaddr(e_memaddr), .m_memaddr(m_memaddr),
	.e_memin(e_memin), .m_memin(m_memin),
	.e_rn(e_rn), .m_rn(m_rn),
	.dbg_e_pc(dbg_e_pc), .dbg_m_pc(dbg_m_pc),
	.dbg_e_inst(dbg_e_inst), .dbg_m_inst(dbg_m_inst),
	.e_do_jmp_in_m(e_do_jmp_in_m), .m_do_jmp_in_m(m_do_jmp),
	.e_mode(e_mode), .m_mode(m_target_mode),
	.e_aluout(e_aluout), .m_aluout(m_aluout)
);
assign wmem = m_wmem;
assign mem_addr = m_memaddr;
assign mem_datain = m_memin;
assign m_memout = mem_dataout;
assign m_available = 1;
assign m_output = m_wreg;
assign m_target_pc = mem_dataout;

// ================= WB =================
pipeline_W W(
	.clk(clock),
	.resetn(resetn),
	.w_stall(w_stall), .w_bubble(w_bubble),
	.m_wreg(m_wreg), .w_wreg(w_wreg),
	.m_m2reg(m_m2reg), .w_m2reg(w_m2reg),
	.m_aluout(m_aluout), .w_aluout(w_aluout),
	.m_memout(m_memout), .w_memout(w_memout),
	.m_rn(m_rn), .w_rn(w_rn),
	.dbg_m_pc(dbg_m_pc), .dbg_w_pc(dbg_w_pc),
	.dbg_m_inst(dbg_m_inst), .dbg_w_inst(dbg_w_inst)
);

mux2x32 w_mux_d(
	.a0(w_aluout),
	.a1(w_memout),
	.s(w_m2reg),
	.y(w_d)
);
assign w_available = 1;
assign w_output = 1;

endmodule
