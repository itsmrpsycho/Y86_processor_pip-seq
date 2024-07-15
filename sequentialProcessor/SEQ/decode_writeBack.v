`timescale 1ns/10ps

module decode_writeBack(clock, icode, rA, rB, valA, valB, valE, valM, Cnd);

//// decode
// inputs
input clock;
input [3:0] icode;
input [3:0] rA;
input [3:0] rB;
// outputs
output reg [63:0] valA;
output reg [63:0] valB;

//// writeBack
input [63:0] valE;
input [63:0] valM;
input Cnd;

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
  valA = 64'd0;
  valB = 64'd0;

  // registers
  registers[rax]=64'h0;
  registers[rcx]=64'h1;
  registers[rdx]=64'h2;
  registers[rbx]=64'h3;
  registers[rsp]=64'h5;
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

always @(*) begin
  // checking command
  case(icode)
  codeHalt:begin
      // Nothing
  end
  codeNop:begin
    // Nothing
  end
  codeCmovXX:begin
    valA = registers[rA];
  end
  codeIRmovq:begin
    // nothing
  end
  codeRMmovq:begin
    valA = registers[rA];
    valB = registers[rB];
  end
  codeMRmovq:begin
    valB = registers[rB];
  end
  codeOPq:begin
    valA = registers[rA];
    valB = registers[rB];
  end
  codeCall:begin
    valB = registers[rsp];
  end
  codeRet:begin
    valA = registers[rsp];
    valB = registers[rsp];
  end
  codePushq:begin
    valA = registers[rA];
    valB = registers[rsp];
  end
  codePopq:begin
    valA = registers[rsp];
    valB = registers[rsp];
  end
  endcase
end  

////WRITEBACK

// for accessing registers
reg [3:0] regNo;
reg sel_reg_IO;

always @(posedge clock) begin
  sel_reg_IO = 1; // not inputting
end


always @(negedge clock) begin
case(icode)
  codeHalt:begin
    // Nothing
  end
  codeNop:begin
    // Nothing
  end
  codeCmovXX:begin
    if (Cnd == 1) begin
      registers[rB] = valE;
    end
    else begin
      registers[4'hf] = valE;
    end
  end
  codeIRmovq:begin
    registers[rB] = valE;
  end
  codeRMmovq:begin
    // Nothing
  end
  codeMRmovq:begin
    registers[rA] = valM;
  end
  codeOPq:begin
    registers[rB] = valE;
  end
  codeJXX:begin
    // Nothing
  end
  codeCall:begin
    registers[rsp] = valE;
  end
  codeRet:begin
    registers[rsp] = valE;
  end
  codePushq:begin
    registers[rsp] = valE;
  end
  codePopq:begin
    registers[rsp] = valE;
    registers[rA] = valM;
  end
endcase
end

endmodule
