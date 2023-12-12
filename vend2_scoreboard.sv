// VEND2 Scoreboard
class vend2_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(vend2_scoreboard)

  uvm_analysis_imp #(vend2_seq_item, vend2_scoreboard) ap_imp;

  function new(string name = "vend2_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    ap_imp = new("ap_imp", this);
  endfunction : build_phase

  function void write(vend2_seq_item packet);
  endfunction : write

endclass : vend2_scoreboard

