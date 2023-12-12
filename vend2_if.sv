interface vend2_if(input clock);
  reg reset;
  reg money_present;
  reg [3:0] money_amount;
  reg vend_idle;
  reg money_return;
  reg [3:0] return_amount;
  reg return_complete;
  reg vend_request;
  reg [11:0] vend_amount;
  reg vend_ok;
  reg vend_reject;
  reg vend_complete;
  reg vend_cancel;
  reg cancel_complete;
  reg [15:0] hopper_empty;
  reg [15:0] total;

  modport vend2_drv_mp( input clock, 
                        output reset,
                        output money_present,
                        output money_amount,
                        input  vend_idle,
                        input  money_return,
                        input  return_amount,
                        output return_complete,
                        output vend_request,
                        output vend_amount,
                        input  vend_ok,
                        input  vend_reject,
                        output vend_complete,
                        output vend_cancel,
                        input  cancel_complete,
                        output hopper_empty,
                        input  total);

  modport vend2_mon_mp( input clock,
                        input reset,
                        input money_present,
                        input money_amount,
                        input vend_idle,
                        input money_return,
                        input return_amount,
                        input return_complete,
                        input vend_request,
                        input vend_amount,
                        input vend_ok,
                        input vend_reject,
                        input vend_complete,
                        input vend_cancel,
                        input cancel_complete,
                        input hopper_empty,
                        input total);

endinterface : vend2_if
