class rand_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(rand_seq)
  
  seq_item rand_item ;
  
  function  new(string name = "rand_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    rand_item = seq_item::type_id::create("rand_item") ;
    start_item(rand_item) ; 
    assert(rand_item.randomize() )           
    else
    `uvm_error(get_type_name(),"randomization failed in rand_sequence")
    rand_item.Get_type ;  
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

class imm_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(imm_seq)
  
  seq_item imm_item ;
  
  function  new(string name = "imm_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    imm_item = seq_item::type_id::create("imm_item") ;
    start_item(imm_item) ;  
    assert(imm_item.randomize() with {
           imm_item.InstrF[6:0] == imm ;
           imm_item.InstrF[11:7] != 0 ; // rd not 0
           imm_item.InstrF[14:12] inside {3'b000,3'b001,3'b010,3'b100,3'b101,3'b110,3111}; })  
     else     
      `uvm_error(get_type_name(),"randomization failed in imm_sequence")
       imm_item.Get_type ;
     finish_item(imm_item);	 
  endtask
  
endclass: imm_seq

//----------------------------------------------------------------------------------

class arith_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(arith_seq)
  
  seq_item arith_item ;
  
  function  new(string name = "arith_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    arith_item = seq_item::type_id::create("arith_item") ;
    start_item(arith_item) ;  
    assert(arith_item.randomize() with {
           arith_item.InstrF[6:0] == arith ;
           arith_item.InstrF[11:7] != 0 ; // rd not 0
           arith_item.InstrF[14:12] inside {3'b000,3'b001,3'b010,3'b100,3'b101,3'b110,3111}; })  
     else     
      `uvm_error(get_type_name(),"randomization failed in arith_sequence")
       arith_item.Get_type ;
     finish_item(arith_item);	 
  endtask
  
endclass: arith_seq

//----------------------------------------------------------------------------------

class branch_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(branch_seq)
  
  seq_item branch_item ;
  
  function  new(string name = "branch_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    branch_item = seq_item::type_id::create("branch_item") ;
    start_item(branch_item) ;  
    assert(branch_item.randomize() with {
           branch_item.InstrF[6:0] == brnch ;
           branch_item.InstrF[14:12] inside {beq,bne,blt,bge}; })  
     else     
      `uvm_error(get_type_name(),"randomization failed in branch_sequence")
       branch_item.Get_type ;
     finish_item(branch_item);	 
  endtask
  
endclass: branch_seq

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
           addi_item.InstrF[6:0] == imm ;
           addi_item.InstrF[19:15] != 0 ; // rs1 not 0 
           addi_item.InstrF[11:7] != 0 ; // rd not 0
           addi_item.InstrF[14:12] == 3'b000;})  
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

class jal_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(jal_seq)
  
  seq_item jal_item ;
  
  function  new(string name = "jal_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    jal_item = seq_item::type_id::create("jal_item") ;
    start_item(jal_item) ; 
    assert(jal_item.randomize() with {
           jal_item.inst_type == JAL ;
           jal_item.InstrF[6:0] == jal ;})
     else     
       `uvm_error(get_type_name(),"randomization failed in JAL_sequence")
       
       finish_item(jal_item);	 
  endtask 
endclass: jal_seq

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


class ori_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(ori_seq)
  
  seq_item ori_item ;
  
  function  new(string name = "ori_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    ori_item = seq_item::type_id::create("ori_item") ;
    start_item(ori_item) ; 
    assert(ori_item.randomize() with {
           ori_item.inst_type == ORI ;
           ori_item.InstrF[6:0] == imm ;
           ori_item.InstrF[14:12] == 3'b110;})
     else     
       `uvm_error(get_type_name(),"randomization failed in ORI_sequence")
       
       finish_item(ori_item);	 
  endtask
  
endclass: ori_seq

//---------------------------------------------------------------------------------

class andi_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(andi_seq)
  
  seq_item andi_item ;
  
  function  new(string name = "andi_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    andi_item = seq_item::type_id::create("andi_item") ;
    start_item(andi_item) ; 
    assert(andi_item.randomize() with {
           andi_item.inst_type == ANDI ;
           andi_item.InstrF[6:0] == imm ;
           andi_item.InstrF[14:12] == 3'b111;})
     else     
       `uvm_error(get_type_name(),"randomization failed in ANDI_sequence")
       
       finish_item(andi_item);	 
  endtask
  
endclass: andi_seq

//---------------------------------------------------------------------------------

class add_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(add_seq)
  
  seq_item add_item ;
  
  function  new(string name = "add_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    add_item = seq_item::type_id::create("add_item") ;
    start_item(add_item) ; 
    assert(add_item.randomize() with {
           add_item.inst_type == ADD ;
           add_item.InstrF[6:0] == arith ;
           add_item.InstrF[31:25] == 7'b0000000 ;
           add_item.InstrF[14:12] == 3'b000;})
     else     
       `uvm_error(get_type_name(),"randomization failed in ADD_sequence")
       
       finish_item(add_item);	 
  endtask
  
endclass: add_seq

//---------------------------------------------------------------------------------

class sub_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(sub_seq)
  
  seq_item sub_item ;
  
  function  new(string name = "sub_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    sub_item = seq_item::type_id::create("sub_item") ;
    start_item(sub_item) ; 
    assert(sub_item.randomize() with {
           sub_item.inst_type == SUB ;
           sub_item.InstrF[6:0] == arith ;
           sub_item.InstrF[31:25] == 7'b0100000 ;
           sub_item.InstrF[14:12] == 3'b000;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SUB_sequence")
       
       finish_item(sub_item);	 
  endtask
  
endclass: sub_seq

//---------------------------------------------------------------------------------

class sll_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(sll_seq)
  
  seq_item sll_item ;
  
  function  new(string name = "sll_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    sll_item = seq_item::type_id::create("sll_item") ;
    start_item(sll_item) ; 
    assert(sll_item.randomize() with {
           sll_item.inst_type == SLL ;
           sll_item.InstrF[6:0] == arith ;         
           sll_item.InstrF[31:25] == 7'b0000000 ;
      sll_item.InstrF[11:7] != 0 ; 
      sll_item.InstrF[19:15] != 0 ; 
      sll_item.InstrF[24:20] != 0 ; 
           sll_item.InstrF[14:12] == 3'b001;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SLL_sequence")
       
       finish_item(sll_item);	 
  endtask
  
endclass: sll_seq

//---------------------------------------------------------------------------------

class slt_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(slt_seq)
  
  seq_item slt_item ;
  
  function  new(string name = "slt_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    slt_item = seq_item::type_id::create("slt_item") ;
    start_item(slt_item) ; 
    assert(slt_item.randomize() with {
           slt_item.inst_type == SLT ;
           slt_item.InstrF[6:0] == arith ;
           slt_item.InstrF[31:25] == 7'b0000000 ;
           slt_item.InstrF[14:12] == 3'b010;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SLT_sequence")
       
       finish_item(slt_item);	 
  endtask
  
endclass: slt_seq

//---------------------------------------------------------------------------------

class xor_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(xor_seq)
  
  seq_item xor_item ;
  
  function  new(string name = "xor_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    xor_item = seq_item::type_id::create("xor_item") ;
    start_item(xor_item) ; 
    assert(xor_item.randomize() with {
           xor_item.inst_type == XOR ;
           xor_item.InstrF[6:0] == arith ;
           xor_item.InstrF[31:25] == 7'b0000000 ;
           xor_item.InstrF[14:12] == 3'b100;})
     else     
       `uvm_error(get_type_name(),"randomization failed in XOR_sequence")
       
       finish_item(xor_item);	 
  endtask
  
endclass: xor_seq

//---------------------------------------------------------------------------------

class srl_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(srl_seq)
  
  seq_item srl_item ;
  
  function  new(string name = "srl_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    srl_item = seq_item::type_id::create("srl_item") ;
    start_item(srl_item) ; 
    assert(srl_item.randomize() with {
           srl_item.inst_type == SRL ;
           srl_item.InstrF[6:0] == arith ;
           srl_item.InstrF[31:25] == 7'b0000000 ;
           srl_item.InstrF[14:12] == 3'b101;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SRL_sequence")
       
       finish_item(srl_item);	 
  endtask
  
endclass: srl_seq

//---------------------------------------------------------------------------------

class sra_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(sra_seq)
  
  seq_item sra_item ;
  
  function  new(string name = "sra_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    sra_item = seq_item::type_id::create("sra_item") ;
    start_item(sra_item) ; 
    assert(sra_item.randomize() with {
           sra_item.inst_type == SRA ;
           sra_item.InstrF[6:0] == arith ;
           sra_item.InstrF[31:25] == 7'b0100000 ;
           sra_item.InstrF[14:12] == 3'b101;})
     else     
       `uvm_error(get_type_name(),"randomization failed in SRA_sequence")
       
       finish_item(sra_item);	 
  endtask
  
endclass: sra_seq

//---------------------------------------------------------------------------------

class or_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(or_seq)
  
  seq_item or_item ;
  
  function  new(string name = "or_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    or_item = seq_item::type_id::create("or_item") ;
    start_item(or_item) ; 
    assert(or_item.randomize() with {
           or_item.inst_type == OR ;
           or_item.InstrF[6:0] == arith ;
           or_item.InstrF[31:25] == 7'b0000000 ;
           or_item.InstrF[14:12] == 3'b110;})
     else     
       `uvm_error(get_type_name(),"randomization failed in OR_sequence")
       
       finish_item(or_item);	 
  endtask
  
endclass: or_seq

//---------------------------------------------------------------------------------

class and_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(and_seq)
  
  seq_item and_item ;
  
  function  new(string name = "and_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    and_item = seq_item::type_id::create("and_item") ;
    start_item(and_item) ; 
    assert(and_item.randomize() with {
           and_item.inst_type == AND ;
           and_item.InstrF[6:0] == arith ;
           and_item.InstrF[31:25] == 7'b0000000 ;
           and_item.InstrF[14:12] == 3'b111;})
     else     
       `uvm_error(get_type_name(),"randomization failed in AND_sequence")
       
       finish_item(and_item);	 
  endtask
  
endclass: and_seq


//---------------------------------------------------------------------------------

class auipc_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(auipc_seq)
  
  seq_item auipc_item ;
  
  function  new(string name = "and_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    auipc_item = seq_item::type_id::create("auipc_item") ;
    start_item(auipc_item) ; 
    assert(auipc_item.randomize() with {
           auipc_item.inst_type == AUIPC ;
           auipc_item.InstrF[6:0] == auipc ;})
     else     
       `uvm_error(get_type_name(),"randomization failed in AUIPC_sequence")
       
       finish_item(auipc_item);	 
  endtask
  
endclass: auipc_seq


//---------------------------------------------------------------------------------

class lui_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(lui_seq)
  
  seq_item lui_item ;
  
  function  new(string name = "lui_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    lui_item = seq_item::type_id::create("lui_item") ;
    start_item(lui_item) ; 
    assert(lui_item.randomize() with {
           lui_item.inst_type == LUI ;
           lui_item.InstrF[6:0] == lui ;})
     else     
       `uvm_error(get_type_name(),"randomization failed in LUI_sequence")
       
       finish_item(lui_item);	 
  endtask
  
endclass: lui_seq

//---------------------------------------------------------------------------------

class beq_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(beq_seq)
  
  seq_item beq_item ;
  
  function  new(string name = "beq_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    beq_item = seq_item::type_id::create("beq_item") ;
    start_item(beq_item) ; 
    assert(beq_item.randomize() with {
           beq_item.inst_type == BEQ ; 
           beq_item.InstrF[6:0] == brnch ;
      beq_item.InstrF[19:15] == 6 ; 
      beq_item.InstrF[24:20] == 2 ;
           beq_item.InstrF[14:12] == 3'b000;})
     else     
       `uvm_error(get_type_name(),"randomization failed in BEQ_sequence")
       
       finish_item(beq_item);	 
  endtask  
endclass: beq_seq

//---------------------------------------------------------------------------------

class bne_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(bne_seq)
  
  seq_item bne_item ;
  
  function  new(string name = "bne_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    bne_item = seq_item::type_id::create("bne_item") ;
    start_item(bne_item) ; 
    assert(bne_item.randomize() with { 
           bne_item.inst_type == BNE ;
           bne_item.InstrF[6:0] == brnch ;
      bne_item.InstrF[19:15] == 6 ; 
      bne_item.InstrF[24:20] == 2 ;
           bne_item.InstrF[14:12] == 3'b001;})
     else     
       `uvm_error(get_type_name(),"randomization failed in BNE_sequence")
       
       finish_item(bne_item);	 
  endtask  
endclass: bne_seq

//---------------------------------------------------------------------------------

class blt_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(blt_seq)
  
  seq_item blt_item ;
  
  function  new(string name = "blt_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    blt_item = seq_item::type_id::create("blt_item") ;
    start_item(blt_item) ; 
    assert(blt_item.randomize() with {
           blt_item.inst_type == BLT ;
           blt_item.InstrF[6:0] == brnch ;
           blt_item.InstrF[14:12] == 3'b100;})
     else     
       `uvm_error(get_type_name(),"randomization failed in BLT_sequence")
       
       finish_item(blt_item);	 
  endtask  
endclass: blt_seq

//---------------------------------------------------------------------------------

class bge_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(bge_seq)
  
  seq_item bge_item ;
  
  function  new(string name = "bge_seq");
    super.new(name); 
  endfunction: new
  
  task body() ; 	
    bge_item = seq_item::type_id::create("bge_item") ;
    start_item(bge_item) ; 
    assert(bge_item.randomize() with {
           bge_item.inst_type == BGE ;
           bge_item.InstrF[6:0] == brnch ;
           bge_item.InstrF[14:12] == 3'b101;})
     else     
       `uvm_error(get_type_name(),"randomization failed in BGE_sequence")
       
       finish_item(bge_item);	 
  endtask  
endclass: bge_seq


