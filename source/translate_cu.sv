module translate_cu(
	input mode,
	input [47:0] inst,
	input [31:0] next_inst_pc,
	output [3:0] aluc,
	output [31:0] imm,
	output [4:0] ra, rb, rn,
	output m2reg, wmem, wreg, useimm,
	output [3:0] jmp,
	output available, _output,
	output need_ra, need_rb,
	output setcond, do_jmp, target_mode,
	output [31:0] target_pc,
	output [1:0] target_sel);

assign available = 1;
assign _output = 1;

reg [3:0] _aluc;
assign aluc = _aluc;
localparam ALU_ADD = 4'b0000;
localparam ALU_SUB = 4'b0100;
localparam ALU_AND = 4'b0001;
localparam ALU_OR = 4'b0101;
localparam ALU_XOR = 4'b0010;
localparam ALU_SLL = 4'b0011;
localparam ALU_SRL = 4'b0111;
localparam ALU_SRA = 4'b1111;
reg[31:0] _imm;
assign imm = _imm;
reg [4:0] _ra, _rb, _rn;
assign ra = _ra;
assign rb = _rb;
assign rn = _rn;
reg _m2reg, _wmem, _wreg, _useimm;
assign m2reg = _m2reg;
assign wmem = _wmem;
assign wreg = _wreg;
assign useimm = _useimm;
reg [3:0] _jmp;
assign jmp = _jmp;
localparam JMP_ALWAYS = 4'h0;
localparam JMP_LE = 4'h1;
localparam JMP_L = 4'h2;
localparam JMP_E = 4'h3;
localparam JMP_NE = 4'h4;
localparam JMP_GE = 4'h5;
localparam JMP_G = 4'h6;
localparam JMP_MIPS_E = 4'h7;
localparam JMP_MIPS_NE = 4'h8;
localparam JMP_NEVER = 4'hf;

wire [5:0] mips_op = inst[31:26];
localparam MIPS_OP_R = 6'b000000;
localparam MIPS_OP_ADDI = 6'b001000;
localparam MIPS_OP_ANDI = 6'b001100;
localparam MIPS_OP_ORI = 6'b001101;
localparam MIPS_OP_XORI = 6'b001110;
localparam MIPS_OP_LW = 6'b100011;
localparam MIPS_OP_SW = 6'b101011;
localparam MIPS_OP_BEQ = 6'b000100;
localparam MIPS_OP_BNE = 6'b000101;
localparam MIPS_OP_LUI = 6'b001111;
localparam MIPS_OP_J = 6'b000010;
localparam MIPS_OP_JAL = 6'b000011;
wire [4:0] mips_rs = inst[25:21];
wire [4:0] mips_rt = inst[20:16];
wire [4:0] mips_rd = inst[15:11];
wire [4:0] mips_sa = inst[10:6];
wire [5:0] mips_func = inst[5:0];
localparam MIPS_FUNC_ADD = 6'b100000;
localparam MIPS_FUNC_SUB = 6'b100010;
localparam MIPS_FUNC_AND = 6'b100100;
localparam MIPS_FUNC_OR = 6'b100101;
localparam MIPS_FUNC_XOR = 6'b100110;
localparam MIPS_FUNC_SLL = 6'b000000;
localparam MIPS_FUNC_SRL = 6'b000010;
localparam MIPS_FUNC_SRA = 6'b000011;
localparam MIPS_FUNC_JR = 6'b001000;
wire [15:0] mips_imm = inst[15:0];
wire [25:0] mips_addr = inst[25:0];

reg _need_ra, _need_rb, _setcond;
assign need_ra = _need_ra;
assign need_rb = _need_rb;
assign setcond = _setcond;

reg _do_jmp, _target_mode;
reg [31:0] _target_pc;
assign do_jmp = _do_jmp;
assign target_mode = _target_mode;
assign target_pc = _target_pc;

reg [1:0] _target_sel;
assign target_sel = _target_sel;
localparam TARGET_IMM = 2'b00;
localparam TARGET_Q1 = 2'b01;
localparam TARGET_MEM = 2'b10;

always @(*) begin
	_aluc = ALU_ADD;
	_imm = 0;
	_ra = 0;
	_rb = 0;
	_rn = 0;
	_m2reg = 0;
	_wmem = 0;
	_wreg = 0;
	_useimm = 0;
	_jmp = JMP_NEVER;
	_need_ra = 0;
	_need_rb = 0;
	_do_jmp = 0;
	_target_mode = 0;
	_target_pc = 0;
	_target_sel = TARGET_IMM;
	if (mode == 0) begin
		_wreg = 1;
		_ra = mips_rs;
		_rb = mips_rt;
		_rn = mips_rt;
		_useimm = 1;
		_need_ra = 1;
		_need_rb = 0;
		_setcond = 0;
		case (mips_op)
		MIPS_OP_R: begin
			_rn = mips_rd;
			_useimm = 0;
			_need_rb = 1;
			case (mips_func)
			MIPS_FUNC_ADD: _aluc = ALU_ADD;
			MIPS_FUNC_SUB: _aluc = ALU_SUB;
			MIPS_FUNC_AND: _aluc = ALU_AND;
			MIPS_FUNC_OR: _aluc = ALU_OR;
			MIPS_FUNC_XOR: _aluc = ALU_XOR;
			MIPS_FUNC_SLL: begin
				_ra = mips_rt;
				_aluc = ALU_SLL;
				_imm = { 26'b0, mips_sa };
				_useimm = 1;
			end
			MIPS_FUNC_SRL: begin
				_ra = mips_rt;
				_aluc = ALU_SRL;
				_imm = { 26'b0, mips_sa };
				_useimm = 1;
			end
			MIPS_FUNC_SRA: begin
				_ra = mips_rt;
				_aluc = ALU_SRA;
				_imm = { 26'b0, mips_sa };
				_useimm = 1;
			end
			MIPS_FUNC_JR: begin
				_wreg = 0;
				_jmp = JMP_ALWAYS;
				_target_sel = TARGET_Q1;
			end
			default: _wreg = 0;
			endcase
		end
		MIPS_OP_ADDI: begin
			_aluc = ALU_ADD;
			_imm = { {16{mips_imm[15]}}, mips_imm };
		end
		MIPS_OP_ANDI: begin
			_aluc = ALU_AND;
			_imm = { 16'b0, mips_imm };
		end
		MIPS_OP_ORI: begin
			_aluc = ALU_OR;
			_imm = { 16'b0, mips_imm };
		end
		MIPS_OP_XORI: begin
			_aluc = ALU_XOR;
			_imm = { 16'b0, mips_imm };
		end
		MIPS_OP_LW: begin
			_aluc = ALU_ADD;
			_imm = { {16{mips_imm[15]}}, mips_imm };
			_m2reg = 1;
		end
		MIPS_OP_SW: begin
			_aluc = ALU_ADD;
			_imm = { {16{mips_imm[15]}}, mips_imm };
			_wmem = 1;
			_wreg = 0;
		end
		MIPS_OP_BEQ: begin
			_wreg = 0;
			_imm = { {14{mips_imm[15]}}, mips_imm, 2'b00 } + next_inst_pc;
			_jmp = JMP_MIPS_E;
		end
		MIPS_OP_BNE: begin
			_wreg = 0;
			_imm = { {14{mips_imm[15]}}, mips_imm, 2'b00 } + next_inst_pc;
			_jmp = JMP_MIPS_NE;
		end
		MIPS_OP_LUI: begin
			_aluc = ALU_OR;
			_imm = { mips_imm, 16'd0 };
			_need_ra = 0;
		end
		MIPS_OP_J: begin
			_need_ra = 0;
			_jmp = JMP_NEVER;
			_wreg = 0;
			_do_jmp = 1;
			_target_pc = { next_inst_pc[31:28], mips_addr, 2'b00 };
			_target_mode = 0;
		end
		MIPS_OP_JAL: begin
			_ra = 5'd0;
			_imm = next_inst_pc;
			_aluc = ALU_OR;
			_rn = 5'd31;
			_jmp = JMP_NEVER;
			_do_jmp = 1;
			_target_pc = { next_inst_pc[31:28], mips_addr, 2'b00 };
			_target_mode = 0;
		end
		default: begin
			_wreg = 0;
			_need_ra = 0;
		end
		endcase
	end else begin
		_setcond = 1;
	end
end

endmodule
