module controller(input logic clk, reset,
						input logic [6:0] op,
                        input logic [2:0] funct3D,
						input logic funct7b5,
						input logic ZeroE,
						input logic SignE,
						input logic FlushE,
						output logic ResultSrcE0,
						output logic [1:0] ResultSrcW,
						output logic MemWriteM,
						output logic PCJalSrcE, PCSrcE, ALUSrcAE, 
						output logic [1:0] ALUSrcBE,
						output logic RegWriteM, RegWriteW,
						output logic [2:0] ImmSrcD,
						output logic [3:0] ALUControlE);

logic [1:0] ALUOpD;
logic [1:0] ResultSrcD, ResultSrcE, ResultSrcM;
logic [3:0] ALUControlD;
logic BranchD, BranchE, MemWriteD, MemWriteE, JumpD, JumpE;
logic ZeroOp, ALUSrcAD, RegWriteD, RegWriteE;
logic [1:0] ALUSrcBD;
logic SignOp;
logic BranchOp;
logic [2:0]funct3E ;  

// main decoder
maindec md(op, ResultSrcD, MemWriteD, BranchD, ALUSrcAD, ALUSrcBD, RegWriteD, JumpD, ImmSrcD, ALUOpD);

// alu decoder
aludec ad(op[5], funct3D, funct7b5, ALUOpD, ALUControlD);


c_ID_IEx c_pipreg0(clk, reset, FlushE, RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcAD, ALUSrcBD, ResultSrcD, ALUControlD, funct3D, 
										 RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcAE, ALUSrcBE, ResultSrcE, ALUControlE, funct3E);
assign ResultSrcE0 = ResultSrcE[0];

c_IEx_IM c_pipreg1(clk, reset, RegWriteE, MemWriteE, ResultSrcE, RegWriteM,  MemWriteM, ResultSrcM);

c_IM_IW c_pipreg2 (clk, reset, RegWriteM, ResultSrcM, RegWriteW, ResultSrcW);


assign ZeroOp = ZeroE ^ funct3E[0]; // Complements Zero flag for BNE Instruction
assign SignOp = (SignE ^ funct3E[0]) ; //Complements Sign for BGE
assign BranchOp = funct3E[2] ? (SignOp) : (ZeroOp); 
assign PCSrcE = (BranchE & BranchOp) | JumpE;
assign PCJalSrcE = (op == 7'b1100111) ? 1 : 0; // jalr

//mux2 BranchSrc (ZeroOp, SignOp, funct3[2], BranchOp); // fix this later
  
endmodule
