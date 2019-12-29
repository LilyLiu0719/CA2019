module SingleCycleMIPS( 
    clk,
    rst_n,
    IR_addr,
    IR,
    ReadDataMem,
    CEN,
    WEN,
    A,
    Data2Mem,
    OEN
);

//==== in/out declaration =================================
    //-------- processor ----------------------------------
    input         clk, rst_n;
    input  [31:0] IR;
    output [31:0] IR_addr;
    //-------- data memory --------------------------------
    input  [31:0] ReadDataMem;  
    output        CEN;  
    output        WEN; 
    output  [6:0] A;
    output [31:0] Data2Mem;  
    output        OEN;

//==== reg/wire declaration ===============================
    // wire [5:0] _funct, _opcode;
    // wire [4:0] rs, rd, rt, shamt, write_reg;
	// wire [25:0] address;
	// wire [15:0] immediate;
	// wire RegDstJump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	// wire [1:0] ALUOp;
	// wire [31:0] read_data1, read_data2, ALUResult;
	// wire [3:0] ALUFunct;

	wire [5:0] _funct, _opcode;
	wire [4:0] _fmt;
	wire [4:0] _ft, _fs, _fd;
	wire [2:0] _rnd;
	wire [31:0] _faluin1, _faluin2, _addout, _subout, _mulout, _divout;
	wire [63:0] _daluin1, _daluin2, _daddout, _dsubout;

	// reg [31:0] IR_r, IR_w, IR_addr_w, IR_addr_r, ReadDataMem_r, ReadDataMem_w, Data2Mem_r, Data2Mem_w;
	// reg [6:0] A_r, A_w;
	// reg CEN_r, CEN_w, WEN_r, WEN_w, OEN_r, OEN_w;
	// reg [5:0] funct_r, funct_w, opcode_r, opcode_w;
    // reg [4:0] rs_r, rs_w, rd_r, rd_w, rt_r, rt_w, shamt_r, shamt_w, write_reg_r, write_reg_w;
	// reg [25:0] address_r, address_w;
	// reg [15:0] immediate_r, immediate_w;
	// reg RegDstJump_r, RegDstJump_w, Branch_r, Branch_w, MemRead_r, MemRead_w, MemtoReg_w, MemtoReg_w, MemWrite_r, MemWrite_w, ALUSrc_r, ALUSrc_w, RegWrite_r, RegWrite_w;
	// reg [1:0] ALUOp_r, ALUOp_w;
	// reg [31:0] read_data1_r, read_data1_w, read_data2_r, read_data2_w, ALUResult_r, ALUResult_w, read_data2_or_im_r, read_data2_or_im_w;
	// reg [3:0] ALUFunct_r, ALUFunct_w;

	reg [31:0] read_data1_r, read_data1_w, read_data2_r, read_data2_w, write_data_r, write_data_w;
	reg [63:0] dread_data1_r, dread_data1_w, dread_data2_r, dread_data2_w, dwrite_data_r, dwrite_data_w;
	reg [2:0] rnd_w, rnd_r;
	reg [31:0] addout_r, addout_w, subout_r, subout_w, mulout_r, mulout_w, divout_r, divout_w;
	reg FPCond_w, FPCond_r;
	reg [31:0] Freg_r[0:31], Freg_w[0:31];
	reg [63:0] daddout_r, daddout_w, dsubout_r, dsubout_w;
     
//==== wire connection to submodule ======================
//Example:
//	ctrl control(
//	.clk(clk),
//	.rst_n(rst_n), ......

//	);

	//read  instruction
	assign _rnd = rnd_w;
	assign _opcode = IR[31:26];
	assign _fmt = IR[25:21];
	assign _ft = IR[20:16];
	assign _fs = IR[15:11];
	assign _fd = IR[10:6];
	assign _funct = IR[5:0];
	assign _faluin1 = read_data1_w;
	assign _faluin2 = read_data2_w;
	assign _addout = addout_w;
	assign _subout = subout_w;
	assign _mulout = mulout_w;
	assign _divout = divout_w;
	assign _daddout = daddout_w;
	assign _dsubout = dsubout_w;

	DW_fp_add fp_adder(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_addout)
	);

	DW_fp_sub fp_sub(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_subout)
	);

	DW_fp_mult fp_mul(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_mulout)
	);
	
	DW_fp_div fp_div(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_divout)
	);

	DW_fp_add #(52, 11, 0) dp_adder(
		.a(_daluin1), 
		.b(_daluin2), 
		.rnd(_rnd), 
		.z(_daddout)
	);

	DW_fp_sub #(52, 11, 0) dp_sub(
		.a(_daluin1), 
		.b(_daluin2), 
		.rnd(_rnd), 
		.z(_dsubout)
	);

	// FRegister Freg(
	// 	.read_reg1(_fs), //input
	// 	.read_reg2(_ft), //input
	// 	.write_reg(_fd), //input
	// 	.write_data(_faluout), //input
	// 	.read_data1(_faluin1), 
	// 	.read_data2(_faluin2)
	// );

	// assign Data2Mem = ALUResult;
	// assign write_reg = write_reg_w;
	// Inparser input_parser(
	// 	.IR(IR_w), // input
	// 	.opcode(opcode_w), 
	// 	.rs(rs_w), 
	// 	.rt(rt_w),  
	// 	.rd(rd_w),
	// 	.shamt(shamt_w), 
	// 	.fs(fs_w), 
	// 	.ft(ft_w), 
	// 	.fd(ft_w), 
	// 	.fmt(fmt_w), 
	// 	.funct(funct_w), 
	// 	.immediate(immediate_w),
	// 	.address(address_w)
	// );

	// Ctrl control(
	// 	.clk(clk),
	// 	.rst(rst_n), 
	// 	.opcode(opcode), //input
	// 	.RegDst(RegDst),
	// 	.Branch(Branch), 
	// 	.MemRead(MemRead), 
	// 	.MemtoReg(MemtoReg), 
	// 	.MemWrite(MemWrite), 
	// 	.ALUSrc(ALUSrc),
	// 	.RegWrite(RegWrite)
	// );
	
	// Registers reg_process(
	// 	.read_reg1(rs), //input
	// 	.read_reg2(rt), //input
	// 	.write_reg(write_reg), //input
	// 	.write_data(write_data), //input
	// 	.read_data1(read_data1), 
	// 	.read_data2(read_data2)
	// );

	// ALUControl ALU_control(
	// 	.aluop(ALUOp), //input
	// 	.alufunction(immediate), //input 
	// 	.alufunct(ALUFunct)
	// );

	// ALU32 alu(
	// 	.ALU_input_1(read_data1),
	// 	.ALU_input_2(read_data2_or_im),
	// 	.ALU_funct(ALUFunct), 
	// 	.ALU_out(ALUResult)
	// );

//==== combinational part =================================

always@(*)begin // 改w=r
	// MUX1
	// IR_w = IR_r;
	// IR_addr_w = IR_addr_r;
	// ReadDataMem_w = ReadDataMem_r;
	// Data2Mem_w = Data2Mem_r;
	// A_w = A_r;
	// CEN_w = CEN_r;
	// WEN_w = WEN_r;
	// OEN_w = OEN_r;
	// funct_w = funct_r;
	// opcode_w = opcode_r;
	// rs_w = rs_r;
	// rt_w = rt_r;
	// rd_w = rd_r;
	// shamt_w = shamt_r;
	// write_reg_w = write_reg_r;
	// address_w = address_r;
	// immediate_w = immediate_r;
	// RegDstJump_w = RegDstJump_r;
	// Branch_w = Branch_r;
	// MemRead_w = MemRead_r;
	// MemtoReg_w = MemtoReg_r;
	// MemWrite_w = MemWrite_r;
	// ALUSrc_w = ALUSrc_r;
	// RegWrite_w = RegWrite_r;
	// ALUOp_w = ALUOp_r;
	// read_data1_w = read_data1_r;
	// read_data2_w = read_data2_r;
	// ALUResult_w = ALUResult_r; 
	// read_data2_or_im_w = read_data2_or_im_r;
	// ALUFunct_w = ALUFunct_r;

	// if(RegDst == 1'b1) begin
	// 	write_reg_w = rd;
	// end
	// else begin
	// 	write_reg_w = rt_r;
	// end

	// // MUX2
	// if(ALUSrc == 1'b1) begin
	// 	read_data2_or_im_w = { {16{immediate_r[15]}}, immediate_r};
	// end
	// else begin
	// 	read_data2_or_im_w = read_data2_r;
	// end

	// // MUX3
	// if(MemtoReg_w == 1'b1) begin
	// 	write_data_w = ReadDataMem_r;
	// end
	// else begin
	// 	write_data_w = ALUResult_r;
	// end
	// write_reg = write_reg_w;
	// ReadDataMem = ReadDataMem_r;
	// IR = IR_r;
	// IR_addr = IR_addr_r;
	// CEN = CEN_r;
	// WEN = WEN_r;
	rnd_w = 3'd0;
	case(_opcode)
		6'h11: begin // FR
			case(_fmt)
				6'h10: begin
					read_data1_w = Freg_r[_rs];
					read_data2_w = Freg_r[_rt];
					case(_funct)
						6'h00: write_data_w = addout_r;
						6'h01: write_data_w = subout_r;
						6'h02: write_data_w = mulout_r;
						6'h03: write_data_w = divout_r;
						6'h32: FPCond_w = (read_data1_w == read_data2_w) ? (1'b1) : (1'b0)
					endcase
					Freg_w[_rd] = write_data_w;
				end
				// bclt
				6'h8: IR_addr_w = (FPCond_r == 1'b1) ? (IR_addr_r + 4 + {14'b0, _immediate, 2'b0}) : (IR_addr_r + 32'd4); 
				6'h11: begin // double
					dread_data1_w = { Freg_r[_rs], Freg_r[_rs+1] };
					dread_data2_w = { Freg_r[_rt], Freg_r[_rt+1] };
					case(_funct)
						6'h00: dwrite_data_w = daddout_r;
						6'h01: dwrite_data_w = dsubout_r;
					endcase
					Freg_w[_rd] = write_data_w[63:32];
					Freg_w[_rd+1] = write_data_w[31:0];
				end
			endcase
		end
		6'h31: begin //lwcl
			case(process_counter_r)
				4'd0: begin
					process_counter_w = 4'd1;
					OEN_w = 1'b0;
					CEN_w = 1'b0;
					WEN_w = 1'b1;
					A_w = (Freg_r[_fs] + {16'b0 ,_immediate}) >> 2;
				end
				4'd1: begin
					state_w = PROCESS;
					process_counter_w = 4'd0;
					CEN_w = 1'b1;
					Freg_w[_rt] = ReadDataMem;
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		6'h39: begin // swcl
			case(process_counter_r)
				4'd0: begin
					process_counter_w = 4'd1;
					CEN_w = 1'b0;
					WEN_w = 1'b0;
					OEN_w = 1'b1;
					A_w = (Freg_r[_rs] + {16'b0 ,_immediate}) >> 2;
					Data2Mem_w = Freg_r[_rt];
				end
				4'd1: begin
					state_w = PROCESS;
					process_counter_w = 4'd0;
					CEN_w = 1'b1;
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		end
		6'h35: begin //ldcl
			case(process_counter_r)
				4'd0: begin
					process_counter_w = 4'd1;
					OEN_w = 1'b0;
					CEN_w = 1'b0;
					WEN_w = 1'b1;
					A_w = (Freg[_fs] + {16'b0 ,_immediate}) >> 2;
				end
				4'd1: begin
					process_counter_w = 4'd2;
					CEN_w = 1'b1;
					Freg[_rt] = ReadDataMem;
				end
				4'd2: begin
					process_counter_w = 4'd3;
					OEN_w = 1'b0;
					CEN_w = 1'b0;
					WEN_w = 1'b1;
					A_w = (Freg[_fs+1] + {16'b0 ,_immediate}) >> 2;
				end
				4'd3: begin
					state_w = PROCESS;
					process_counter_w = 4'd0;
					CEN_w = 1'b1;
					Freg[_rt+1] = ReadDataMem;
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		6'h3D: begin // sdcl
			case(process_counter_r)
				4'd0: begin
					process_counter_w = 4'd1;
					CEN_w = 1'b0;
					WEN_w = 1'b0;
					OEN_w = 1'b1;
					A_w = (Freg[_rs] + {16'b0 ,_immediate}) >> 2;
					Data2Mem_w = Freg_r[_rt];
				end
				4'd1: begin
					process_counter_w = 4'd2;
					CEN_w = 1'b1;
				end
				4'd2: begin
					process_counter_w = 4'd3;
					CEN_w = 1'b0;
					WEN_w = 1'b0;
					OEN_w = 1'b1;
					A_w = (Freg[_rs+1] + {16'b0 ,_immediate}) >> 2;
					Data2Mem_w = Freg_r[_rt+1];
				end
				4'd3: begin
					state_w = PROCESS;
					process_counter_w = 4'd0;
					CEN_w = 1'b1;
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		end
	endcase


end

//==== sequential part ====================================
always@(posedge clk)begin //r=w
	rnd_r = rnd_w;
	addout_r = addout_w;
	subout_r = subout_w;
	mulout_r = mulout_w;
	divout_r = divout_w;
	FPCond_r = FPCond_w;
	daddout_r = daddout_w;
	dsubout_r = dsubout_w;
	read_data1_r = read_data1_w;
	read_data2_r = read_data2_w;
	write_data_r = write_data_w;
	dread_data1_r = dread_data1_w;
	dread_data2_r = dread_data2_w;
	dwrite_data_r = dwrite_data_w;
	for( i=0; i<32; i=i+1) begin
		Freg_r[i] = Freg_w[i];
	end

	// // j
	// if(opcode == 6'h2) begin
	// 	IR_addr = address;
	// end
	// // jr
	// else if(opcode == 6'h0 & funct == 6'h08) begin
	// 	IR_addr = read_data1;
	// end
	// // branch
	// else if(write_data == 0 & Branch == 1) begin
	// 	IR_addr = IR_addr + 4 + $signed(immediate); 
	// end
	// else begin
	// 	IR_addr = IR_addr+4;
	// end
end

endmodule

// recommend you to use submodule for easier debugging 
//=========================================================
//Example:
//	module ctrl(
//		clk,
//		rst_n, ....  


//	);





//	endmodule
		
