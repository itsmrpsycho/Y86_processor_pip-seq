`timescale 1ns/10ps

module memory(clock, icode, valA, valE, valP, valM);


// inputs
input clock;
input [3:0 ] icode;
input [63:0] valA;
input [63:0] valE;
input [63:0] valP;

// outputs
output reg [63:0] valM;

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

reg [63:0] mem [0:127];

initial begin
    mem[  0] = 64'h00;  
    mem[  1] = 64'h00;
    mem[  2] = 64'h00;
    mem[  3] = 64'h00;
    mem[  4] = 64'h00;
    mem[  5] = 64'h0f;
    mem[  6] = 64'h00;
    mem[  7] = 64'h00;
    mem[  8] = 64'h00;
    mem[  9] = 64'h00;
    mem[ 10] = 64'h00;
    mem[ 11] = 64'h00;
    mem[ 12] = 64'h00;
    mem[ 13] = 64'h00;
    mem[ 14] = 64'h00;
    mem[ 15] = 64'h00;
    mem[ 16] = 64'h00;
    mem[ 17] = 64'h00;
    mem[ 18] = 64'h00;
    mem[ 19] = 64'h00;
end

always@(*)begin
  case(icode)
  codeHalt:begin
    // Nothing
  end
  codeNop:begin
    // Nothing
  end
  codeCmovXX:begin
    // Nothing
  end
  codeIRmovq:begin
    // Nothing
  end
  codeRMmovq:begin
    mem[valE] = valA;
  end
  codeMRmovq:begin
    valM = mem[valE];
  end
  codeOPq:begin
    // Nothing
  end
  codeJXX:begin
    // idk
  end
  codeCall:begin
    mem[valE] = valP;
  end
  codeRet:begin
    valM = mem[valA];
  end
  codePushq:begin
    mem[valE] = valA;
  end
  codePopq:begin
    valM = mem[valA];
  end
endcase
end

endmodule