`timescale 1ns/10ps

module XOR64 (a,b,out,overflow);
input signed [63:0] a, b;
output overflow;
output signed [63:0] out;
wire zero_bit = 0;
wire one_bit = 1;

genvar i;
generate
    for (i=0; i<64; i = i + 1)
    begin
        xor u1 (out[i],a[i],b[i]);
    end
endgenerate
and over_bit (overflow,zero_bit,zero_bit);

endmodule
