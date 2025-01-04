    wr_forward  = mem_forward ;     // Store previous output to be forwarded later  
    mem_forward = p_item.DataAdrM ; // Store previous output to be forwarded later  
    $display("Mem forward : %d", mem_forward) ;
    $display("Wr foward : %d", wr_forward) ;


    case(forward_A)
      2'b10 : srcA = mem_forward ; 
      2'b01 : srcA = wr_forward  ;
      2'b00 : srcA = temp_srcA ;
    endcase 
    
    case(forward_B)
      2'b10 : srcB = mem_forward ; 
      2'b01 : srcB = wr_forward  ;
      2'b00 : srcB = temp_srcB ;
    endcase 


    ral_model_h.regs[inst_mem[19:15]].read(status, temp_srcA, UVM_BACKDOOR) ;
    ral_model_h.regs[inst_mem[24:20]].read(status, temp_srcB, UVM_BACKDOOR) ;
    
