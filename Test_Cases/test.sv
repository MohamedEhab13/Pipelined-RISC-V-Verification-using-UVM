


//========================================================================================


class rand_test extends base_test ;
  `uvm_component_utils(rand_test)
  rand_seq rand_s ;
  
  function new(string name = "jump_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rand_s = rand_seq::type_id::create("rand_s");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat (2) reset_s.start(risc_env.risc_agent.risc_sequencer);
    repeat (200) rand_s.start(risc_env.risc_agent.risc_sequencer);   
    
    phase.drop_objection(this);
  endtask

endclass

//========================================================================================


class memory_test extends uvm_test ; // Directed test to verify memory read and write operations 
  `uvm_component_utils(memory_test)

  env risc_env ;
  reset_seq  reset_s  ;
  addi_seq  addi_s ;
  sw_seq sw_s ;
  lw_seq lw_s ;
  and_seq and_s ;
 

  // Constructor 
  function new(string name = "memory_test" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    risc_env = env::type_id::create("risc_env",this);
  endfunction : build_phase 

  // Run Phase 
  task  run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
  
    repeat(1) begin
       reset_s = reset_seq::type_id::create("reset_s");
       reset_s.start(risc_env.risc_agent.risc_sequencer);
    end

    repeat(60) begin 
      addi_s = addi_seq::type_id::create("addi_s");
      addi_s.start(risc_env.risc_agent.risc_sequencer);	 
     end
       
//     repeat(1) begin 
//       sw_s = sw_seq::type_id::create("sw_s");
//       sw_s.start(risc_env.risc_agent.risc_sequencer);	 
//      end
    repeat(10) begin 
      and_s = and_seq::type_id::create("and_s");
      and_s.start(risc_env.risc_agent.risc_sequencer);	 
     end
    
    repeat(10) begin 
      addi_s = addi_seq::type_id::create("addi_s");
      addi_s.start(risc_env.risc_agent.risc_sequencer);	 
     end

//     repeat(20) begin 
//       lw_s = lw_seq::type_id::create("lw_s");
//       lw_s.start(risc_env.risc_agent.risc_sequencer);	 
//      end
    
 //  $stop ;  
    phase.drop_objection(this);  
  endtask :run_phase

endclass :memory_test

//========================================================================================


class stall_test extends uvm_test ; // Directed test to verify the LW stall hazard 
  `uvm_component_utils(stall_test)

  env risc_env ;
  
  reset_seq  reset_s  ;
  addi_seq addi_s ;
  addi_1  addi_s1 ;
  addi_2  addi_s2 ;
  addi_3  addi_s3 ;
  addi_4  addi_s4 ;
  addi_5  addi_s5 ;
  sw_test sw_s ;
  sw_test2 sw_s2 ;
  lw_test lw_s ;
  
  lw_seq lw_sv ;
  sw_seq sw_sv ;

  // Constructor 
  function new(string name = "stall_test" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    risc_env = env::type_id::create("risc_env",this);
  endfunction : build_phase 

  // Run Phase 
  task  run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
  
    repeat(2) begin
       reset_s = reset_seq::type_id::create("reset_s");
       reset_s.start(risc_env.risc_agent.risc_sequencer);
    end
    
    addi_s1 = addi_1::type_id::create("addi_s1"); // x6 = x1(0) + 77 
    addi_s1.start(risc_env.risc_agent.risc_sequencer);	
    
    addi_s2 = addi_2::type_id::create("addi_s2");  // x2 = x1(0) + 33 
    addi_s2.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s3 = addi_3::type_id::create("addi_s3"); // x3 = x1(0) + 55
    addi_s3.start(risc_env.risc_agent.risc_sequencer);
     
    repeat(1) begin 
     sw_s = sw_test::type_id::create("sw_s"); // mem[7] = x6(77)
     sw_s.start(risc_env.risc_agent.risc_sequencer);	 
    end
    
    addi_s3 = addi_3::type_id::create("addi_s3"); // x3 = x1(0) + 55
    addi_s3.start(risc_env.risc_agent.risc_sequencer);
      
    lw_s = lw_test::type_id::create("lw_s"); // x4 = mem[7](77)
    lw_s.start(risc_env.risc_agent.risc_sequencer);	
         
    addi_s4 = addi_4::type_id::create("addi_s4"); // x7 = x4(77) + 3 = 80 
    addi_s4.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s5 = addi_5::type_id::create("addi_s5"); // x16 = x1(0) + 3
    addi_s5.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s1 = addi_1::type_id::create("addi_s1");   // rd = rs1(0) + 77 
    addi_s1.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s5 = addi_5::type_id::create("addi_s5"); // x16 = x1(0) + 3
     addi_s5.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s5 = addi_5::type_id::create("addi_s5"); // x16 = x1(0) + 3
     addi_s5.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s2 = addi_2::type_id::create("addi_s2");  // x2 = x1(0) + 33 
     addi_s2.start(risc_env.risc_agent.risc_sequencer);
    
    addi_s3 = addi_3::type_id::create("addi_s3"); // x3 = x1(0) + 55
    addi_s3.start(risc_env.risc_agent.risc_sequencer);  
    
  //  $stop ;    
    phase.drop_objection(this);  
  endtask :run_phase

endclass : stall_test

//======================================================================================

class jump_test extends base_test ;
  `uvm_component_utils(jump_test)

  addi_seq addi_s ;
  jal_seq jal_s ;
  jalr_seq jalr_s ;
  bne_seq bne_s ;
  beq_seq beq_s ;
  bge_seq bge_s ;
  blt_seq blt_s ;
  sw_seq sw_s ;
  lw_seq lw_s ;
  
  addi_1 addi_s1 ;
  addi_2 addi_s2 ;
  addi_3 addi_s3 ;
  addi_4 addi_s4 ;
  addi_5 addi_s5 ;
  
  bne_test bne_ts ;
  
  function new(string name = "jump_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      addi_s = addi_seq::type_id::create("addi_s");
      jal_s = jal_seq::type_id::create("jal_s");
      jalr_s = jalr_seq::type_id::create("jalr_s");
      bne_s = bne_seq::type_id::create("bne_s");
      beq_s = beq_seq::type_id::create("beq_s");
      blt_s = blt_seq::type_id::create("blt_s");
      bge_s = bge_seq::type_id::create("bge_s");
      sw_s = sw_seq::type_id::create("sw_s"); 
      lw_s = lw_seq::type_id::create("lw_s"); 
    
    addi_s1 = addi_1::type_id::create("addi_s1");
    addi_s2 = addi_2::type_id::create("addi_s2");
    addi_s3 = addi_3::type_id::create("addi_s3");
    addi_s4 = addi_4::type_id::create("addi_s4");
    addi_s5 = addi_5::type_id::create("addi_s5");
    
    bne_ts = bne_test::type_id::create("bne_ts");
      
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat (2) reset_s.start(risc_env.risc_agent.risc_sequencer);
    repeat (20) addi_s.start(risc_env.risc_agent.risc_sequencer); 
//     repeat (1) addi_s1.start(risc_env.risc_agent.risc_sequencer); // x6 = 77
//     repeat (1) addi_s2.start(risc_env.risc_agent.risc_sequencer); // x2 = 77
//     repeat (4) addi_s4.start(risc_env.risc_agent.risc_sequencer); // x3 = 55 
    repeat (20)  bge_s.start(risc_env.risc_agent.risc_sequencer); 
 //   repeat (1)  sw_s.start(risc_env.risc_agent.risc_sequencer);
  //  repeat (10) addi_s.start(risc_env.risc_agent.risc_sequencer); 

    #100;
    phase.drop_objection(this);
  endtask

endclass

