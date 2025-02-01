module risc_top (input  logic 	    clk, reset, 
            input  logic [31:0]     InstrF , 
            output logic [31:0]     PCF ,	        		
            output logic [31:0]     WriteDataM, DataAdrM, ReadDataM,
	    output logic 	    MemWriteM);
            
	
// instantiate processor and memories

	riscv_pip rv( clk, reset, PCF, InstrF, MemWriteM, DataAdrM, WriteDataM, ReadDataM);
	dmem dmem(clk, MemWriteM, DataAdrM, WriteDataM, ReadDataM);
endmodule
