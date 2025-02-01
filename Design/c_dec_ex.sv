module c_ID_IEx (input logic clk, reset, clear,
        input logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcAD,
		input logic [1:0] ALUSrcBD,
        input logic [1:0] ResultSrcD, 
        input logic [3:0] ALUControlD, 
        input logic [2:0] funct3D,          
        output logic RegWriteE, MemWriteE, JumpE, BranchE,  ALUSrcAE,
		output logic [1:0] ALUSrcBE,
        output logic [1:0] ResultSrcE,
        output logic [3:0] ALUControlE, 
        output logic [2:0] funct3E);

always_ff @( posedge clk, posedge reset ) begin

		if (reset) begin
            funct3E <= 0;
			RegWriteE <= 0;
			MemWriteE <= 0;
			JumpE <= 0;
			BranchE <= 0; 
			ALUSrcAE <= 0;
			ALUSrcBE <= 0;
			ResultSrcE <= 0;
			ALUControlE <= 0;          
		end

		else if (clear) begin
            funct3E <= 0;
			RegWriteE <= 0;
			MemWriteE <= 0;
			JumpE <= 0;
			BranchE <= 0; 
			ALUSrcAE <= 0;
			ALUSrcBE <= 0;
			ResultSrcE <= 0;
			ALUControlE <= 0;    			
		end
		
		else begin
            funct3E <= funct3D;
			RegWriteE <= RegWriteD;
			MemWriteE <= MemWriteD;
			JumpE <= JumpD;
			BranchE <= BranchD; 
			ALUSrcAE <= ALUSrcAD;
			ALUSrcBE <= ALUSrcBD;
			ResultSrcE <= ResultSrcD;
			ALUControlE <= ALUControlD;   
		end
		 
	 end
  
endmodule


    
