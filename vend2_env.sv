// Class : VEND2 ENV
class vend2_env extends uvm_env;
  `uvm_component_utils(vend2_env)

  vend2_agent agent;
  vend2_scoreboard scbd;

  //Constructor 
  function new(string name = "env", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new 

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = vend2_agent::type_id::create("agent", this);
    scbd  = vend2_scoreboard::type_id::create("scbd", this);
  endfunction : build_phase

  //Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //agent.monitor.mon_ap.connect(scbd.ap_imp);
  endfunction : connect_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask: run_phase

endclass : vend2_env
