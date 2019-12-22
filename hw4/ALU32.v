module ALU32(
    input [7:0] ALU_input_1,
    input [7:0] ALU_input_2,        
    input [3:0] ALU_funct, 
    output reg [31:0] ALU_out, 
    output reg Zero
);

always@(ALU_input_1 or ALU_input_2 or ALU_funct) begin
  case(ALU_funct)
    4'b0000: ALU_out = ALU_input_1 & ALU_input_2;
    4'b0001: ALU_out = ALU_input_1 | ALU_input_2;
    4'b0010: ALU_out = ALU_input_1 + ALU_input_2;
    4'b0011: ALU_out = ALU_input_1 * ALU_input_2;
    4'b0100: ALU_out = ALU_input_1 / ALU_input_2;
    4'b0101: ALU_out = ~ALU_input_1;
    4'b0110: ALU_out = ALU_input_1 - ALU_input_2;
    4'b0111: ALU_out = ALU_input_1 < ALU_input_2? 32'd1:32'd0;
    default: ALU_out = 32'd0;
  endcase
end
endmodule