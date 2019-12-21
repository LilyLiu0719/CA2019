module  Registers(
    input [5:0] read_reg1, read_reg2, write_reg;
    input regdst, regwrite, memtoreg;
	input [31:0] read_data_mem, alu_result, read_data1, read_data2;
);
