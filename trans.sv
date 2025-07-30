`include"def.sv"
class trans;
  rand logic [1:0] INP_VALID;
  randc logic MODE;
  randc logic CE;
  rand logic CIN;
  rand logic [`op_len-1:0] OPA, OPB;
  rand logic [`cmd_len-1:0] CMD;

  logic [`op_len:0] RES;
  logic ERR, L, G, E, COUT, OFLOW;

 /* constraint c1 {
   // CMD inside {0};
   // MODE == 1;
   // INP_VALID == 3;
  }*/

  virtual function trans copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass

// Arithmetic mode
class trans1 extends trans;

  constraint c2 {
    CE == 1'b1;
    MODE == 1'b1;
    CMD inside {[0:10]};
  }
  virtual function trans1 copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass

// MODE = 0
class trans2 extends trans;

  constraint c3 {
    MODE == 0;
    CMD inside {[0:13]};
  }

  virtual function trans2 copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass
// MODE=1, CMD=11 to 15
class trans3 extends trans;

  constraint c4 {
    CE == 1;
    MODE == 1;
    CMD inside {[11:15]};
  }

  virtual function trans3 copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass

// Corner case-2 MODE=0 CMD=14,15
class trans4 extends trans;

  constraint c5 {
    MODE == 1'b0;
    CMD inside {14,15};
    CE == 1;
  }

  virtual function trans4 copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass

// Corner case-3 MODE=1, INP_VALID=00
class trans5 extends trans;

  constraint c6 {
    INP_VALID == 2'b00;
    CMD inside {[0:13]};
  }

  virtual function trans5 copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass

// Corner case-4 MODE=1, INP_VALID=01 (A valid)
class trans6 extends trans;

  constraint c7 {
    MODE == 1'b1;
    INP_VALID == 2'b01;
    CMD inside {0,1,2,3,6,7,8,9,10};
  }

  virtual function trans6 copy();
   copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass

// Corner case-5 MODE=1, INP_VALID=10 (B valid)
class trans7 extends trans;

  constraint c8 {
    MODE == 1'b1;
    INP_VALID == 2;
    CMD inside {0,1,2,3,4,5,8,9,10};
  }

  virtual function trans7 copy();
    copy = new();
    copy.INP_VALID = this.INP_VALID;
    copy.MODE = this.MODE;
    copy.CE = this.CE;
    copy.CIN = this.CIN;
    copy.OPA = this.OPA;
    copy.OPB = this.OPB;
    copy.CMD = this.CMD;
    copy.G = this.G;
    copy.L = this.L;
    copy.E = this.E;
    copy.RES = this.RES;
    copy.ERR = this.ERR;
    copy.COUT = this.COUT;
    copy.OFLOW = this.OFLOW;
    return copy;
  endfunction
endclass
