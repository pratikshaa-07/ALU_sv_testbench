`include "def.sv"

class scb;
  trans trans_ref, trans_mon;
  mailbox #(trans) mb_rs;
  mailbox #(trans) mb_ms;

  int MATCH = 0;
  int MISMATCH = 0;

  function new(mailbox #(trans) mb_rs, mailbox #(trans) mb_ms);
    this.mb_rs = mb_rs;
    this.mb_ms = mb_ms;
  endfunction

task start();
  for (int i = 0; i < `no_of_transactions; i++)
  begin
    fork
      begin
      mb_rs.get(trans_ref);
      $display("-----------SCOREBOARD[%0t] RECIVED REFERENCE MODEL OUTPUT [%0t]--------",i+1,$time);
      $display("REF MODEL OUTPUT  SCOREBOARD => RES = %0d | E = %0b | G = %0b | L = %0b | COUT = %0b | ERR = %0b | OFLOW = %0b",
                            trans_ref.RES, trans_ref.E, trans_ref.G, trans_ref.L, trans_ref.COUT, trans_ref.ERR, trans_ref.OFLOW);
      end

      begin
      mb_ms.get(trans_mon);
      $display("-----------SCOREBOARD-%0d RECIVED MONITOR OUTPUT [%0t]---------------",i+1,$time);
      $display("MONITOR OUTPUT SCOREBOARD  => RES = %0d | E = %0b | G = %0b | L = %0b | COUT = %0b | ERR = %0b | OFLOW = %0b",
                         trans_mon.RES, trans_mon.E, trans_mon.G, trans_mon.L, trans_mon.COUT, trans_mon.ERR, trans_mon.OFLOW);
      end
    join
    if ((trans_ref.RES   === trans_mon.RES)   && (trans_ref.E    ===   trans_mon.E)     &&   (trans_ref.G    ===   trans_mon.G)     && (trans_ref.L    ===   trans_mon.L)     &&
       (trans_ref.COUT  ===   trans_mon.COUT)  &&(trans_ref.ERR   ===   trans_mon.ERR)   && (trans_ref.OFLOW ===   trans_mon.OFLOW))
   begin
      MATCH++;  $display("EXPECTED RESULT MATCHES ACTUAL RESULT FOR TRANSACTION - %0d",i+1);
    end
    else begin
      MISMATCH++;
      $display("EXPECTED RESULT DOES NOT MATCH ACTUAL RESULT FOR TRANSACTION - %0d",i+1);

      //checking for mismatched fields
      if (trans_ref.RES !== trans_mon.RES)
        $display("  MISMATCH in RES    : REF = %0d, DUT = %0d", trans_ref.RES, trans_mon.RES);
      if (trans_ref.E !== trans_mon.E)
        $display("  MISMATCH in E      : REF = %0d, DUT = %0d", trans_ref.E, trans_mon.E);
      if (trans_ref.G !== trans_mon.G)
      $display("  MISMATCH in G      : REF = %0d, DUT = %0d", trans_ref.G, trans_mon.G);
      if (trans_ref.L !== trans_mon.L)
        $display("  MISMATCH in L      : REF = %0d, DUT = %0d", trans_ref.L, trans_mon.L);
      if (trans_ref.COUT !== trans_mon.COUT)
        $display("  MISMATCH in COUT   : REF = %0d, DUT = %0d", trans_ref.COUT, trans_mon.COUT);
      if (trans_ref.ERR !== trans_mon.ERR)
        $display("  MISMATCH in ERR    : REF = %0d, DUT = %0d", trans_ref.ERR, trans_mon.ERR);
      if (trans_ref.OFLOW !== trans_mon.OFLOW)
        $display("  MISMATCH in OFLOW  : REF = %0d, DUT = %0d", trans_ref.OFLOW, trans_mon.OFLOW);
    end
  $display("----------------------------COMPLETION OF %0d  TRANSACTION AT %0t----------------------------------",i+1,$time);
  end
  $display("\n*********************** SCOREBOARD SUMMARY ************************");
  $display("TOTAL MATCH    = %0d", MATCH);
  $display("TOTAL MISMATCH = %0d", MISMATCH);
endtask
endclass
