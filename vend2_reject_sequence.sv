// Class : VEND2 Reject Sequence
class vend2_reject_sequence extends vend2_sequence;

  int num_txns;

  `uvm_object_utils(vend2_reject_sequence)

  //Constructor
  function new(string name = "vend2_reject_sequence");
    super.new(name);

    if(!$value$plusargs("NUM_TXNS=%d", num_txns))
    begin
      num_txns = $urandom_range(5,10);
    end
  endfunction : new

  //PRE_BODY
  virtual task pre_body();
    super.pre_body();
  endtask : pre_body

  virtual task body();
  
    int indx;
    bit [1:0] sel;

    for(int indx = 0; indx < num_txns; indx++)
    begin
      
      sel = $urandom_range(0,3);

      case(sel)
        // Vend Amount > Money In
        0:
        begin
          `uvm_info(get_type_name(), $sformatf("Sending Transaction # %0d", indx+1), UVM_MEDIUM)
          `uvm_info(get_type_name(), $sformatf("Scenario : Vend_Amount > Money_In"), UVM_MEDIUM)
          `uvm_do_with(req, {action == VEND; money_in inside {[20:2000]}; vend_amount > money_in;})
        end
  
        // Money In = 0; Vend amount > 0
        1:
        begin
          `uvm_info(get_type_name(), $sformatf("Sending Transaction # %0d", indx+1), UVM_MEDIUM)
          `uvm_info(get_type_name(), $sformatf("Scenario : Money_In = 0; Vend_Amount > 0"), UVM_MEDIUM)
          `uvm_do_with(req, {req.action == VEND; req.money_in == 0; req.vend_amount > req.money_in;})
          indx++;
        end
  
        // Hopper Empty
        2:
        begin
          `uvm_info(get_type_name(), $sformatf("Sending Transaction # %0d", indx+1), UVM_MEDIUM)
          `uvm_info(get_type_name(), $sformatf("Scenario : Hopper_Empty = '1"), UVM_MEDIUM)
          `uvm_do_with(req, {req.action == VEND; req.money_in inside {[20:2000]}; req.vend_amount inside {[(money_in*8/10) : money_in]};req.hopper == '1; })
          indx++;
        end

        //Appropriate change not available
        3:
        begin
          `uvm_info(get_type_name(), $sformatf("Sending Transaction # %0d", indx+1), UVM_MEDIUM)
          `uvm_info(get_type_name(), $sformatf("Scenario : Appropriate Change not Available"), UVM_MEDIUM)
          `uvm_do_with(req, {req.action == VEND; req.money_in inside {[20:2000]}; req.vend_amount < (req.money_in-200) ;req.hopper == 16'h00FF; })
          indx++;
        end
      endcase
    end
  endtask: body

endclass : vend2_reject_sequence
