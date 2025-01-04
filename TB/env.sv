class env extends uvm_env;
  `uvm_component_utils(env)
  
  
  agent risc_agent ;
  scoreboard risc_scoreboard ;
  ral_model ral_model_h;
  coverage risc_coverage ;
 
  
  
  // Constructor 
    function new(string name = "env" ,uvm_component parent);
         super.new(name,parent); 
    endfunction : new
              
              
  
  // Build Phase 
    function void build_phase(uvm_phase phase);
     super.build_phase(phase); 
           
      ral_model_h   = ral_model::type_id::create("ral_model_h"); 
      ral_model_h.build();
      ral_model_h.lock_model();
      ral_model_h.reset(); 
      uvm_config_db#(ral_model)::set(null, "*", "ral_model_h", ral_model_h);
      
      risc_agent = agent::type_id::create("risc_agent",this);  
      risc_scoreboard = scoreboard::type_id::create("risc_scoreboard",this);  
      risc_coverage = coverage::type_id::create("risc_coverage",this);     
    endfunction :build_phase    
              
  
  
    
  // Connect Phase 
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase); 
      risc_agent.risc_monitor.monitor_ap.connect(risc_scoreboard.sb_mon_port) ; // Connect monitor to scoreboard by analysis port              
      risc_agent.risc_monitor.monitor_ap.connect(risc_coverage.cov_mon_port) ; // Connect monitor to Coverage by analysis port        
  endfunction :connect_phase
  
  // Run Phase 
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
    endtask : run_phase
  
endclass : env
