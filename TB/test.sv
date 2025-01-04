class test extends uvm_test ;
  `uvm_component_utils(test)


  env risc_env ;
  addi_seq   addi_s ;
  slli_seq   slli_s ;
  slti_seq   slti_s ;
  reset_seq  reset_s  ;
  xori_seq   xori_s ;
  srli_seq   srli_s ;
  srai_seq   srai_s ;


  // Constructor 
  function new(string name = "test" ,uvm_component parent);
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
   // `uvm_info(get_type_name(),"start of RESET sequence", UVM_LOW)
    repeat(5) begin
       reset_s = reset_seq::type_id::create("reset_s");
       reset_s.start(risc_env.risc_agent.risc_sequencer);
    end

   // `uvm_info(get_type_name(),"start of ADDI sequence", UVM_LOW)
    repeat(60) begin 
      addi_s = addi_seq::type_id::create("addi_s");
      addi_s.start(risc_env.risc_agent.risc_sequencer);	 
     end
    
    repeat(60) begin 
      srai_s = srai_seq::type_id::create("srai_s");
      srai_s.start(risc_env.risc_agent.risc_sequencer);	 
    end
    
    $stop ;    
    phase.drop_objection(this);  
  endtask :run_phase



endclass :test
