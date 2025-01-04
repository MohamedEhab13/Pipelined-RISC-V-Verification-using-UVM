`timescale 1ns/1ps

module riscv_pip_tb;

  // Clock and reset signals
  logic clk;
  logic reset;

  // DUT signals
  logic [31:0] PCF;
  logic [31:0] InstrF;
  logic MemWriteM;
  logic [31:0] DataAdrM, WriteDataM , ReadDataM ;

  // Instantiate the DUT
  risc_top DUT (
    .clk(clk),
    .reset(reset),
    .PCF(PCF),
    .InstrF(InstrF),
    .MemWriteM(MemWriteM),
    .DataAdrM(DataAdrM),
    .WriteDataM(WriteDataM),
    .ReadDataM(ReadDataM)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Testbench logic
  initial begin
    // Initialize signals
    clk = 0;
    reset = 1;
    InstrF = 0;
    

    // Reset the DUT
    #15 reset = 0;

    // Send ADDI instructions 
    InstrF = {12'b000000000001, // immediate = 21
                 5'b00000,    // rs1 = x1 (source register)
                 3'b000,      // funct3 for ADDI
                 5'b00010,    // rd = x3 (destination register)
                 7'b0010011}; // opcode for ADDI
    
    #10; // Wait for a clock cycle
    
    InstrF = {12'b000000000101, // immediate = 5
                 5'b00000,    // rs1 = x1 (source register)
                 3'b000,      // funct3 for ADDI
                 5'b00011,    // rd = x7 (destination register)
                 7'b0010011}; // opcode for ADDI
    
    #10; // Wait for a clock cycle
    
    InstrF = {12'b000000000110, // immediate = 6
                 5'b00000,    // rs1 = x3 (source register)
                 3'b000,      // funct3 for SLLI
                 5'b00100,    // rd = x2 (destination register)
                 7'b0010011}; // opcode 
    
    #10; // Wait for a clock cycle
    
    InstrF = {12'b000000000011, // immediate = 4
                 5'b00010,    // rs1 = x1 (source register)
                 3'b001,      // funct3 for ADDI
                 5'b00111,    // rd = x3 (destination register)
                 7'b0010011}; // opcode for ADDI
    
    #10; // Wait for a clock cycle
    
    // Send SW instruction
//        InstrF = {7'b0000000,    // imm[11:5] (upper 7 bits of immediate = 0)
//                  5'b00010,      // rs2 = x2 (source register containing data to store)
//                  5'b00011,      // rs1 = x3 (base register for memory address)
//                  3'b010,        // funct3 for SW
//                  5'b00000,      // imm[4:0] (lower 5 bits of immediate)
//                  7'b0100011};   // opcode for SW
                           
                
      #10; // Wait for a clock cycle
    
    // Send LW instruction
//        InstrF = {12'b000000000000, // immediate = 0
//                  5'b00011,         // rs1 = x3 (base register for memory address)
//                  3'b010,           // funct3 for LW
//                  5'b00100,         // rd = x4 (destination register to load data)
//                  7'b0000011};      // opcode for LW
    
    #10; // Wait for a clock cycle
    
    // Send ADDI instructions 
//        InstrF = {12'b00000000011, // immediate = 3
//                  5'b00100,    // rs1 = x1 (source register)
//                  3'b000,      // funct3 for ADDI
//                  5'b00110,    // rd = x6 (destination register)
//                  7'b0010011}; // opcode for ADDI

   
    
    #50 $stop;
  end
  
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
endmodule
