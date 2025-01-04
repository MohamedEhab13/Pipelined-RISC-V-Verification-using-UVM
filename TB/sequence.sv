class rand_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(rand_seq)
  
  seq_item rand_item ;
  
  function  new(string name = "rand_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    rand_item = seq_item::type_id::create("rand_item") ;
    start_item(rand_item) ; 
    assert(rand_item.randomize())
    else
    `uvm_error(get_type_name(),"randomization failed in rand_sequence")
      
    finish_item(rand_item);	 
  endtask
  
endclass: rand_seq


//--------------------------------------------------------------------------------

class reset_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(reset_seq)
  
  seq_item reset_item ;
  
  function  new(string name = "reset_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    reset_item = seq_item::type_id::create("reset_item") ;
    start_item(reset_item) ; 
    assert(reset_item.randomize() with {
           reset_item.inst_type == RESET ;
           reset_item.reset == 1;})
     else     
       `uvm_error(get_type_name(),"randomization failed in reset_sequence")
       
       finish_item(reset_item);	 
  endtask
  
endclass: reset_seq

//----------------------------------------------------------------------------------


class lw_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(lw_seq)
  
  seq_item lw_item ;
  
  function  new(string name = "lw_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    lw_item = seq_item::type_id::create("lw_item") ;
    start_item(lw_item) ; 
    assert(lw_item.randomize() with {
           lw_item.inst_type == LW ;
           lw_item.InstrF[6:0] == lw ;
           lw_item.InstrF[14:12] == 3'b010;})
     else     
       `uvm_error(get_type_name(),"randomization failed in lw_sequence")
       
     finish_item(lw_item);	 
  endtask
  
endclass: lw_seq

//----------------------------------------------------------------------------------


class addi_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(addi_seq)
  
  seq_item addi_item ;
  
  function  new(string name = "addi_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    addi_item = seq_item::type_id::create("addi_item") ;
    start_item(addi_item) ;  
    assert(addi_item.randomize() with {
           addi_item.inst_type == ADDI ;
    //     addi_item.InstrF[31:20] inside {[0:40]};
           addi_item.InstrF[6:0] == imm ;
           addi_item.InstrF[14:12] == 3'b000;      
           addi_item.InstrF[11:7] != 0  ; }) // rd != 0 
     else     
      `uvm_error(get_type_name(),"randomization failed in addi_sequence")
       
     finish_item(addi_item);	 
  endtask
  
endclass: addi_seq

//----------------------------------------------------------------------------------

class slli_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(slli_seq)
  
  seq_item slli_item ;
  
  function  new(string name = "slli_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    slli_item = seq_item::type_id::create("slli_item") ;
    start_item(slli_item) ; 
    assert(slli_item.randomize() with {
           slli_item.inst_type == SLLI ;
           slli_item.InstrF[6:0] == imm ;
           slli_item.InstrF[14:12] == 3'b001 ;
           slli_item.InstrF[31:25] == 7'b0000000;})
    else     
      `uvm_error(get_type_name(),"randomization failed in slli_sequence")
       
    finish_item(slli_item);	 
  endtask
  
endclass: slli_seq

//----------------------------------------------------------------------------------


class slti_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(slti_seq)
  
  seq_item slti_item ;
  
  function  new(string name = "slti_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    slti_item = seq_item::type_id::create("slti_item") ;
    start_item(slti_item) ; 
    assert(slti_item.randomize() with {
           slti_item.inst_type == SLTI ;
           slti_item.InstrF[6:0] == imm ;
      //   slti_item.InstrF[31:20] inside {[0:20]} ;
           slti_item.InstrF[14:12] == 3'b010;})
     else     
       `uvm_error(get_type_name(),"randomization failed in slti_sequence")
       
     finish_item(slti_item);	 
  endtask
  
endclass: slti_seq

//----------------------------------------------------------------------------------

class xori_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(xori_seq)
  
  seq_item xori_item ;
  
  function  new(string name = "xori_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    xori_item = seq_item::type_id::create("xori_item") ;
    start_item(xori_item) ; 
    assert(xori_item.randomize() with {
           xori_item.inst_type == XORI ;
           xori_item.InstrF[6:0] == imm ;
           xori_item.InstrF[14:12] == 3'b100;})
     else     
       `uvm_error(get_type_name(),"randomization failed in xori_sequence")
       
       finish_item(xori_item);	 
  endtask
  
endclass: xori_seq

//----------------------------------------------------------------------------------


class sw_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(sw_seq)
  
  seq_item sw_item ;
  
  function  new(string name = "sw_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    sw_item = seq_item::type_id::create("sw_item") ;
    start_item(sw_item) ; 
    assert(sw_item.randomize() with {
           sw_item.inst_type == SW ;
           sw_item.InstrF[6:0] == sw ;
           sw_item.InstrF[14:12] == 3'b010;})
     else     
       `uvm_error(get_type_name(),"randomization failed in sw_sequence")
       
       finish_item(sw_item);	 
  endtask
  
endclass: sw_seq

//----------------------------------------------------------------------------------

class jalr_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(jalr_seq)
  
  seq_item jalr_item ;
  
  function  new(string name = "jalr_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    jalr_item = seq_item::type_id::create("jalr_item") ;
    start_item(jalr_item) ; 
    assert(jalr_item.randomize() with {
           jalr_item.inst_type == JALR ;
           jalr_item.InstrF[6:0] == jalr ;
           jalr_item.InstrF[14:12] == 3'b000;})
     else     
       `uvm_error(get_type_name(),"randomization failed in jalr_sequence")
       
       finish_item(jalr_item);	 
  endtask
  
endclass: jalr_seq

//---------------------------------------------------------------------------------

class srli_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(srli_seq)
  
  seq_item srli_item ;
  
  function  new(string name = "srli_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    srli_item = seq_item::type_id::create("srli_item") ;
    start_item(srli_item) ; 
    assert(srli_item.randomize() with {
           srli_item.inst_type == SRLI ;
           srli_item.InstrF[6:0] == imm ;
           srli_item.InstrF[31:25] == 7'b0000000 ;
           srli_item.InstrF[14:12] == 3'b101;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SRLI_sequence")
       
       finish_item(srli_item);	 
  endtask
  
endclass: srli_seq

//---------------------------------------------------------------------------------

class srai_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(srai_seq)
  
  seq_item srai_item ;
  
  function  new(string name = "srai_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    srai_item = seq_item::type_id::create("srai_item") ;
    start_item(srai_item) ; 
    assert(srai_item.randomize() with {
           srai_item.inst_type == SRAI ;
           srai_item.InstrF[6:0] == imm ;
           srai_item.InstrF[31:25] == 7'b0100000 ;
           srai_item.InstrF[14:12] == 3'b101;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SRAI_sequence")
       
       finish_item(srai_item);	 
  endtask
  
endclass: srai_seq

//---------------------------------------------------------------------------------

