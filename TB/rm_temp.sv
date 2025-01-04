  
  task predict (      input ral_model ral_model_h,
                            input  logic [31:0] inst_mem, inst_ex,
                            input  logic [31:0] pc_ex,
                            input  bit   [1:0]  forward_a, forward_b,
                            input  bit          lw_stall,
                            input  logic [31:0] mem_forward , wr_forward, // store the memory and write back stages for  forwarding
                            
                            output logic [31:0] pc_p, WriteData_p, DataAdr_p, ReadData_p,
                            output logic        MemWrite_p);
     
    uvm_status_e   status ;
    logic [31:0] srcA , srcB ;
    case(forward_a)
      2'b01 : srcA = mem_forward ; 
      2'b10 : srcA = wr_forward  ;
      2'b00 : ral_model_h.regs[inst_mem[19:!5]].read(status, srcA, UVM_BACKDOOR) ;
    endcase 
    
    case(forward_b)
      2'b01 : srcB = mem_forward ; 
      2'b10 : srcB = wr_forward  ;
      2'b00 : ral_model_h.regs[inst_mem[24:20]].read(status, srcA, UVM_BACKDOOR) ;
    endcase 
    
    
    
    case (inst_mem[6:0]) // opcode case 
      
      lw : begin 
        pc_p = pc_ex + 4 ; 
        MemWrite_p = 0 ;
        DataAdr_p = srcA + Extend(inst_mem[31:20]) ; 
        ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
      end
      
      
      imm : begin 
        case(inst_mem[14:12]) // Immediate operation case 
          
          3'b000 : begin // addi 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA + Extend(inst_mem[31:20]) ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          
          3'b001 : begin // slli 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA << inst_mem[24:20] ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          
          3'b010 : begin // slti 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = (srcA < Extend(inst_mem[31:20])) ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          
          3'b100 : begin // xori 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA ^ Extend(inst_mem[31:20]) ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          
          3'b101 : begin // srli or srai
            if (inst_mem[30] == 0) begin // srai 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA >>> inst_mem[24:20] ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
            end
            else // srli
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA >> inst_mem[24:20] ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;  
            end 
          
          3'b110 : begin // ori 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA | Extend(inst_mem[31:20]) ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          
          3'b111 : begin // andi 
            pc_p = pc_ex +4 ;
            MemWrite_p = 0 ;
            DataAdr_p = srcA & Extend(inst_mem[31:20]) ;
            ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          
          default : begin  		// Check this out if there is an error 	 
					 DataAdr_p = 32'bx ;
			         MemWrite_p = 1'bx ; 
				     pc_p = 32'bx ;  
          end	
          
        endcase // immediate operations case 
      end 
      
      auipc : begin 
        pc_p = pc_ex + 4 ; 
        MemWrite_p = 0 ;
        DataAdr_p = pc_ex + {inst_mem[31:12] , 12'b0} ; 
        ral_model_h.dmem.read(status , srcA , ReadData_p , UVM_BACKDOOR) ;
      end
      
      sw : begin 
        pc_p = pc_ex + 4 ; 
        MemWrite_p = 1 ;
        DataAdr_p = srcA + Extend({inst_mem[31:25] , inst_mem[11:7]}) ; 
        WriteData_p = srcB ;
        ral_model_h.dmem.read(status , srcA , ReadData_p , UVM_BACKDOOR) ;
      end
      
      arith : begin 
      case(inst_mem[14:12]) // Arithmetic operations case         
        3'b000 : begin // add or sub
          if(inst_mem[30] == 0) begin // add
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA + srcB ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
          end
          else begin // sub
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA - srcB ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;  
          end
          end
          
        3'b001 : begin // sll 
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA << srcB[4:0] ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end
          
        3'b010 : begin // slt 
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = (srcA < srcB) ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end
          
        3'b100 : begin // xor 
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA ^ srcB ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end  
          
        3'b101 : begin // srl or sra
          if(inst_mem[30] == 0) begin // srl
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA >> srcB[4:0] ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end        
          else  begin // sra 
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA >>> srcB[4:0] ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end 
          end

        3'b110 : begin // xor 
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA | srcB ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end  
        
        3'b111 : begin // and 
          pc_p = pc_ex + 4 ;
          MemWrite_p = 0 ;
          DataAdr_p = srcA & srcB ; 
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;   
          end  
      endcase // Arithmetic operations case 
      end  
      
      lui : begin 
        pc_p = pc_ex + 4 ; 
        MemWrite_p = 0 ;
        DataAdr_p = {inst_mem[31:12] , 12'b0} ; 
        ral_model_h.dmem.read(status , srcA , ReadData_p , UVM_BACKDOOR) ;
      end
      
      brnch : begin 
      case(inst_mem[14:12]) // Branch operations case 
        3'b000 : begin // beq
          MemWrite_p = 0 ;
          DataAdr_p = srcA - srcB ; 
          pc_p = DataAdr_p ? (pc_ex + 4) : (pc_ex + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) ;
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
        end
        
        3'b001 : begin // bne 
          MemWrite_p = 0 ;
          DataAdr_p = srcA - srcB ; 
          pc_p = DataAdr_p ? (pc_ex + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) : (pc_ex + 4) ;
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
        end
        
        3'b100 :begin // blt 
          MemWrite_p = 0 ;
          DataAdr_p = (srcA < srcB) ; 
          pc_p = DataAdr_p ? (pc_ex + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) : (pc_ex + 4) ;
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
        end
        
        3'b101 :begin // bge 
          MemWrite_p = 0 ;
          DataAdr_p = (srcA >= srcB) ; 
          pc_p = DataAdr_p ? (pc_ex + Extend({inst_mem[31],inst_mem[7],inst_mem[30:25],inst_mem[11:9],1'b0})) : (pc_ex + 4) ;  
          ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
        end      
        endcase  // Branch operations case
      end
        
      jalr : begin 
        MemWrite_p = 0 ;
        DataAdr_p = srcA + Extend(inst_mem[31:20]) ;
        pc_p = DataAdr_p ;
        ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
      end 
        
      jal : begin 
        MemWrite_p = 0 ; 
        DataAdr_p = pc_ex + Extend({inst_mem[31],inst_mem[19:!2],inst_mem[20],inst_mem[30:22],1'b0}) ;
        pc_p = DataAdr_p ;
        ral_model_h.dmem.read(status , DataAdr_p , ReadData_p , UVM_BACKDOOR) ;
      end
      
    endcase // opcode case 
    
  endtask
 

  //------------------------------------------------------------------------------------------------------------

  
  function [31:0] Extend;
         input [11:0] IMM;
         Extend = {{20{IMM[11]}}, IMM};
  endfunction	
  
