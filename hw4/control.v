module Ctrl(
	input clk, rst;
	input [5:0] opcode;
	output RegDst, Branch, MemtoReg, MemRead, MemWrite, ALUSrc, RegWrite;
	output [1:0] ALUOp;
);
endmodule