module dmem(input logic clk, we, 
		input logic [31:0] a, wd, 
		output logic [31:0] rd);
		
  logic [31:0] RAM[255:0]; // 64 x 32 bit memory
  assign rd = RAM[a[9:2]];     // read operation
	
	// 6 bit address enough to address the 64 locations in data memory
	
	always_ff @(posedge clk)
      if (we) RAM[a[9:2]] <= wd;
endmodule