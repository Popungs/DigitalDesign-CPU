/* MIPS CPU module implementation */

module cpu (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [31:0] gpio_in,		/* GPIO input */

/**** outputs ****************************************************************/

	output [31:0] gpio_out	/* GPIO output */

);

logic [31:0] instruction_memory [4095:0]; // declare instruction memory 
logic [11:0] PC_FETCH;
logic [31:0] instruction_EX;
logic [31:0] a_EX, b_EX;
logic [4:0] shamt_EX;
logic [4:0] writeaddr_WB, rd_prev;
logic [15:0] temp_load;
logic zero_EX, regwrite_WB, regwrite_EX, enhilo_EX, rdrt_EX, rdrt_WB, enhilo_WB, gpio_out_en;
logic [1:0] regsel_EX, regsel_WB, alusrc_EX, alusrc_WB;
logic [31:0] hi_EX, lo_EX, R_EX,gpio_WB, lo_WB, hi_WB, R_WB, regdata_in, rd2_out, b_input,  HR_WB;
logic [3:0] op_EX;



initial begin
/*
	clk = 1'b1; #5;
	clk = 1'b0; #5;
*/
	

	//$readmemh("rtypedump.dat",instruction_memory, 0, 1023); // R TYPE 
	
	//$readmemh("itypedump.dat",instruction_memory, 0, 1023);

	$readmemh("realgpio.dat", instruction_memory, 0, 1023);

end
logic [31:0] gpio_out_t; 
assign gpio_out = gpio_out_t;

always_ff @(posedge clk, posedge rst) begin
	if (rst) begin 
		PC_FETCH <= 12'b0;
		instruction_EX <= 32'b0;
		regwrite_WB <= 1'b0;
		gpio_out_t <= 32'b0;
        end else begin
		instruction_EX <= instruction_memory[PC_FETCH];
		PC_FETCH <= PC_FETCH + 12'b1;
		regwrite_WB <= regwrite_EX; // write enable signal 
		if (gpio_out_en == 1'b1) begin
			gpio_out_t <= rd2_out;
		end
		if (rdrt_EX == 1'b0) begin 
			writeaddr_WB <= instruction_EX[15:11]; // RD register to write address this is true for R type
		end else if (rdrt_EX == 1'b1) begin
			writeaddr_WB <= instruction_EX[20:16]; // used for I type
			
		end
		
		alusrc_WB <= alusrc_EX; // this should determine sign or zero extend in I types
		regsel_WB <= regsel_EX; //
		rdrt_WB <= rdrt_EX;
		enhilo_WB <= enhilo_EX;

		if (enhilo_EX == 1'b1) begin // high on enable hi during mult
			hi_WB <= hi_EX;	
			R_WB <= lo_EX;
		end else begin
			lo_WB <= lo_EX;
		end


		gpio_WB <= gpio_in;

        end    
end
assign b_EX = alusrc_EX == 2'b11 && rdrt_EX ? instruction_EX[15:0] :
	      alusrc_EX == 2'b10 && rdrt_EX ? {{16{instruction_EX[15]}},instruction_EX[15:0]} :
	      alusrc_EX == 2'b01 && rdrt_EX ? {16'b0,instruction_EX[15:0]} :
	      rd2_out; // else b_EX = rd2_out
assign regdata_in = regsel_WB == 2'b01 ? gpio_WB :
		    regsel_WB == 2'b10 ? R_WB :
		    regsel_WB == 2'b11 ? hi_WB : 
		    lo_WB; // else regdata_in = lo_WB
/*
always @(*) begin
	if (regsel_WB == 2'b00) begin // regsel 0 alu_lo output 
		regdata_in = lo_WB;
	end else if (regsel_WB == 2'b01) begin // gpio_in 
		regdata_in = gpio_WB;
	end else if (regsel_WB == 2'b10) begin // lo if mflo
		regdata_in = R_WB;
	end else if (regsel_WB == 2'b11) begin // hi if mfhi
		regdata_in = hi_WB;
	end

	// alusrc mux 
	if (rdrt_EX == 1'b1 && alusrc_EX == 2'b11) begin // lui 
		b_EX = instruction_EX[15:0];
	end else if (rdrt_EX == 1'b1 && alusrc_EX == 2'b10) begin // sign
		b_EX = {{16{instruction_EX[15]}},instruction_EX[15:0]};
	end else if (rdrt_EX == 1'b1 && alusrc_EX == 2'b01) begin // zero
		b_EX = {16'b0,instruction_EX[15:0]};
	end else begin
		b_EX = rd2_out;
	end


end
*/



regfile myregfile (.clk(clk),
		   .rst(rst),
                    .we(regwrite_WB), 
                    .readaddr1(instruction_EX[25:21]),
                    .readaddr2(instruction_EX[20:16]), 
                    .writeaddr(writeaddr_WB), 
                    .writedata(regdata_in), 
                    .readdata1(a_EX), 
                    .readdata2(rd2_out));

alu thisalu (.a(a_EX),
	     .b(b_EX),
	     .op(op_EX),
	     .shamt(shamt_EX), 
	     .hi(hi_EX), 
	     .lo(lo_EX), 
             .zero(zero_EX));


controlUnit control(.func_code(instruction_EX[5:0]), 
		     .ins_shamt(instruction_EX[10:6]), 
		     .ins_opcode(instruction_EX[31:26]), 
		     .imm(instruction_EX[15:0]), // this is unused in R 
		     .rdrt(rdrt_EX), 
		     .alusrc(alusrc_EX), // X
		     .regwrite(regwrite_EX), // X
		     .regsel(regsel_EX), // X
		     .op(op_EX), // X
                     .shamt(shamt_EX), // X
	             .enhilo(enhilo_EX), // X
                     .gpio_we(gpio_out_en)); // X


endmodule
