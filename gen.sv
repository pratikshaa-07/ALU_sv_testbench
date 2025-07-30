`include"def.sv"

class generator;
trans blueprint;
mailbox #(trans)mb_gd;

function  new (mailbox #(trans)mb_gd);
    this.mb_gd=mb_gd;
    blueprint=new();
endfunction

task start();
    $display("--------------GENERATOR---------------");
    for(int i=0;i<`no_of_transactions;i++)
    begin
        if(blueprint.randomize())
            $display("Randomizing the fields");
        else
            $fatal("couldn't randomize!!");
        mb_gd.put(blueprint.copy());
        $display("Generated: CE=%0d | MODE=%0d | INP_VALID=%0d | OPA=%0d |  OPB=%0d | CIN=%0d | CMD=%0d",blueprint.CE,blueprint.MODE,blueprint.INP_VALID,blueprint.OPA,blueprint.OPB,blueprint.CIN,blueprint.CMD);
    end
endtask
endclass
