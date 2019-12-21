module Inparser(
	input [31:0] IR;
	input [5:0] opcode;
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
