//including interfcae and testcase files
`include "mips_interface.sv"
`include "mips_base_test.sv"
`include "mips_sequence_test.sv"


module tbench_top;
  
  //---------------------------------------
  //clock and reset signal declaration
  //---------------------------------------
  bit clk;
  bit rst;
  
  //---------------------------------------
  //clock generation
  //---------------------------------------
  always #5 clk = ~clk;
  
  //---------------------------------------
  //reset Generation
  //---------------------------------------
  initial begin
    rst = 1;
    #6 rst =0;
  end  

  //creatinng instance of interface, inorder to connect DUT and testcase
  mips_if i_intf(clk,rst);  
  
  //DUT instance, interface signals are connected to the DUT ports
  MIPS UUT (
    .clk(i_intf.clk),
    .rst(i_intf.rst),
    .extInst_en(1'b1),
    .extInst(i_intf.extInst),
    .to_reg_file(i_intf.regmem_data),//lw y R type
    .to_memdata(i_intf.datamem_data),
    .pc_current(i_intf.pc_current),
    .pc_next(i_intf.pc_next),
    .regf1(i_intf.regf1),
    .regf2(i_intf.regf2)
    );  
  
//passing the interface handle to lower heirarchy using set method 
  //and enabling the wave dump
  //---------------------------------------
  initial begin 
    uvm_config_db#(virtual mips_if)::set(uvm_root::get(),"*","vif",i_intf);
    //enable wave dump
    $dumpfile("dump.vcd"); 
    $dumpvars;
  end
  
  //---------------------------------------
  //calling test
  //---------------------------------------
  initial begin 
    run_test();
  end
  
endmodule  