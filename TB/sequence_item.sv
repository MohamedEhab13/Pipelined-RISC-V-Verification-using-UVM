import risc_pkg::* ;

class seq_item extends uvm_sequence_item ; 
	 
     // Constructor
     function new (string name = "risc_seq_item") ;
         super.new(name) ;
     endfunction		 
	  
     // Inputs  
     rand logic        reset  ;
     rand bit   [31:0] InstrF ; 
	 
     // Outputs 
     logic [31:0] PCF        ;
     logic [31:0] WriteDataM ;
     logic [31:0] DataAdrM   ;
     logic [31:0] ReadDataM  ;
     logic        MemWriteM  ;
  
     // Auxiliary fields 
     rand instr_type inst_type ;
     bit  lwstall ;
     bit  beqflush ;
  
     // Functions Automation (copy, compare and print)
     `uvm_object_utils_begin(seq_item)
     `uvm_field_int (reset      , UVM_DEFAULT)
     `uvm_field_int (InstrF     , UVM_DEFAULT)
     `uvm_field_int (PCF        , UVM_DEFAULT)
     `uvm_field_int (WriteDataM , UVM_DEFAULT)
     `uvm_field_int (DataAdrM   , UVM_DEFAULT)
     `uvm_field_int (ReadDataM  , UVM_DEFAULT)
     `uvm_field_int (MemWriteM  , UVM_DEFAULT) 
     `uvm_field_int (lwstall    , UVM_DEFAULT)
     `uvm_field_int (beqflush   , UVM_DEFAULT)
     `uvm_field_enum(instr_type , inst_type , UVM_DEFAULT) 
     `uvm_object_utils_end
  
  
  // Basic Constraints 
  constraint opcode_range {InstrF[6:0] inside {lw, imm,
                                               auipc, sw, 
                                               arith, lui,
                                               brnch, jalr,
                                               jal}; } ;   // op_code in the range of the supported instructions only 

  //constraint opcode_dist {InstrF[6:0] dist{lw:=1, imm:=3, auipc:=1, sw:=1, arith:=2, lui:=1, brnch:=1, jalr:=1, jal:=1}; };
	 
  constraint funct_range { (InstrF[6:0] == lw) -> (InstrF[14:12] == 3'b010) ; // lw funct3 
                             
      ((InstrF[6:0] == imm) && (InstrF[14:12] == 3'b101)) -> (InstrF[31:25] inside {7'b0000000, 7'b0100000}) ; // srli and srai funct7  
                              
      ((InstrF[6:0] == imm) && (InstrF[14:12] == 3'b001)) -> (InstrF[31:25] == 7'b0000000) ;// slli funct7  
       
      (InstrF[6:0] == imm) -> (InstrF[14:12] != 3'b011) ; // sltiu is not supported 
       
      (InstrF[6:0] == sw) -> (InstrF[14:12] == 3'b010) ; // sw funct3
                             
      (InstrF[6:0] == arith) -> (InstrF[14:12] inside {add, sll, slt, Xor, srl, Or, And}); // funct3 in range of supported R-type instructions
                             
      ((InstrF[6:0] == arith) && (InstrF[14:12] == add)) -> (InstrF[31:25] inside {7'b0000000, 7'b0100000}); // add and sub funct7
                             
      ((InstrF[6:0] == arith) && (InstrF[14:12]==sll || InstrF[14:12]==slt || InstrF[14:12]==Xor || InstrF[14:12]==Or || InstrF[14:12]==And )) -> (InstrF[31:25] == 7'b0000000); 
                             
      ((InstrF[6:0] == arith) && (InstrF[14:12] == sra)) -> (InstrF[31:25] inside {7'b0100000, 7'b0000000}); // sra and srl funct7  
                             
      (InstrF[6:0] == brnch) -> (InstrF[14:12] inside {beq, bne, blt, bge}); // funct3 in range of supported branch instructions 
                             
      (InstrF[6:0] == jalr) -> (InstrF[14:12] == 3'b000); // jalr funct3
					
      ((InstrF[6:0] != sw) && (InstrF[6:0] != brnch)) -> (InstrF[11:7] != 0) ; // rd is not equal to 0                    
                             } ;
  
  constraint reset_dist {reset dist{1:=1 , 0:=100000}; };
  
 //========================= Item Functions ===========================\\
  
  // Reset Function 
      function void Reset();
        InstrF     = 32'b0;
        PCF        = 32'b0;
        DataAdrM   = 32'b0;
        MemWriteM  = 1'b0;
        WriteDataM = 32'b0;
        lwstall    = 1'b0;
        beqflush   = 1'b0;
        inst_type  = RESET;
      endfunction
  
  
 // Get Instruction type function  
      function Get_type ;
        case (InstrF[6:0])  
          
          lw    : inst_type = LW    ;
          sw    : inst_type = SW    ;
          lui   : inst_type = LUI   ;
          auipc : inst_type = AUIPC ;
          jalr  : inst_type = JALR  ;
          jal   : inst_type = JAL   ;
          
          imm : begin 
            case(InstrF[14:12])     
            3'b000 : inst_type = ADDI ;
            3'b001 : inst_type = SLLI ;
            3'b010 : inst_type = SLTI ;
            3'b100 : inst_type = XORI ;
            3'b110 : inst_type = ORI  ; 
            3'b111 : inst_type = ANDI ;    
            3'b101 : begin 
              if (InstrF[30] == 0) inst_type = SRLI ;
              else inst_type = SRAI ;
             end
            endcase 
          end
          
          arith : begin 
            case(InstrF[14:12])     
            3'b001 : inst_type = SLL ;
            3'b010 : inst_type = SLT ;
            3'b100 : inst_type = XOR ;
            3'b110 : inst_type = OR  ; 
            3'b111 : inst_type = AND ;   
            3'b000 : begin 
              if (InstrF[30] == 0) inst_type = ADD ;
                     else inst_type = SUB ;
                     end
            3'b101 : begin 
              if (InstrF[30] == 0) inst_type = SRL ;
                     else inst_type = SRA ;
                     end  
            endcase   
          end
            
          brnch : begin 
            case(InstrF[14:12])     
            3'b000 : inst_type = BEQ ;
            3'b001 : inst_type = BNE ;
            3'b100 : inst_type = BLT ;
            3'b101 : inst_type = BGE  ;     
            endcase 
          end 
        default : inst_type = UNKNOWN ; 
        endcase 

      endfunction
  
  
  // Extend Immediate function 
  function [31:0] Extend ;

      case(InstrF[6:0])
        // I−type
        imm, lw, jalr : Extend = {{20{InstrF[31]}}, InstrF[31:20]};
		
        // S−type (stores)
        sw : Extend = {{20{InstrF[31]}}, InstrF[31:25], InstrF[11:7]};
		
        // B−type (branches)
        brnch : Extend = {{20{InstrF[31]}}, InstrF[7], InstrF[30:25], InstrF[11:8], 1'b0};
		
        // J−type (jal)
        jal : Extend = {{12{InstrF[31]}}, InstrF[19:12], InstrF[20], InstrF[30:21], 1'b0};
		
        // U-type
        lui, auipc : Extend = {InstrF[31:12], 12'b0};
		
        default: Extend = 32'bx; // undefined
	endcase  
  endfunction : Extend
  
endclass 
