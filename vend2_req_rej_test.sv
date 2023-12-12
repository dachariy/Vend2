// Class : VEND2 TXN TEST
class vend2_req_rej_test extends vend2_base_test;

  `uvm_component_utils(vend2_req_rej_test)

  vend2_reset_sequence reset_seq;
  vend2_reject_request_sequence test_seq;

  //Constructor
  function new(string name = "vend2_req_rej_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    env.agent.functional_monitor.demote_incorrect_vend_ok = 1;

    phase.raise_objection(this);

    reset_seq = vend2_reset_sequence::type_id::create("reset_seq", this);
    test_seq = vend2_reject_request_sequence::type_id::create("reset_seq", this);

    reset_seq.start(env.agent.sequencer);
    test_seq.start(env.agent.sequencer);
    #500us;

    phase.drop_objection(this);
 endtask: run_phase

endclass : vend2_req_rej_test
