// Class : VEND2 Cancel Sequence
class vend2_cancel_sequence extends vend2_sequence;

  int num_txns;

  `uvm_object_utils(vend2_cancel_sequence)

  //Constructor
  function new(string name = "vend2_cancel_sequence");
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
  
    for(int indx = 0; indx < num_txns; indx++)
    begin
      `uvm_info(get_type_name(), $sformatf("Sending Transaction # %0d", indx+1), UVM_MEDIUM)
      `uvm_do_with(req, {req.action == CANCEL; req.money_in inside {[20:2000]}; req.vend_amount inside {[(money_in*8/10) : money_in]};})
    end
  
  endtask: body

endclass : vend2_cancel_sequence
