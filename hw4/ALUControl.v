module  ALUControl(
    input [1:0] aluop;
    input [5:0] alufunction;
	output [3:0] alufunct;
);

assign alufunct = 4'b0000;

endmodule