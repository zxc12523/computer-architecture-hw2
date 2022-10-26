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

reg [DATA_WIDTH:0] result;
assign o_data = result[31:0];
assign o_overflow = result[32];

integer i;

always @(i_inst or i_data_a or i_data_b) begin
    // homework
    if (i_inst == 5'd10)
        result = i_data_a & i_data_b;
    else if (i_inst == 5'd11)
        result = i_data_a | i_data_b;
    else if (i_inst == 5'd12)
        result = i_data_a ^ i_data_b;
    else if (i_inst == 5'd13)
        result = ~i_data_a;
    else if (i_inst == 5'd13)
        for( i = 0 ; i < DATA_WIDTH ; i = i + 1 ) begin
            result[i] = i_data_a[31-i];
        end
    else if (i_inst == 5'd15)
        result = i_data_a < i_data_b;
    else if (i_inst == 5'd16)
        result = i_data_a >= i_data_b;
        
end
endmodule

// module cmp_unsigned_32bits #(parameter DATA_WIDTH = 32
// )(
//     output ret,
//     input  [DATA_WIDTH-1 : 0] a, 
//     input  [DATA_WIDTH-1 : 0] b
// ) ;

// integer i;
// for(i=DATA_WIDTH-1;i>=0;i--) {
//     if (a[i] < b[i])
//         assign ret = 0;
// }

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

// module add_signed_32bits #(parameter DATA_WIDTH = 32
// )(
//     output overflow,
//     output [DATA_WIDTH-1 : 0] s,
//     input  [DATA_WIDTH-1 : 0] a, 
//     input  [DATA_WIDTH-1 : 0] b
// ) ;

//     wire o1, o2;

//     assign {o1, s} = a + b;

// endmodule

// module HA (output s, output c, input a, input b) ;
//     assign s = a ^ b;
//     assign c = a & b;
// endmodule

// module FA (output s, output c_out, input a, input b, input c_in) ;
//     assign s = a ^ b ^ c_in;
//     assign c_out = a*b + b*c_in + c_in*a;
// endmodule