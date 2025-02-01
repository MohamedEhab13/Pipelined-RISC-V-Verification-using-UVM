interface intf (input logic clk) ; 
  
  import risc_pkg::* ;
  
  logic        reset      ; 
  logic [31:0] InstrF     ;
  logic [31:0] PCF        ;
  logic [31:0] WriteDataM ;
  logic [31:0] DataAdrM   ;
  logic [31:0] ReadDataM  ;
  logic        MemWriteM  ; 
  instr_type   inst_type  ;
  

endinterface 
