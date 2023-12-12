// Class : VEND2 Driver
class vend2_driver extends uvm_driver # (vend2_seq_item);

  virtual vend2_if.vend2_drv_mp drv_vif;
  vend2_seq_item packet;

  `uvm_component_utils(vend2_driver)

  //Constructor
  function new(string name = "vend2_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db #(virtual vend2_if.vend2_drv_mp)::get(this, "*", "drv_vif", drv_vif)))
    begin
      `uvm_fatal(get_type_name, "Cant fetch drv_if from config_db")
    end
  endfunction : build_phase

  //Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever
    begin
      seq_item_port.get_next_item(packet);

      packet.print();

      if(packet.action == RESET)    //RESET action sequence
      begin
        @(posedge drv_vif.clock);
        drv_vif.reset = 1;
        drv_vif.money_present = 0;
        drv_vif.money_amount = 0;
        drv_vif.return_complete = 0;
        drv_vif.vend_request = 0;
        drv_vif.vend_amount = 0;
        drv_vif.vend_complete = 0;
        drv_vif.vend_cancel = 0;
        drv_vif.hopper_empty = 0;

        @(posedge drv_vif.clock);
        drv_vif.reset = 0;
      end
      else  //VEND or CANCEL action sequence
      begin
        foreach(packet.money_amount[i])   //VEND or CANCEL action sequence
        begin
          wait(drv_vif.vend_idle == 1);
          repeat(5) @(posedge drv_vif.clock);
          drv_vif.money_amount = packet.money_amount[i];
          drv_vif.money_present = 0;
          repeat(10)begin  //wait 10 clocks before the money_present signal goes high
            @(posedge drv_vif.clock);
          end

          drv_vif.money_present = 1;
          repeat(20)begin  //the money_present signal stay high for 20 clocks
            @(posedge drv_vif.clock);
          end

          drv_vif.money_present = 0;
          repeat(10)
          begin  //the money_amount must not change for at least 10 clocks
            @(posedge drv_vif.clock);
          end
        end
      end

      if(packet.action == CANCEL) cancel_action();
      if(packet.action == VEND) vend_action();

      seq_item_port.item_done();
    end

  endtask: run_phase


  //vend cancel function
  task cancel_action();
    wait(drv_vif.vend_idle == 1);
    drv_vif.vend_cancel = 1;
    wait(drv_vif.vend_idle == 0);
    return_action();
    wait(drv_vif.cancel_complete == 1);
    drv_vif.vend_cancel = 0;
  endtask : cancel_action


  //vend function
  task vend_action();
      wait(drv_vif.vend_idle == 1);
      drv_vif.vend_amount = packet.vend_amount;
      drv_vif.vend_request = 0;
      repeat(10)begin  //the vend_amount must be present at least 10 clocks before the vend_request goes high.
          @(posedge drv_vif.clock);
      end
      drv_vif.vend_request = 1;

      wait(drv_vif.vend_ok == 1 || drv_vif.vend_reject == 1);

      //the vend_request signal must go low within 2 clocks.
      repeat(2) @(posedge drv_vif.clock);
      drv_vif.vend_request = 0;
      
      drv_vif.vend_complete =1;
      repeat(10)@(posedge drv_vif.clock);
      drv_vif.vend_complete =0;	    
      
      //if(packet.money_in > packet.vend_amount) 
      //begin
        return_action();
      //end     
  endtask : vend_action


  //vend return function
  task return_action();
    process p1,p2;
    fork  
      begin
        p1 = process::self();
        wait(drv_vif.vend_idle == 1);
      end
      begin
        p2 = process::self();
        forever
        begin
          wait(drv_vif.money_return == 1);
          drv_vif.return_complete = 1; 
          wait(drv_vif.money_return == 0);
          @(posedge drv_vif.clock);     
          drv_vif.return_complete = 0;
        end
      end
    join_any
    if(p2 != null) p2.kill();
  endtask : return_action



endclass : vend2_driver

