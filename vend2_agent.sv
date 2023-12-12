// Class : VEND2 Agent
class vend2_agent extends uvm_agent;
  `uvm_component_utils(vend2_agent)
  
  uvm_sequencer # (vend2_seq_item) sequencer;
  vend2_driver driver;
  vend2_functional_monitor functional_monitor;
  vend2_timing_monitor timing_monitor;

  //Constructor 
  function new(string name = "agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new 

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    functional_monitor = vend2_functional_monitor::type_id::create("functional_monitor", this);
    timing_monitor = vend2_timing_monitor::type_id::create("timing_monitor", this);
    driver = vend2_driver::type_id::create("driver", this);
    sequencer = uvm_sequencer#(vend2_seq_item)::type_id::create("sequencer", this);
  endfunction : build_phase

  //Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction : connect_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase

endclass : vend2_agent
