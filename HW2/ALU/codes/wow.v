// module wow();

// reg [31:0] a = 32'h123;
// reg [31:0] b = 32'h123;
// reg [31:0] s;
// reg overflow;

// add_unsigned_32bits add(overflow, s, a, b);

// endmodule

// module cmp_unsigned_32bits #(parameter DATA_WIDTH = 32
// )(
//     output ret,
//     input  [DATA_WIDTH-1 : 0] a, 
//     input  [DATA_WIDTH-1 : 0] b
// ) ;

// always @ (a or b) begin

// if (a <= b) 
//     ret = 1'b0;
// else 
//     ret = 1'b1;

// end

// endmodule

module add_unsigned_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    assign {overflow, s} = a + b;

endmodule

module add_signed_32bits #(parameter DATA_WIDTH = 32
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire o1, o2;

    assign {o1, s} = a + b;

endmodule