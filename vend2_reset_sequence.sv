// Class : VEND2 reset Sequence
class vend2_reset_sequence extends uvm_sequence # (vend2_seq_item);

  int txn_no;

  `uvm_object_utils(vend2_reset_sequence)

  //Constructor
  function new(string name = "vend2_reset_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_do_with(req, {req.action == RESET;})
  endtask: body

endclass : vend2_reset_sequence
