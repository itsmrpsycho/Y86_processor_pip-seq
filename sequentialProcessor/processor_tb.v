`timescale 1ns/10ps
`include "./ALU/ALU.v"
`include "./SEQ/fetch.v"
`include "./SEQ/decode_writeBack.v"
`include "./SEQ/execute.v"
`include "./SEQ/memory.v"
// `include "./SEQ/writeBack.v"
`include "./SEQ/PCUpdate.v"

module processor_tb; 

//// fetch I/O
// inputs
reg clock;
wire [63:0] PC;
// outputs
wire [3:0] icode;
wire [3:0] ifun;
wire [3:0] rA;
wire [3:0] rB;
wire [63:0] valC;
wire [63:0] valP;
wire halt;

//// decode I/O 
wire signed [63:0] valA;
wire signed [63:0] valB;

//// execute I/O
wire signed [63:0] valE;
// reg [2:0] CCold;
wire [2:0] CC;
wire Cnd;

// memory I/O
wire signed [63:0] valM;

fetch UUT_fetch (clock,PC,icode, ifun, rA, rB, valC, valP, halt);
decode_writeBack UUT_decode_writeBack (clock,icode,rA,rB,valA,valB,valE,valM,Cnd);
execute UUT_execute (clock, icode, ifun, valA, valB, valC, CC, valE, CC, Cnd);
memory UUT_memory (clock, icode, valA, valE, valP, valM);
PCUpdate UUT_PCUpdate (clock, icode, Cnd, valP, valC, valM, PC);

initial begin
    $dumpfile("processor_tb.vcd");
    $dumpvars(0,processor_tb);

    clock = 0;    
    #90 $finish;
end

always begin
	#10 
    clock = ~clock;
    $monitor($time, "\nPC = %d\nicode = %h\nifun = %h\nrA = %h\nrB = %h\nvalA = %d\nvalB = %d\nvalC = %h\nvalE = %d\n ZF = %b, SF = %b, OF = %b, Cnd=%b\n", PC, icode, ifun, rA, rB, valA, valB, valC, valE, CC[2], CC[1], CC[0], Cnd);
end

// iverilog -o processor_tb processor_tb.v
// to view result: vvp processor_tb

endmodule