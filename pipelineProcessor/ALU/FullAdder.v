module FullAdder (a,b,c,sum,car);
input a,b,c;
output sum,car;

wire x1,x2,x3;

xor gateXOR1(x1,a,b);
xor gateSUM(sum,x1,c);
and gateAND1(x2,c,x1);
and gateAND2(x3,a,b);
or gateCARRY(car,x2,x3);

endmodule