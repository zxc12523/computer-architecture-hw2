module wow();

wire [31:0] a = 32'hfffffffe;
wire [31:0] b = 32'hffffffff;

wire [31:0] result[0:16];
wire overflow;

add_signed_32bits       adds    (overflow, result[0], a, b);
// sub_signed_32bits       subs    (overflow, result[1], a, b);
// mul_signed_32bits       muls    (overflow, result[2], a, b);
// max_signed_32bits       maxs    (result[3], a, b);
// min_signed_32bits       mins    (result[4], a, b);
add_unsigned_32bits     addu    (overflow, result[5], a, b);
// sub_unsigned_32bits     subu    (overflow, result[6], a, b);
// mul_unsigned_32bits     mulu    (overflow, result[7], a, b);
// max_unsigned_32bits     maxu    (result[8], a, b);
// min_unsigned_32bits     minu    (result[9], a, b);
and_32bits              and1    (result[10], a, b);
or_32bits               or1     (result[11], a, b);
xor_32bits              xor1    (result[12], a, b);
not_32bits              not1    (result[13], a);
reverse_32bits          rev     (result[14], a);
lt_signed_32bits        lts     (result[15], a, b);
ge_signed_32bits        ges     (result[16], a, b);

integer i;

initial begin
    for(i=0;i<1;i=i+1) begin
        $display("time / a / b");
        $monitor("%4d %b %b", $time, a, b);
        #10
        $monitor("%4d %b %b", $time, result[15], overflow);
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

    wire [DATA_WIDTH-1:0] notb;
    not_32bits not1(notb, b);
    add_signed_32bits(overflow, s, a, notb);

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

module max_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign s = (a <= b) ? b : a;

endmodule

module min_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign s = (a <= b) ? a : b;

endmodule

module and_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign s = a & b;

endmodule

module or_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign s = a | b;

endmodule

module xor_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign s = a ^ b;

endmodule

module not_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a
) ;

    assign s = ~a;

endmodule

module reverse_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a
) ;

genvar i;
generate
for(i=0;i<DATA_WIDTH;i=i+1) begin
    assign s[i] = a[DATA_WIDTH-i];
end
endgenerate

endmodule

module lt_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

reg signed [31:0] tmp1;
reg signed [31:0] tmp2;

always @(a or b) begin
    tmp1 <= a;
    tmp2 <= b;
end

assign s = (tmp1 < tmp2);

endmodule

module ge_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

reg signed [31:0] tmp1;
reg signed [31:0] tmp2;

always @(a or b) begin
    tmp1 <= a;
    tmp2 <= b;
end

assign s = (tmp1 >= tmp2);

endmodule

module signed_32bits #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a
) ;

wire [31:0] tmp;
not_32bits not1(tmp, a);
assign s = tmp + 1;

endmodule