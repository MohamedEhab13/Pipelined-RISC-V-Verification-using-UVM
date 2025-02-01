class rand_test extends base_test ;
 `uvm_component_utils(rand_test)

  rand_seq rand_s ;
  
  function new(string name = "rand_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rand_s = rand_seq::type_id::create("rand_s");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat (2) reset_s.start(risc_env.risc_agent.risc_sequencer);
    repeat (10000) rand_s.start(risc_env.risc_agent.risc_sequencer);
    repeat (5) reset_s.start(risc_env.risc_agent.risc_sequencer);
    repeat (10000) rand_s.start(risc_env.risc_agent.risc_sequencer);   
    
    phase.drop_objection(this);
  endtask

endclass
