interface mips_if(input logic clk,rst);
  
  //---------------------------------------
  //declaring the signals
  //---------------------------------------  
  logic [31:0] extInst;
  logic [31:0] regmem_data;
  logic [31:0] datamem_data;
  logic [31:0] pc_current;
  logic [31:0] pc_next;
  logic [31:0] regf1;
  logic [31:0] regf2;  
  
  //---------------------------------------
  //driver clocking block
  //---------------------------------------
  clocking driver_cb @(posedge clk);
    default input #1 output #1;
    output extInst;
    input  regmem_data;  
    input  datamem_data;
    input  pc_current;
    input  pc_next;
    input  regf1;
    input  regf2;
  endclocking
  
  //---------------------------------------
  //monitor clocking block
  //---------------------------------------
  clocking monitor_cb @(posedge clk);
    default input #1 output #1;
    input extInst;
    input  regmem_data;  
    input  datamem_data;
    input  pc_current;
    input  pc_next;
    input  regf1;
    input  regf2;  
  endclocking
  
  //---------------------------------------
  //driver modport
  //---------------------------------------
  modport DRIVER  (clocking driver_cb,input clk,rst);
  
  //---------------------------------------
  //monitor modport  
  //---------------------------------------
    modport MONITOR (clocking monitor_cb,input clk,rst);
  
endinterface  