module regfile(input logic clk,
					input logic we3,
					input logic [4:0] a1, a2, a3,
					input logic [31:0] wd3,
					output logic [31:0] rd1, rd2);
					
  logic [31:0] register [31:0]; 	// register file
	

	
	// write on falling edge
	// read on rising edge 
	
	// r0 hardwired to 0
	
	
  assign rd1 = (a1 != 0 ) ? register[a1] : 0;
  assign rd2 = (a2 != 0 ) ? register[a2] : 0;
	
	
	always_ff @(negedge clk)
      if (we3) register[a3] <= wd3;

endmodule
