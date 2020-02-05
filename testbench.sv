module testbench;

logic clk, rst;
logic [31:0] gpio_in;
logic [17:0] SW;
cpu thiscpu (.clk(clk),
	     .rst(rst), 
	     .gpio_in({14'h0,SW}), 
	     .gpio_out());

initial begin
	//rst = 1'b0; #5;
	rst = 1'b1; #5;
	rst = 1'b0; #5;
end
always begin
	
	
	clk = 1'b1; #5;
	//gpio_in = 32'd09876543;
	//gpio_in = 32'd23456789;
	//gpio_in = 32'd59595959; 
	SW = 32'd1231;
	//gpio_in = 32'd00001234;
	clk = 1'b0; #5;
/*
	gpio_in = 32'd23456789; # 100;
	gpio_in = 32'd59595959; # 100;
	gpio_in = 32'd09876543; # 100;
	gpio_in = 32'd12312312; # 100;
*/	

end



endmodule 
