module sc_cpu (clock,resetn,mem_dataout,wmem,mem_addr,mem_datain,pc,instmem_dataout);
input [31:0] mem_dataout;
input [7:0] instmem_dataout;
input clock,resetn;
output [31:0] mem_datain,pc,mem_addr;
output wmem;
  
wire [31:0] f_pc, next_pc, f_next_inst_pc;
wire [47:0] f_inst, _f_inst;
wire [2:0] f_off, next_off;
wire f_stall, f_mode, next_mode;

wire [31:0] t_next_inst_pc, t_transed_inst;
wire [47:0] t_inst;
wire t_stall, t_bubble, t_mode;

wire [31:0] d_next_inst_pc, d_next_inst_pc_imm, d_q1, d_q2, d_ext_imm, _d_q1, _d_q2, dbg_d_pc, d_target_pc;
wire [31:0] d_inst;
wire d_stall, d_bubble, d_wmem, d_wreg, d_regrt, d_m2reg, d_shift, d_aluimm, d_jal, d_sext, d_need_q1, d_need_q2, d_mode, d_flush_fetch, d_target_mode;
wire [3:0] d_aluc;
wire [4:0] d_rn;
wire [5:0] d_op = d_inst[31:26];
wire [5:0] d_func = d_inst[5:0];
wire [4:0] d_rs = d_inst[25:21];
wire [4:0] d_rt = d_inst[20:16];
wire [4:0] d_rd = d_inst[15:11];
wire [15:0] d_imm = d_inst[15:0];
wire [25:0] d_addr = d_inst[25:0];

wire e_wreg, e_m2reg, e_wmem, e_jal, e_aluimm, e_shift, e_stall, e_bubble;
wire [3:0] e_aluc;
wire [31:0] e_p4, e_q1, e_q2, e_ext_imm, e_aluout, e_data, e_alua, e_alub, dbg_e_pc, dbg_e_inst;
wire [4:0] _e_rn, e_rn;

wire m_stall, m_bubble, m_wreg, m_m2reg, m_wmem;
wire [31:0] m_data, m_memin, m_memout, dbg_m_pc, dbg_m_inst;
wire [4:0] m_rn;

wire w_wreg, w_m2reg, w_stall, w_bubble;
wire [31:0] w_data, w_memout, w_d, dbg_w_pc, dbg_w_inst;
wire [4:0] w_rn;

wire [1:0] forward_d_q1, forward_d_q2;

hazard_cu hazard_cu(
	.f_stall(f_stall), 
	.d_stall(d_stall), .d_bubble(d_bubble), 
	.e_stall(e_stall), .e_bubble(e_bubble), 
	.m_stall(m_stall), .m_bubble(m_bubble), 
	.w_stall(w_stall), .w_bubble(w_bubble),
	.d_rs(d_rs), .d_rt(d_rt), .e_rn(e_rn), .m_rn(m_rn),
	.forward_d_q1(forward_d_q1), .forward_d_q2(forward_d_q2),
	.e_m2reg(e_m2reg), .e_wreg(e_wreg),
	.m_m2reg(m_m2reg), .m_wreg(m_wreg),
	.d_need_q1(d_need_q1), .d_need_q2(d_need_q2)
);

// ================= IF =================
pipeline_F F(
	.clk(clock),
	.resetn(resetn),
	.f_stall(0),
	.next_pc(next_pc), .f_pc(f_pc),
	.next_off(next_off), .f_off(f_off),
	.next_mode(next_mode), .f_mode(f_mode),
	._f_inst(_f_inst), .f_inst(f_inst)
);

assign pc = f_pc + f_off;
fetch_cu fetch_cu(
	.f_pc(f_pc), .next_pc(next_pc), .f_next_inst_pc(f_next_inst_pc),
	.f_off(f_off), .next_off(next_off),
	.instmem_dataout(instmem_dataout), .f_inst(f_inst), ._f_inst(_f_inst),
	.f_mode(f_mode), .next_mode(next_mode),
	.d_flush_fetch(d_flush_fetch),
	.d_target_pc(d_target_pc), .d_target_mode(d_target_mode)
);

// =============== TRANS ================
pipeline_T T(
	.clk(clock),
	.resetn(resetn),
	.t_stall(t_stall), .t_bubble(t_bubble),
	.f_inst(f_inst), .t_inst(t_inst),
	.t_isbubble(t_isbubble)
);
	
// ================= ID =================
pipeline_D D(
	.clk(clock),
	.resetn(resetn),
	.d_stall(d_stall),
	.d_bubble(d_bubble),
	.t_inst(f_mode == 0 ? f_inst[31:0] : t_transed_inst), .d_inst(d_inst),
	.t_next_inst_pc(f_mode == 0 ? f_next_inst_pc : t_next_inst_pc), .d_next_inst_pc(d_next_inst_pc),
	.dbg_t_pc(t_pc), .dbg_d_pc(dbg_d_pc)
);

sc_cu d_cu(
	.op(d_op), .func(d_func),
	.z(d_q1 == d_q2),
	.wmem(d_wmem),
	.wreg(d_wreg),
	.regrt(d_regrt),
	.m2reg(d_m2reg),
	.aluc(d_aluc),
	.shift(d_shift),
	.aluimm(d_aluimm),
	.jal(d_jal),
	.sext(d_sext),
	.need_q1(d_need_q1), .need_q2(d_need_q2)
);
regfile rf(
	.rna(d_rs),
	.rnb(d_rt),
	.d(w_d),
	.wn(w_rn),
	.we(w_wreg),
	.clk(~clock),
	.clrn(resetn),
	.qa(_d_q1),
	.qb(_d_q2)
);
assign d_ext_imm = { {16{d_sext & d_imm[15]}}, d_imm };
assign d_next_inst_pc_imm = d_next_inst_pc + { d_ext_imm[29:0], 2'b00 };
mux2x5 d_mux_rn(
	.a0(d_rd),
	.a1(d_rt),
	.s(d_regrt),
	.y(d_rn)
);
mux4x32 d_mux_q1(
	.a0(_d_q1),
	.a1(e_data),
	.a2(m_memout),
	.a3(0),
	.s(forward_d_q1),
	.y(d_q1)
);
mux4x32 d_mux_q2(
	.a0(_d_q2),
	.a1(e_data),
	.a2(m_memout),
	.a3(0),
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
	.d_jal(d_jal), .e_jal(e_jal),
	.d_aluc(d_aluc), .e_aluc(e_aluc),
	.d_aluimm(d_aluimm), .e_aluimm(e_aluimm),
	.d_shift(d_shift), .e_shift(e_shift),
	.d_next_inst_pc(d_next_inst_pc), .e_next_inst_pc(e_next_inst_pc),
	.d_q1(d_q1), .e_q1(e_q1),
	.d_q2(d_q2), .e_q2(e_q2),
	.d_ext_imm(d_ext_imm), .e_ext_imm(e_ext_imm),
	.d_rn(d_rn), .e_rn(_e_rn),
	.dbg_d_pc(dbg_d_pc), .dbg_e_pc(dbg_e_pc),
	.dbg_d_inst(d_inst), .dbg_e_inst(dbg_e_inst)
);

mux2x32 e_mux_alua(
	.a0(e_q1),
	.a1({ 27'b0, e_ext_imm[10:6] }),
	.s(e_shift),
	.y(e_alua)
);
mux2x32 e_mux_alub(
	.a0(e_q2),
	.a1(e_ext_imm),
	.s(e_aluimm),
	.y(e_alub)
);
alu e_alu(
	.a(e_alua),
	.b(e_alub),
	.aluc(e_aluc),
	.s(e_aluout)
);
mux2x32 e_mux_data(
	.a0(e_aluout),
	.a1(e_next_inst_pc),
	.s(e_jal),
	.y(e_data)
);
assign e_rn = e_jal ? 5'd31 : _e_rn;

// ================ MEM =================
pipeline_M M(
	.clk(clock),
	.resetn(resetn),
	.m_stall(m_stall), .m_bubble(m_bubble),
	.e_wreg(e_wreg), .m_wreg(m_wreg),
	.e_m2reg(e_m2reg), .m_m2reg(m_m2reg),
	.e_wmem(e_wmem), .m_wmem(m_wmem),
	.e_data(e_data), .m_data(m_data),
	.e_memin(e_q2), .m_memin(m_memin),
	.e_rn(e_rn), .m_rn(m_rn),
	.dbg_e_pc(dbg_e_pc), .dbg_m_pc(dbg_m_pc),
	.dbg_e_inst(dbg_e_inst), .dbg_m_inst(dbg_m_inst)
);
assign wmem = m_wmem;
assign mem_addr = m_data;
assign mem_datain = m_memin;
assign m_memout = mem_dataout;

// ================= WB =================
pipeline_W W(
	.clk(clock),
	.resetn(resetn),
	.w_stall(w_stall), .w_bubble(w_bubble),
	.m_wreg(m_wreg), .w_wreg(w_wreg),
	.m_m2reg(m_m2reg), .w_m2reg(w_m2reg),
	.m_data(m_data), .w_data(w_data),
	.m_memout(m_memout), .w_memout(w_memout),
	.m_rn(m_rn), .w_rn(w_rn),
	.dbg_m_pc(dbg_m_pc), .dbg_w_pc(dbg_w_pc),
	.dbg_m_inst(dbg_m_inst), .dbg_w_inst(dbg_w_inst)
);

mux2x32 w_mux_d(
	.a0(w_data),
	.a1(w_memout),
	.s(w_m2reg),
	.y(w_d)
);

endmodule
