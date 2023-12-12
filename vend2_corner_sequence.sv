// Class : VEND2 Corner Sequence
class vend2_corner_sequence extends uvm_sequence # (vend2_seq_item);

  int num_txns;

  `uvm_object_utils(vend2_corner_sequence)

  //Constructor
  function new(string name = "vend2_corner_sequence");
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
      `uvm_do_with(req, {req.action == VEND; req.money_in == 0;})
      `uvm_do_with(req, {req.action == VEND; req.money_in == 4095; vend_amount == 4095;})
    end
  
  endtask: body

endclass : vend2_corner_sequence
