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
    output 	[6:0] A;
    output [31:0] Data2Mem;  
    output        OEN;
  
//==== reg/wire declaration ===============================
	// param state
	parameter IDLE = 2'd0;
	parameter PROCESS = 2'd1;

	// wire
	wire [5:0] _opcode, _funct;
	wire [4:0] _rs, _rt, _rd, _shamt;
	wire signed [15:0] _immediate;
	wire [25:0] _address;

	//fpu wire
	wire [4:0] _fmt;
	wire [4:0] _ft, _fs, _fd;
	wire [2:0] _rnd;
	wire [31:0] _faluin1, _faluin2, _addout, _subout, _mulout, _divout;
	wire [63:0] _daluin1, _daluin2, _daddout, _dsubout;
	
	// reg
	reg CEN_w, CEN_r, WEN_w, WEN_r, OEN_w, OEN_r;
	reg [6:0] 	A_w, A_r;
	reg signed [31:0]	Data2Mem_w, Data2Mem_r;
	reg signed [31:0]	ReadDataMem_w, ReadDataMem_r;
	reg [31:0]	IR_addr_w, IR_addr_r;

	// internal reg
	reg [3:0] process_counter_w, process_counter_r;
	reg [31:0] instruction_w, instruction_r;

	// fpu
	reg [31:0] read_data1_r, read_data1_w, read_data2_r, read_data2_w, write_data_r, write_data_w;
	reg [63:0] dread_data1_r, dread_data1_w, dread_data2_r, dread_data2_w, dwrite_data_r, dwrite_data_w;
	reg [2:0] rnd_w, rnd_r;
	reg [31:0] addout_r, addout_w, subout_r, subout_w, mulout_r, mulout_w, divout_r, divout_w;
	reg FPCond_w, FPCond_r;
	reg [63:0] daddout_r, daddout_w, dsubout_r, dsubout_w;

	// MIPS register
	reg signed [31:0] register_r[0:31];
	reg signed [31:0] register_w[0:31];
	reg [31:0] Freg_r[0:31], Freg_w[0:31];

	// assign wire 
	assign _opcode = IR[31:26];
	assign _rs = IR[25:21];
	assign _rt = IR[20:16];
	assign _rd = IR[15:11];
	assign _shamt = IR[10:6];
	assign _funct = IR[5:0];
	assign _immediate = IR[15:0];
	assign _address = IR[25:0];

	assign IR_addr = IR_addr_r;
	assign CEN = CEN_w;
	assign WEN = WEN_w;
	assign A = A_w;
	// assign ReadDataMem = ReadDataMem_w;
	assign Data2Mem = Data2Mem_w;
	assign OEN = OEN_w;

	// fpu assign
	assign _rnd = rnd_w;
	assign _opcode = IR[31:26];
	assign _fmt = IR[25:21];
	assign _ft = IR[20:16];
	assign _fs = IR[15:11];
	assign _fd = IR[10:6];
	assign _funct = IR[5:0];
	assign _faluin1 = read_data1_w;
	assign _faluin2 = read_data2_w;
	// assign _addout = addout_w;
	// assign _subout = subout_w;
	// assign _mulout = mulout_w;
	// assign _divout = divout_w;
	// assign _daddout = daddout_w;
	// assign _dsubout = dsubout_w;


	DW_fp_add fp_adder(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_addout)
	);

	DW_fp_sub fp_sub(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_subout)
	);

	DW_fp_mult fp_mul(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_mulout)
	);
	
	DW_fp_div fp_div(
		.a(_faluin1), 
		.b(_faluin2), 
		.rnd(_rnd), 
		.z(_divout)
	);

	DW_fp_add #(52, 11, 0) dp_adder(
		.a(_daluin1), 
		.b(_daluin2), 
		.rnd(_rnd), 
		.z(_daddout)
	);

	DW_fp_sub #(52, 11, 0) dp_sub(
		.a(_daluin1), 
		.b(_daluin2), 
		.rnd(_rnd), 
		.z(_dsubout)
	);

	// $ZERO
	// assign register_w[0] = 32'd0;
//==== combinational part =================================
	integer i;
always@(*)begin
	for ( i=0 ; i<32; i=i+1) begin
		register_w[i] = register_r[i];
	end
	register_w[0] = 0;

	for( i=0; i<32; i=i+1) begin
		Freg_w[i] = Freg_r[i];
	end

	rnd_w = rnd_r;
	addout_w = addout_r;
	subout_w = subout_r;
	mulout_w = mulout_r;
	divout_w = divout_r;
	FPCond_w = FPCond_r;
	daddout_w = daddout_r;
	dsubout_w = dsubout_r;
	read_data1_w = read_data1_r;
	read_data2_w = read_data2_r;
	write_data_w = write_data_r;
	dread_data1_w = dread_data1_r;
	dread_data2_w = dread_data2_r;
	dwrite_data_w = dwrite_data_r;
	

	instruction_w = instruction_r;
	process_counter_w = process_counter_r;
	IR_addr_w = IR_addr_r;

	ReadDataMem_w = ReadDataMem;
	Data2Mem_w = Data2Mem_r;
	
	A_w = A_r;
	WEN_w = 1'b1;
	OEN_w = 1'b1;
	CEN_w = 1'b1;
	rnd_w = 3'd0;
	
	if(IR != 0) begin
		case(_opcode)
		6'h0: begin
			case(_funct)
			6'h0: begin //sll
				case (_shamt)
					31 : register_w[_rd] = {register_r[_rt][0:0], 31'b0};
					30 : register_w[_rd] = {register_r[_rt][1:0], 30'b0};
					29 : register_w[_rd] = {register_r[_rt][2:0], 29'b0};
					28 : register_w[_rd] = {register_r[_rt][3:0], 29'b0};
					27 : register_w[_rd] = {register_r[_rt][4:0], 27'b0};
					26 : register_w[_rd] = {register_r[_rt][5:0], 26'b0};
					25 : register_w[_rd] = {register_r[_rt][6:0], 25'b0};
					24 : register_w[_rd] = {register_r[_rt][7:0], 24'b0};
					23 : register_w[_rd] = {register_r[_rt][8:0], 23'b0};
					22 : register_w[_rd] = {register_r[_rt][9:0], 22'b0};
					21 : register_w[_rd] = {register_r[_rt][10:0], 21'b0};
					20 : register_w[_rd] = {register_r[_rt][11:0], 20'b0};
					19 : register_w[_rd] = {register_r[_rt][12:0], 19'b0};
					18 : register_w[_rd] = {register_r[_rt][13:0], 18'b0};
					17 : register_w[_rd] = {register_r[_rt][14:0], 17'b0};
					16 : register_w[_rd] = {register_r[_rt][15:0], 16'b0};
					15 : register_w[_rd] = {register_r[_rt][16:0], 15'b0};
					14 : register_w[_rd] = {register_r[_rt][17:0], 14'b0};
					13 : register_w[_rd] = {register_r[_rt][18:0], 13'b0};
					12 : register_w[_rd] = {register_r[_rt][19:0], 12'b0};
					11 : register_w[_rd] = {register_r[_rt][20:0], 11'b0};
					10 : register_w[_rd] = {register_r[_rt][21:0], 10'b0};
					9 : register_w[_rd] = {register_r[_rt][22:0], 9'b0};
					8 : register_w[_rd] = {register_r[_rt][23:0], 8'b0};
					7 : register_w[_rd] = {register_r[_rt][24:0], 7'b0};
					6 : register_w[_rd] = {register_r[_rt][25:0], 6'b0};
					5 : register_w[_rd] = {register_r[_rt][26:0], 5'b0};
					4 : register_w[_rd] = {register_r[_rt][27:0], 4'b0};
					3 : register_w[_rd] = {register_r[_rt][28:0], 3'b0};
					2 : register_w[_rd] = {register_r[_rt][29:0], 2'b0};
					1 : register_w[_rd] = {register_r[_rt][30:0], 1'b0};
					0 : register_w[_rd] = 	register_r[_rt][31:0];
				endcase
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h02: begin //srl
				case (_shamt)
					31 : register_w[_rd] = {31'b0, register_r[_rt][31:31]};
					30 : register_w[_rd] = {30'b0, register_r[_rt][31:30]};
					29 : register_w[_rd] = {29'b0, register_r[_rt][31:29]};
					28 : register_w[_rd] = {28'b0, register_r[_rt][31:28]};
					27 : register_w[_rd] = {27'b0, register_r[_rt][31:27]};
					26 : register_w[_rd] = {26'b0, register_r[_rt][31:26]};
					25 : register_w[_rd] = {25'b0, register_r[_rt][31:25]};
					24 : register_w[_rd] = {24'b0, register_r[_rt][31:24]};
					23 : register_w[_rd] = {23'b0, register_r[_rt][31:23]};
					22 : register_w[_rd] = {22'b0, register_r[_rt][31:22]};
					21 : register_w[_rd] = {21'b0, register_r[_rt][31:21]};
					20 : register_w[_rd] = {20'b0, register_r[_rt][31:20]};
					19 : register_w[_rd] = {19'b0, register_r[_rt][31:19]};
					18 : register_w[_rd] = {18'b0, register_r[_rt][31:18]};
					17 : register_w[_rd] = {17'b0, register_r[_rt][31:17]};
					16 : register_w[_rd] = {16'b0, register_r[_rt][31:16]};
					15 : register_w[_rd] = {15'b0, register_r[_rt][31:15]};
					14 : register_w[_rd] = {14'b0, register_r[_rt][31:14]};
					13 : register_w[_rd] = {13'b0, register_r[_rt][31:13]};
					12 : register_w[_rd] = {12'b0, register_r[_rt][31:12]};
					11 : register_w[_rd] = {11'b0, register_r[_rt][31:11]};
					10 : register_w[_rd] = {10'b0, register_r[_rt][31:10]};
					9 : register_w[_rd] = {9'b0, register_r[_rt][31:9]};
					8 : register_w[_rd] = {8'b0, register_r[_rt][31:8]};
					7 : register_w[_rd] = {7'b0, register_r[_rt][31:7]};
					6 : register_w[_rd] = {6'b0, register_r[_rt][31:6]};
					5 : register_w[_rd] = {5'b0, register_r[_rt][31:5]};
					4 : register_w[_rd] = {4'b0, register_r[_rt][31:4]};
					3 : register_w[_rd] = {3'b0, register_r[_rt][31:3]};
					2 : register_w[_rd] = {2'b0, register_r[_rt][31:2]};
					1 : register_w[_rd] = {1'b0, register_r[_rt][31:1]};
					0 : register_w[_rd] = 	register_r[_rt][31:0];
				endcase
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h20: begin //add 
				register_w[_rd] = register_r[_rs] + register_r[_rt];
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h22: begin //sub
				register_w[_rd] = register_r[_rs] - register_r[_rt];
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h24: begin //and
				register_w[_rd] = register_r[_rs] & register_r[_rt];
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h25: begin //or
				register_w[_rd] = register_r[_rs] | register_r[_rt];
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h2A: begin //slt
				if(register_r[_rs] < register_r[_rt]) begin
					register_w[_rd] = 1;
				end
				else begin
					register_w[_rd] = 0;
				end
				IR_addr_w = IR_addr_r + 32'd4;
				instruction_w = IR;
			end
			6'h8: begin //jr
				IR_addr_w = register_r[_rs];
				instruction_w = IR;
			end
			endcase
		end
		6'h8: begin // addi 
			register_w[_rt] = $unsigned( $signed(register_r[_rs]) + _immediate);
			IR_addr_w = IR_addr_r + 32'd4;
			instruction_w = IR;
		end
		6'h23: begin // lw
			CEN_w = 1'b0;
			WEN_w = 1'b1;
			OEN_w = 1'b0;
			A_w = $unsigned( $signed (register_r[_rs]) + _immediate) >> 2;
			register_w[_rt] = ReadDataMem;
			ReadDataMem_w = ReadDataMem;

			IR_addr_w = IR_addr_r + 32'd4;
			instruction_w = IR;	
		end
		6'h2B: begin // sw
			CEN_w = 1'b0;
			WEN_w = 1'b0;
			OEN_w = 1'b1;
			
			A_w = $unsigned( $signed(register_r[_rs]) + _immediate) >> 2;
			Data2Mem_w = register_r[_rt];
			IR_addr_w = IR_addr_r + 32'd4;
			instruction_w = IR;
		end
		6'h4: begin // beq
			if(register_r[_rs] == register_r[_rt]) begin
				IR_addr_w = $unsigned ($signed (IR_addr_r) + _immediate*4 + 4);
			end
			else begin
				IR_addr_w = (IR_addr_r + 32'd4);
			end
			instruction_w = IR;
		end
		6'h5: begin // bne
			if(register_r[_rs] == register_r[_rt]) begin
				IR_addr_w = (IR_addr_r + 32'd4);
			end
			else begin
				IR_addr_w = $unsigned ($signed (IR_addr_r) + _immediate*4 + 4);
			end
			instruction_w = IR;
		end
		6'h2: begin // j
			IR_addr_w = {IR_addr_r[31:28] ,_address, 2'b0};
			instruction_w = IR;
		end
		6'h3: begin // jal
			register_w[31] =  IR_addr_r + 32'd4;
			IR_addr_w = {IR_addr_r[31:28] ,_address, 2'b0};
			instruction_w = IR;
		end
		6'h11: begin // FR
			case(_fmt)
				6'h10: begin
					read_data1_w = Freg_r[_fs];
					read_data2_w = Freg_r[_ft];
					case(_funct)
						// 6'h00: write_data_w = addout_r;
						// 6'h01: write_data_w = subout_r;
						// 6'h02: write_data_w = mulout_r;
						// 6'h03: write_data_w = divout_r;
						6'h00: begin 
							write_data_w = _addout;
							Freg_w[_fd] = write_data_w;
						end
						6'h01: begin
							write_data_w = _subout;
							Freg_w[_fd] = write_data_w;
						end
						6'h02: begin
							write_data_w = _mulout;
							Freg_w[_fd] = write_data_w;
						end
						6'h03: begin
							write_data_w = _divout;
							Freg_w[_fd] = write_data_w;
						end
						6'h32: begin 
							if(read_data1_w == read_data2_w) begin
								FPCond_w = 1;
							end
							else begin
								FPCond_w = 0;
							end
						end
					endcase
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
				// bclt
				6'h8: begin
					if(FPCond_r == 1'b1) begin
						IR_addr_w = $unsigned ($signed (IR_addr_r) + _immediate*4 + 4);
					end
					else begin
						IR_addr_w = (IR_addr_r + 32'd4);
					end
				end
				6'h11: begin // double
					dread_data1_w = { Freg_r[_fs], Freg_r[_fs+1] };
					dread_data2_w = { Freg_r[_ft], Freg_r[_ft+1] };
					case(_funct)
						6'h00: dwrite_data_w = _daddout;
						6'h01: dwrite_data_w = _dsubout;
					endcase
					Freg_w[_fd] = dwrite_data_w[63:32];
					Freg_w[_fd+1] = dwrite_data_w[31:0];
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		end
		6'h31: begin //lwcl
			CEN_w = 1'b0;
			OEN_w = 1'b0;	
			WEN_w = 1'b1;
			A_w = $unsigned( $signed(register_r[_rs]) + _immediate) >> 2;
			Freg_w[_ft] = ReadDataMem;
			ReadDataMem_w = ReadDataMem;
			IR_addr_w = IR_addr_r + 32'd4;
			instruction_w = IR;
		end
		6'h39: begin // swcl
			CEN_w = 1'b0;
			OEN_w = 1'b1;
			WEN_w = 1'b0;
			A_w = $unsigned( $signed(register_r[_rs]) + _immediate) >> 2;
			Data2Mem_w = Freg_r[_ft];
			IR_addr_w = IR_addr_r + 32'd4;
			instruction_w = IR;
		end

		6'h35: begin //ldcl
			case(process_counter_r)
				4'd0: begin
					process_counter_w = 4'd1;
					OEN_w = 1'b0;
					CEN_w = 1'b1;
					WEN_w = 1'b0;
					A_w = $unsigned( $signed(register_r[_rs]) + _immediate) >> 2;
					Freg_w[_ft] = ReadDataMem;
					ReadDataMem_w = ReadDataMem;
				end
				4'd1: begin
					process_counter_w = 4'd0;
					OEN_w = 1'b0;
					CEN_w = 1'b1;
					WEN_w = 1'b0;
					A_w = $unsigned( $signed(register_r[_rs+1]) + _immediate) >> 2;
					Freg_w[_ft+1] = ReadDataMem;
					ReadDataMem_w = ReadDataMem;
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		end
		6'h3D: begin // sdcl
			case(process_counter_r)
				4'd0: begin
					process_counter_w = 4'd1;
					CEN_w = 1'b0;
					WEN_w = 1'b0;
					OEN_w = 1'b1;
					A_w = $unsigned( $signed(register_r[_rs]) + _immediate) >> 2;
					Data2Mem_w = Freg_r[_ft];
					process_counter_w = 4'd2;
					CEN_w = 1'b1;
				end
				4'd1: begin
					process_counter_w = 4'd0;
					CEN_w = 1'b0;
					WEN_w = 1'b0;
					OEN_w = 1'b1;
					A_w = $unsigned( $signed(register_r[_rs+1]) + _immediate) >> 2;
					Data2Mem_w = Freg_r[_ft+1];
					IR_addr_w = IR_addr_r + 32'd4;
					instruction_w = IR;
				end
			endcase
		end
		endcase
	end
	else begin
		IR_addr_w = IR_addr_r + 32'd4;
		instruction_w = IR;
	end
end

//==== sequential part ====================================
always@(posedge clk, negedge rst_n)begin
	if(!rst_n) begin
		// reset
		process_counter_r <= 4'd0;
		IR_addr_r <= 0;
		instruction_r <= 0;
		ReadDataMem_r <= 0;
		Data2Mem_r <= 0;
		A_r <= 0;
		CEN_r <= 0;
		WEN_r <= 1;
		OEN_r <= 1;
		rnd_r <= 3'd0;
		FPCond_r <= 0;

		for (i=0 ; i<32; i=i+1) begin
			register_r[i] <= 0;
		end
		//fpu
		for( i=0; i<32; i=i+1) begin
			Freg_r[i] <= 0;
		end
	end
	else begin
		// main
		for ( i=0 ; i<32; i=i+1) begin
			register_r[i] <= register_w[i];
		end
		$display("[%h] %h", IR_addr_w, IR);


		instruction_r <= instruction_w;
		IR_addr_r <= IR_addr_w;
		process_counter_r <= process_counter_w;
		Data2Mem_r <= Data2Mem_w;
		ReadDataMem_r <= ReadDataMem_w;
		A_r <= A_w;
		CEN_r <= CEN_w;
		WEN_r <= WEN_w;
		OEN_r <= OEN_w;

		// fpu
		rnd_r <= rnd_w;
		addout_r <= addout_w;
		subout_r <= subout_w;
		mulout_r <= mulout_w;
		divout_r <= divout_w;
		FPCond_r <= FPCond_w;
		daddout_r <= daddout_w;
		dsubout_r <= dsubout_w;
		read_data1_r <= read_data1_w;
		read_data2_r <= read_data2_w;
		write_data_r <= write_data_w;
		dread_data1_r <= dread_data1_w;
		dread_data2_r <= dread_data2_w;
		dwrite_data_r <= dwrite_data_w;

		for( i=0; i<32; i=i+1) begin
			Freg_r[i] <= Freg_w[i];
		end
	end
end
endmodule