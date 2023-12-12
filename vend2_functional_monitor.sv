// Class : VEND2 Functional Monitor
class vend2_functional_monitor extends uvm_monitor;

  virtual vend2_if.vend2_mon_mp mon_vif;
  vend2_seq_item packet;
  uvm_analysis_port #(vend2_seq_item) mon_ap;
  int txn_no = 0;

  reg [15:0] total = 0;
  reg [11:0] money_in = 0;
  bit rej_req;
  bit demote_incorrect_vend_ok;

  `uvm_component_utils(vend2_functional_monitor)

  //Constructor
  function new(string name = "functional_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db #(virtual vend2_if.vend2_mon_mp)::get(this, "*", "mon_vif", mon_vif)))
    begin
      `uvm_fatal(get_type_name, "Cant fetch mon_if from config_db")
    end
    mon_ap = new("mon_ap", this);
  endfunction : build_phase

  //Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    fork
      reset();
      check_total();
      detect_money_input();
      vend_action();
      cancel_action();
    join
  endtask: run_phase

  virtual task reset();
    forever
    begin
      @(negedge mon_vif.reset);
      if(mon_vif.total !== 0)
      begin
        `uvm_error("total_on_reset", "Total is not 0 post reset.")
      end
      else
      begin
        `uvm_info("total_on_reset", "Total is 0 on reset", UVM_HIGH)
      end
      total = 0;
      money_in = 0;
    end
  endtask : reset

  virtual task detect_money_input();
    forever
    begin
      @(posedge mon_vif.money_present);
      repeat(2) @(negedge mon_vif.clock);

      case(mon_vif.money_amount)
        0:;
        NICKLE:
          begin
            total = total + 1;
            money_in = money_in + 1;
          end
        DIME:
          begin
            total = total + 2;
            money_in = money_in + 2;
          end
        QUARTER:
          begin
            total = total + 5;
            money_in = money_in + 5;
          end
        HALF:
          begin
            total = total + 10;
            money_in = money_in + 10;
          end
        DOLLAR_COIN:
          begin
            total = total + 20;
            money_in = money_in + 20;
          end
        DOLLAR_BILL:
          begin
            total = total + 20;
            money_in = money_in + 20;
          end
        FIVE:
          begin
            total = total + 100;
            money_in = money_in + 100;
          end
        TEN:
          begin
            total = total + 200;
            money_in = money_in + 200;
          end
        TWENTY:
          begin
            total = total + 400;
            money_in = money_in + 400;
          end
        default:;
      endcase
    end
  endtask : detect_money_input

  virtual task check_total();
    forever
    begin
      @(posedge mon_vif.vend_request or posedge mon_vif.vend_idle);
      @(posedge mon_vif.clock);
      if(total !== mon_vif.total)
        `uvm_error("total_error", $sformatf("Total amount is incorrect. Actual:%0d | Expected:%0d",mon_vif.total, total))
      else
        `uvm_info("total_error", $sformatf("Total amount is correct. Actual:%0d | Expected:%0d",mon_vif.total, total), UVM_HIGH)
    end
  endtask : check_total

  virtual task vend_action();
    process p1, p2;
    forever
    begin
      @(posedge mon_vif.vend_request);
      fork
        begin
          p1 = process::self();
          @(posedge mon_vif.vend_ok)
          if(mon_vif.vend_amount > money_in)
          begin
            if(!demote_incorrect_vend_ok)`uvm_error("incorrect_vend_ok", $sformatf("Vend_OK detected when Vend_Amount > Money_In. Vend_Amount=%0d | Money_in=%0d", mon_vif.vend_amount, money_in))
            accept_money_return(0);
            if(rej_req) total = total - mon_vif.vend_amount;
          end
          else
          begin
            `uvm_info("incorrect_vend_ok", $sformatf("Vend_OK detected when Vend_Amount > Money_In. Vend_Amount=%0d | Money_in=%0d", mon_vif.vend_amount, money_in), UVM_HIGH)
            if(mon_vif.hopper_empty == '1) `uvm_error("hopper_error","Vend_ok asserted when hopper is empty") 
            if((money_in - mon_vif.vend_amount < 200) && (mon_vif.hopper_empty == 'hFF)) `uvm_error("hopper_error","Vend_ok asserted when hopper is empty") 
            total = total - mon_vif.vend_amount;
            if(mon_vif.vend_amount < money_in) accept_money_return(0);
          end
          rej_req = 0;
        end
        begin
          p2 = process::self();
          @(posedge mon_vif.vend_reject)
          rej_req = 1;
          if(mon_vif.vend_amount < money_in)
          begin
            `uvm_error("incorrect_vend_ok", $sformatf("Vend_OK detected when Vend_Amount > Money_In. Vend_Amount=%0d | Money_in=%0d", mon_vif.vend_amount, money_in))
            accept_money_return(1);
          end
        end
      join_any
      money_in = 0;
      if(p1.status == process::FINISHED) p2.kill();
      if(p2.status == process::FINISHED) p1.kill();
    end
  endtask : vend_action

  virtual task cancel_action();
    forever
    begin
      @(posedge mon_vif.vend_cancel);
      accept_money_return(0);
      money_in = 0;
    end
  endtask : cancel_action

  virtual task accept_money_return(bit req0_rej1);
    
    process p1,p2;

    fork
      begin
        p1 = process::self();
        @(posedge mon_vif.vend_idle);
      end
      begin
        p2 = process::self();
        forever 
        begin
          @(posedge mon_vif.money_return);
          case(mon_vif.return_amount)
            NICKLE:
              begin
                total = total - 1;
                if(mon_vif.hopper_empty[1] == 1) `uvm_error("hopper_error",$sformatf("NICKLE vended when hooper is empty"))
              end
            DIME:
              begin
                total = total - 2;
                if(mon_vif.hopper_empty[2] == 1) `uvm_error("hopper_error",$sformatf("DIME vended when hooper is empty"))
              end
            QUARTER:
              begin
                total = total - 5;
                if(mon_vif.hopper_empty[3] == 1) `uvm_error("hopper_error",$sformatf("QUARTER vended when hooper is empty"))
              end
            HALF:
              begin
                total = total - 10;
                if(mon_vif.hopper_empty[4] == 1) `uvm_error("hopper_error",$sformatf("HALF vended when hooper is empty"))
              end
            DOLLAR_COIN:
              begin
                total = total - 20;
                if(mon_vif.hopper_empty[5] == 1) `uvm_error("hopper_error",$sformatf("DOLLAR_COIN vended when hooper is empty"))
              end
            DOLLAR_BILL:
              begin
                total = total - 20;
                if(mon_vif.hopper_empty[6] == 1) `uvm_error("hopper_error",$sformatf("DOLLAR_BILL vended when hooper is empty"))
              end
            FIVE:
              begin
                total = total - 100;
                if(mon_vif.hopper_empty[7] == 1) `uvm_error("hopper_error",$sformatf("DOLLAR_BILL vended when hooper is empty"))
              end
            TEN:
              begin
                total = total - 200;
                if(mon_vif.hopper_empty[8] == 1) `uvm_error("hopper_error",$sformatf("TEN vended when hooper is empty"))
              end
            TWENTY:
              begin
                total = total - 400;
                if(mon_vif.hopper_empty[9] == 1) `uvm_error("hopper_error",$sformatf("TWENTY vended when hooper is empty"))
              end
            default:;
          endcase
        end
      end
    join_any
    p2.kill();
  endtask : accept_money_return

endclass : vend2_functional_monitor

