`timescale 1ns/10ps

module insMem(PC,instruction);

input [63:0] PC;
reg [7:0] insMem [0:127];
output reg [7:0] instruction;

initial begin
    insMem[  0] = 8'h60;
    insMem[  1] = 8'h22;
    insMem[  2] = 8'h80;
    insMem[  3] = 8'h0e;
    insMem[  4] = 8'h00;
    insMem[  5] = 8'h00;
    insMem[  6] = 8'h00;
    insMem[  7] = 8'h00;
    insMem[  8] = 8'h00;
    insMem[  9] = 8'h00;
    insMem[ 10] = 8'h00;
    insMem[ 11] = 8'h61;
    insMem[ 12] = 8'h32;
    insMem[ 13] = 8'h00;
    insMem[ 14] = 8'h30;
    insMem[ 15] = 8'hf9;
    insMem[ 16] = 8'h45;
    insMem[ 17] = 8'h00;
    insMem[ 18] = 8'h00;
    insMem[ 19] = 8'h00;
    insMem[ 20] = 8'h00;
    insMem[ 21] = 8'h00;
    insMem[ 22] = 8'h00;
    insMem[ 23] = 8'h00;
    insMem[ 24] = 8'h61;
    insMem[ 25] = 8'hee;
    insMem[ 26] = 8'h21;
    insMem[ 27] = 8'hbd;
    insMem[ 28] = 8'h60;
    insMem[ 29] = 8'hdd;
end

always@(*)begin
    instruction = insMem[PC];
end

endmodule