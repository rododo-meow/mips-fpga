module hazard_cu(
	output f_stall, d_stall, d_bubble, e_stall, e_bubble, m_stall, m_bubble, w_stall, w_bubble,
	input [4:0] d_rs, d_rt, e_rn, m_rn,
	output [1:0] forward_d_q1, forward_d_q2,
	input e_m2reg, e_wreg,
	input d_need_q1, d_need_q2,
	input m_m2reg, m_wreg);
	
assign d_bubble = 0;
assign e_stall = 0;
assign m_stall = 0;
assign m_bubble = 0;
assign w_stall = 0;
assign w_bubble = 0;

wire stall_d;

wire e_data_overwrite_reg = (e_m2reg == 0) && (e_wreg == 1);
wire forward_e_data_to_d_q1 = d_need_q1 && e_data_overwrite_reg && (d_rs == e_rn);
wire forward_e_data_to_d_q2 = d_need_q2 && e_data_overwrite_reg && (d_rt == e_rn);
wire e_memout_overwrite_reg = (e_m2reg == 1) && (e_wreg == 1);
wire forward_e_memout_to_d_q1 = d_need_q1 && e_memout_overwrite_reg && (d_rs == e_rn);
wire forward_e_memout_to_d_q2 = d_need_q2 && e_memout_overwrite_reg && (d_rt == e_rn);
wire m_memout_overwrite_reg = (m_m2reg == 1) && (m_wreg == 1);
wire forward_m_memout_to_d_q1 = d_need_q1 && ~forward_e_data_to_d_q1 && m_memout_overwrite_reg && (d_rs == m_rn);
wire forward_m_memout_to_d_q2 = d_need_q2 && ~forward_e_data_to_d_q2 && m_memout_overwrite_reg && (d_rt == m_rn);

assign forward_d_q1[1] = forward_m_memout_to_d_q1;
assign forward_d_q1[0] = forward_e_data_to_d_q1;
assign forward_d_q2[1] = forward_m_memout_to_d_q2;
assign forward_d_q2[0] = forward_e_data_to_d_q2;

assign stall_d = forward_e_memout_to_d_q1 || forward_e_memout_to_d_q2;

assign f_stall = stall_d;
assign d_stall = stall_d;
assign e_bubble = stall_d;

endmodule
