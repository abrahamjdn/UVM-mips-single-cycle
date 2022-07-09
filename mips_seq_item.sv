//-------------------------------------------------------------------------
//						mem_seq_item - www.verificationguide.com 
//-------------------------------------------------------------------------

class mips_seq_item extends uvm_sequence_item;
  //---------------------------------------
  //data and control fields
  //---------------------------------------
    rand bit [31:0] extInst;
  	randc bit [5:0] opcode;
    randc bit [5:0] funct;
    rand bit [4:0] rd;
    rand bit [4:0] rs;
    rand bit [4:0] rt;
    rand bit [15:0] imm;
    rand bit [4:0] shamt;
    rand bit [25:0] jta;
    bit [31:0] regmem_data;
  	bit [31:0] datamem_data;
    bit [31:0] pc_current;
  	bit [31:0] pc_next;
  	bit [31:0] regf1;
  	bit [31:0] regf2;  

   //constraints
  constraint opcode_const {opcode inside{0, 2, 4, 5, 35, 43};} //r,jump,beq,bne,lw,sw  ***************
    constraint rd_const {rd inside {[2:25]};}
    constraint rs_const {rs inside {[2:25]};}
    constraint rt_const {rt inside {[2:25]};}
  	constraint imm_const {imm inside {[4:2**16-1]};}
  	constraint jta_const {jta inside {[4:2**26-1]};}
  	constraint shamt_const {shamt == 5'b00000;}
    constraint funct_type_r {
      (opcode == 0) -> funct inside {32,34,36,37,42}; //add,sub,and,or,slt
    }
    constraint type_func{
      (opcode == 0) -> extInst == {opcode, rs, rt, rd, shamt, funct};
      (opcode == 2) -> extInst == {opcode, jta};
      (opcode inside {4, 5, 35, 43}) -> extInst =={opcode, rs, rt, imm[15:0]};    
    }
  
  //---------------------------------------
  //Utility and Field macros
  //---------------------------------------
  `uvm_object_utils_begin(mips_seq_item)
    `uvm_field_int(extInst,UVM_ALL_ON)
    `uvm_field_int(regmem_data,UVM_ALL_ON)
    `uvm_field_int(datamem_data,UVM_ALL_ON)
    `uvm_field_int(pc_current,UVM_ALL_ON)
    `uvm_field_int(pc_next,UVM_ALL_ON)
    `uvm_field_int(regf1,UVM_ALL_ON)
    `uvm_field_int(regf2,UVM_ALL_ON)
    `uvm_object_utils_end    
  
  //---------------------------------------
  //Constructor
  //---------------------------------------
  function new(string name = "mips_seq_item");
    super.new(name);
  endfunction

   function void display(string name);
     $display("\n----------------------------------------------------------------------------------------------------------");
          `uvm_info(get_type_name(),$sformatf("- Instruction = %32b", extInst),UVM_LOW)
     case (extInst[31:26])
      0:          `uvm_info(get_type_name(),$sformatf("opcode= %6b rs= %5b rt= %5b rd= %5b shamt= %5b funct= %6b",extInst[31:26],extInst[25:21], extInst[20:16], extInst[15:11], extInst[10:6], extInst[5:0]),UVM_LOW)
        
       2:
                  `uvm_info(get_type_name(),$sformatf("opcode= %6b jta= %26b",extInst[31:26],extInst[25:0]),UVM_LOW)

       default: `uvm_info(get_type_name(),$sformatf("opcode= %6b rs= %5b rt= %5b imm= %16b ",extInst[31:26],extInst[25:21], extInst[20:16], extInst[15:0]),UVM_LOW) 

     endcase

  endfunction

endclass  