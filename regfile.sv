/* 32 x 32 register file implementation */

module regfile (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [0:0 ] we,		/* write enable */
	input [4:0 ] readaddr1,		/* read address 1 */
	input [4:0 ] readaddr2,		/* read address 2 */
	input [4:0 ] writeaddr,		/* write address */
	input [31:0] writedata,		/* write data */

/**** outputs ****************************************************************/

	output [31:0] readdata1,	/* read data 1 */
	output [31:0] readdata2		/* read data 2 */
);


reg [31:0] mem [31:0]; 
/*
initial begin
	mem[readaddr1] = 5'b0;
	mem[readaddr2] = 5'b1;
end
*/
/*
always @(posedge rst) begin
	mem[0] <= 5'b0;
	mem[writeaddr] <= 5'b0;

	mem[5'd1] <= 5'd11;
	mem[5'd2] <= 5'd17;


		

end
*/

always_ff @(posedge clk, posedge rst) begin
	if (rst) begin
		mem[0] <= 5'b0;
		mem[writeaddr] <= 5'b0;

		mem[5'd1] <= 5'd11;
		mem[5'd2] <= 5'd17;
/*
		readaddr1 = 5'b0;
		readaddr2 = 5'b1;
*/
/*
		mem[readaddr1] <= 5'b0;
		mem[readaddr2] <= 5'b1;
*/

	end else if (we && writeaddr == readaddr1) begin
		mem[writeaddr] = writedata;
		mem[readaddr1] = writedata;
	end else if (we && writeaddr == readaddr2) begin
		mem[writeaddr] = writedata;
		mem[readaddr2] = writedata;
	end else if (we) begin
		mem[writeaddr] <= writedata;
	end else if (we && writeaddr == 0) begin
		//readdata1 <= 32'b0;
		mem[writeaddr] <= 32'b0;
	end

end
/*
assign readdata1 = mem[readaddr1];
assign readdata2 = mem[readaddr2]; 
*/


assign	readdata1 = readaddr1 == writeaddr && we ? writedata : mem[readaddr1];

assign	readdata2 = readaddr2 == writeaddr && we ? writedata : mem[readaddr2];


endmodule
