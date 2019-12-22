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
	reg signed [31:0] temp;

     
//==== wire connection to submodule ======================
//Example:
//	ctrl control(
//	.clk(clk),
//	.rst_n(rst_n), ......

//	);

	//read  instruction
	assign Data2Mem = ALUResult
	
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
		.write_data(//todo), //input
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

always@(*)begin
	// MUX1
	if(RegDst == 1b'1) begin
		write_reg = rd;
	end
	else begin
		write_reg = rt;
	end

	// MUX2
	if(ALUSrc == 1b'1) begin
		read_data2_or_im = { {16{immediate[15]}}, immediate};
	end
	else begin
		read_data2_or_im = read_data2;
	end

	// MUX3
	if(MemtoReg == 1b'1) begin
		write_data = ReadDataMem;
	end
	else begin
		write_data = ALUResult;
	end

end

//==== sequential part ====================================
always@(posedge clk)begin
	// j
	if(opcode == 6'h2) begin
		IR_addr = address;
	end
	// jr
	else if(opcode == 6'h0 & funct == 6'h08) begin
		IR_addr = read_data1;
	end
	// branch
	else if(write_data == 0 & branch_signal == 1) begin
		PC = PC + 1 + $signed(immediate); 
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
		
