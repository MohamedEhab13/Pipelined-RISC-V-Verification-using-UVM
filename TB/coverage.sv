class coverage extends uvm_subscriber #(seq_item) ;
  `uvm_component_utils(coverage)
  
  uvm_analysis_imp #(seq_item, coverage) cov_mon_port; // Connect Monitor to scoreboard
  
  
  // Handles declaration 
  seq_item cov_item ; // Copy the recieved item from monitor here to avoid override elsewhere 
  ral_model ral_model_h ; // ral handle 
  uvm_status_e   status ; // needed in ral read task 
  
  // Signal Declaration 
  bit [31:0] inst_fetch , inst_dec , inst_ex , inst_mem , inst_wr ; // For Instruction pipelining 
  bit        forward ; // dedect RAW hazard 
  
  // Covergroups 
  covergroup hazard_cg ; // To Cover All Hazards 
    RAW : coverpoint forward {bins raw_hazard = {1};} // Raw Hazard 
  endgroup : hazard_cg
  
  covergroup reset_cg ;
    Reset : coverpoint cov_item.reset { bins reset_on  = {1} ;
                                        bins reset_off = {0} ; }
  endgroup : reset_cg
  
  // Constructor 
  function new(string name = "coverage_collector" ,uvm_component parent);
     super.new(name,parent);
     cov_mon_port = new ("cov_mon_port" ,this); 
     hazard_cg = new() ;
     reset_cg  = new() ;
  endfunction : new
  
  
  
 // Build Phase 
  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
    if (!uvm_config_db #(ral_model)::get(null, "", "ral_model_h", ral_model_h ))
    `uvm_error(get_type_name(), "RAL model not found" );
  endfunction
  
  
  
  function void write (seq_item  t);
     cov_item = seq_item::type_id::create("sb_item"); 
     cov_item.copy(t) ;       // To prevent unwanted change
    // cov_item.print() ;
     // Instruction pipelining
     inst_wr    = inst_mem ; 
     inst_mem   = inst_ex ; 
     inst_ex    = inst_dec ; 
     inst_dec   = inst_fetch ; 
     inst_fetch = cov_item.InstrF ;
    
     forward = ((inst_mem[11:7] == inst_ex[19:15]) || (inst_mem[11:7] == inst_ex[24:20]) || (inst_wr[11:7] == inst_ex[19:15]) || (inst_wr[11:7] == inst_ex[24:20])) && ((inst_mem[6:0] != sw) && (inst_mem[6:0] != brnch));
    
     // Sampling covergroups 
    hazard_cg.sample() ;
    reset_cg.sample() ;
    
  endfunction : write 
  
  
endclass : coverage