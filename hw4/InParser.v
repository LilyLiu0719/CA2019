module Inparser(
        input [31:0] IR;
        output reg [4:0]
        output wire [5:0] opcode,
        output reg [4:0] rs, rt, rd, shamt, 
        output reg [5:0] funct,
        output reg[15:0] immediate,
        output reg [25:0] address,
);
	assign opcode = instruction[31:26];

	always @(IR) begin
		// R type
		if(opcode == 6'h0) begin
                        rs = instruction[25:21];
                        rt = instruction[20:16];
                        rd = instruction[15:11];
                        shamt = instruction[10:6];
			funct = instruction[5:0];
		end
		// J type
		else if(opcode == 6'h2 | opcode == 6'h3) begin
			address = instruction[26:0];
		end
		// I type
		else begin
			rt = instruction[20:16];
			rs = instruction[25:21];
			immediate = instruction[15:0];
		end
	end
	
endmodule