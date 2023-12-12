// Class : VEND2 Sequence Item(Packet Class)

typedef enum bit [1:0] {RESET, VEND, CANCEL} action_e;
typedef enum bit [3:0] {BAD, NICKLE, DIME, QUARTER, HALF, DOLLAR_COIN, DOLLAR_BILL, FIVE, TEN, TWENTY} money_amount_e;

class vend2_seq_item extends uvm_sequence_item;

   //Rand variables
   rand action_e action;
   rand bit [11:0] money_in;
   rand money_amount_e money_amount[];
   rand bit [15:0] hopper;
   rand bit [11:0] vend_amount;


   rand bit [11:0] num_bad;
   rand bit [11:0] num_nickles;
   rand bit [11:0] num_dime;
   rand bit [11:0] num_quarter;
   rand bit [11:0] num_half;
   rand bit [11:0] num_dollar_coin;
   rand bit [11:0] num_dollar_bill;
   rand bit [11:0] num_five;
   rand bit [11:0] num_ten;
   rand bit [11:0] num_twenty;
   rand bit [11:0] total_money;

   //Non_Rand Variable
   real amount;

  //UVM Automation Macro
  `uvm_object_utils_begin(vend2_seq_item)
    `uvm_field_enum(action_e, action, UVM_DEFAULT)
    `uvm_field_int(money_in, UVM_DEFAULT | UVM_DEC)
    `uvm_field_array_enum(money_amount_e, money_amount, UVM_ALL_ON)
    `uvm_field_real(amount, UVM_DEFAULT)
    `uvm_field_int(hopper, UVM_DEFAULT)
    `uvm_field_int(vend_amount, UVM_DEFAULT | UVM_DEC)
  `uvm_object_utils_end
  
  //-------------------------------------------------------------------------------- 
  // Constraints
  //-------------------------------------------------------------------------------- 

  constraint amount_in_nickles
  {
    money_in == num_nickles + num_dime*2 + num_quarter*5 + num_half*10 + num_dollar_coin*20 + num_dollar_bill*20 + num_five*100 + num_ten*200 + num_twenty*400;
    action == RESET -> money_in == 0;
  }

  constraint money_amount_size
  {
    total_money == num_bad + num_nickles + num_dime + num_quarter + num_half + num_dollar_coin + num_dollar_bill + num_five + num_ten + num_twenty;
    money_amount.size == total_money;
  }

  constraint reasonable_money
  {
    num_bad inside {[0:5]};
  }


  //-------------------------------------------------------------------------------- 
  // Functions//
  //-------------------------------------------------------------------------------- 

  //Constructor
  function new(string name = "vend2_seq_item");
    super.new(name);
    amount = 0;
  endfunction : new

  //Pre Randomize
  function void pre_randomize();
    super.pre_randomize();
  endfunction : pre_randomize

  //Post Randomize
  function void post_randomize();
    super.post_randomize();
    amount = (money_in * 5.0)/100.0;

    for(int idx = 0; idx < money_amount.size; idx++)
    begin
      for(int idx_2 = 0; idx_2 < num_bad; idx_2++) money_amount[idx++] = BAD;
      for(int idx_2 = 0; idx_2 < num_nickles; idx_2++) money_amount[idx++] = NICKLE;
      for(int idx_2 = 0; idx_2 < num_dime; idx_2++) money_amount[idx++] = DIME;
      for(int idx_2 = 0; idx_2 < num_quarter; idx_2++) money_amount[idx++] = QUARTER;
      for(int idx_2 = 0; idx_2 < num_half; idx_2++) money_amount[idx++] = HALF;
      for(int idx_2 = 0; idx_2 < num_dollar_coin; idx_2++) money_amount[idx++] = DOLLAR_COIN;
      for(int idx_2 = 0; idx_2 < num_dollar_bill; idx_2++) money_amount[idx++] = DOLLAR_BILL;
      for(int idx_2 = 0; idx_2 < num_five; idx_2++) money_amount[idx++] = FIVE;
      for(int idx_2 = 0; idx_2 < num_ten; idx_2++) money_amount[idx++] = TEN;
      for(int idx_2 = 0; idx_2 < num_twenty; idx_2++) money_amount[idx++] = TWENTY;
    end
    money_amount.shuffle();
  
  endfunction : post_randomize

  function void calculate_amount();
    num_bad=0;
    num_nickles=0;
    num_dime=0;
    num_quarter=0;
    num_half=0;
    num_dollar_coin=0;
    num_dollar_bill=0;
    num_five=0;
    num_ten=0;
    num_twenty=0;
    total_money=0;

    foreach(money_amount[i])
    begin
      case(money_amount[i])
        BAD: num_bad++; 
        NICKLE: num_nickles++;
        DIME: num_dime++;
        QUARTER: num_quarter++;
        HALF: num_half++;
        DOLLAR_COIN: num_dollar_coin++;
        DOLLAR_BILL: num_dollar_bill++;
        FIVE: num_five++;
        TEN: num_ten++;
        TWENTY:num_twenty++;
      endcase
    end

    money_in = num_nickles + num_dime*2 + num_quarter*5 + num_half*10 + num_dollar_coin*20 + num_dollar_bill*20 + num_five*100 + num_ten*200 + num_twenty*400;
    total_money = num_bad + num_nickles + num_dime + num_quarter + num_half + num_dollar_coin + num_dollar_bill + num_five + num_ten + num_twenty;
    amount = (money_in * 5.0)/100.0;
  
  endfunction : calculate_amount
 
endclass : vend2_seq_item

