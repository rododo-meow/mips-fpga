`include "common.v"
module hazard_cu(
	output d_available,
	input [4:0] d_ra, d_rb, e_rn, m_rn,
	output [1:0] forward_d_q1, forward_d_q2,
	input e_m2reg, e_wreg,
	input d_need_ra, d_need_rb,
	input m_m2reg, m_wreg,
	input [3:0] d_jmp,
	input e_setcond);

wire e_data_overwrite_reg = (e_m2reg == 0) && (e_wreg == 1);
wire forward_e_data_to_d_q1 = d_need_ra && e_data_overwrite_reg && (d_ra == e_rn);
wire forward_e_data_to_d_q2 = d_need_rb && e_data_overwrite_reg && (d_rb == e_rn);
wire e_memout_overwrite_reg = (e_m2reg == 1) && (e_wreg == 1);
wire forward_e_memout_to_d_q1 = d_need_ra && e_memout_overwrite_reg && (d_ra == e_rn);
wire forward_e_memout_to_d_q2 = d_need_rb && e_memout_overwrite_reg && (d_rb == e_rn);
wire m_memout_overwrite_reg = (m_m2reg == 1) && (m_wreg == 1);
wire forward_m_memout_to_d_q1 = d_need_ra && ~forward_e_data_to_d_q1 && m_memout_overwrite_reg && (d_ra == m_rn);
wire forward_m_memout_to_d_q2 = d_need_rb && ~forward_e_data_to_d_q2 && m_memout_overwrite_reg && (d_rb == m_rn);

assign forward_d_q1[1] = forward_m_memout_to_d_q1;
assign forward_d_q1[0] = forward_e_data_to_d_q1;
assign forward_d_q2[1] = forward_m_memout_to_d_q2;
assign forward_d_q2[0] = forward_e_data_to_d_q2;

wire forward_e_cond_to_d = (
	d_jmp != `JMP_NEVER && 
	d_jmp != `JMP_ALWAYS && 
	d_jmp != `JMP_MIPS_E &&
	d_jmp != `JMP_MIPS_NE &&
	e_setcond);
assign d_available = (~forward_e_memout_to_d_q1) & (~forward_e_memout_to_d_q2) & (~forward_e_cond_to_d);

endmodule
