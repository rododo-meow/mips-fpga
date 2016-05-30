module pipeline_cu(
	input f_available, f_output, t_available, t_output, d_available, d_output, e_available, e_output, m_available, m_output, w_available, w_output, d_do_jmp, m_do_jmp, t_do_jmp,
	output f_stall, t_stall, t_bubble, d_stall, d_bubble, e_stall, e_bubble, m_stall, m_bubble, w_stall, w_bubble);
	
	wire t_flush = m_do_jmp | d_do_jmp | t_do_jmp;
	wire d_flush = m_do_jmp | d_do_jmp;
	wire e_flush = m_do_jmp;
	wire m_flush = m_do_jmp;
	assign f_stall = (f_output & t_stall) | ~f_available;
	assign t_stall = ((t_output & d_stall) | ~t_available) & ~t_flush;
	assign t_bubble = (~f_output & t_available) | t_flush;
	assign d_stall = ((d_output & e_stall) | ~d_available) & ~d_flush;
	assign d_bubble = (~t_output & d_available) | d_flush;
	assign e_stall = ((e_output & m_stall) | ~e_available) & ~e_flush;
	assign e_bubble = (~d_output & e_available) | e_flush;
	assign m_stall = ((m_output & w_stall) | ~m_available) & ~m_flush;
	assign m_bubble = (~e_output & m_available) | m_flush;
	assign w_stall = 0;
	assign w_bubble = ~m_output & w_available;
endmodule
