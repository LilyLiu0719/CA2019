module Ctrl(
	input clk, rst;
	input [5:0] opcode;
	output RegDst, Branch, MemtoReg, MemRead, MemWrite, ALUSrc, RegWrite;
	output [1:0] ALUOp;
);
	parameter IDLE = 2'd0;
	parameter FETCH = 2'd1;
	parameter PROCESS = 2'd2;

	reg [1:0]main_state_w, main_state_r;
	reg [3:0]process_count_w, process_count_r;

	
	always @(*) begin
		case (state_r)
        IDLE: begin
    
        end
        FETCH: begin
        
        end 
        PROCESS: begin
            
        end 
        default: begin
            state_w = IDLE;
        end
    endcase
	end

	always@(posedge clk)begin
		
	end
endmodule