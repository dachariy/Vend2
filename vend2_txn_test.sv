// Class : VEND2 TXN TEST
class vend2_txn_test extends vend2_base_test;

  `uvm_component_utils(vend2_txn_test)

  vend2_reset_sequence reset_seq;
  vend2_sequence test_seq;

  //Constructor
  function new(string name = "vend2_txn_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if($test$plusargs("CANCEL_TEST"))
    begin
      vend2_sequence::type_id::set_type_override(vend2_cancel_sequence::get_type());
    end
    else if($test$plusargs("REJECT_TEST"))
    begin
      vend2_sequence::type_id::set_type_override(vend2_reject_sequence::get_type());
    end

  endfunction : build_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);

    reset_seq = vend2_reset_sequence::type_id::create("reset_seq", this);
    test_seq = vend2_sequence::type_id::create("test_seq", this);

    reset_seq.start(env.agent.sequencer);
    test_seq.start(env.agent.sequencer);

    phase.drop_objection(this);
 endtask: run_phase

endclass : vend2_txn_test
