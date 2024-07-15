`timescale 1ns/10ps

module PCUpdate (clock, icode, Cnd, valP, valC, valM, PC);
// inputs
input clock;
input [3:0] icode;
input Cnd;
input [63:0] valP;
input [63:0] valC;
input [63:0] valM;

// outputs
output reg [63:0] PC;

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

initial begin
    {PC} = 0;
end

always@(negedge clock)begin
  if (icode == codeJXX) begin
    if (Cnd == 1) begin
      PC = valC;
    end
    else begin
      PC = valP;
    end
  end
  else if (icode == codeCall) begin
    PC = valC;
  end
  else if (icode == codeRet) begin
    PC = valM;
  end
  else begin
    PC = valP;
  end
end

endmodule