`timescale 1ns/10ps

module controlLogic(clock, F_icode, D_icode, E_icode, M_icode, E_dstM, e_Cnd, D_rA, D_rB,
 F_control, D_control, E_control); 
  // inputs
  input clock;
  input [3:0 ] F_icode;
  input [3:0 ] D_icode;
  input [3:0 ] E_icode;
  input [3:0 ] M_icode;
  input [3:0 ] E_dstM;
  input        e_Cnd;
  input [3:0 ] D_rA;
  input [3:0 ] D_rB;

  // outputs
  output reg [63:0] F_control;
  output reg [63:0] D_control;
  output reg [63:0] E_control;

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

  // 0 - normal
  // 1 - stall
  // 2 - bubble

  initial begin
    F_control = 0;
    D_control = 0;
    E_control = 0;
  end

  always@(*)begin

    // for fetch
    if ((E_icode == codeMRmovq | E_icode == codePopq) & (E_dstM == D_rA | E_dstM == D_rB)) begin
      F_control = 1; // load use hazard STALL
    end
    else if (D_icode == codeRet | E_icode == codeRet | M_icode == codeRet)begin
      F_control = 1; // return instruction STALL
    end
    else begin
      F_control = 0; // NORMAL
    end

    // for decode 
    if ((E_icode == codeMRmovq | E_icode == codePopq) & (E_dstM == D_rA | E_dstM == D_rB)) begin
      D_control = 1; // load use hazard STALL
    end
    else if (E_icode == codeJXX & e_Cnd == 0)begin
      D_control = 2; // mispredicted branch BUBBLE
    end
    else if (D_icode == codeRet | E_icode == codeRet | M_icode == codeRet)begin
      D_control = 2; // return instruction BUBBLE
    end
    else begin
      D_control = 0; // NORMAL
    end

    // for execute
    if (E_icode == codeJXX & e_Cnd == 0)begin
      E_control = 2; // BUBBLE
    end
    else if ((E_icode == codeMRmovq | E_icode == codePopq) & (E_dstM == D_rA | E_dstM == D_rB)) begin
      E_control = 2; // BUBBLE
    end
    else begin
      E_control = 0;
    end

  end

  


endmodule