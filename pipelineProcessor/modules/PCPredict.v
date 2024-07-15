`timescale 1ns/10ps
module PCPredict (clock, F_control, f_icode, f_valC, f_valP, PCpred);
  // inputs
  input clock;
  input [ 3:0] f_icode;
  input [63:0] f_valC;
  input [63:0] f_valP;
  input [63:0] F_control;
  // outputs
  output reg [63:0] PCpred;

  // icodes
  reg [3:0] codeHalt   = 4'b0000;// 0
  reg [3:0] codeNop    = 4'b0001;// 1
  reg [3:0] codeCmovXX = 4'b0010;// 2
  reg [3:0] codeIRmovq = 4'b0011;// 3
  reg [3:0] codeRMmovq = 4'b0100;// 4
  reg [3:0] codeMRmovq = 4'b0101;// 5
  reg [3:0] codeOPq    = 4'b0110;// 6
  reg [3:0] codeJXX    = 4'b0111;// 7
  reg [3:0] codeCall   = 4'b1000;// 8
  reg [3:0] codeRet    = 4'b1001;// 9
  reg [3:0] codePushq  = 4'b1010;// A
  reg [3:0] codePopq   = 4'b1011;// B

  always @(*)begin
    if (clock == 0) begin
      PCpred = 0;end
  end

  always@(negedge clock)begin
    if (F_control == 0) begin
      if (f_icode == codeCall) begin
        PCpred = f_valC; end
      else if (f_icode == codeJXX) begin
        PCpred = f_valC; end
      else begin
        PCpred = f_valP; end
    end
    else begin // F is stalled
      case(f_icode)
      codeHalt:begin
        PCpred = f_valP - 1;
      end
      codeNop:begin
        PCpred = f_valP - 1;
      end
      codeCmovXX:begin
        PCpred = f_valP - 2;
      end
      codeIRmovq:begin
        PCpred = f_valP - 10;
      end
      codeRMmovq:begin
        PCpred = f_valP - 10;
      end
      codeMRmovq:begin
        PCpred = f_valP - 10;
      end
      codeOPq:begin
        PCpred = f_valP - 2;
      end
      codeJXX:begin
        PCpred = f_valP - 9;
      end
      codeCall:begin
        PCpred = f_valP - 9;
      end
      codeRet:begin
        PCpred = f_valP - 1;
      end
      codePushq:begin
        PCpred = f_valP - 2;
      end
      codePopq:begin
        PCpred = f_valP - 2;
      end
      
    endcase
    end
  end
endmodule