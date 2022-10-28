module alu #(
    parameter DATA_WIDTH = 32,
    parameter INST_WIDTH = 5
)(
    input                   i_clk,
    input                   i_rst_n,
    input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
    input  [INST_WIDTH-1:0] i_inst,
    input                   i_valid,
    output [DATA_WIDTH-1:0] o_data,
    output                  o_overflow,
    output                  o_valid
);

wire [31:0] a;
wire [31:0] b;
wire [31:0] result[0:16];
wire [16:0] overflow;

reg [31:0] tmp;
reg o;
reg v;

assign a = i_data_a;
assign b = i_data_b;

assign o_data = tmp;
assign o_overflow = o;
assign o_valid = v;

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

always @((i_inst or i_data_a or i_data_b) and posedge i_clk) begin
    
    case (i_inst)
        5'd0: begin tmp = result[0]; o = overflow[0]; v = 1; end
        5'd1: begin tmp = result[1]; o = overflow[1]; v = 1; end
        5'd2: begin tmp = result[2]; o = overflow[2]; v = 1; end
        5'd3: begin tmp = result[3]; o = overflow[3]; v = 1; end
        5'd4: begin tmp = result[4]; o = overflow[4]; v = 1; end
        5'd5: begin tmp = result[5]; o = overflow[5]; v = 1; end
        5'd6: begin tmp = result[6]; o = overflow[6]; v = 1; end
        5'd7: begin tmp = result[7]; o = overflow[7]; v = 1; end
        5'd8: begin tmp = result[8]; o = overflow[8]; v = 1; end
        5'd9: begin tmp = result[9]; o = overflow[9]; v = 1; end
        5'd10: begin tmp = result[10]; o = overflow[10]; v = 1; end
        5'd11: begin tmp = result[11]; o = overflow[11]; v = 1; end
        5'd12: begin tmp = result[12]; o = overflow[12]; v = 1; end
        5'd13: begin tmp = result[13]; o = overflow[13]; v = 1; end
        5'd14: begin tmp = result[14]; o = overflow[14]; v = 1; end
        5'd15: begin tmp = result[15]; o = overflow[15]; v = 1; end
        5'd16: begin tmp = result[16]; o = overflow[16]; v = 1; end
        default: begin tmp = 0; o = 0; v = 0; end
    endcase

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
    multiplexer2_32bits multi(s, a, b, tmp[0]);

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
    multiplexer2_32bits multi(s, a, b, tmp[0]);

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

module multiplexer2_32bits #(parameter DATA_WIDTH = 32
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

