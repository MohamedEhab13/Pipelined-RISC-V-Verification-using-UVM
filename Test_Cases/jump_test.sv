class jump_test extends base_test ;
 `uvm_component_utils(jump_test)

  jal_seq jal_s;
  jalr_seq jalr_s;
  sw_seq sw_s;
  lw_seq lw_s;
  branch_seq branch_s;  
  arith_seq arith_s;

  function new(string name = "jump_test",uvm_component parent=null);
    super.new(name,parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sw_s = sw_seq::type_id::create("sw_s");
    lw_s = lw_seq::type_id::create("lw_s");
    jal_s = jal_seq::type_id::create("jal_s");
    jalr_s = jalr_seq::type_id::create("jalr_s");
    branch_s = branch_seq::type_id::create("branch_s");
    arith_s = arith_seq::type_id::create("arith_s");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    repeat (2) reset_s.start(risc_env.risc_agent.risc_sequencer);

    repeat (20) begin // jal --> R
       jal_s.start(risc_env.risc_agent.risc_sequencer);
       arith_s.start(risc_env.risc_agent.risc_sequencer);   
    end

    repeat (20) begin // jalr --> R 
       jalr_s.start(risc_env.risc_agent.risc_sequencer);
       arith_s.start(risc_env.risc_agent.risc_sequencer);   
    end

    repeat (20) begin // jal --> branch
       jal_s.start(risc_env.risc_agent.risc_sequencer);
       branch_s.start(risc_env.risc_agent.risc_sequencer);   
    end

    repeat (20) begin // jalr --> branch 
       jalr_s.start(risc_env.risc_agent.risc_sequencer);
       branch_s.start(risc_env.risc_agent.risc_sequencer);   
    end
   
    repeat (1) begin 
       jal_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(2)sw_s.start(risc_env.risc_agent.risc_sequencer);   
    end

   repeat (1) begin 
       jal_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(2)lw_s.start(risc_env.risc_agent.risc_sequencer); 
   end

   repeat (1) begin 
       jalr_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(2)sw_s.start(risc_env.risc_agent.risc_sequencer);   
    end

   repeat (1) begin 
       jalr_s.start(risc_env.risc_agent.risc_sequencer);
       repeat(3)lw_s.start(risc_env.risc_agent.risc_sequencer);  
    end
    
    phase.drop_objection(this);
  endtask

  
endclass
