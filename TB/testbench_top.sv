`timescale 1ns/1ns
`include "uvm_macros.svh"


  module tb_top;
    
   import uvm_pkg::*;
   import risc_pkg::* ;
   
   
   bit clk ;
    
  // RAL HDL paths
  string blk_hdl_path = "tb_top.dut";
  string mem_hdl_path = "dmem.RAM";
  string reg_hdl_path = "rv.dp.rf.register[%0d]";
  
  // Interface Initaition
  intf risc_intf(clk)  ;
   
  // DUT Intiation 
  risc_top  dut (
           .clk(clk),   
           .reset(risc_intf.reset), 
           .InstrF(risc_intf.InstrF),	
           .PCF(risc_intf.PCF),
           .WriteDataM(risc_intf.WriteDataM),
           .DataAdrM(risc_intf.DataAdrM),
           .ReadDataM(risc_intf.ReadDataM),
           .MemWriteM(risc_intf.MemWriteM)
		  );
  
  
  // Clock Generation
  initial begin 
    forever  #5 clk = ~clk;
  end
  
  
  initial begin 
    uvm_config_db #(virtual intf)::set(null,"*","risc_intf",risc_intf);
    uvm_config_db #(string)::set(null,"*", "blk_hdl_path", blk_hdl_path);
    uvm_config_db #(string)::set(null,"*", "mem_hdl_path", mem_hdl_path);
    uvm_config_db #(string)::set(null,"*", "reg_hdl_path", reg_hdl_path);
    run_test();
  end
    
  initial 
  begin
    // Required to dump signals to EPWave
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end
  

endmodule 
