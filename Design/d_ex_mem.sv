module IEx_IMem(input logic clk, reset,
                input logic PCJalSrcE,
                input logic [31:0] ALUResultE, WriteDataE, 
                input logic [4:0] RdE, 
                input logic [31:0] PCPlus4E,
                output logic [31:0] ALUResultM, WriteDataM,
                output logic [4:0] RdM, 
                output logic [31:0] PCPlus4M,
                output logic        PCJalSrcM);

always_ff @( posedge clk, posedge reset ) begin 
    if (reset) begin
        ALUResultM <= 0;
        WriteDataM <= 0;
        RdM <= 0; 
        PCPlus4M <= 0;
        PCJalSrcM <= 0 ;
    end

    else begin
        ALUResultM <= ALUResultE;
        WriteDataM <= WriteDataE;
        RdM <= RdE; 
        PCPlus4M <= PCPlus4E; 
        PCJalSrcM <= PCJalSrcE;
    end
    
end

endmodule

