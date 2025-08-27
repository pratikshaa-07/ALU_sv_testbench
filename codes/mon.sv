
`include"def.sv"
class monitor;

  trans mtrans;
  mailbox #(trans) mb_ms;
  virtual inf vif;

  int i;
  bit go;

//COVERAGE

  covergroup mcg;
    RES   : coverpoint mtrans.RES    { bins result  = {[0:255]}; }
    E     : coverpoint mtrans.E      { bins equal   = {0,1}; }
    L     : coverpoint mtrans.L      { bins less    = {0,1}; }
    G     : coverpoint mtrans.G      { bins greater = {0,1}; }
    COUT  : coverpoint mtrans.COUT   { bins cout    = {0,1}; }
    OFLOW : coverpoint mtrans.OFLOW  { bins oflow   = {0,1}; }
    ERR   : coverpoint mtrans.ERR    { bins error   = {0,1}; }
  endgroup

  function new(mailbox #(trans) mb_ms, virtual inf vif);
    this.mb_ms = mb_ms;
    this.vif   = vif;
    mcg=new();
  endfunction

  task start();
    repeat(2) @(posedge vif.mcb);

    for (i = 0; i < `no_of_transactions; i++) begin
      mtrans = new();
      go = 0;
      repeat (1) @(posedge vif.mcb);

      // Wait for INP_VALID == 3
      if ((vif.MODE &&( vif.INP_VALID != 3 && vif.INP_VALID !=0)  && vif.CMD inside {0,1,2,3,8,9,10}) ||
          (!vif.MODE && (vif.INP_VALID != 3 && vif.INP_VALID !=0) && vif.CMD inside {0,1,2,3,4,5,12,13}))
      begin
          repeat (16) @(posedge vif.mcb)
          begin
         if (vif.INP_VALID == 3) begin
              $display("[MONITOR-%0d] %0t Looping FOUND",i+1,$time);
            go = 1;
            break;
          end
       end
     end
      else begin
        go = 1;
      end
      // Wait for operation cycles
      if (go) begin
        if (vif.MODE && vif.CMD inside {9,10} && vif.INP_VALID==3)  // multiplication
        begin
            repeat (2) @(posedge vif.mcb);
        end
        else
        begin
          repeat (1) @(posedge vif.mcb);
      end
      end
      else
      begin
        repeat (1) @(posedge vif.mcb);
      end

      // capture the output after proper wait
      mtrans.RES   = vif.mcb.RES;
      mtrans.COUT  = vif.mcb.COUT;
      mtrans.E     = vif.mcb.E;
      mtrans.L     = vif.mcb.L;
      mtrans.G     = vif.mcb.G;
      mtrans.OFLOW = vif.mcb.OFLOW;
      mtrans.ERR   = vif.mcb.ERR;

      $display("\n[MONITOR-%0d] Passing data to Scoreboard at %0t",i+1, $time);
      $display("THE INPUTS : CE=%0d | MODE=%0d | INP_VALID=%0d | CMD=%0d | OPA=%0d | OPB=%0d | CIN=%0d",vif.CE,vif.MODE,vif.INP_VALID,vif.CMD,vif.OPA,vif.OPB,vif.CIN);
      $display("THE OUTPUT : RESULT = %0d | COUT = %0d | OFLOW = %0d | E = %0d | L = %0d | G = %0d | ERR = %0d", mtrans.RES, mtrans.COUT, mtrans.OFLOW, mtrans.E, mtrans.L, mtrans.G, mtrans.ERR);

    mb_ms.put(mtrans.copy());
    mcg.sample();
    $display("[MONITOR-%0d] Functional coverage for current transaction %0d",i+1,i+1);
    $display("FUNCTIONAL COVERAGE = %.2f%%",mcg.get_coverage());
    end
  endtask
endclass

