`include "def.sv"

interface inf(input logic CLK, RST);

  logic [`op_len-1:0] OPA, OPB;
  logic MODE, CE, CIN;
  logic [`cmd_len-1:0] CMD;
  logic [1:0] INP_VALID;
  //logic valid_out;
  logic [`op_len:0] RES;
  logic ERR, L, G, E, COUT, OFLOW;

  clocking dcb @(posedge CLK);
    default input #0 output #0;
    input  CLK, RST;
    output OPA, OPB, MODE, CE, CIN, INP_VALID, CMD;
  endclocking

  clocking mcb @(posedge CLK);
    default input #0;
    input RES, ERR, L, G, E, COUT, OFLOW;
  endclocking

  clocking rcb @(posedge CLK);
    default input #0;
    input CLK, RST;
    input OPA, OPB, MODE, CE, CIN, INP_VALID, CMD;
    input RES, ERR, L, G, E, COUT, OFLOW;
  endclocking

  modport DRV (clocking dcb);
  modport MON (clocking mcb);
  modport REF (clocking rcb);
endinterface

//------------------------------------------------------------------------------------------------------------------------------------------------------------------------------//
//ASSERTIONS
  property p1;
  @(posedge CLK) disable iff (reset)
    !CE |=> (RES === 'z);
endproperty

assert property (p1)
  $info("CE=0 Assertion-1 Passed");
else
  $error("CE=0 Assertion-1 Failed");
*/
 /* property p2;
  @(posedge CLK);
 (INP_VALID==1) |-> !$isunknown(OPA);

   assert property (p2)
      $info("INP_VALID is 1 and OPA is not unknown Assertion-2  Passed");
   else
      $error("INP_VALID is 1 and OPA is not unknow Assertion-2 Failed");

  property p3;
  @(posedge CLK);
  (INP_VALID==2) |-> !$isunknown(OPB);

   assert property (p3)
      $info("INP_VALID is 2 and OPB is not unknown Assertion-3  Passed");
   else
      $error("INP_VALID is 2 and OPB is not unknow Assertion-3 Failed");

  property p4;
  @(posedge CLK);
   (INP_VALID==3) |-> (!$isunknown(OPA) && !$isunknown(OPB));

   assert property (p3)
      $info("INP_VALID is 3 and OPA and OPB is not unknown Assertion-4  Passed");
   else
      $error("INP_VALID is 3 and OPA and OPB is not unknow Assertion-4 Failed");

  property p5;
  @(posedge CLK);
   RST |-> (RES=='0 && E=0 && L=0 && G=0 && OFLOW=0 && COUT=0);

   assert property (p5)
      $info("RST condition Assertion-5  Passed");
   else
      $error("RST condition Assertion-5 Failed");

  property p6;
  @(posedge CLK);
   CMD inside {14,15} |-> (RES='z);

   assert property (p6)
      $info("Invalid CMD for both modes Assertion-6  Passed");
   else
      $error("Inavlid CMD for both modes Assertion-6 Failed");

  property p7;
  @(posedge CLK);
   (INP_VALID==3) |-> !$isunknown(CMD);

   assert property (p7)
  $info("INP_VALID is 3 and CMD is not unknown Assertion-7  Passed");
   else
      $error("INP_VALID is 3 and CMD is not unknow Assertion-7 Failed");
endinterface
