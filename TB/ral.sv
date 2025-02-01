import uvm_pkg::*;
class reg32 extends uvm_reg; 
  `uvm_object_utils(reg32) 

  uvm_reg_field field;  // register is one field


  function new(string name = "reg32");
    super.new(name, 32, UVM_NO_COVERAGE); // constructor (name , size , coverage)
  endfunction


  virtual function void build();
    field = uvm_reg_field::type_id::create("field"); 

    //function void configure( uvm_reg 	parent,
    // int 	unsigned 	size,
    // int 	unsigned 	lsb_pos,
    // string 	access,
    // bit 	volatile,
    // uvm_reg_data_t 	reset,
    // bit 	has_reset,
    // bit 	is_rand,
    // bit 	individually_accessible	)

    field.configure(this, 32, 0 , "RW", 0, 32'b0, 1, 1, 1);

  endfunction
endclass

////////////////////////////////////////////////////////////////////////////

class data_mem extends uvm_mem;
  `uvm_object_utils(data_mem)
  function new(string name = "data_mem");
    super.new(name, // Name of the memory
              256,  // Number of words (1 KB = 256 words of 4 bytes each)
              32,   // Data width (32 bits)
              "RW", // Access rights
              UVM_NO_COVERAGE); // Coverage (optional)
  endfunction
endclass


////////////////////////////////////////////////////////////////////////////


class ral_model extends uvm_reg_block;
  `uvm_object_utils(ral_model)

  reg32 regs[32];
  data_mem dmem;
  uvm_reg_map map;

  string blk_hdl_path;
  string mem_hdl_path;
  string reg_hdl_path;

  function new(string name = "ral_model");
    super.new(name, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    


    uvm_config_db #(string)::get(null, "", "blk_hdl_path", blk_hdl_path);
    uvm_config_db #(string)::get(null, "", "mem_hdl_path", mem_hdl_path);
    uvm_config_db #(string)::get(null, "", "reg_hdl_path", reg_hdl_path);

    add_hdl_path(blk_hdl_path); // HDL path for reg block
    map = create_map("map",'h0, 4, UVM_BIG_ENDIAN, 0);

    dmem = data_mem::type_id::create("dmem"); // Create mem object
    dmem.configure(this, mem_hdl_path); // Parent , HDL path
    map.add_mem( dmem, 0, "RW");

    // create map object
    // Map name, Offset, Number of bytes, Endianess, byte addressing) 


    // Create 32 registers
    foreach (regs[i]) begin
      regs[i] = reg32::type_id::create($sformatf("x%0d", i));
      regs[i].configure(this, null,$sformatf(reg_hdl_path,i) );
      regs[i].build();

      // add reg to map
      // reg, offset, access
      if (i == 0)
        map.add_reg(regs[i], i+500, "RO");  // Read-only access for x0
      else
        map.add_reg(regs[i], i+500, "RW");  // Read-write access

    end
  endfunction
  
  task initialize;
    uvm_status_e status;
    for (int i=0; i <256; i++) this.dmem.write(status, i, 0, UVM_BACKDOOR);
    for (int i=0; i <32; i++ ) this.regs[i].write(status, 0, UVM_BACKDOOR);
  endtask
 

endclass