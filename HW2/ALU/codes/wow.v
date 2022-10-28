module wow();

wire [31:0] a = 32'h00000003;
wire [31:0] b = 32'h7ffffffd;

wire [31:0] result[0:16];
wire [16:0]  overflow;

add_signed_32bits       adds    (overflow[0], result[0], a, b);
sub_signed_32bits       subs    (overflow[1], result[1], a, b);
mul_signed_32bits       muls    (overflow[2], result[2], a, b);
max_signed_32bits       maxs    (overflow[3], result[3], a, b);
min_signed_32bits       mins    (overflow[4], result[4], a, b);
add_unsigned_32bits     addu    (overflow[5], result[5], a, b);
sub_unsigned_32bits     subu    (overflow[6], result[6], a, b);
mul_unsigned_32bits     mulu    (overflow[7], result[7], a, b);
max_unsigned_32bits     maxu    (overflow[8], result[8], a, b);
min_unsigned_32bits     minu    (overflow[9], result[9], a, b);
and_32bits              and1    (overflow[10], result[10], a, b);
or_32bits               or1     (overflow[11], result[11], a, b);
xor_32bits              xor1    (overflow[12], result[12], a, b);
not_32bits              not1    (overflow[13], result[13], a);
reverse_32bits          rev     (overflow[14], result[14], a);
lt_signed_32bits        lts     (overflow[15], result[15], a, b);
ge_signed_32bits        ges     (overflow[16], result[16], a, b);

integer i;

initial begin
    for(i=0;i<1;i=i+1) begin
        $display("time / a / b");
        $monitor("%4d %b %b", $time, a, b);
        #10
        $monitor("%4d a + b     (signed)   %b %b", $time, result[0], overflow[0]);
        #10
        $monitor("%4d a - b     (signed)   %b %b", $time, result[1], overflow[1]);
        #10
        $monitor("%4d a * b     (signed)   %b %b", $time, result[2], overflow[2]);
        #10
        $monitor("%4d max(a, b) (signed)   %b %b", $time, result[3], overflow[3]);
        #10
        $monitor("%4d min(a, b) (signed)   %b %b", $time, result[4], overflow[4]);
        #10
        $monitor("%4d a + b     (unsigned) %b %b", $time, result[5], overflow[5]);
        #10
        $monitor("%4d a - b     (unsigned) %b %b", $time, result[6], overflow[6]);
        #10
        $monitor("%4d a * b     (unsigned) %b %b", $time, result[7], overflow[7]);
        #10
        $monitor("%4d max(a, b) (unsigned) %b %b", $time, result[8], overflow[8]);
        #10
        $monitor("%4d min(a, b) (unsigned) %b %b", $time, result[9], overflow[9]);
        #10
        $monitor("%4d a and b   (unsigned) %b %b", $time, result[10], overflow[10]);
        #10
        $monitor("%4d a or b    (unsigned) %b %b", $time, result[11], overflow[11]);
        #10
        $monitor("%4d a xor b   (unsigned) %b %b", $time, result[12], overflow[12]);
        #10
        $monitor("%4d not a     (unsigned) %b %b", $time, result[13], overflow[13]);
        #10
        $monitor("%4d rev a     (unsigned) %b %b", $time, result[14], overflow[14]);
        #10
        $monitor("%4d lt (a, b) (signed)   %b %b", $time, result[15], overflow[15]);
        #10
        $monitor("%4d ge (a, b) (signed)   %b %b", $time, result[16], overflow[16]);
    end
end

endmodule

module add_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire [DATA_WIDTH-1:0] tmp;

    assign tmp = a + b;

    assign overflow = (a[31] == 0 && b[31] == 0 && tmp[31] == 1) | 
                      (a[31] == 1 && b[31] == 1 && tmp[31] == 0);
    
    assign s = tmp;

endmodule

module sub_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    add_signed_32bits adds(overflow, s, a, ~b+1);

    // assign overflow = 0;
    // assign s = ~b+1;

endmodule

module mul_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

wire signed [31:0] tmp1;
wire signed [31:0] tmp2;
wire signed [63:0] tmp3;
wire signed [63:0] tmp4;
wire signed [63:0] tmp5;

assign tmp1 = a;
assign tmp2 = b;
assign tmp3 = tmp1 * tmp2;
assign tmp4 = 64'h000000007fffffff;
assign tmp5 = 64'hffffffff80000000;

assign overflow = (tmp3 > tmp4) | (tmp3 < tmp5);

assign s = tmp3[31:0];

endmodule

module max_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire [31:0] tmp;
    lt_signed_32bits lts(overflow, tmp, a, b);
    multiplexer_32bits multi(s, a, b, tmp[0]);

endmodule

module min_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire [31:0] tmp;
    ge_signed_32bits lts(overflow, tmp, a, b);
    multiplexer_32bits multi(s, a, b, tmp[0]);

endmodule

module add_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign {overflow, s} = a + b;

endmodule

module sub_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign overflow = a < b;
    assign s = a - b;

endmodule

module mul_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire [63:0] tmp;

    assign tmp = a * b;

    assign overflow = tmp[63:32] > 0;
    assign s = tmp[31:0];

endmodule

module max_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;
    assign overflow = 0;
    assign s = (a <= b) ? b : a;

endmodule

module min_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign overflow = 0;
    assign s = (a <= b) ? a : b;

endmodule

module and_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign overflow = 0;
    assign s = a & b;

endmodule

module or_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign overflow = 0;
    assign s = a | b;

endmodule

module xor_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign overflow = 0;
    assign s = a ^ b;

endmodule

module not_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a
) ;

    assign overflow = 0;
    assign s = ~a;

endmodule

module reverse_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a
) ;

    assign overflow = 0;

    genvar i;
    generate
    for(i=0;i<DATA_WIDTH;i=i+1) begin
        assign s[i] = a[DATA_WIDTH-1-i];
    end
    endgenerate

endmodule

module lt_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire signed [31:0] tmp1, tmp2;
    assign tmp1 = a;
    assign tmp2 = b;

    assign overflow = 0;
    assign s = (tmp1 < tmp2);

endmodule

module ge_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire signed [31:0] tmp1, tmp2;
    assign tmp1 = a;
    assign tmp2 = b;

    assign overflow = 0;
    assign s = (tmp1 >= tmp2);

endmodule

module multiplexer_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a,
    input  [DATA_WIDTH-1 : 0] b,
    input   select
) ;

genvar i;
generate
for(i=0;i<DATA_WIDTH;i=i+1) begin
    assign s[i] = (~select & a[i]) | (select & b[i]);
end
endgenerate

endmodule