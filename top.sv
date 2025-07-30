`include "dut.v"
`include "pkg.sv"
`include "inf.sv"

module top();

  import alu_pkg::*;

  bit CLK = 0;
  bit RST = 0;

  initial begin
    forever #10 CLK = ~CLK;
  end


  initial begin
    RST = 1;
    repeat(1) @(posedge CLK);
    RST = 0;
  end

  // intface
  inf tinf(CLK, RST);
//dut
  ALU_DESIGN DUV (
    .INP_VALID(tinf.INP_VALID),
    .OPA(tinf.OPA),
    .OPB(tinf.OPB),
    .CIN(tinf.CIN),
    .CLK(CLK),
    .RST(RST),
    .CMD(tinf.CMD),
    .CE(tinf.CE),
    .MODE(tinf.MODE),
    .COUT(tinf.COUT),
    .OFLOW(tinf.OFLOW),
    .RES(tinf.RES),
    .G(tinf.G),
    .E(tinf.E),
    .L(tinf.L),
    .ERR(tinf.ERR)
  );

  // Test class
  test tb = new(tinf.DRV, tinf.MON, tinf.REF);
  test1 tb1 = new(tinf.DRV, tinf.MON, tinf.REF);
  test2 tb2 = new(tinf.DRV, tinf.MON, tinf.REF);
  test3 tb3 = new(tinf.DRV, tinf.MON, tinf.REF);
  test4 tb4 = new(tinf.DRV, tinf.MON, tinf.REF);
  test5 tb5 = new(tinf.DRV, tinf.MON, tinf.REF);
  test6 tb6 = new(tinf.DRV, tinf.MON, tinf.REF);
  test7 tb7 = new(tinf.DRV, tinf.MON, tinf.REF);
  treg  tbr = new(tinf.DRV, tinf.MON, tinf.REF);


  initial begin
    $display("-------------------------------------------THE RISE OF THE PROCESS------------------------------------------------------------");
    tb.start();
    tb1.start();
    tb2.start();
    tb3.start();
    tb4.start();
    tb5.start();
    tb6.start();
    tb7.start();
    tbr.start();

    #10000;
    $display("-------------------------------------------THE END OF THE PROCESS--------------------------------------------------------------");
    $finish;
  end

endmodule
