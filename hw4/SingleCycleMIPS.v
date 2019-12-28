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
    wire [5:0] funct, opcode;
    wire [4:0] rs, rd, rt, shamt, write_reg;
	wire [25:0] address;
	wire [15:0] immediate;
	wire RegDstJump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	wire [1:0] ALUOp;
	wire [31:0] read_data1, read_data2, ALUResult, read_data2_or_im;
	wire [3:0] ALUFunct;

	reg [31:0] IR_r, IR_w, IR_addr_w, IR_addr_r, ReadDataMem_r, ReadDataMem_w, Data2Mem_r, Data2Mem_w;
	reg [6:0] A_r, A_w;
	reg CEN_r, CEN_w, WEN_r, WEN_w, OEN_r, OEN_w;
	reg [5:0] funct_r, funct_w, opcode_r, opcode_w;
    reg [4:0] rs_r, rs_w, rd_r, rd_w, rt_r, rt_w, shamt_r, shamt_w, write_reg_r, write_reg_w;
	reg [25:0] address_r, address_w;
	reg [15:0] immediate_r, immediate_w;
	reg RegDstJump_r, RegDstJump_w, Branch_r, Branch_w, MemRead_r, MemRead_w, MemtoReg_w, MemtoReg_w, MemWrite_r, MemWrite_w, ALUSrc_r, ALUSrc_w, RegWrite_r, RegWrite_w;
	reg [1:0] ALUOp_r, ALUOp_w;
	reg [31:0] read_data1_r, read_data1_w, read_data2_r, read_data2_w, ALUResult_r, ALUResult_w, read_data2_or_im_r, read_data2_or_im_w;
	reg [3:0] ALUFunct_r, ALUFunct_w;
     
//==== wire connection to submodule ======================
//Example:
//	ctrl control(
//	.clk(clk),
//	.rst_n(rst_n), ......

//	);

	//read  instruction
	assign Data2Mem = ALUResult;
	Inparser input_parser(
		.IR(IR), // input
		.opcode(opcode), 
		.rs(rs), 
		.rt(rt),  
		.rd(rd),
		.shamt(shamt), 
		.funct(funct), 
		.immediate(immediate),
		.address(address)
	);

	Ctrl control(
		.clk(clk),
		.rst(rst_n), 
		.opcode(opcode), //input
		.RegDst(RegDst),
		.Branch(Branch), 
		.MemRead(MemRead), 
		.MemtoReg(MemtoReg), 
		.MemWrite(MemWrite), 
		.ALUSrc(ALUSrc),
		.RegWrite(RegWrite)
	);
	
	Registers reg_process(
		.read_reg1(rs), //input
		.read_reg2(rt), //input
		.write_reg(write_reg), //input
		.write_data(write_data), //input
		.read_data1(read_data1), 
		.read_data2(read_data2)
	);

	ALUControl ALU_control(
		.aluop(ALUOp), //input
		.alufunction(immediate), //input 
		.alufunct(ALUFunct)
	);

	ALU32 alu(
		.ALU_input_1(read_data1),
		.ALU_input_2(read_data2_or_im),
		.ALU_funct(ALUFunct), 
		.ALU_out(ALUResult)
	);

//==== combinational part =================================

always@(*)begin // 改w=r
	// MUX1
	IR_w = IR_r;
	IR_addr_w = IR_addr_r;
	ReadDataMem_w = ReadDataMem_r;
	Data2Mem_w = Data2Mem_r;
	A_w = A_r;
	CEN_w = CEN_r;
	WEN_w = WEN_r;
	OEN_w = OEN_r;
	funct_w = funct_r;
	opcode_w = opcode_r;
	rs_w = rs_r;
	rt_w = rt_r;
	rd_w = rd_r;
	shamt_w = shamt_r;
	write_reg_w = write_reg_r;
	address_w = address_r;
	immediate_w = immediate_r;
	RegDstJump_w = RegDstJump_r;
	Branch_w = Branch_r;
	MemRead_w = MemRead_r;
	MemtoReg_w = MemtoReg_r;
	MemWrite_w = MemWrite_r;


	if(RegDst == 1'b1) begin
		write_reg = rd;
	end
	else begin
		write_reg = rt;
	end

	// MUX2
	if(ALUSrc == 1'b1) begin
		read_data2_or_im = { {16{immediate[15]}}, immediate};
	end
	else begin
		read_data2_or_im = read_data2;
	end

	// MUX3
	if(MemtoReg == 1'b1) begin
		write_data = ReadDataMem;
	end
	else begin
		write_data = ALUResult;
	end

end

//==== sequential part ====================================
always@(posedge clk)begin //r=w
	// j
	if(opcode == 6'h2) begin
		IR_addr = address;
	end
	// jr
	else if(opcode == 6'h0 & funct == 6'h08) begin
		IR_addr = read_data1;
	end
	// branch
	else if(write_data == 0 & Branch == 1) begin
		IR_addr = IR_addr + 4 + $signed(immediate); 
	end
	else begin
		IR_addr = IR_addr+4;
	end
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
		
