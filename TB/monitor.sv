class monitor extends uvm_monitor ;
  `uvm_component_utils(monitor)


  virtual intf monitor_intf;
  uvm_analysis_port #(seq_item) monitor_ap;
  seq_item monitor_item;

  // Constructor 
  function new(string name = "monitor" ,uvm_component parent);
    super.new(name,parent);
  endfunction :new


  // Build Phase 
  function void build_phase(uvm_phase phase);
    if(!uvm_config_db #(virtual intf)::get(this, "*","risc_intf", monitor_intf))
      `uvm_fatal("MONITOR", "Failed to get Interface");
    
    
    monitor_ap  = new("monitor_ap",this);
  endfunction : build_phase


  // Run Phase 
  task  run_phase(uvm_phase phase);
    super.run_phase(phase);
	
    forever begin 
         monitor_item = seq_item::type_id::create("monitor_item");	 
         @(posedge monitor_intf.clk) ; 	
         monitor_item.reset      = monitor_intf.reset      ;
         monitor_item.InstrF     = monitor_intf.InstrF     ;
         monitor_item.inst_type  = monitor_intf.inst_type  ;
         monitor_item.PCF        = monitor_intf.PCF        ;
         monitor_item.WriteDataM = monitor_intf.WriteDataM ;
         monitor_item.DataAdrM   = monitor_intf.DataAdrM   ;
         monitor_item.MemWriteM  = monitor_intf.MemWriteM  ;	
         monitor_item.ReadDataM  = monitor_intf.ReadDataM  ;
      #1 ;
         monitor_ap.write(monitor_item) ;
    end 
    
  endtask : run_phase  


endclass 
