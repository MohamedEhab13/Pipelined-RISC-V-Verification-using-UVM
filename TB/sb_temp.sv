`include "ref_model.sv"
class scoreboard extends uvm_scoreboard  ;
  `uvm_component_utils(scoreboard);


  uvm_analysis_imp #(seq_item, scoreboard) monitor_export ; // Connect monitor to scoreboard
  
  seq_item sb_item ;
  ral_model ral_model_h ;
  uvm_status_e   status ;
  logic [31:0] temp ;
  
  
  // Signal Declaration 
  logic [31:0] instr_fetch , instr_dec , instr_ex , instr_mem , instr_wr ; // For Instruction pipelining 
  logic [31:0] pc_fetch , pc_dec , pc_ex , pc_mem , pc_wr ; // For pc pipelining
  logic [31:0] pc_p ;                                             
  logic [31:0] DataAdr_p , WriteData_p , ReadData_p ;                      
  logic [31:0] mem_forward , wr_forward ; // store the memory and write back stages for  forwarding
  logic        MemWrite_p ;
  bit   [1:0]  forward_A , forward_B ; // For Read after write Hazard
  bit          lwstall , beqflush ;    // For lw data and control hazard 
   
  
  // Constructor
  function new (string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    monitor_export = new ("monitor_export" ,this);
  endfunction : new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase) ;    
    if (!uvm_config_db #(ral_model)::get(null, "", "ral_model_h", ral_model_h ))
      `uvm_error(get_type_name(), "RAL model not found" );
  endfunction : build_phase

  // Write Function 
  function void write(seq_item t) ;
    
    sb_item = seq_item::type_id::create("sb_item"); 
    sb_item.copy(t) ;       // To prevent unwanted change  
    
    
    
    if (sb_item.reset) begin 
      {instr_fetch , instr_dec , instr_ex , instr_mem , instr_wr} = 0 ;
      {pc_fetch , pc_dec , pc_ex , pc_mem , pc_wr} = 0 ;
      pc_p        = 0 ;
      DataAdr_p   = 0 ;
      WriteData_p = 0 ;
      MemWrite_p  = 0 ;
    end
    else begin
      // Instruction pipelining
      instr_wr    = instr_mem ; 
      instr_mem   = instr_ex ; 
      instr_ex    = instr_dec ; 
      instr_dec   = instr_fetch ; 
      instr_fetch = sb_item.InstrF ;
     
      // Program counter pipelining 
      pc_wr    = pc_mem ; 
      pc_mem   = pc_ex ; 
      pc_ex    = pc_dec ; 
      pc_dec   = pc_fetch ; 
      pc_fetch = sb_item.PCF ;
            
      // Forward Hazard 
      if ((instr_ex[19:15] == instr_mem[11:7]) && (instr_ex[19:15] != 0) && (instr_mem[6:0] != brnch) && (instr_mem[6:0] != sw)) 
        forward_A = 2'b01 ;  // Get Source A from memory stage 
      else if ((instr_ex[19:15] == instr_wr[11:7]) && (instr_ex[19:15] != 0) && (instr_mem[6:0] != brnch) && (instr_mem[6:0] != sw))
        forward_A = 2'b10 ;  // Get Source A from write back stage 
      else 
        forward_A = 2'b00 ;  
      
      if ((instr_ex[24:20] == instr_mem[11:7]) && (instr_ex[19:15] != 0) && (instr_mem[6:0] != brnch) && (instr_mem[6:0] != sw)) 
        forward_B = 2'b01 ;   // Get Source B from memory stage
      else if ((instr_ex[24:20] == instr_wr[11:7]) && (instr_ex[19:15] != 0) && (instr_mem[6:0] != brnch) && (instr_mem[6:0] != sw))
        forward_B = 2'b10 ;   // Get Source B from write back stage 
      else 
        forward_B = 2'b00 ;
      
      // LW stall Hazard 
      lwstall = (instr_ex[6:0] == lw) && ((instr_ex[11:7] == instr_dec[19:15]) || (instr_ex[11:7] == instr_dec[24:20])) ;
      
      // PC control hazard 
      
       fork 
         predict(ral_model_h,instr_mem, instr_ex, pc_ex, forward_A, forward_B, lwstall, mem_forward, wr_forward, pc_p, WriteData_p, DataAdr_p, ReadData_p, MemWrite_p);
          join_none
       
      mem_forward = DataAdr_p ;
      wr_forward  = mem_forward ;
      
     // compare(pc_p, WriteData_p, DataAdr_p, ReadData_p, MemWrite_p, sb_item) ;
    end 
    
    // Debug display 
    $display("==============================================") ;
    $display("Fetch stage instruction : %h", instr_fetch) ;
    $display("Decode stage instruction : %h", instr_dec) ;
    $display("Excute stage instruction : %h", instr_ex) ;
    $display("Memory stage instruction : %h", instr_mem) ;
    $display("Writeback stage instruction : %h", instr_wr) ;
    $display("WriteDataM: " , sb_item.WriteDataM) ;
    $display("DataAdrM: "   , sb_item.DataAdrM) ;
    $display("MemWriteM: "  , sb_item.MemWriteM) ;
    $display("ReadDataM: " , sb_item.ReadDataM) ;
    $display("PCF: " , sb_item.PCF) ;
    $display("==============================================") ;
    
  endfunction: write 
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase); 
    ral_model_h.regs[instr_mem[19:!5]].read(status, temp, UVM_BACKDOOR) ;
  endtask
  
  
  
  virtual function void compare (input logic [31:0] pc_p , WriteData_p , DataAdr_p , ReadData_p,
                                 input logic MemWrite_p , 
                                 input seq_item actual
                                 );		
		bit pass ; 
		
    pass = (actual.DataAdrM   == DataAdr_p)   &&
           (actual.MemWriteM  == MemWrite_p)  && 
           (actual.PCF        == pc_p) ;
    if (pass)
      $display("SUCCESFUL OPERATTION!") ;
    else 
      $display("FAILED!") ;
     
      $display("         |   Data to mem     |      Address      |      Write Enable     |    Data from mem     |      Program Counter |") ;
    $display("===========|===================|===================|=======================|=============|======================|");
    $display("Actual     |        %d         |         %d        |           %d          |           %d         |"  , actual.WriteDataM , actual.DataAdrM , actual.MemWriteM , actual.ReadDataM , actual.PCF) ; 	
    $display("Predicted  |        %d         |         %d        |           %d          |           %d         |"  , WriteData_p , DataAdr_p , MemWrite_p , ReadData_p , pc_p) ;
		$display("===========|===================|===================|=======================|======================|");  
      
    
  endfunction // compare 
  
endclass: scoreboard
    
    
    
    
    
    