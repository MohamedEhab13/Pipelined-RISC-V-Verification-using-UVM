import risc_pkg::* ;

class seq_item extends uvm_sequence_item ; 
	 
	 // Constructor
     function new (string name = "risc_seq_item") ;
         super.new(name) ;
     endfunction	
	 
	  
	 // Inputs  
	 rand logic        reset  ;
	 rand logic [31:0] InstrF ; 
	 
	 // Outputs 
	 logic [31:0] PCF        ;
	 logic [31:0] WriteDataM ;
	 logic [31:0] DataAdrM   ;
     logic [31:0] ReadDataM  ;
	 logic        MemWriteM  ;
  
     // Auxiliary fields 
     rand instr_type inst_type ;
  
     // Functions Automation (copy, compare and print)
     `uvm_object_utils_begin(seq_item)
     `uvm_field_int(reset      , UVM_DEFAULT)
     `uvm_field_int(InstrF     , UVM_DEFAULT)
     `uvm_field_int(PCF        , UVM_DEFAULT)
     `uvm_field_int(WriteDataM , UVM_DEFAULT)
     `uvm_field_int(DataAdrM   , UVM_DEFAULT)
     `uvm_field_int(ReadDataM  , UVM_DEFAULT)
     `uvm_field_int(MemWriteM  , UVM_DEFAULT) 
     `uvm_field_enum(instr_type , inst_type , UVM_DEFAULT) 
     `uvm_object_utils_end
  
  
      // Basic Constraints 
      constraint opcode_range {InstrF[6:0] inside {lw, imm, auipc, sw, arith, lui, brnch, jalr, jal}; } ;
	 
	  constraint funct_range { (InstrF[6:0] == lw) -> ((InstrF[14:12] == 3'b010) && (InstrF[31] == 1'b0)); // lw 
                             
      ((InstrF[6:0] == imm) && (InstrF[14:12] == 3'b101)) -> (InstrF[31:25] inside {7'b0000000, 7'b0100000}) ; // I-type srli and srai
                              
      ((InstrF[6:0] == imm) && (InstrF[14:12] == 3'b001)) -> (InstrF[31:25] == 7'b0000000) ;// I-type slli 
       
      (InstrF[6:0] == imm) -> (InstrF[14:12] != 3'b011) ; // sltiu not included 
       
      (InstrF[6:0] == sw) -> (InstrF[14:12] != 3'b010) ; // sw
                             
      (InstrF[6:0] == arith) -> (InstrF[14:12] inside {add, sll, slt, Xor, srl, Or, And}); // R-type constraint
                             
	  ((InstrF[6:0] == arith) && (InstrF[14:12] == add)) -> (InstrF[31:25] inside {7'b0000000, 7'b0100000}); // R-type constraint
                             
	  ((InstrF[6:0] == arith) && (InstrF[14:12]==sll || InstrF[14:12]==slt || InstrF[14:12]==Xor || InstrF[14:12]==srl || InstrF[14:12]==Or ||                                 InstrF[14:12]==And )) -> (InstrF[31:25] == 7'b0000000); // R-type constraint
                             
	  ((InstrF[6:0] == arith) && (InstrF[14:12] == sra)) -> (InstrF[31:25] == 7'b0100000); // R-type constraint 
                             
	  (InstrF[6:0] == brnch) -> (InstrF[14:12] inside {beq, bne, blt, bge}); // Branch constraint
                             
	  (InstrF[6:0] == jalr) -> (InstrF[14:12] == 3'b000); // jalr constraint
							} ;
  
      constraint reset_dist {reset dist{1:=1 , 0:=100}; };
  

      function void Reset();
        PCF        = 32'b0;
        DataAdrM   = 32'b0;
        MemWriteM  = 1'b0;
        WriteDataM = 32'b0;
      endfunction
	 
  
endclass 