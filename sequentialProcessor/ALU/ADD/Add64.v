`timescale 1ns/10ps

// module FullAdder (a,b,c,sum,car);
// input a,b,c;
// output sum,car;

// wire x1,x2,x3;

// xor gateXOR1(x1,a,b);
// xor gateSUM(sum,x1,c);
// and gateAND1(x2,c,x1);
// and gateAND2(x3,a,b);
// or gateCARRY(car,x2,x3);

// endmodule

module Add64 (a,b,out,overflow);
input signed [63:0] a, b;
output overflow;
output signed [63:0] out;

wire reg [63:0] carries;
wire zero_bit = 0;
wire one_bit = 1;
FullAdder u0 (a[0],b[0],zero_bit,out[0],carries[0]);

genvar i;
generate
    for (i=1; i<64; i = i + 1)
    begin
        FullAdder u1 (a[i],b[i],carries[i-1],out[i],carries[i]);
    end
endgenerate
xor over_bit (overflow,carries[63],carries[62]);

endmodule
