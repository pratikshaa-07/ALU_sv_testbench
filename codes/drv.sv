`include "def.sv"
class driver;
  trans dtrans;
  mailbox #(trans) mb_gd;
  mailbox #(trans) mb_dr;
  virtual inf vif;
  bit got, want;

//COVERAGE

covergroup dcg;
  CE:       coverpoint dtrans.CE   { bins ce[]={0,1};}
  CMD:      coverpoint dtrans.CMD  { bins cmd[]={[0:13]};}
  CIN:      coverpoint dtrans.CIN  { bins cin ={0,1};}
  OPA:      coverpoint dtrans.OPA  { bins opa={[0:255]};}
  OPB:      coverpoint dtrans.OPB  { bins opb={[0:255]};}
  INP_VALID:coverpoint dtrans.INP_VALID { bins inp_valid[]={[0:3]};}
  MODE:     coverpoint dtrans.MODE { bins mode[]={0,1};}

  MODE_and_CMD:
  cross CMD, MODE {
  bins mode0_cmd = binsof(CMD) intersect {[0:13]} && binsof(MODE) intersect {0};
  bins mode1_cmd = binsof(CMD) intersect {[0:10]} && binsof(MODE) intersect {1};

  ignore_bins invalid_cmd_mode0 = binsof(CMD) intersect {[14:15]} && binsof(MODE) intersect {0};
  ignore_bins invalid_cmd_mode1 = binsof(CMD) intersect {[11:15]} && binsof(MODE) intersect {1};
  }

  IN_and_CMD:
  cross CMD,INP_VALID,MODE {
  bins inp3_cmd_mode1  = binsof(CMD) intersect {0,1,2,3,8,9,10} && binsof (MODE) intersect {1} &&  binsof (INP_VALID) intersect {3};
  bins inp3_cmd_mode0  = binsof(CMD) intersect {0,1,2,3,4,5,12,13} && binsof (MODE) intersect {0} && binsof (INP_VALID) intersect {3};

  bins inp1_cmd_mode1  = binsof(CMD) intersect {4,5} && binsof (MODE) intersect {1} && binsof (INP_VALID) intersect {1};
  bins inp1_cms_mode0  = binsof(CMD) intersect {6,8,9} && binsof (MODE) intersect {0} && binsof (INP_VALID) intersect {1};

  bins inp2_cms_mode0  = binsof(CMD) intersect {6,7} && binsof (MODE) intersect {1} && binsof (INP_VALID) intersect {2};
  bins inp2_cmd_mode1  = binsof(CMD) intersect {7,10,11} && binsof (MODE) intersect {0} && binsof (INP_VALID) intersect {2};

  }

endgroup

  function new(mailbox #(trans) mb_gd, mailbox #(trans) mb_dr, virtual inf vif);
    this.mb_gd = mb_gd;
    this.mb_dr = mb_dr;
    this.vif   = vif;
    dcg=new();
  endfunction

  task start();
  repeat(2)@(posedge vif.dcb);
    for (int i = 0; i < `no_of_transactions; i++)
    begin
      $display("----------------DRIVER-%0d DRIVING AT %0t------------------",i+1, $time);

      dtrans = new();
      mb_gd.get(dtrans);
      want=0;
     if (dtrans.MODE && (dtrans.CMD inside {0, 1, 2, 3, 8, 9, 10}))
                 want = 1;
     else if (!dtrans.MODE && (dtrans.CMD inside {0, 1, 2, 3, 4, 5, 12, 13}))
                 want = 1;

      vif.CE        <= dtrans.CE;
      vif.INP_VALID <= dtrans.INP_VALID;
      vif.CMD       <= dtrans.CMD;
      vif.MODE      <= dtrans.MODE;
      vif.OPA       <= dtrans.OPA;
      vif.OPB       <= dtrans.OPB;
      vif.CIN       <= dtrans.CIN;
      $display("[DRIVER-%0d] [%0t] Sent To DUT",i+1,$time);
     repeat (1) @(vif.dcb);
      mb_dr.put(dtrans.copy());
      $display("\n[DRIVER-%0d] Sent to Reference Model %0t",i+1, $time);
      $display("OPA=%0d | OPB=%0d | CIN=%0d | CMD=%d | INP_VALID=%0d | MODE=%0d | CE=%0d",dtrans.OPA, dtrans.OPB,dtrans.CIN, dtrans.CMD, dtrans.INP_VALID, dtrans.MODE,dtrans.CE);
      if (dtrans.CE)
      begin
        if (want && (dtrans.INP_VALID != 2'b11 && dtrans.INP_VALID!=2'b00))
        begin
          got = 0;

          for (int j = 0; j < 16; j++)
          begin
            $display("[DRIVER-%0d]Inside 16 clk cycle finding the one at %0t - %0d",i+1,$time,j+1);
            dtrans.CMD.rand_mode(0);
            @(vif.dcb);

            dtrans.randomize() with {
              CE   == dtrans.CE;
              MODE == dtrans.MODE;
            };

            vif.CE        <= dtrans.CE;
            vif.MODE      <= dtrans.MODE;
            vif.CMD       <= dtrans.CMD;
            vif.OPA       <= dtrans.OPA;
            vif.OPB       <= dtrans.OPB;
            vif.CIN       <= dtrans.CIN;
            vif.INP_VALID <= dtrans.INP_VALID;
         
            if (dtrans.INP_VALID == 2'b11)
            begin
              got = 1;
              break;
            end
          end
          if(got)
              $display("[DRIVER-%0d] RECIVED proper INP_VALID=%0d  for MODE=%0d | CMD=%0d | OPA=%0d | OPB=%0d | CIN=%0d at %0t",i+1,dtrans.INP_VALID,dtrans.MODE,dtrans.CMD,dtrans.OPA,
          dtrans.OPB,dtrans.CIN,$time);
          else
             $display("[DRIVER-%0d] NOT RECIVED proper INP_VALID=%0d  for MODE=%0d | CMD=%0d %0t",i+1,dtrans.INP_VALID,dtrans.MODE,dtrans.CMD,$time);
         repeat(1)@(vif.dcb);
         mb_dr.put(dtrans.copy());
        end
      end
   if(dtrans.CMD inside {9,10} && dtrans.INP_VALID==3 && dtrans.MODE)
       repeat(2)@(vif.dcb);
   else
       repeat(1)@(vif.dcb);
  dcg.sample();
  $display("[DRIVER-%0d] Functional Coverage for current transaction %0d",i+1,i+1);
  $display("FUNCTIONAL COVERAGE = %.2f%%",dcg.get_coverage());
  end
  endtask
endclass
