class coverage extends uvm_subscriber #(seq_item) ;
  `uvm_component_utils(coverage)
  
  uvm_analysis_imp #(seq_item, coverage) cov_mon_port; // Connect Monitor to scoreboard

  // Signals Declaration
   instr_type instruction ;
   logic [31:0] PC, DataAdr, WriteData, ReadData ;
   logic [4:0] rs1, rs2, rd ;
   logic       MemWrite ;
   logic       reset ;
  
  
  // Handles declaration 
  seq_item cov_item ; // Copy the recieved item from monitor here to avoid override elsewhere 
  
  
  
  // Covergroups 
  covergroup Instruction_cg ; // To Cover All Instructions and crosses among them
  Instructions_cp :       coverpoint instruction { 
                          bins I_Type[] = {LW, ADDI, SLLI, SLTI, XORI, SRLI, SRAI, ORI, ANDI, JALR} ;
                          bins R_Type[] = {ADD, SUB, SLL, SLT, XOR, SRL, SRA, OR, AND} ;
                          bins B_Type[] = {BEQ, BNE, BLT, BGE} ;
                          bins U_Type[] = {LUI, AUIPC} ;
                          bins S_Type[] = {SW} ;
                          bins J_Type[] = {JAL} ;
                          bins  Reset[] = {RESET} ;
                          illegal_bins unknow = {UNKNOWN} ; 
                          } 
 
  Imm_Transitions_cp :    coverpoint instruction {
                          bins I_R[]     = (SLTI, SRLI => SLL, SLT) ;
                          bins I_B[]     = (SLTI => BEQ, BNE, BLT, BGE) ;
                          bins I_SW[]    = (SLTI => SW) ;
                          bins I_SW_SW[] = (SLTI => SW[*2]) ;
                          bins I_LW[]    = (SLTI => LW) ;
                          bins I_LW_LW[] = (SLTI => LW[*2]) ;
                          bins I_J[]     = (ADDI, SLTI => JAL,JALR) ;
                          bins I_J_J[]   = (ADDI, SLTI => JAL[*2]) ;
                          bins I_JR_JR[] = (ADDI, SLTI => JALR[*2]) ;
                          }

  Branch_Transitions_cp : coverpoint instruction {                      
                          bins B_R[]     = (BEQ, BNE, BLT, BGE => ADD, SLT, SRA) ;
                          bins B_B[]     = (BEQ, BNE, BLT, BGE => BEQ, BNE, BLT, BGE) ;
                          bins B_J[]     = (BEQ, BNE, BLT, BGE => JAL,JALR) ;
                          bins B_J_J[]   = (BEQ, BNE, BLT, BGE => JAL) ;
                          bins B_JR_JR[] = (BEQ, BNE, BLT, BGE => JALR[*2]) ;
                          bins B_SW[]    = (BEQ, BNE, BLT, BGE => SW) ;
                          bins B_SW_SW[] = (BEQ, BNE, BLT, BGE => SW[*2]) ;
                          bins B_LW[]    = (BEQ, BNE, BLT, BGE => LW) ;
                          bins B_LW_LW[] = (BEQ, BNE, BLT, BGE => LW[*2]) ;                         
                          }

  Jump_Transitions_cp :   coverpoint instruction {                     
                          bins J_R[]     = (JAL, JALR => SUB, SLT, SRA) ;
                          bins J_J[]     = (JAL, JALR => JAL,JALR) ;
                          bins J_B[]     = (JAL, JALR => BEQ, BNE, BLT, BGE) ;
                          bins J_B_B[]   =  (JAL, JALR => BEQ,BLT[*2]) ;
                          bins J_SW[]    = (JAL, JALR => SW) ;
                          bins J_SW_SW[] = (JAL, JALR => SW[*2]) ;
                          bins J_LW[]    = (JAL, JALR => LW) ;
                          bins J_LW_LW[] = (JAL  => LW[*2]) ;
                          }

  SW_Transitions_cp :    coverpoint instruction {
                         bins SW_B[]   = (SW => BEQ, BNE, BLT, BGE) ;
                         bins SW_J[]   = (SW => JAL, JALR) ;                      
                         bins SW_SW[] = (SW => SW) ;                        
                         bins SW_LW[] = (SW => LW) ;
                         bins SW_I[]  = (SW => SLTI) ;
                         }

  LW_Transitions_cp :    coverpoint instruction {
                         bins LW_B[]  = (LW => BEQ, BNE, BLT, BGE) ;
                         bins LW_J[]  = (LW => JAL, JALR) ;
                         bins LW_LW[] = (LW => LW) ;
                         bins LW_SW[] = (LW => SW) ;
                         }

  endgroup : Instruction_cg 


  
  covergroup Reset_cg ;
    Reset_Transition_cp : coverpoint reset { 
                          bins OFF_ON = (0 => 1) ;
                          bins ON_OFF = (1 => 0) ; 
                          }
  endgroup : Reset_cg

  covergroup Registers_cg ;
    Rs1_cp : coverpoint rs1 {bins Rs1[] = {[0:31]};}
    Rs2_cp : coverpoint rs2 {bins Rs2[] = {[0:31]};}
    Rd_cp  : coverpoint rd  {bins Rd[]  = {[1:31]};} 
  endgroup : Registers_cg

  covergroup Memory_cg ;
    DataAdr_cp        : coverpoint DataAdr[9:2] {bins DataAddress[] = {[8'h00 : 8'hff]};}

    MemWrite_cp       : coverpoint MemWrite {
                        bins write = {1};
                        bins read  = {0};
                        } 
  
    Memory_Address_cp : cross MemWrite_cp, DataAdr_cp {
                        bins write_addresses = binsof(MemWrite_cp.write) && binsof(DataAdr_cp);
                        }
 
  endgroup : Memory_cg
  
  // Constructor 
  function new(string name = "coverage_collector" ,uvm_component parent);
     super.new(name,parent);
     cov_mon_port = new ("cov_mon_port" ,this); 
     Instruction_cg = new() ;
     Reset_cg  = new() ;
     Registers_cg = new() ;
     Memory_cg = new() ;
  endfunction : new
  
  
  
 // Build Phase 
  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
  endfunction
  
  
  
  function void write (seq_item  t);
     cov_item = seq_item::type_id::create("sb_item"); 
     cov_item.copy(t) ;   // To prevent unwanted change
     Inst_decode(cov_item) ;
    
       
    // Sampling covergroups 
    Instruction_cg.sample() ; 
    Reset_cg.sample() ;
    Registers_cg.sample() ;
    Memory_cg.sample() ;
    
  endfunction : write 

  function void Inst_decode (seq_item cov_item);

    instruction = cov_item.inst_type;
    reset       = cov_item.reset;
    PC          = cov_item.PCF;
    WriteData   = cov_item.WriteDataM;
    DataAdr     = cov_item.DataAdrM;
    ReadData    = cov_item.ReadDataM;
    MemWrite    = cov_item.MemWriteM;

    case (cov_item.InstrF[6:0])
     arith : 
              begin
                rd  = cov_item.InstrF[11:7];
                rs1 = cov_item.InstrF[19:15];
                rs2 = cov_item.InstrF[24:20];
              end

    imm,lw : 
              begin 
                rd    = cov_item.InstrF[11:7];
                rs1   = cov_item.InstrF[19:15];
              end

    sw,brnch : 
             begin
               rs1   = cov_item.InstrF[19:15];
               rs2   = cov_item.InstrF[24:20];
             end

    jal,jalr,lui,auipc:
            begin
              rd    = cov_item.InstrF[11:7];
            end
    endcase
  endfunction
  
  
endclass : coverage
