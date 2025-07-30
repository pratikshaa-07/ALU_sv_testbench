`include"def.sv"
class environment;
//handles of all comp
  generator gen;
  driver    drv;
  monitor   mon;
  reference ref_mod;
  scb       sb;

//virtual
  virtual inf dif;
  virtual inf mif;
  virtual inf rif;

//mailbox
  mailbox #(trans) mb_gd;
  mailbox #(trans) mb_dr;
  mailbox #(trans) mb_ms;
  mailbox #(trans) mb_rs;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    this.dif = dif;
    this.mif = mif;
    this.rif = rif;
  endfunction

  task build();
    begin
      mb_gd = new();
      mb_dr = new();
      mb_ms = new();
      mb_rs = new();

      gen     = new(mb_gd);
      drv     = new(mb_gd,mb_dr,dif);
      mon     = new(mb_ms, mif);
      ref_mod = new(mb_dr, mb_rs, rif);
      sb      = new(mb_rs, mb_ms);
    end
  endtask

  task start();

    fork
      gen.start();
      drv.start();
  mon.start();
      ref_mod.start();
      sb.start();
    join
  endtask
endclass
