`include "def.sv"

class reference;

  trans rtrans;
  mailbox #(trans) mb_dr;
  mailbox #(trans) mb_rs;
  virtual inf vif;
  logic [8:0]store;
  logic e;
  logic g;
  logic l;
  logic oflow;
  logic cout;

  bit is_mul;
  bit got;
  localparam bits_req = $clog2(`op_len);
  bit [bits_req-1:0] shift_val;

  function new(mailbox #(trans) mb_dr, mailbox #(trans) mb_rs, virtual inf vif);
    this.mb_dr = mb_dr;
    this.mb_rs = mb_rs;
    this.vif   = vif;
  endfunction

  task start();
    for (int i = 0; i < `no_of_transactions; i++) begin
//      rtrans = new();
      mb_dr.get(rtrans);
       $display("[REFERENCE MODEL-%0d] GOT PACKET at %0t: CE=%0d | INP_VALID=%0d | CMD=%0d | OPA =%0d | OPB =%0d  | MODE=%0d ",i+1,$time,rtrans.CE,rtrans.INP_VALID, rtrans.CMD,
           rtrans.OPA,rtrans.OPB,rtrans.MODE);
      shift_val = rtrans.OPB[bits_req-1:0];
      is_mul = 0;

      rtrans.COUT  = 'z;
      rtrans.OFLOW = 'z;
      rtrans.E     = 'z;
      rtrans.G     = 'z;
      rtrans.L     = 'z;
      rtrans.ERR   = 'z;
      //rtrans.RES   = 'z;

      if (vif.RST || (rtrans.CE==0) ) begin
          $display("INSIDE RST or CE");
          if(vif.RST)
          begin
        rtrans.RES   ='0;
        rtrans.L     = 0;
        rtrans.G     = 0;
        rtrans.E     = 0;
        rtrans.COUT  = 0;
        rtrans.OFLOW = 0;
        rtrans.ERR   = 0;
        got = 0;
       end
      else if(rtrans.CE==0)
          begin
          rtrans.RES=store;
          rtrans.G=g;
          rtrans.E=e;
          rtrans.L=l;
          rtrans.OFLOW=oflow;
          rtrans.COUT=cout;
          end
      end

      else if(rtrans.CE==0)
      begin
          $diplay("inside ce=0");
          rtrans.RES=store;
          rtrans.G=g;
          rtrans.E=e;
          rtrans.L=l;
          rtrans.OFLOW=oflow;
          rtrans.COUT=cout;
      end
      else if ((rtrans.MODE == 1 && !(rtrans.CMD inside {0,1,2,3,4,5,6,7,8,9,10})) ||
              (rtrans.MODE == 0 && !(rtrans.CMD inside {0,1,2,3,4,5,6,7,8,9,10,11,12,13}))) begin
        rtrans.ERR = 1;
        got = 0;
       end
      else if ((rtrans.MODE  && (rtrans.CMD inside {0,1,2,3,8,9,10}) && (!rtrans.CE==0) && (rtrans.INP_VALID != 2'b11 && rtrans.INP_VALID!=2'b00)  ||
               (!rtrans.MODE && (rtrans.CMD inside {0,1,2,3,4,5,12,13}) && (rtrans.CE==0) &&( rtrans.INP_VALID!=2'b00 && rtrans.INP_VALID != 2'b11)))) begin
          got = 0;
        repeat (16) @(posedge vif.rcb) begin
          mb_dr.get(rtrans);
          if (rtrans.INP_VALID == 2'b11) begin
            got = 1;
            break;
          end
        end
      end
      else begin
        got = 1;
  end

      if (got && (rtrans.CE!=0))
      begin
        if (rtrans.MODE) begin
          case (rtrans.INP_VALID)
            2'b01: begin
              case (rtrans.CMD)
                4'd4: rtrans.RES = rtrans.OPA + 1;
                4'd5: begin  rtrans.RES = rtrans.OPA - 1;end
                default: rtrans.RES = 'z;
              endcase
            end

            2'b10: begin
              case (rtrans.CMD)
                4'd6: rtrans.RES = rtrans.OPB + 1;
                4'd7: rtrans.RES = rtrans.OPB - 1;
                default: rtrans.RES = 'z;
              endcase
            end

            2'b11: begin
              case (rtrans.CMD)
                  4'd4:begin  rtrans.RES = rtrans.OPA + 1; rtrans.ERR='z;rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; end
                  4'd5:begin  rtrans.RES = rtrans.OPA - 1;rtrans.E='z; rtrans.ERR='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; end
                  4'd6:begin rtrans.RES = rtrans.OPB + 1;rtrans.E='z;rtrans.L='z; rtrans.ERR='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; end
                  4'd7:begin rtrans.RES = rtrans.OPB - 1;rtrans.E='z;rtrans.L='z;rtrans.G='z; rtrans.ERR='z;rtrans.OFLOW='z;rtrans.COUT='z; end
                4'd0: begin
                  rtrans.RES = rtrans.OPA + rtrans.OPB;
                   rtrans.COUT = rtrans.RES[`op_len]; rtrans.ERR='z;
                   rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;
                end
                4'd1: begin
                  rtrans.RES = rtrans.OPA - rtrans.OPB;
                  rtrans.COUT = (rtrans.OPA < rtrans.OPB); rtrans.ERR='z;
                  rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;
                end
                4'd2: begin
                  rtrans.RES = rtrans.OPA + rtrans.OPB + rtrans.CIN;
                  rtrans.COUT = rtrans.RES[`op_len]; rtrans.ERR='z;
                  rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;
                end
                4'd3: begin
                  rtrans.RES = rtrans.OPA - rtrans.OPB - rtrans.CIN;
                  rtrans.COUT = (rtrans.OPA >= (rtrans.OPB + rtrans.CIN));
                  rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z; rtrans.ERR='z;
                end
                4'd8: begin
                    $display("COMPARISION");
                    if (rtrans.OPA > rtrans.OPB) begin
                        rtrans.G = 1;
                        rtrans.E ='z;
                        rtrans.L ='z;
                        rtrans.RES='z;
                        rtrans.ERR='z;
                        rtrans.OFLOW='z;rtrans.COUT='z;
                    end
                    else if(rtrans.OPA < rtrans.OPB) begin
                        rtrans.L = 1;
                        rtrans.G ='z;
                        rtrans.E ='z;
                        rtrans.RES='z;
                        rtrans.ERR='z;
                        rtrans.OFLOW='z;rtrans.COUT='z;
                    end
                    else begin
                        rtrans.E = 1;
                        rtrans.G ='z;
                        rtrans.L ='z;
                        rtrans.RES='z;
                        rtrans.ERR='z;
                        rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z;
                    end
                end
                4'd9: begin
                  rtrans.RES = (rtrans.OPA + 1) * (rtrans.OPB + 1);
                  is_mul = 1;
                  rtrans.E='z;rtrans.L='z;rtrans.G='z;
                  rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z;
                end
                4'd10: begin
                  rtrans.RES = (rtrans.OPA << 1) * rtrans.OPB;
                  is_mul = 1;
                  rtrans.E='z;rtrans.L='z;rtrans.G='z;
                  rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z;
                end
                default: rtrans.RES = 'z;
              endcase
            end
            2'b00: begin
                   rtrans.ERR=1;
                   rtrans.RES=store;
                   rtrans.E=e;
                   rtrans.G=g;
                   rtrans.L=l;
                   end
            default: rtrans.RES = 'z;
          endcase

        end else begin : mode0_block
          case (rtrans.INP_VALID)
            2'b01: begin
              case (rtrans.CMD)
                4'd6: rtrans.RES ={1'b0, ~rtrans.OPA};
                4'd8: rtrans.RES ={1'b0, rtrans.OPA >> 1};
                4'd9: rtrans.RES ={1'b0, rtrans.OPA << 1};
                default: rtrans.RES = 'z;
              endcase
            end

            2'b10: begin
              case (rtrans.CMD)
                4'd7: rtrans.RES ={1'b0, ~rtrans.OPB};
                4'd10: rtrans.RES = {1'b0,rtrans.OPB >> 1};
                4'd11: rtrans.RES = {1'b0,rtrans.OPB << 1};
                default: rtrans.RES = 'z;
              endcase
            end

            2'b11: begin
              case (rtrans.CMD)
                  4'd6:begin  rtrans.RES = {1'b0,~rtrans.OPA};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                              rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z;
                          end
                  4'd8:begin  rtrans.RES = {1'b0,rtrans.OPA >> 1};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                              rtrans.OFLOW='z;rtrans.COUT='z;  rtrans.ERR='z;
                          end
                  4'd9:begin  rtrans.RES = {1'b0,rtrans.OPA << 1};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                              rtrans.OFLOW='z;rtrans.COUT='z;  rtrans.ERR='z;
                          end
                  4'd7:begin  rtrans.RES = {1'b0,~rtrans.OPB};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                              rtrans.OFLOW='z;rtrans.COUT='z;  rtrans.ERR='z;
                          end
                  4'd10:begin rtrans.RES = {1'b0,rtrans.OPB >> 1};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                              rtrans.OFLOW='z;rtrans.COUT='z;  rtrans.ERR='z;
                          end
                  4'd11:begin rtrans.RES = {1'b0,rtrans.OPB << 1};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                             rtrans.OFLOW='z;rtrans.COUT='z;  rtrans.ERR='z;
                          end
                  4'd0:begin rtrans.RES = {1'b0,rtrans.OPA & rtrans.OPB};
                             rtrans.E='z;rtrans.L='z;rtrans.G='z;
                             rtrans.OFLOW='z;rtrans.COUT='z;  rtrans.ERR='z;
                         end
                  4'd1:begin  rtrans.RES = {1'b0, ~(rtrans.OPA & rtrans.OPB)};
                              rtrans.E='z;rtrans.L='z;rtrans.G='z;
                              rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z;
                          end
                  4'd2:begin rtrans.RES = {1'b0,rtrans.OPA | rtrans.OPB};rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z; end
                  4'd3:begin rtrans.RES = {1'b0,~(rtrans.OPA | rtrans.OPB)};rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z; end
                  4'd4:begin rtrans.RES = {1'b0,rtrans.OPA ^ rtrans.OPB};rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z; end
                  4'd5:begin rtrans.RES = {1'b0,~(rtrans.OPA ^ rtrans.OPB)};rtrans.E='z;rtrans.L='z;rtrans.G='z;rtrans.OFLOW='z;rtrans.COUT='z; rtrans.ERR='z; end
                  4'd12:begin
                  if (|rtrans.OPB[`op_len-1:bits_req]) begin
                    rtrans.ERR = 1;
                    rtrans.RES = 0;
                    rtrans.E='z;rtrans.L='z;rtrans.G='z;
                  end else begin
                      rtrans.RES ={1'b0, (rtrans.OPA << shift_val) | (rtrans.OPA >> (`op_len - shift_val))};rtrans.E='z;rtrans.L='z;rtrans.G='z; rtrans.ERR='z;
                  end
                end
                4'd13: begin
                  if (|rtrans.OPB[`op_len-1:bits_req]) begin
                    rtrans.ERR = 1;
                    rtrans.RES = 0;
                    rtrans.E='z;rtrans.L='z;rtrans.G='z; rtrans.ERR='z;
                  end else begin
                    rtrans.RES = {1'b0,(rtrans.OPA >> shift_val) | (rtrans.OPA << (`op_len - shift_val))};
                    rtrans.E='z;rtrans.L='z;rtrans.G='z; rtrans.ERR='z;
                  end
                end
                default:begin
                rtrans.RES = 'z;
                rtrans.E = 'z;
                rtrans.G ='z;
                rtrans.L ='z;
                rtrans.ERR='z;
                rtrans.OFLOW='z;
                rtrans.COUT='z;
              end
              endcase
            end
          2'b00: begin
                 rtrans.ERR=1;
                 rtrans.RES=store;
                 rtrans.E=e;
     rtrans.G=g;
                 rtrans.L=l;
                 rtrans.OFLOW=oflow;
                 rtrans.COUT=cout;
             end
          default:begin
                rtrans.RES = 'z;
                rtrans.E='z;
                rtrans.G='z;
                rtrans.L='z;
           end
          endcase
        end

      end
      else
      begin
        if(rtrans.CE==0)
        begin
          rtrans.RES=store;
          rtrans.G=g;
          rtrans.E=e;
          rtrans.L=l;
          rtrans.OFLOW=oflow;
          rtrans.COUT=cout;
        end
        else
        begin

        rtrans.ERR   = 1;
        rtrans.OFLOW = 'z;
        rtrans.COUT  = 'z;
        rtrans.G     = 'z;
        rtrans.E     = 'z;
        rtrans.L     = 'z;
        rtrans.RES   = 'z;
       end
      end

      // Final delay block happens after got
      if (is_mul)
      begin
        $display("[REF_MODEL-%0d][%0t] Multiplication detected. Waiting 2 cycles...",i+1, $time);
        repeat (2) @(posedge vif.CLK);
        store=rtrans.RES;
        g=rtrans.G;
     e=rtrans.E;
        l=rtrans.L;
      end
      else
      begin
        $display("[[REF_MODEL-%0d][%0t] Non-multiplication operation. Waiting 1 cycle...",i+1,$time);
        repeat (1) @(posedge vif.CLK);
        store=rtrans.RES;
        g=rtrans.G;
        e=rtrans.E;
        l=rtrans.L;
      end


     if(rtrans.CMD !=8 && rtrans.MODE)
      begin
          rtrans.E='z;
          rtrans.G='z;
          rtrans.L='z;
      end
      mb_rs.put(rtrans.copy());

      $display("[REFERENCE MODEL] Passing data to scoreboard at %0t",$time);
      $display("THE INPUTS  :  CE=%0d | INP_VALID=%0d |  CMD=%0d | MODE=%0d | OPA=%0d | OPB=%0d | CIN=%0d",rtrans.CE,rtrans.INP_VALID, rtrans.CMD, rtrans.MODE,rtrans.OPA,rtrans.OPB,
          rtrans.CIN);
      $display("THE OUTPUTS :  RES=%0d | OFLOW=%0d | COUT=%0d | ERR=%0d | OFLOW=%0d | G=%0d | E=%0d | L=%0b",  rtrans.RES,rtrans.OFLOW,rtrans.COUT,rtrans.ERR, rtrans.COUT, rtrans.OFLOW,
          rtrans.G, rtrans.E, rtrans.L);

    end // for
  endtask
endclass

