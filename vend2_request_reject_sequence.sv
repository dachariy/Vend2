// Class : VEND2 Reject Request Sequence
class vend2_reject_request_sequence extends vend2_sequence;

  int num_txns;

  `uvm_object_utils(vend2_reject_request_sequence)

  //Constructor
  function new(string name = "vend2_reject_request_sequence");
    super.new(name);

    if(!$value$plusargs("NUM_TXNS=%d", num_txns))
    begin
      num_txns = 1;
    end
  
  endfunction : new

  //PRE_BODY
  virtual task pre_body();
    super.pre_body();

  endtask : pre_body

  virtual task body();
  
    for(int indx = 0; indx < num_txns; indx++)
    begin
      `uvm_info(get_type_name(), $sformatf("Sending Transaction # %0d", indx+1), UVM_MEDIUM)
      `uvm_do_with(req, {req.action == VEND; req.money_in == 200; vend_amount == 2000;})
      `uvm_do_with(req, {req.action == VEND; req.money_in == 0; vend_amount == 100;})
      `uvm_do_with(req, {req.action == VEND; req.money_in == 0; vend_amount == 100;})
    end
  
  endtask: body

endclass : vend2_reject_request_sequence
