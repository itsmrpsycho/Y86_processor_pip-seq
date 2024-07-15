`timescale 1ns/10ps
`include "./modules/fetch.v"
`include "./modules/decode_writeBack.v"
`include "./modules/execute.v"
`include "./modules/memory.v"
`include "./modules/PCPredict.v"
`include "./modules/controlLogic.v"

module processor_tb; 

//// fetch I/O
// inputs
reg clock;
wire [63:0] PCpred;
wire [63:0] PC;
// outputs
wire [ 3:0] f_icode;
wire [ 3:0] f_ifun;
wire [ 3:0] f_rA;
wire [ 3:0] f_rB;
wire [63:0] f_valP;
wire [63:0] f_valC;
wire f_halt;

//// decode I/O 
// inputs
reg [3:0] D_icode;
reg [3:0] D_ifun;
reg [3:0] D_rA;
reg [3:0] D_rB;
reg [63:0] D_valC;
reg [63:0] D_valP;
// outputs
wire [63:0] d_valA;
wire [63:0] d_valB;
wire [3:0 ] d_dstE;
wire [3:0 ] d_dstM;

//// execute I/O
// inputs
reg [3:0 ] E_icode;
reg [3:0 ] E_ifun;
reg [63:0] E_valA;
reg [63:0] E_valB;
reg [63:0] E_valC;
reg [3:0 ] E_dstE;
reg [3:0 ] E_dstM;
reg [2:0 ] CCold;
// outputs
wire e_Cnd;
wire [2:0] CCtemp;
wire [2:0] CC;
wire [63:0] e_valE;

// memory I/O
// inputs
reg [3:0 ] M_icode;
reg [63:0] M_valA;
reg [63:0] M_valE;
reg [3:0 ] M_dstE;
reg [3:0 ] M_dstM;
reg M_Cnd;
// outputs
wire [63:0] m_valM;

//// writeBack IO
// inputs
reg [3:0]  W_icode;
reg [3:0]  W_dstE;
reg [3:0]  W_dstM;
reg [63:0] W_valE;
reg [63:0] W_valM;

//// controlLogic IO
// outputs
wire [63:0] F_control;
wire [63:0] D_control;
wire [63:0] E_control;

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

PCPredict UUT_PCPredict (clock, F_control, f_icode, f_valC, f_valP, PCpred);
fetch UUT_fetch (clock, F_control, PCpred, M_icode, M_Cnd, M_valA, W_icode, W_valM, f_icode, f_ifun, f_rA, f_rB, f_valC, f_valP, f_halt, PC);
decode_writeBack UUT_decode_writeBack (clock, D_icode, D_ifun, D_rA, D_rB, D_valP, d_valA, d_valB, d_dstE, d_dstM, E_dstE,M_dstM,M_dstE,W_dstM,W_dstE,e_valE,m_valM,M_valE,W_valM,W_valE,W_icode, W_dstE, W_dstM, W_valE, W_valM);
execute UUT_execute (clock, E_icode, E_ifun, E_valA, E_valB, E_valC, CCold, E_dstE, E_dstM, e_valE, CC, e_Cnd);
memory UUT_memory (clock, M_icode, M_valA, M_valE, M_dstE, M_dstM, M_Cnd, m_valM);
controlLogic UUT_controlLogic (clock, f_icode, D_icode, E_icode, M_icode, E_dstM, e_Cnd, D_rA, D_rB,F_control, D_control, E_control); 

initial begin
    $dumpfile("processor_tb.vcd");
    $dumpvars(0,processor_tb);

    clock = 0;    
    #500 $finish;
end

always begin
    if (f_icode == codeHalt)begin
        $finish; end
    #10 
    clock = ~clock;
end

always @(*) begin
    $monitor($time, "\nFETCH: PCpred=%0d, PC=%0d\nf_icode=%d, f_ifun=%d, f_rA=%d, f_rB=%d, f_valC=%0d, f_valP=%0d\n",PCpred,PC,f_icode,f_ifun,f_rA,f_rB,f_valC,f_valP,
            "DECODE:\nD_icode=%d, D_ifun=%d, D_rA=%d, D_rB=%d, D_valP=%0d, d_valA=%0d, d_valB=%0d\n",D_icode,D_ifun,D_rA,D_rB,D_valP,d_valA,d_valB,
            "EXECUTE:\nE_icode=%d, E_ifun=%d, E_valA=%0d, E_valB=%0d, E_valC=%0d, E_dstE=%d, E_dstM=%d, e_valE=%0d, e_Cnd=%d\n",E_icode,E_ifun,E_valA,E_valB,E_valC,E_dstE,E_dstM,e_valE,e_Cnd,
            "MEMORY:\nM_icode=%d, M_valA=%0d, M_valE=%0d, M_dstE=%d, M_dstM=%d, M_Cnd=%d, m_valM=%0d\n",M_icode,M_valA,M_valE,M_dstE,M_dstM,M_Cnd,m_valM,
            "WRITEBACK:\nW_icode=%d, W_dstE=%d, W_dstM=%d, W_valE=%0d, W_valM=%0d\n",W_icode,W_dstE,W_dstM,W_valE,W_valM);
end

always @(negedge clock) begin // IO register handling
    // m to W
    W_icode = M_icode;
    W_dstE  = M_dstE;
    W_dstM  = M_dstM;
    W_valE  = M_valE;
    W_valM  = m_valM;
    // e to M
    M_icode = E_icode;
    M_valA  = E_valA;
    M_valE  = e_valE;
    M_dstE  = E_dstE;
    M_dstM  = E_dstM;
    M_Cnd   = e_Cnd;
    // d to E
    if (E_control == 0) begin
        E_icode = D_icode;   
        E_ifun  = D_ifun;
        E_valA  = d_valA;
        E_valB  = d_valB;
        E_valC  = D_valC;
        E_dstE  = d_dstE;
        E_dstM  = d_dstM;
        CCold   = CC; 
    end
    else if (E_control == 2) begin // bubble
        E_icode = 4'h1;   
        E_ifun  = 4'h0;
        E_valA  = 64'h0;
        E_valB  = 64'h0;
        E_valC  = 64'h0;
        E_dstE  = 4'hf;
        E_dstM  = 4'hf;
    end
    // f to D
    if (D_control == 0) begin
        D_icode = f_icode;
        D_ifun  = f_ifun;
        D_rA    = f_rA; 
        D_rB    = f_rB;
        D_valC  = f_valC;
        D_valP  = f_valP;
    end
    else if (D_control == 2) begin // bubble
        D_icode = 4'h1;
        D_ifun  = 4'h0;
        D_rA    = 4'hf; 
        D_rB    = 4'hf;
        D_valC  = 64'h0;
        D_valP  = 64'h0;
    end
end

// iverilog -o processor_tb processor_tb.v
// to view result: vvp processor_tb

endmodule
