// Class : VEND2 Random TEST
class vend2_random_test extends vend2_base_test;

  `uvm_component_utils(vend2_random_test)


  vend2_reset_sequence          reset_sequence;
  vend2_sequence                txn_sequence;
  vend2_cancel_sequence         cancel_sequence;
  vend2_corner_sequence         corner_sequence;
  vend2_reject_sequence         reject_sequence;
  vend2_reject_request_sequence request_reject_sequence;
  vend2_request_sequence        request_sequence;
  
  int num_txns;

  //Constructor
  function new(string name = "vend2_random_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);

    bit [2:0] sel;

    super.run_phase(phase);

    if(!$value$plusargs("NUM_TXNS=%d", num_txns))
    begin
      num_txns = $urandom_range(10,20);
    end

    phase.raise_objection(this);

    reset_sequence = vend2_reset_sequence::type_id::create("reset_sequence",this);
    txn_sequence = vend2_sequence::type_id::create("txn_sequence",this);
    cancel_sequence = vend2_cancel_sequence::type_id::create("cancel_sequence",this);
    corner_sequence = vend2_corner_sequence::type_id::create("corner_sequence",this);
    reject_sequence = vend2_reject_sequence::type_id::create("reject_sequence",this);
    request_reject_sequence = vend2_reject_request_sequence::type_id::create("request_reject_sequence",this);
    request_sequence = vend2_request_sequence::type_id::create("request_sequence",this);

    txn_sequence.num_txns = 1;
    cancel_sequence.num_txns = 1; 
    corner_sequence.num_txns = 1;
    reject_sequence.num_txns = 1;
    request_reject_sequence.num_txns = 1; 
    request_sequence.num_txns = 1;

    reset_sequence.start(env.agent.sequencer);

    for(int indx = 0; indx < num_txns; indx++)
    begin
      
      sel = $urandom_range(0,6);

      case(sel)
        0 : reset_sequence.start(env.agent.sequencer);
        1 : txn_sequence.start(env.agent.sequencer); 
        //2 : cancel_sequence.start(env.agent.sequencer); 
        3 : corner_sequence.start(env.agent.sequencer); 
        4 : reject_sequence.start(env.agent.sequencer); 
        5 : request_reject_sequence.start(env.agent.sequencer); 
        6 : request_sequence.start(env.agent.sequencer); 
      endcase
    end

    phase.drop_objection(this);
 endtask: run_phase

endclass : vend2_random_test
