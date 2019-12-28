module Ctrl(
	input clk, rst;
	input [5:0] opcode;
	output RegDst, Branch, MemtoReg, MemRead, MemWrite, ALUSrc, RegWrite;
	output [1:0] ALUOp;
);
	always@(posedge clk)begin
		assign RegDst = Branch = MemtoReg = MemRead = MemWrite = ALUSrc = RegWrite = 1'b0;
		assign ALUOp = 2'b00;
	end
endmodule