//======================================================
// mips_sequence - random stimulus 
//======================================================
class mips_random_sequence extends uvm_sequence#(mips_seq_item);
  
  `uvm_object_utils(mips_random_sequence)
  
  //--------------------------------------- 
  //Constructor
  //---------------------------------------
  function new(string name = "mips_random_sequence");
    super.new(name);
  endfunction
  
  `uvm_declare_p_sequencer(mips_sequencer) 
  
  //---------------------------------------
  // create, randomize and send the item to driver
  //---------------------------------------
  virtual task body();
    repeat(10) begin
    req = mips_seq_item::type_id::create("req");
    wait_for_grant();
    req.randomize();
    send_request(req);
    wait_for_item_done();
   end 
  endtask
endclass  