`timescale 1ns/10ps


module decode_writeBack(clock, D_icode, D_ifun, D_rA, D_rB, D_valP,
d_valA, d_valB, d_dstE, d_dstM, E_dstE,M_dstM,M_dstE,W_dstM,W_dstE,e_valE,m_valM,M_valE,W_valM,W_valE,
W_icode, W_dstE, W_dstM, W_valE, W_valM);

  //// decode
  // inputs
  input clock;
  input [ 3:0] D_icode;
  input [ 3:0] D_ifun;
  input [ 3:0] D_rA;
  input [ 3:0] D_rB;
  input [63:0] D_valC;
  input [63:0] D_valP;

  input [ 3:0] E_dstE;
  input [ 3:0] M_dstM;
  input [ 3:0] M_dstE;
  input [ 3:0] W_dstM;
  input [ 3:0] W_dstE;

  input [63:0] e_valE;
  input [63:0] m_valM;
  input [63:0] M_valE;
  input [63:0] W_valM;
  input [63:0] W_valE;
  // outputs
  output reg [63:0] d_valA;
  output reg [63:0] d_valB;
  output reg [3:0 ] d_dstE;
  output reg [3:0 ] d_dstM;

  // registers
  reg [63:0] d_rvalA;
  reg [63:0] d_rvalB;

  //// writeBack
  input [3:0]  W_icode;
  // input [3:0]  W_dstE;
  // input [3:0]  W_dstM;
  // input [63:0] W_valE;
  // input [63:0] W_valM;

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

  // registers
  parameter rax = 4'h0;
  parameter rcx = 4'h1;
  parameter rdx = 4'h2;
  parameter rbx = 4'h3;
  parameter rsp = 4'h4;
  parameter rbp = 4'h5;
  parameter rsi = 4'h6;
  parameter rdi = 4'h7;
  parameter r8  = 4'h8;
  parameter r9  = 4'h9;
  parameter r10 = 4'hA;
  parameter r11 = 4'hB;
  parameter r12 = 4'hC;
  parameter r13 = 4'hD;
  parameter r14 = 4'hE;
  parameter r15 = 4'hF;

  reg [63:0] registers [0:15];

  initial begin
    // d_valA = 64'd0;
    d_valB = 64'd0;

    // registers
    registers[rax]=64'h0;
    registers[rcx]=64'h1;
    registers[rdx]=64'h2;
    registers[rbx]=64'h3;
    registers[rsp]=64'h10;
    registers[rbp]=64'h5;
    registers[rsi]=64'h6;
    registers[rdi]=64'h7;
    registers[r8 ]=64'h8;
    registers[r9 ]=64'h9;
    registers[r10]=64'ha;
    registers[r11]=64'hb;
    registers[r12]=64'hc;
    registers[r13]=64'hd;
    registers[r14]=64'he;
    registers[r15]=64'hf;
  end

  always @(posedge clock) begin
    // for rA
    if (D_icode == codeCall | D_icode == codeJXX)begin
      d_valA = D_valP;end // Use incremented PC for fallback
    else if (D_icode == codeRet)begin
      d_valA = registers[rsp];end
    else if (D_rA == E_dstE)begin
      d_valA = e_valE;end // forward valE from execute
    else if (D_rA == M_dstM)begin
      d_valA = m_valM;end // forward valM from memory
    else if (D_rA == M_dstE)begin
      d_valA = M_valE;end // forward valE from memory
    else if (D_rA == W_dstM)begin
      d_valA = W_valM;end // forward valM from writeback
    else if (D_rA == W_dstE)begin
      d_valA = W_valE;end // forward valE from writeback
    else begin
      d_valA = registers[D_rA];end // get value from register rA
    // for rB
    if (D_icode == codeCall | D_icode == codeRet) begin
      d_valB = registers[rsp];end
    if (D_rB == E_dstE)begin
      d_valB = e_valE;end // forward valE from execute
    else if (D_rB == M_dstM)begin
      d_valB = m_valM;end // forward valM from memory
    else if (D_rB == M_dstE)begin
      d_valB = M_valE;end // forward valE from memory
    else if (D_rB == W_dstM)begin
      d_valB = W_valM;end // forward valM from writeback
    else if (D_rB == W_dstE)begin
      d_valB = W_valE;end // forward valE from writeback
    else begin
      d_valB = registers[D_rB];end // get value from register rB
  end

  always @(posedge clock) begin
    // checking command
    case(D_icode)
    codeHalt:begin
        // Nothing
    end
    codeNop:begin
      // Nothing
    end
    codeCmovXX:begin
      d_dstE = D_rB;
      d_dstM = 4'hf;
    end
    codeIRmovq:begin
      d_dstE = D_rB;
      d_dstM = 4'hf;
    end
    codeRMmovq:begin
      d_dstE = 4'hf;
      d_dstM = 4'hf;
    end
    codeMRmovq:begin
      d_dstE = 4'hf;
      d_dstM = D_rA;
    end
    codeOPq:begin
      d_dstE = D_rB;
      d_dstM = 4'hf;
    end
    codeCall:begin
      d_dstE = rsp;
      d_dstM = 4'hf;
    end
    codeRet:begin
      d_dstE = rsp;
      d_dstM = 4'hf;
    end
    codePushq:begin
      d_dstE = rsp;
      d_dstM = 4'hf;
    end
    codePopq:begin
      d_dstE = rsp;
      d_dstM = D_rA;
    end
    endcase
    
  end  

  ////WRITEBACK

  always @(posedge clock) begin
  case(W_icode)
    codeHalt:begin
      // Nothing
    end
    codeNop:begin
      // Nothing
    end
    codeCmovXX:begin
      registers[W_dstE] = W_valE;
    end
    codeIRmovq:begin
      registers[W_dstE] = W_valE;
    end
    codeRMmovq:begin
      // Nothing
    end
    codeMRmovq:begin
      registers[W_dstM] = W_valM;
    end
    codeOPq:begin
      registers[W_dstE] = W_valE;
    end
    codeJXX:begin
      // Nothing
    end
    codeCall:begin
      registers[rsp] = W_valE;
    end
    codeRet:begin
      registers[rsp] = W_valE;
    end
    codePushq:begin
      registers[rsp] = W_valE;
    end
    codePopq:begin
      registers[rsp] = W_valE;
      registers[W_dstM] = W_valM;
    end
  endcase
  end

endmodule