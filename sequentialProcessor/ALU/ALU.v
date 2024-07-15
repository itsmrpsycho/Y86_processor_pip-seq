`timescale 1ns/10ps
`include "./ALU/ADD/Add64.v"
`include "./ALU/SUB/Sub64.v"
`include "./ALU/AND/AND64.v"
`include "./ALU/XOR/XOR64.v"
`include "./ALU/FullAdder.v"

// ================================

module ALU(sel,a,b,out,CondCod); //zf sf of
input [1:0] sel;
input signed [63:0] a, b;
output reg signed [63:0] out;
output reg [2:0] CondCod;
wire signed [63:0] outAdd,outSub,outAND,outXOR;
wire ovAdd,ovSub,ovADD,ovXOR;

Add64 ADDER      (a,b,outAdd,ovAdd);
Sub64 SUBTRACTER (a,b,outSub,ovSub);
AND64 ANDER      (a,b,outAND,ovAND);
XOR64 XORER      (a,b,outXOR,ovXOR);

initial begin
  CondCod[0] = 0; 
  CondCod[1] = 0;
  CondCod[2] = 0;
end

always@(*)
begin
  case(sel)
    2'b00:begin
        out=outAdd;
        CondCod[0]=ovAdd;
      end
    2'b01:begin
        out=outSub;
        CondCod[0]=ovSub;
      end    
    2'b10:begin
        out=outAND;
        CondCod[0]=ovAND;
      end
    2'b11:begin
        out=outXOR;
        CondCod[0]=ovXOR;
      end
  endcase

  if (out[63]==1'd1) begin
    CondCod[1] = 1;
  end
  else begin
    CondCod[1] = 0;
  end
  if (out == 64'd0) begin
    CondCod[2] = 1;
  end
  else begin
    CondCod[2] = 0;
  end
end  

endmodule