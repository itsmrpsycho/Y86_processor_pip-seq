`timescale 1ns/10ps
`include "./ALU/ALU.v"

module conditionalCodes (icode,ifun, CC, Cnd);
  input [3:0] icode;
	input [3:0] ifun;
	input [2:0] CC;
	output Cnd;

	parameter BRANCH_UNC = 4'h0; // Unconditional jump
	parameter BRANCH_LE  = 4'h1; // Jump if less than or equal
	parameter BRANCH_L   = 4'h2; // Jump if less than
	parameter BRANCH_E   = 4'h3; // Jump if equal
	parameter BRANCH_NE  = 4'h4; // Jump if not equal
	parameter BRANCH_GE  = 4'h5; // Jump if greater than or equal
	parameter BRANCH_G   = 4'h6; // Jump if greater than

	wire ZF = CC[2];
	wire SF = CC[1];
	wire OF = CC[0];

	assign Cnd =
	(ifun == BRANCH_UNC) |
	(ifun == BRANCH_LE & ((SF ^ OF) | ZF)) |
	(ifun == BRANCH_L  & (SF ^ OF)) |
	(ifun == BRANCH_E  & ZF) |
	(ifun == BRANCH_NE & ~ZF) |
	(ifun == BRANCH_GE & ~(SF ^ OF)) |
	(ifun == BRANCH_G  & ~(SF ^ OF) & ~ZF) | 
  (icode==4'd6);
endmodule

module execute (clock, E_icode, E_ifun, E_valA, E_valB, E_valC, CCold, E_dstE, E_dstM,
e_valE, CC, e_Cnd);

// inputs
input clock;
input [3:0 ] E_icode;
input [3:0 ] E_ifun;
input [63:0] E_valA;
input [63:0] E_valB;
input [63:0] E_valC;
input [3:0 ] E_dstE;
input [3:0 ] E_dstM;
input [2:0 ] CCold;
// for CondCod
output e_Cnd;

// outputs
wire [2:0] CCtemp;
output reg [2:0] CC;
output wire [63:0] e_valE;

// for ALU
reg [1:0] sel;
reg signed [63:0] ALU_a,ALU_b;
wire [63:0] ALU_out;


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

initial begin
  // valE = 64'd0;
  CC = 3'b000;
end

always @(posedge clock) begin
case(E_icode)
  codeHalt:begin
    // Nothing
  end
  codeNop:begin
    // Nothing
  end
  codeCmovXX:begin
    ALU_a = E_valA;
    ALU_b = 64'd0;
    sel = 2'b00; // add
    CC = CCold;
  end
  codeIRmovq:begin
    ALU_a = E_valC;
    ALU_b = 64'd0;
    sel = 2'b00; // add
    CC = CCtemp;
  end
  codeRMmovq:begin
    ALU_a = E_valC;
    ALU_b = E_valB;
    sel = 2'b00; // add
    CC = CCtemp;
  end
  codeMRmovq:begin
    ALU_a = E_valC;
    ALU_b = E_valB;
    sel = 2'b00; // add
    CC = CCtemp;
  end
  codeOPq:begin
    ALU_a = E_valA;
    ALU_b = E_valB;
    case (E_ifun)
    4'd0:begin // add
      sel = 2'd0;
    end
    4'd1:begin // sub
      sel = 2'd1;
    end
    4'd2:begin // and
      sel = 2'd2;
    end
    4'd3:begin // xor
      sel = 2'd3;
    end
    endcase
    CC = CCtemp;
  end
  codeJXX:begin
    // It will set Cnd
    CC = CCold;
  end
  codeCall:begin
    ALU_a = E_valB; 
    ALU_b = 64'd8;
    sel = 2'b01; // SUB
    CC = CCtemp;
  end
  codeRet:begin
    ALU_a = E_valB; 
    ALU_b = 64'd8;
    sel = 2'b00; // ADD
    CC = CCtemp;
  end
  codePushq:begin
    ALU_a = E_valB;
    ALU_b = 64'd8;
    sel = 2'b01; // SUB
    CC = CCtemp;
  end
  codePopq:begin
    ALU_a = E_valB;
    ALU_b = 64'd8;
    sel = 2'b00; // ADD
    CC = CCtemp;
  end
endcase
end

ALU UUT_alu (sel,ALU_a,ALU_b,ALU_out,CCtemp);
conditionalCodes UUT_cond2 (E_icode,E_ifun, CCold, e_Cnd);

assign e_valE = ALU_out;
endmodule