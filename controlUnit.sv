module controlUnit (input [5:0] func_code, 
		    input [10:6] ins_shamt,
		    input [31:26] ins_opcode,
		    input [15:0] imm,
		     output [0:0] rdrt,
		     output [1:0] alusrc,
			output [0:0] regwrite,
			   output[1:0] regsel,
			    output[3:0] op,
			    output[4:0] shamt,
			    output[0:0] enhilo,
			    output[0:0] gpio_we);
logic [31:0] hi,lo,gpio_out;
logic [31:0] PC; // program counter

/*
	rdrt = 1'bX // 2 bits
	instruction [20:16] = 1
	instruction [15:11] = 0 
	
	So R type destination = instruction [15:11] 

	regsel = lo, gpio_in,mflo, mfhi 

	lo = regsel 2'b00
	gpio_in = regsel 2'b01
	mflo = 2'b10
	mfhi = 2'b11

	enhilo = 1 write hi, 0 write lo
	
	alusrc 

*/
logic [0:0] rdrt_e, regwrite_e, gpio_we_e;
logic [1:0] alusrc_e, regsel_e, enhilo_e;
logic [3:0] op_e;
logic [4:0] shamt_e;
assign rdrt = rdrt_e;
assign alusrc = alusrc_e;
assign regwrite = regwrite_e;
assign regsel = regsel_e;
assign op = op_e;
assign shamt = shamt_e;
assign enhilo = enhilo_e;
assign gpio_we = gpio_we_e;


always @(*) begin 
	if (ins_opcode == 6'b000000) begin // R type writes to instruction [15:11] 
		rdrt_e = 1'b0;
		gpio_we_e = 1'b0;
		alusrc_e = 2'b0; // dont do anything 
		if (func_code == 6'b100000 || func_code == 6'b100001) begin // add, addu
			op_e = 4'b0100;
			shamt_e = 5'bX;
			enhilo_e = 1'b0; // only lo
			regsel_e = 2'b00; // writting lo 
			regwrite_e = 1'b1; // write enable
		end else if (func_code == 6'b000000 && ins_shamt == 6'b000000) begin // NOP
			op_e = 4'b0000;
			shamt_e = 5'bX;
			enhilo_e = 1'bX;
			regsel_e = 2'b00;
			regwrite_e = 1'b0;
			
		end else if (func_code == 6'b100010 || func_code == 6'b100011) begin // sub, subu
			op_e = 4'b0101; // 5
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b011000) begin // mul, 
			op_e = 4'b0110; // 6 
			shamt_e = 5'bX;
			enhilo_e = 1'b1; // write to hi
			regsel_e = 2'b00;
			regwrite_e = 1'b0;
		end else if (func_code == 6'b011001) begin // mulu
			op_e = 4'b0111; // 7
			shamt_e = 5'bX;
			enhilo_e = 1'b1;
			regsel_e = 2'b00;
			regwrite_e = 1'b0;
		end else if (func_code == 6'b100100) begin // AND
			op_e = 4'b0000;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b100101) begin // OR
			op_e = 4'b0001;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b100110) begin // XOR
			op_e = 4'b0011; 
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b100111) begin // NOR 
			op_e = 4'b0010; //2 
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b000000 && ins_shamt != 6'b000000) begin // sll b << a
			op_e = 4'b1000;
			shamt_e = ins_shamt; // [10:6] of instruction bit
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b000010 && ins_shamt == 6'b000000) begin // srl with 0 shamt
			op_e = 4'b1001;
			shamt_e = ins_shamt;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
			gpio_we_e = 1'b1; // only on srl with shamt = 0
		end else if (func_code == 6'b000010 && ins_shamt != 5'b0) begin // srl b >> a 
			op_e = 4'b1001;
			shamt_e = ins_shamt;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
    end else if (func_code == 6'b000010 && ins_shamt == 5'b0) begin // srl by 0 =  gpio out
      			gpio_we_e = 1'b1;
		end else if (func_code == 6'b000011 && ins_shamt == 5'b0) begin // sra (GPIO input) 
			op_e = 4'bX; 
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b01;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b000011 && ins_shamt != 5'b0) begin // sra b >>> a arithmetic shift
			op_e = 4'b1010; 
			shamt_e = ins_shamt;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b101010) begin // slt a < b (signed)
			op_e = 4'b1100;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b101011) begin // sltu a < b (unsigned) (errors?)
			op_e = 4'b1101;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
		end else if (func_code == 6'b010000) begin // mfhi copies hi register to register rd
			// ???
			op_e = 4'bX;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b11; // hi     
			regwrite_e = 1'b1;
		end else if (func_code == 6'b010010) begin // mflo copies lo register to register rd
			// ???
			op_e = 4'bX;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b10;
			regwrite_e = 1'b1;
		end
	end 

	else begin // I type
		// alusrc_e = 2'b01 zero extended 
		// alusrc_e = 2'b10 sign extended 
		// alusrc_e = 2'b11 reserved for lui
		rdrt_e = 1'b1; // writes to instruction[20:16]
		if (ins_opcode == 6'b001111) begin // lui rt,imm rt <- imm this is an exception 
			op_e = 4'b1000;
			shamt_e = 5'd16;
			enhilo_e = 1'b0;
			regsel_e = 2'b0;
			regwrite_e = 1'b1;
			alusrc_e = 2'b11;
		end else if (ins_opcode == 6'b001000 || ins_opcode == 6'b001001) begin // addi, addiu
			op_e = 4'b0100;
			shamt_e = 5'bX;
			enhilo_e = 1'b0; // only lo
			regsel_e = 2'b00; // writting lo 
			regwrite_e = 1'b1; // write enable
			alusrc_e = 2'b10;
		end else if (ins_opcode == 6'b001100) begin // andi
			op_e = 4'b0000;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
			alusrc_e = 2'b01;
		end else if (ins_opcode == 6'b001101) begin // ori
			op_e = 4'b0001;
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
			alusrc_e = 2'b01;
		end else if (ins_opcode == 6'b001110) begin // xori
			op_e = 4'b0011; 
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
			alusrc_e = 2'b01;
		end else if (ins_opcode == 6'b001010) begin // slti
			op_e = 4'b1100; 
			shamt_e = 5'bX;
			enhilo_e = 1'b0;
			regsel_e = 2'b00;
			regwrite_e = 1'b1;
			alusrc_e = 2'b10;
		end 
	end

end













endmodule
