package risc_pkg;

  import uvm_pkg::*;

     localparam [6:0] lw    = 7'b0000011 ,
	                  imm   = 7'b0010011 ,
					  auipc = 7'b0010111 ,
					  sw    = 7'b0100011 ,
					  arith = 7'b0110011 ,
					  lui   = 7'b0110111 ,
					  brnch = 7'b1100011 ,
					  jalr  = 7'b1100111 , 
					  jal   = 7'b1101111 ;
 
					  
	 localparam [2:0] add = 3'b000 ,
	                  sub = 3'b000 ,
                      sll = 3'b001 ,
                      slt = 3'b010 ,
                      Xor = 3'b100 , 
                      srl = 3'b101 , 
					  sra = 3'b101 ,
                      Or  = 3'b110 ,
                      And = 3'b111 ;


     localparam [2:0] beq = 3'b000 , 
                      bne = 3'b001 ,
                      blt = 3'b100 ,
                      bge = 3'b101 ;


     typedef enum logic [5:0] {LW,SW,
                               ADDI,SLLI,SLTI,XORI,SRLI,SRAI,ORI,ANDI,
                               AUIPC,LUI,
                               ADD,SUB,SLL,SLT,XOR,SRL,SRA,OR,AND,
                               BEQ,BNE,BLT,BGE,
                               JALR,JAL,
                               RESET} instr_type;


function instr_type inst_type(bit [31:0] inst);
        case (inst[6:0])  
          
          lw   : inst_type = LW   ;
          sw   : inst_type = SW   ;
          lui  : inst_type = LUI  ;
          jalr : inst_type = JALR ;
          jal  : inst_type = JAL  ;
          
          imm : begin 
            case(inst[14:12])     
            3'b000 : inst_type  = ADDI ;
            3'b001 : inst_type = SLLI ;
            3'b010 : inst_type = SLTI ;
            3'b100 : inst_type = XORI ;
            3'b110 : inst_type = ORI  ; 
            3'b111 : inst_type = ANDI ;    
            3'b101 : begin 
                     if (inst[30] == 0) inst_type = SRAI ;
                     else inst_type = SRLI ;
                     end
            endcase 
          end
          
          arith : begin 
            case(inst[14:12])     
            3'b001 : inst_type = SLL ;
            3'b010 : inst_type = SLT ;
            3'b100 : inst_type = XOR ;
            3'b110 : inst_type = OR  ; 
            3'b111 : inst_type = AND ;   
            3'b000 : begin 
                     if (inst[30] == 0) inst_type = ADD ;
                     else inst_type = SUB ;
                     end
            3'b101 : begin 
              if (inst[30] == 0) inst_type = SRL ;
                     else inst_type = SRA ;
                     end  
            endcase   
          end
            
          brnch : begin 
            case(inst[14:12])     
            3'b000 : inst_type = BEQ ;
            3'b001 : inst_type = BNE ;
            3'b100 : inst_type = BLT ;
            3'b101 : inst_type = BGE  ;     
            endcase 
          end 
        endcase 
      endfunction 

              
              

`include "uvm_macros.svh"
`include "sequence_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "ral.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "coverage.sv"
`include "agent.sv"
`include "env.sv"
`include "test.sv"

endpackage 