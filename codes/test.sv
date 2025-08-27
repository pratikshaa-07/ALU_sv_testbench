`include"def.sv"
class test;
  virtual inf dif;
  virtual inf mif;
  virtual inf rif;

  environment env;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    this.dif = dif;
    this.mif = mif;
    this.rif = rif;
  endfunction

  task start();
    env = new(dif, mif, rif);
    env.build();
    env.start();
  endtask
endclass

class test1 extends test;
trans1 trans_1;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
    env.build();
    begin
      trans_1 = new();
      env.gen.blueprint = trans_1; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass

class test2 extends test;
trans2 trans_2;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
                                                                               env.build();
    begin
      trans_2 = new();
      env.gen.blueprint = trans_2; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass

class test3 extends test;
trans3 trans_3;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
    env.build();
    begin
      trans_3 = new();
      env.gen.blueprint = trans_3; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass

class test4 extends test;
trans4 trans_4;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
    env.build();
    begin
      trans_4 = new();
      env.gen.blueprint = trans_4; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass

class test5 extends test;
trans5 trans_5;
  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
    env.build();
    begin
      trans_5 = new();
      env.gen.blueprint = trans_5; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass

class test6 extends test;
trans6 trans_6;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
    env.build();
    begin
      trans_6 = new();
      env.gen.blueprint = trans_6; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass

class test7 extends test;
trans1 trans_7;

  function new(virtual inf dif, virtual inf mif, virtual inf rif);
    super.new(dif, mif, rif);  // match parent constructor
  endfunction

  task start();
    env = new(dif, mif, rif);  // match expected arguments
    env.build();
    begin
      trans_7 = new();
      env.gen.blueprint = trans_7; // make sure gen and blueprint exist
    end
    env.start();
  endtask
endclass


class treg extends test;
 trans t0;
 trans1 t1;
 trans2 t2;
 trans3 t3;
 trans4 t4;
 trans5 t5;
 trans6 t6;
 trans7 t7;
  function new(virtual inf  dif,
               virtual inf  mif,
               virtual inf  rif);
    super.new(dif,mif,rif);
  endfunction

  task run();
    //$display("child test");
    env=new(dif,mif,rif);
    env.build();
///////////////////////////////////////////////////////
    begin
    t0 = new();
    env.gen.blueprint= t0;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    t1 = new();
    env.gen.blueprint= t1;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    t2 = new();
    env.gen.blueprint= t2;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
                                                               begin
    t3 = new();
    env.gen.blueprint= t3;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    t4 = new();
    env.gen.blueprint= t4;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    t5 = new();
    env.gen.blueprint= t5;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    t6 = new();
    env.gen.blueprint= t6;
    end
    env.start();
//////////////////////////////////////////////////////

///////////////////////////////////////////////////////
    begin
    t7 = new();
    env.gen.blueprint= t7;
    end
    env.start();
  endtask
endclass
                       
