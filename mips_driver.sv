//-------------------------------------------------------------------------
//						mips_driver - 
//-------------------------------------------------------------------------

`define DRIV_IF vif.DRIVER.driver_cb

class mips_driver extends uvm_driver #(mips_seq_item);
  
  //--------------------------------------- 
  // Virtual Interface
  //--------------------------------------- 
  virtual mips_if vif;
  `uvm_component_utils(mips_driver)
  
  //--------------------------------------- 
  // Constructor
  //--------------------------------------- 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new  
  
  //--------------------------------------- 
  // build phase
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mips_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase  
  
  
  
  //---------------------------------------  
  // run phase
  //---------------------------------------  
  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
    end
  endtask : run_phase  
  
 //---------------------------------------
  // drive - transaction level to signal level
  // drives the value's from seq_item to interface signals
  //---------------------------------------
  virtual task drive();
    @(posedge vif.DRIVER.clk);
    `DRIV_IF.extInst <= req.extInst;   
    @(negedge vif.DRIVER.clk);
  endtask : drive
endclass : mips_driver  