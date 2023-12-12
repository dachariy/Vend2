// Class : VEND2 TEST
class vend2_base_test extends uvm_test;

  `uvm_component_utils(vend2_base_test)

  vend2_env env;
  //Constructor
  //
  function new(string name = "vend2_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = vend2_env::type_id::create("env", this);
  endfunction : build_phase

  //Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction : end_of_elaboration_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Starting Run_Phase", UVM_NONE)
 endtask: run_phase

 function void report_phase(uvm_phase phase);
   
   uvm_report_server svr;
   super.report_phase(phase);
   svr = uvm_report_server::get_server();

   if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) + svr.get_severity_count(UVM_WARNING) > 0)
    `uvm_info("final_phase", "TEST_RESULT: FAIL", UVM_LOW)
   else
    `uvm_info("final_phase", "TEST_RESULT: PASS", UVM_LOW)

endfunction : report_phase

endclass : vend2_base_test
