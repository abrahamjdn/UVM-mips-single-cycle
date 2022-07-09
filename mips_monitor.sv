//-------------------------------------------------------------------------
//						mips_monitor - 
//-------------------------------------------------------------------------

class mips_monitor extends uvm_monitor;

  //---------------------------------------
  // Virtual Interface
  //---------------------------------------
  virtual mips_if vif;

  //---------------------------------------
  // analysis port, to send the transaction to scoreboard
  //---------------------------------------
  uvm_analysis_port #(mips_seq_item) item_collected_port;
  
 // The following property holds the transaction information currently
  // begin captured (by the collect_address_phase and data_phase methods).
  //---------------------------------------
  mips_seq_item trans_collected;

  `uvm_component_utils(mips_monitor)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
    trans_collected = new();
    item_collected_port = new("item_collected_port", this);
  endfunction : new
  
 //---------------------------------------
  // build_phase - getting the interface handle
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual mips_if)::get(this, "", "vif", vif))
       `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
  endfunction: build_phase  
  
 //---------------------------------------
  // run_phase - convert the signal level activity to transaction level.
  // i.e, sample the values on interface signal ans assigns to transaction class fields
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.MONITOR.clk);
        wait(vif.monitor_cb.extInst);
      @(negedge vif.MONITOR.clk);
      trans_collected.regmem_data   = vif.monitor_cb.regmem_data;
      trans_collected.datamem_data   = vif.monitor_cb.datamem_data;
      trans_collected.extInst   = vif.monitor_cb.extInst;        
      trans_collected.pc_current =vif.monitor_cb.pc_current;
      trans_collected.pc_next =vif.monitor_cb.pc_next;
      trans_collected.regf1 =vif.monitor_cb.regf1;
      trans_collected.regf2 =vif.monitor_cb.regf2;
	  
      item_collected_port.write(trans_collected);
     trans_collected.display("[Monitor]");
    end
  endtask : run_phase

endclass : mips_monitor