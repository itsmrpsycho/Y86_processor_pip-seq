`timescale 1ns/10ps

`include "./insMem.v"

module fetch (clock, PC,icode, ifun, rA, rB, valC, valP, halt);
// inputs
input clock;
input [63:0] PC;

// memory
reg [63:0] memPCval;

// outputs
output reg [ 3:0] icode;
output reg [ 3:0] ifun;
output reg [ 3:0] rA;
output reg [ 3:0] rB;
output reg [63:0] valP;
output reg [63:0] valC;
output reg halt;

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

wire [7:0] byte1;
wire [7:0] byte2;
wire [7:0] byte3;
wire [7:0] byte4;
wire [7:0] byte5;
wire [7:0] byte6;
wire [7:0] byte7;
wire [7:0] byte8;
wire [7:0] byte9;
wire [7:0] byte10;

insMem UUTmem1  (PC + 0, byte1);
insMem UUTmem2  (PC + 1, byte2);
insMem UUTmem3  (PC + 2, byte3);
insMem UUTmem4  (PC + 3, byte4);
insMem UUTmem5  (PC + 4, byte5);
insMem UUTmem6  (PC + 5, byte6);
insMem UUTmem7  (PC + 6, byte7);
insMem UUTmem8  (PC + 7, byte8);
insMem UUTmem9  (PC + 8, byte9);
insMem UUTmem10 (PC + 9, byte10);

always @(posedge clock)
begin
  // initial conditions
  rA = 4'b1111;
  rB = 4'b1111;
  valC = 64'd0;
  valP = 64'd0;
  halt = 0;

  if (PC >= 127) begin
		halt = 1;
	end
  else begin
    // calculating icode and ifun
		icode = byte1[7:4];
		ifun  = byte1[3:0];
    case(icode)
    codeHalt:begin
      halt = 1;
      valP = PC + 1;
    end
    codeNop:begin
      valP = PC + 1;
    end
    codeCmovXX:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valP = PC+2;
    end
    codeIRmovq:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valC = {byte10,byte9,byte8,byte7,byte6,byte5,byte4,byte3};
      valP = PC+10;
    end
    codeRMmovq:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valC = {byte10,byte9,byte8,byte7,byte6,byte5,byte4,byte3};
      valP = PC+10;
    end
    codeMRmovq:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valC = {byte10,byte9,byte8,byte7,byte6,byte5,byte4,byte3};
      valP = PC+10;
    end
    codeOPq:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valP = PC+2;
    end
    codeJXX:begin
      valC = {byte9,byte8,byte7,byte6,byte5,byte4,byte3,byte2};
			valP = PC + 9;
    end
    codeCall:begin
      valC = {byte9,byte8,byte7,byte6,byte5,byte4,byte3,byte2};
			valP = PC + 9;
    end
    codeRet:begin
      valP = PC + 1;
    end
    codePushq:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valP = PC+2;
    end
    codePopq:begin
      rA = byte2[7:4];
			rB = byte2[3:0];
      valP = PC+2;
    end
    
  endcase
  end
end  

endmodule
