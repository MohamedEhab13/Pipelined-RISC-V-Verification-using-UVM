class scoreboard extends uvm_scoreboard ;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(seq_item, scoreboard) sb_mon_port; // Connect Monitor to scoreboard
  
  // Handle Declaration 
  seq_item sb_item ; // Copy the recieved item from monitor here to avoid override elsewhere 
  seq_item p_item ; // Predicted sequence item 
  seq_item temp_item ;
  ral_model ral_model_h ; // ral handle 
  uvm_status_e   status ; // needed in ral read task 
  
  // Signal Declaration 
  bit [31:0] inst_fetch , inst_dec , inst_ex , inst_mem , inst_wr ; // For Instruction pipelining 
  logic [31:0] pc_fetch , pc_dec , pc_ex , pc_mem , pc_wr ; // For program counter pipelining
  logic [31:0] mem_forward , wr_forward ; // store the memory and write back stages for later forwarding
  bit   [1:0]  forward_A , forward_B ; // For Read after write Hazard
  bit          lwstall ; // For Load word hazard 
  bit          beqflush ;  // For branch control hazard 
  
  // Constructor
  function new (string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    sb_mon_port = new ("sb_mon_port" ,this);
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
    p_item = seq_item::type_id::create("p_item");
    sb_item.copy(t) ;       // To prevent unwanted change  
    
    
    if (sb_item.reset) begin 
      {inst_fetch , inst_dec , inst_ex , inst_mem , inst_wr} = 0 ;
      {pc_fetch , pc_dec , pc_ex , pc_mem , pc_wr} = 0 ;
      p_item.Reset() ;
      compare(sb_item,p_item) ;
    end
    else begin
      // Instruction pipelining
      inst_wr    = inst_mem ; 
      inst_mem   = inst_ex ; 
      inst_ex    = inst_dec ; 
      inst_dec   = inst_fetch ; 
      inst_fetch = sb_item.InstrF ;
     
      // Program counter pipelining 
      pc_wr    = pc_mem ; 
      pc_mem   = pc_ex ; 
      pc_ex    = pc_dec ; 
      pc_dec   = pc_fetch ; 
      pc_fetch = sb_item.PCF ;
            
      // Forward Hazard 
      if ((inst_ex[19:15] == inst_mem[11:7]) && (inst_ex[19:15] != 0) && (inst_mem[6:0] != brnch) && (inst_mem[6:0] != sw)) 
      forward_A = 2'b10 ;  // Get Source A from memory stage 
      else if ((inst_ex[19:15] == inst_wr[11:7]) && (inst_ex[19:15] != 0) && (inst_wr[6:0] != brnch) && (inst_wr[6:0] != sw))
      forward_A = 2'b01 ;  // Get Source A from write back stage 
      else 
      forward_A = 2'b00 ;  
      
      if ((inst_ex[24:20] == inst_mem[11:7]) && (inst_ex[24:20] != 0) && (inst_mem[6:0] != brnch) && (inst_mem[6:0] != sw)) 
      forward_B = 2'b10 ;   // Get Source B from memory stage
      else if ((inst_ex[24:20] == inst_wr[11:7]) && (inst_ex[24:20] != 0) && (inst_wr[6:0] != brnch) && (inst_wr[6:0] != sw))
      forward_B = 2'b01 ;   // Get Source B from write back stage 
      else 
      forward_B = 2'b00 ;
      
       //_____\\
      // debug \\
     //_________\\
      `uvm_info(get_type_name(), $sformatf("Forward_A = %h   ,   Forward_B = %h", forward_A , forward_B), UVM_LOW)
      
      
      
      // LW stall Hazard 
      lwstall = (inst_ex[6:0] == lw) && ((inst_ex[11:7] == inst_dec[19:15]) || (inst_ex[11:7] == inst_dec[24:20])) ;
      
      // PC control hazard 
     
      // Predict Output sequence 
       fork 
         begin
         predict();  
         compare(sb_item,p_item) ;
         end
       join_none    
     
    end
   
  endfunction: write 
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase); 
  endtask
  
  task predict ();
     
    logic [31:0] srcA , srcB , temp_srcA , temp_srcB;
     p_item = seq_item::type_id::create("p_item");
     ral_model_h.regs[inst_mem[19:15]].read(status, srcA, UVM_BACKDOOR) ;
    
    case (inst_type(inst_mem)) // Instruction Type 
      
      LW : begin 
        p_item.PCF = pc_fetch ; 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA + Extend(inst_mem[31:20]) ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
          
      ADDI : begin  
        p_item.PCF = pc_dec + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA + Extend(inst_mem[31:20]) ;
      end
          
      SLLI : begin  
        p_item.PCF = pc_dec + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA << inst_mem[24:20] ;
        
      end
          
      SLTI : begin  
        p_item.PCF = pc_dec + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = ($signed(srcA) < $signed(Extend(inst_mem[31:20]))) ;
      end
          
      XORI : begin 
        p_item.PCF = pc_dec + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA ^ Extend(inst_mem[31:20]) ;
      end
          
      SRAI : begin 
        p_item.PCF = pc_dec + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA >>> inst_mem[24:20] ;
      end
            
      SRLI : begin  
        p_item.PCF = pc_dec + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA >> inst_mem[24:20] ;  
      end 
          
      ORI : begin 
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA | Extend(inst_mem[31:20]) ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
          
      ANDI : begin  
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA & Extend(inst_mem[31:20]) ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
          
      AUIPC : begin 
        p_item.PCF = pc_mem + 4 ; 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = pc_ex + {inst_mem[31:12] , 12'b0} ; 
        ral_model_h.dmem.read(status , srcA , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
      
      SW : begin 
        p_item.PCF = pc_mem + 4 ; 
        p_item.MemWriteM = 1 ;
        p_item.DataAdrM = srcA + Extend({inst_mem[31:25] , inst_mem[11:7]}) ; 
        p_item.WriteDataM = srcB ;
        ral_model_h.dmem.read(status , srcA , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
           
      ADD : begin
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA + srcB ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
          
      SUB : begin 
        p_item.PCF = pc_ex + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA - srcB ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;  
      end
             
      SLL : begin   
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA << srcB[4:0] ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end
          
      SLT : begin 
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = (srcA < srcB) ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end
          
      XOR : begin  
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA ^ srcB ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end  
          
      SRL : begin 
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA >> srcB[4:0] ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end  
      
      SRA : begin  
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA >>> srcB[4:0] ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end 

      XOR : begin  
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA | srcB ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end  
        
      AND : begin  
        p_item.PCF = pc_mem + 4 ;
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA & srcB ; 
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;   
      end  
      
      LUI : begin 
        p_item.PCF = pc_mem + 4 ; 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = {inst_mem[31:12] , 12'b0} ; 
        ral_model_h.dmem.read(status , srcA , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
      
      BEQ : begin 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA - srcB ; 
        p_item.PCF = p_item.DataAdrM ? (pc_mem + 4) : (pc_mem + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
        
      BNE : begin 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA - srcB ; 
        p_item.PCF = p_item.DataAdrM ? (pc_mem + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) : (pc_mem + 4) ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
        
      BLT : begin 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = (srcA < srcB) ; 
        p_item.PCF = p_item.DataAdrM ? (pc_mem + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) : (pc_mem + 4) ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
        
      BGE : begin  
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = (srcA >= srcB) ; 
        p_item.PCF = p_item.DataAdrM ? (pc_mem + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) : (pc_mem + 4) ;  
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end      
        
      JALR : begin 
        p_item.MemWriteM = 0 ;
        p_item.DataAdrM = srcA + Extend(inst_mem[31:20]) ;
        p_item.PCF = p_item.DataAdrM ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end 
        
      JAL : begin 
        p_item.MemWriteM = 0 ; 
        p_item.DataAdrM = pc_mem + Extend({inst_mem[31],inst_mem[19:!2],inst_mem[20],inst_mem[30:22],1'b0}) ;
        p_item.PCF = p_item.DataAdrM ;
        ral_model_h.dmem.read(status , p_item.DataAdrM , p_item.ReadDataM , UVM_BACKDOOR) ;
      end
      
    endcase  // Instruction type
     
       //_____\\
      // debug \\
     //_________\\
    `uvm_info(get_type_name(), $sformatf("srcA = %h   ,  immediate = %h",srcA , Extend(inst_mem[31:20])), UVM_LOW)
    
  endtask // predict 
  
  function [31:0] Extend;
         input [11:0] IMM;
         Extend = {{20{IMM[11]}}, IMM};
  endfunction

  
  function void compare (seq_item a_seq , p_seq) ;
    bit pass ;
    
    if(inst_mem == 32'h0) begin 
      `uvm_info(get_type_name(),"No Output yet ... In progress", UVM_LOW)
    end
	else begin 
      pass = (a_seq.DataAdrM   === p_seq.DataAdrM)  &&
             (a_seq.PCF        === p_seq.PCF) ;
      if (pass)
        `uvm_info(get_type_name(),"SUCCESSFUL OPERATION :D", UVM_LOW)
      else  
        `uvm_error(get_type_name(),"FAILED OPEARTION :(")

      
      $display("Actual Sequence :") ;
         a_seq.print() ;
         $display("Predicted Sequence :") ;
         p_seq.print() ;

    end 
  endfunction 
  
endclass : scoreboard