`timescale 1ns/100ps

`include "vend2_if.sv"

package vend2_hw;
  import uvm_pkg::*;
  `include "vend2_seq_item.sv"
  `include "vend2_reset_sequence.sv"
  `include "vend2_sequence.sv"
  `include "vend2_cancel_sequence.sv"
  `include "vend2_reject_sequence.sv"
  `include "vend2_request_sequence.sv"
  `include "vend2_request_reject_sequence.sv"
  `include "vend2_corner_sequence.sv"
  `include "vend2_driver.sv"
  `include "vend2_functional_monitor.sv"
  `include "vend2_timing_monitor.sv"
  `include "vend2_agent.sv"
  `include "vend2_scoreboard.sv"
  `include "vend2_env.sv"
  `include "vend2_base_test.sv"
  `include "vend2_txn_test.sv"
  `include "vend2_req_rej_test.sv"
  `include "vend2_corner_value_test.sv"
  `include "vend2_random_test.sv"
endpackage

module top();
  import uvm_pkg::*;

  reg clk;

  // Interface instance
  vend2_if vend2_vif(clk);

  // DUT instance
  vend2 dut(.clock(vend2_vif.clock),
            .reset(vend2_vif.reset),
            .money_present(vend2_vif.money_present),
            .money_amount(vend2_vif.money_amount),
            .vend_idle(vend2_vif.vend_idle),
            .money_return(vend2_vif.money_return),
            .return_amount(vend2_vif.return_amount),
            .return_complete(vend2_vif.return_complete),
            .vend_request(vend2_vif.vend_request),
            .vend_amount(vend2_vif.vend_amount),
            .vend_ok(vend2_vif.vend_ok),
            .vend_reject(vend2_vif.vend_reject),
            .vend_complete(vend2_vif.vend_complete),
            .vend_cancel(vend2_vif.vend_cancel),
            .cancel_complete(vend2_vif.cancel_complete),
            .hopper_empty(vend2_vif.hopper_empty),
            .total(vend2_vif.total)
);

  // Pass config_db and start test.
  initial 
  begin
    uvm_config_db #(virtual vend2_if.vend2_drv_mp)::set(null, "*", "drv_vif", vend2_vif.vend2_drv_mp);
    uvm_config_db #(virtual vend2_if.vend2_mon_mp)::set(null, "*", "mon_vif", vend2_vif.vend2_mon_mp);
    run_test("vend2_base_test");
  end

  //Generate Clk
  initial
  begin
    clk = 0;
    forever 
    begin 
      #50ns clk = ~clk;
    end
  end

  //Wavedump
  initial
  begin
   if($test$plusargs("WAVE"))
   begin
     $dumpfile("waves.vcd");
     $dumpvars;
   end
  end

  initial
  begin
   if($test$plusargs("TIMEOUT"))
   begin
    #2000us;
    $finish;
   end
  end

endmodule : top

