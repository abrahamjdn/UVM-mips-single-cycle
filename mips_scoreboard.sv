//-------------------------------------------------------------------------
//						mips_scoreboard - 
//-------------------------------------------------------------------------

class mips_scoreboard extends uvm_scoreboard;
  
  //---------------------------------------
  // declaring pkt_qu to store the pkt's recived from monitor
  //---------------------------------------
  mips_seq_item pkt_qu[$];
  
 //Aux variables
  logic [4:0] rt;
  logic [4:0] rs;
  logic [15:0] imm;
  logic [7:0] addr_mem;
  bit [31:0] mem [0:255];// 
  bit [31:0] reg_mem [0:31];// model reg file
  //R
  logic [4:0] rd;
  logic [4:0] shamt;
  logic [5:0] func;
  logic [31:0] y; //result variable
  //j
  logic [25:0] jta; //jump target address
  logic [31:0] pc_temp;
  
  //Report variables
  int R_T=0;
  int J_T=0;
  int BEQ_T=0;
  int BNE_T=0;
  int LW_T=0;
  int SW_T=0;
  int R_E=0;
  int J_E=0;
  int BEQ_E=0;
  int BNE_E=0;
  int LW_E=0;
  int SW_E=0;
  ;

  //---------------------------------------
  //port to recive packets from monitor
  //---------------------------------------
  uvm_analysis_imp#(mips_seq_item, mips_scoreboard) item_collected_export;
  `uvm_component_utils(mips_scoreboard)

  //---------------------------------------
  // new - constructor
  //---------------------------------------
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new
  //---------------------------------------
  // build_phase - create port and initialize local memory
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      item_collected_export = new("item_collected_export", this);
    foreach(mem[i]) mem[i] = i;// inicializar
    foreach(reg_mem[i]) reg_mem[i] = i;// inicializar
  endfunction: build_phase
  
  
  //---------------------------------------
  // write task - recives the pkt from monitor and pushes into queue
  //---------------------------------------
  virtual function void write(mips_seq_item pkt);
    //pkt.print();
    pkt_qu.push_back(pkt);
  endfunction : write

//---------------------------------------
  // run_phase - compare's the read data with the expected data(stored in local memory)
  // local memory will be updated on the write operation.
  //---------------------------------------
  virtual task run_phase(uvm_phase phase);
    mips_seq_item mips_pkt;
    
    forever begin
      wait(pkt_qu.size() > 0);
      mips_pkt = pkt_qu.pop_front();  
      
      case (mips_pkt.extInst[31:26])
////////////////////////////////R-type instructions ///////////////////////////       
        0:  begin  
          `uvm_info(get_type_name(),$sformatf("------ :: R-TYPE  :: ------"),UVM_LOW)   
                rs=mips_pkt.extInst[25:21];
                rt=mips_pkt.extInst[20:16];                
                rd=mips_pkt.extInst[15:11];
                shamt=mips_pkt.extInst[10:6];
                func=mips_pkt.extInst[5:0];
          
                case (func)
                  36: begin 
                    `uvm_info(get_type_name(),$sformatf("------ :: And :: ------"),UVM_LOW)
                    y = reg_mem[rs] & reg_mem[rt];
                  end
                  37:begin 
                    `uvm_info(get_type_name(),$sformatf("------ :: Or  :: ------"),UVM_LOW)
                    y = reg_mem[rs] | reg_mem[rt];
                  end
                  32:begin
                    `uvm_info(get_type_name(),$sformatf("------ :: Addition :: ------"),UVM_LOW)
                    y = reg_mem[rs] + reg_mem[rt];
                  end
                  34:begin 
                    `uvm_info(get_type_name(),$sformatf("------ :: Substraction  :: ------"),UVM_LOW)
                    y = reg_mem[rs] - reg_mem[rt];
                  end
                  42:begin
                    `uvm_info(get_type_name(),$sformatf("------ :: SLT  :: ------"),UVM_LOW)
                    y = reg_mem[rs] < reg_mem[rt] ? 1:0;
                  end
                  default: `uvm_info(get_type_name(),$sformatf("------ :: Error function code  :: ------"),UVM_LOW)
                endcase
          		reg_mem[rd]=y;
          		if(y ===mips_pkt.regmem_data) begin
                  `uvm_info(get_type_name(),$sformatf("------ :: Success  :: ------"),UVM_LOW)                 
          		end
                else begin
                  `uvm_error(get_type_name(),"------ :: Failure  :: ------")
                   R_E++;
                end
                 R_T++; `uvm_info(get_type_name(),$sformatf("Expected: %0d Actual: %0d",(y),mips_pkt.regmem_data),UVM_LOW)
        end
////////////////////////////////J-type instruction /////////////////////
                  ////// 
          2:  begin                 
            `uvm_info(get_type_name(),$sformatf("------ :: jump instruction  :: ------"),UVM_LOW)  
                  jta=mips_pkt.extInst[25:0];
          		  pc_temp=mips_pkt.pc_current+1;
          		  y={pc_temp[31:28],jta};
          		if(y==mips_pkt.pc_next) begin
                  `uvm_info(get_type_name(),$sformatf("------ :: Success  :: ------"),UVM_LOW)
                end
                else begin
          `uvm_error(get_type_name(),"------ :: Failure  :: ------")
                   J_E++;
                end
           	J_T++; `uvm_info(get_type_name(),$sformatf("Expected: %0d Actual: %0d",(y),mips_pkt.pc_next),UVM_LOW)
        end
////////////////////////////////beq instruction /////////////////////////// 
        4:  begin                 
          `uvm_info(get_type_name(),$sformatf("------ :: I-TYPE  :: ------"),UVM_LOW)  
          `uvm_info(get_type_name(),$sformatf("------ :: beq Instruction  :: ------"),UVM_LOW) 
                imm =mips_pkt.extInst[15:0];
                rt=mips_pkt.extInst[20:16];
                rs=mips_pkt.extInst[25:21]; 
                if(reg_mem[rs]==reg_mem[rt]) begin                
                  y = mips_pkt.pc_current + 1 + {{16{imm[15]}},imm};
                end         
                else begin
                  y = mips_pkt.pc_current + 1;
                end
                if(y==mips_pkt.pc_next) begin
                  `uvm_info(get_type_name(),$sformatf("------ :: Success  :: ------"),UVM_LOW)
                end
                else begin
                     BEQ_E++;       `uvm_error(get_type_name(),"------ :: Failure  :: ------")
                end
           	BEQ_T++; `uvm_info(get_type_name(),$sformatf("Expected: %0d Actual: %0d",(y),mips_pkt.pc_next),UVM_LOW)
        end
                  
////////////////////////////////bne instruction /////////////////////////// 
        5:  begin   
          `uvm_info(get_type_name(),$sformatf("------ :: I-TYPE  :: ------"),UVM_LOW)  
          `uvm_info(get_type_name(),$sformatf("------ :: bne Instruction  :: ------"),UVM_LOW) 
                imm =mips_pkt.extInst[15:0];
                rt=mips_pkt.extInst[20:16];
                rs=mips_pkt.extInst[25:21]; 
                if(reg_mem[rs]!=reg_mem[rt]) begin                
                  y = mips_pkt.pc_current + 1 + {{16{imm[15]}},imm};
                end         
                else begin
                  y = mips_pkt.pc_current + 1;
                end
                if(y==mips_pkt.pc_next) begin
                   `uvm_info(get_type_name(),$sformatf("------ :: Success  :: ------"),UVM_LOW)
                end
                else begin
                      BNE_E++;         `uvm_error(get_type_name(),"------ :: Failure  :: ------")
                end
           BNE_T++; `uvm_info(get_type_name(),$sformatf("Expected: %0d Actual: %0d",(y),mips_pkt.pc_next),UVM_LOW)
        end
                  
////////////////////////////////lw instruction /////////////////////////// 
        35: begin								         
          `uvm_info(get_type_name(),$sformatf("------ :: I-TYPE  :: ------"),UVM_LOW)  
          `uvm_info(get_type_name(),$sformatf("------ :: lw Instruction  :: ------"),UVM_LOW) 
                imm =mips_pkt.extInst[15:0];
                rt=mips_pkt.extInst[20:16];
                rs=mips_pkt.extInst[25:21];
                addr_mem=reg_mem[rs]+{{16{imm[15]}},imm};
                reg_mem[rt]=mem[addr_mem];
                $writememb("regMem2.txt", reg_mem);
                if(reg_mem[rt]==mips_pkt.regmem_data) begin
                   `uvm_info(get_type_name(),$sformatf("------ :: Success  :: ------"),UVM_LOW) 
                  end
                  else begin
                    LW_E++;
                    `uvm_error(get_type_name(),"------ :: Failure  :: ------")
                  end
          LW_T++;
          `uvm_info(get_type_name(),$sformatf("Expected: %0d Actual: %0d",reg_mem[rt],mips_pkt.regmem_data),UVM_LOW)
        end
////////////////////////////////sw instruction /////////////////////////// 
        43: begin									
          `uvm_info(get_type_name(),$sformatf("------ :: I-TYPE  :: ------"),UVM_LOW)  
          `uvm_info(get_type_name(),$sformatf("------ :: sw Instruction  :: ------"),UVM_LOW) 
                imm=mips_pkt.extInst[15:0];
                rt=mips_pkt.extInst[20:16];
                rs=mips_pkt.extInst[25:21];
                addr_mem=reg_mem[rs]+{{16{imm[15]}},imm};
                mem[addr_mem]=reg_mem[rt];
                $writememb("data_mem2.txt", mem);
                if(mem[addr_mem]==mips_pkt.datamem_data) begin
                   `uvm_info(get_type_name(),$sformatf("------ :: Success  :: ------"),UVM_LOW)
                  end
                  else begin
                    SW_E++;
                      `uvm_error(get_type_name(),"------ :: Failure  :: ------")
                  end
          SW_T++;
          `uvm_info(get_type_name(),$sformatf("Expected: %0d Actual: %0d",mem[addr_mem],mips_pkt.datamem_data),UVM_LOW)
        end

        default:  $display("INSTRUCTION ERROR."); 
        
    endcase
    end
  endtask : run_phase
    task stats;
      $display("\n--------------------------------------------");
      $display("------[Scoreboard statistics]------");
      $display("- Total instructions: %0d", R_T+J_T+BEQ_T+BNE_T+LW_T+SW_T);
      $display("- Total instructions with success: %0d", R_T+J_T+BEQ_T+BNE_T+LW_T+SW_T-(R_E+J_E+BEQ_E+BNE_E+LW_E+SW_E));
      $display("- Total failures found: %0d", R_E+J_E+BEQ_E+BNE_E+LW_E+SW_E);
      $display("- R-Type instructions with success: %0d Errors: %0d", R_T-R_E,R_E);
      $display("- J-instructions with success: %0d Errors: %0d", J_T-J_E,J_E);
      $display("- BEQ-instructions with success: %0d Errors: %0d", BEQ_T-BEQ_E,BEQ_E);
      $display("- BNE-instructions with success: %0d Errors: %0d", BNE_T-BNE_E,BNE_E);
      $display("- LW-instructions with success: %0d Errors: %0d", LW_T-LW_E,LW_E);
      $display("- SW-instructions with success: %0d Errors: %0d", SW_T-SW_E,SW_E);
    $display("--------------------------------------------\n");
  endtask
  
  
endclass : mips_scoreboard    