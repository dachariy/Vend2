// Class : VEND2 Timing Monitor 
class vend2_timing_monitor extends uvm_monitor; 

  virtual vend2_if.vend2_mon_mp mon_vif;
  vend2_seq_item packet;
  uvm_analysis_port #(vend2_seq_item) mon_ap;
  int txn_no = 0;

  `uvm_component_utils(vend2_timing_monitor)

  //Constructor 
  function new(string name = "timing_monitor", uvm_component parent = null);
    super.new(name, parent);
    clocks = 0;
  endfunction : new 

  //Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db #(virtual vend2_if.vend2_mon_mp)::get(this, "*", "mon_vif", mon_vif)))
    begin
      `uvm_fatal(get_type_name, "Cant fetch mon_if from config_db")
    end
    mon_ap = new("mon_ap", this);
  endfunction : build_phase

  //Connect Phase
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction : connect_phase

//////////////////////////////////////////////////////////////////////////////////
  longint clocks;
  longint clk_money_amount;
  longint clk_money_present;
  reg [3:0] stable_money_amount = 0;
  longint clk_return_amount;
  longint clk_return_complete;
  longint clk_vend_amount;
  longint clk_vend_ok_rej;
  longint clk_low_ok_rej;
  longint clk_vend_request; 
  longint clk_money_am;
 
  //count clock cycles
  virtual task count_clock();
	  forever begin
		  @(posedge mon_vif.clock);
		  clocks++;	
	  end
  endtask : count_clock 
  
  //count money_amount clock  
  virtual task mon_money_amount();
	forever begin
		//The money_amount must be stable for at least 10 clocks before the money_present signal goes high.
		@(posedge mon_vif.money_amount);
		clk_money_amount = clocks; 
		@(negedge mon_vif.money_amount);
		if(clocks - clk_money_amount < 16'd10)begin
			`uvm_error("money_amount","money_amount stable for less than 10 clocks");
		end	
	end	
  endtask : mon_money_amount


  //count money_present clock  
  virtual task mon_money_present();
	forever begin
		//The money_present signal must be high for at least 20 clocks.
		@(posedge mon_vif.money_present);
		clk_money_present = clocks; 
		@(negedge mon_vif.money_present);
		if((clocks - clk_money_present) < 16'd20)begin
			`uvm_error("money_present","money_present stable for less than 20 clocks");
		end	
	end	
  endtask : mon_money_present
  
  
  //check money_amount stable for 10 clocks 
  virtual task check_money_amount();
	forever begin
		@(negedge mon_vif.money_present);
		@(posedge mon_vif.money_amount or negedge mon_vif.money_amount);
                clk_money_am = clocks;
		@(posedge mon_vif.money_amount or negedge mon_vif.money_amount);
		if(clocks - clk_money_am < 16'd10)begin
			`uvm_error("money_amount","money_amount stable for less than 10 clocks");
		end	
	end	
  endtask : check_money_amount
  
  
  //count return_amount clock  
  virtual task mon_return_amount();
	forever begin
		//The return_amount value must be present for at least 50 clocks before the money_return signal goes high.
		@(posedge mon_vif.return_amount);
		clk_return_amount = clocks; 
		@(posedge mon_vif.money_return);
		if(clocks - clk_return_amount < 16'd50)begin
			`uvm_error("return_amount","return_amount presents for less than 50 clocks");
		end	
	end	
  endtask : mon_return_amount
  
  
  //check money_return  
  virtual task mon_money_return();
	forever begin
		//The money_return signal must stay high until a return_complete signal goes high.
		forever begin
			@(posedge mon_vif.money_return);
			if(mon_vif.money_return == 0)begin
			`uvm_error("money_return","money_return goes low before return_complete goes high");
			end	
		end
		@(posedge mon_vif.return_complete);
		if(mon_vif.money_return == 1)begin
			`uvm_error("money_return","money_return stays high after return_complete goes high");
		end	
	end	
  endtask : mon_money_return
  
  
  //check return_complete  
  virtual task mon_return_complete();
	forever begin
		//The return_complete signal stays high until the money_return signal goes low.
		@(negedge mon_vif.money_return);
		if(mon_vif.return_complete !== 1)begin
			`uvm_error("return_complete","return_complete stays high after return_complete goes low");
		end	
	end	
  endtask : mon_return_complete
  
  
  //count vend_amount clock  
  virtual task mon_vend_amount();
	forever begin
		//The vend_amount must be present at least 10 clocks before the vend_request goes high..
		@(posedge mon_vif.vend_amount);
		clk_vend_amount = clocks; 
		@(posedge mon_vif.vend_request);
		if(clocks - clk_vend_amount < 16'd10)begin
			`uvm_error("vend_amount","vend_amount presents for less than 10 clocks");
		end	
	end	
  endtask : mon_vend_amount  
  

  //count vend_ok or vend_reject clock  
  virtual task mon_vend_ok_reject();
	forever begin
		//The DUT will send either a vend_ok signal, or a vend_reject signal within 150 clocks.
		@(posedge mon_vif.vend_request);
		clk_vend_ok_rej = clocks; 
		@(posedge mon_vif.vend_ok or posedge mon_vif.vend_reject);
		if(clocks - clk_vend_ok_rej > 16'd150)begin
			`uvm_error("vend_ok signal & vend_reject","vend_ok signal or vend_reject presents for more than 150 clocks");
		end
	end	
  endtask : mon_vend_ok_reject  

   virtual task mon_complete_vend_ok_reject();
	forever begin
		@(posedge mon_vif.vend_complete);
		clk_low_ok_rej = clocks;
		@(negedge mon_vif.vend_ok or negedge mon_vif.vend_reject);
		if(clocks - clk_low_ok_rej > 16'd2)begin
			`uvm_error("vend_ok signal & vend_reject","vend_ok signal or vend_reject stays high after vend_complete goes high");
		end
		
	end	
  endtask : mon_complete_vend_ok_reject  
  
  
  //count vend_request clock  
  virtual task mon_vend_request();
	forever begin
		//Upon receiving the vend_ok or vend_reject signals, the vend_request signal must go low within 2 clocks.
		@(posedge mon_vif.vend_ok or posedge mon_vif.vend_reject);
		clk_vend_request = clocks; 
		@(negedge mon_vif.vend_request);
		if(clocks - clk_vend_request > 16'd2)begin
			`uvm_error("vend_amount","vend_amount presents for less than 10 clocks");
		end	
	end	
  endtask : mon_vend_request  
  
  

//////////////////////////////////////////////////////////////////////////////////

  //Run Phase
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
	
	fork
		count_clock();
		mon_money_amount();
		mon_money_present();
		check_money_amount();
		mon_return_amount();
		mon_money_return();
		mon_return_complete();
		mon_vend_amount();
		mon_vend_ok_reject();
                mon_complete_vend_ok_reject();
		mon_vend_request();
		
	join

		
  endtask: run_phase

endclass : vend2_timing_monitor



