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
    wire [4:0] rs, rd, rt, shamt;
	wire [25:0] address;
	wire [15:0] immediate;
	wire RegDstJump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
	wire [1:0] ALUOp;
	wire [31:0] read_data1, read_data2, ALUResult;
	wire [3:0] ALUFunct;

     
//==== wire connection to submodule ======================
//Example:
//	ctrl control(
//	.clk(clk),
//	.rst_n(rst_n), ......

//	);

	//read  instruction

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
		.write_reg(rd), //input
		.write_data(//todo), //input
		.reg_write(RegWrite), //input
		.read_data_mem(ReadDataMem), //input 
		.memtoreg(MemtoReg), //input
		.alu_result(ALUResult), //input
		.read_data1(read_data1), 
		.read_data2(read_data2)
	);

	ALUControl ALU_control(
		.aluop(ALUOp), //input
		.alufunction(immediate), //input 
		.alufunct(ALUFunct)
	);

	ALU32 alu(
		.ALU_input_1(),
		.ALU_input_2(),
		.ALU_funct(ALUFunct), 
		.ALU_out(ALUResult)
	);

//==== combinational part =================================

always@(*)begin

// mux



end

//==== sequential part ====================================
always@(posedge clk)begin
	

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
		
