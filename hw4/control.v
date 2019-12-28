module Ctrl(
	input [5:0] opcode;
	output RegDst, Branch, MemtoReg, MemRead, MemWrite, ALUSrc, RegWrite;
	output [1:0] ALUOp;
);

parameter IDLE = 16'd0;
parameter FETCH = 16'd1;
parameter PROCESS = 16'd2;

reg [15:0]state_w, state_r;
reg [5:0]currentOP_w, state_r;

always@(*)begin
//data flow	
	state_w = state_r;
//case 
	case (state_r)
        IDLE: begin
            A_w = 1;
            state_w = COUNT;
        end
        FETCH: begin

        end 
        PROCESS: begin
            
        end 
        default: begin
            
        end
    endcase
end

always@(posedge clk)begin
//data flow	
	state_r <= state_w;
end

endmodule