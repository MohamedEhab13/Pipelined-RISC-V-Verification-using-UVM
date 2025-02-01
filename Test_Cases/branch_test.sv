class branch_test extends base_test ;
 `uvm_component_utils(branch_test)

  rand_seq rand_s ;
  jal_seq jal_s;
  jalr_seq jalr_s;
  arith_seq arith_s;
  branch_seq branch_s;
  sw_seq sw_s;
  
  function new(string name = "branch_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    rand_s = rand_seq::type_id::create("rand_s");
    arith_s = arith_seq::type_id::create("arith_s");
    jal_s = jal_seq::type_id::create("jal_s");
    jalr_s = jalr_seq::type_id::create("jalr_s");
    branch_s = branch_seq::type_id::create("branch_s");
    sw_s = sw_seq::type_id::create("sw_s");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat (2) reset_s.start(risc_env.risc_agent.risc_sequencer);

    repeat (2000) begin 
       branch_s.start(risc_env.risc_agent.risc_sequencer);
       repeat (2) rand_s.start(risc_env.risc_agent.risc_sequencer);   
    end

    repeat (2000) begin 
       branch_s.start(risc_env.risc_agent.risc_sequencer);
       arith_s.start(risc_env.risc_agent.risc_sequencer);   
    end
   
    repeat (100) begin 
       branch_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(2)jal_s.start(risc_env.risc_agent.risc_sequencer);   
    end

   repeat (100) begin 
       branch_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(2)jalr_s.start(risc_env.risc_agent.risc_sequencer);   
    end
 
   repeat (20) begin 
       branch_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(2)sw_s.start(risc_env.risc_agent.risc_sequencer);   
    end
    
    phase.drop_objection(this);
  endtask

  

endclass
