class agent extends uvm_agent ;
  `uvm_component_utils(agent)
  
  
  driver risc_driver ;
  monitor risc_monitor ;
  sequencer risc_sequencer ;
  
  
  // Constructor  
  function new(string name = "agent" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new
  
  
  
  // Build Phase 
  function void build_phase(uvm_phase phase);  
    super.build_phase(phase);
    risc_driver    = driver::type_id::create("risc_driver",this);
    risc_monitor = monitor::type_id::create("risc_monitor",this);
    risc_sequencer = sequencer::type_id::create("risc_sequencer",this); 
  endfunction : build_phase 
  
  
  
 // Connect Phase 
  function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);	  
	 risc_driver.seq_item_port.connect(risc_sequencer.seq_item_export); // connect driver to sequencer
  endfunction :connect_phase
  
  
 // Run Phase 
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask : run_phase
  
  
endclass : agent 
