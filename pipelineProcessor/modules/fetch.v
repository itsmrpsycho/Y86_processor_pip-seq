`timescale 1ns/10ps

`include "./insMem.v"

module fetch (clock, F_control, PCpred, M_icode, M_Cnd, M_valA, W_icode, W_valM,
f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP, f_halt, PC);
  // inputs
  input clock;
  input [63:0] F_control;
  input [63:0] PCpred;
  input [ 3:0] M_icode;
  input        M_Cnd;
  input [63:0] M_valA;
  input [ 3:0] W_icode;
  input [63:0] W_valM;

  // outputs
  output reg [ 3:0] f_icode;
  output reg [ 3:0] f_ifun;
  output reg [ 3:0] f_rA;
  output reg [ 3:0] f_rB;
  output reg [63:0] f_valP;
  output reg [63:0] f_valC;
  output reg f_halt;

  // PC
  output reg [63:0] PC;

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

  always @(*) begin
    // select PC
    if (M_icode == codeJXX && M_Cnd == 0)begin
      PC = M_valA; end
    else if (W_icode == codeRet)begin
      PC = W_valM; end
    else begin
      PC = PCpred; end
  end

  always @(posedge clock)
  begin

    // initial conditions
    f_rA = 4'b1111;
    f_rB = 4'b1111;
    f_valC = 64'd0;
    f_valP = 64'd0;
    f_halt = 0;

    if (PC >= 127) begin
      f_halt = 1;
    end
    else begin
      // calculating icode and ifun
      f_icode = byte1[7:4];
      f_ifun  = byte1[3:0];
      case(f_icode)
      codeHalt:begin
        f_halt = 1;
        f_valP = PC + 1;
      end
      codeNop:begin
        f_valP = PC + 1;
      end
      codeCmovXX:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valP = PC+2;
      end
      codeIRmovq:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valC = {byte10,byte9,byte8,byte7,byte6,byte5,byte4,byte3};
        f_valP = PC+10;
      end
      codeRMmovq:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valC = {byte10,byte9,byte8,byte7,byte6,byte5,byte4,byte3};
        f_valP = PC+10;
      end
      codeMRmovq:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valC = {byte10,byte9,byte8,byte7,byte6,byte5,byte4,byte3};
        f_valP = PC+10;
      end
      codeOPq:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valP = PC+2;
      end
      codeJXX:begin
        f_valC = {byte9,byte8,byte7,byte6,byte5,byte4,byte3,byte2};
        f_valP = PC + 9;
      end
      codeCall:begin
        f_valC = {byte9,byte8,byte7,byte6,byte5,byte4,byte3,byte2};
        f_valP = PC + 9;
      end
      codeRet:begin
        f_valP = PC + 1;
      end
      codePushq:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valP = PC+2;
      end
      codePopq:begin
        f_rA = byte2[7:4];
        f_rB = byte2[3:0];
        f_valP = PC+2;
      end
      
    endcase
    end
  end  

endmodule