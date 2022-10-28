module fpu #(
    parameter DATA_WIDTH = 32,
    parameter INST_WIDTH = 1
)(
    input                   i_clk,
    input                   i_rst_n,
    input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b,
    input  [INST_WIDTH-1:0] i_inst,
    input                   i_valid,
    output [DATA_WIDTH-1:0] o_data,
    output                  o_valid
);

    // homework

    wire [7:0] ex_dif;

    sub_signed_32bits subs(ex_dif, i_data_a[30:23], i_data_b[30:23]);
    

endmodule

module add_signed_8bits #(parameter DATA_WIDTH = 8
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire [DATA_WIDTH-1:0] tmp;

    assign tmp = a + b;

    assign overflow = (a[DATA_WIDTH] == 0 && b[DATA_WIDTH] == 0 && tmp[DATA_WIDTH] == 1) | 
                      (a[DATA_WIDTH] == 1 && b[DATA_WIDTH] == 1 && tmp[DATA_WIDTH] == 0);
    
    assign s = tmp;

endmodule

module sub_signed_8bits #(parameter DATA_WIDTH = 8
)(
    output overflow,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    add_signed_32bits adds(overflow, s, a, ~b+1);

endmodule

module multiplexer2_8bits #(parameter DATA_WIDTH = 8
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

module multiplexer2_23bits #(parameter DATA_WIDTH = 23
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

module control1(
    output ex1, fr1, fr2,
    output [7:0] sh1;
    input [7:0] ex_dif
) ;

always @(ex_dif) begin
    
end

endmodule
