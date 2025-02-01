class base_test extends uvm_test ;
  `uvm_component_utils(base_test)

  env risc_env ;
  reset_seq  reset_s  ;

  // Constructor 
  function new(string name = "base_test" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new

  // Build Phase 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    risc_env = env::type_id::create("risc_env",this);
    reset_s = reset_seq::type_id::create("reset_s");
  endfunction : build_phase 

endclass :base_test
