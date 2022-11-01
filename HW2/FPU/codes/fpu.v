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
    wire [DATA_WIDTH-1:0] result[0:1];

    reg  [DATA_WIDTH-1:0] tmp;

    assign o_data = tmp;
    assign o_valid = 1;

    adder           add1        (result[0], i_data_a, i_data_b);
    multiplier      multiply1   (result[1], i_data_a, i_data_b);

    always @(posedge i_clk) begin
        case (i_inst)
            1'b0: begin tmp = result[0]; end
            1'b1: begin tmp = result[1]; end
        endcase
    end

endmodule

module multiplier #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1:0] result,
    input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b
);

    wire s;
    reg [8:0] tmpex;
    reg [47:0] tmpsum;

    wire [7:0] rexs;
    wire [23:0] rfrs;
    
    assign s = i_data_a[31] ^ i_data_b[31];
    
    always @(i_data_a or i_data_b) begin
        tmpex    = i_data_a[30:23] + i_data_b[30:23] - 8'b01111111;
        tmpsum   = {1'b1, i_data_a[22:0]} * {1'b1, i_data_b[22:0]};

        if (tmpsum[47] == 0) begin
            tmpsum  = tmpsum << 1;
        end
        else begin
            tmpex   = tmpex + 1;
        end

        // $monitor("%4d buf: %b tmpsum: %b", $time, tmpsum[23:0], tmpsum[47:24]);
    end

    float_rounder flr(rexs, rfrs, s, s, tmpex, tmpsum[23:0], tmpsum[47:24]);

    assign result = {s, rexs, rfrs[22:0]};
    
endmodule

module adder #(parameter DATA_WIDTH = 32
)(
    output [DATA_WIDTH-1:0] result,
    input  [DATA_WIDTH-1:0] i_data_a,
    input  [DATA_WIDTH-1:0] i_data_b
) ;

    wire mul_ex1, mul_fr1, mul_fr2, ss, fr1s, fr2s;
    wire [7:0] sh1, ex1, exs, rexs;
    wire [23:0] fr1, fr2, sh_fr1, sh_buf, frs, rfrs;
    wire signed [8:0] ex_dif;

    assign fr1s = (i_data_a[31] & (~mul_fr1)) | (i_data_b[31] & mul_fr1);
    assign fr2s = (i_data_a[31] & (~mul_fr2)) | (i_data_b[31] & mul_fr2);

    sub_signed_9bits        subs(ex_dif, {1'b0, i_data_a[30:23]}, {1'b0, i_data_b[30:23]});
    control1                con1(mul_ex1, mul_fr1, mul_fr2, sh1, ex_dif);

    multiplexer2_8bits      multi1(ex1, i_data_a[30:23], i_data_b[30:23], mul_ex1);
    multiplexer2_24bits     multi2(fr1, {1'b1, i_data_a[22:0]}, {1'b1, i_data_b[22:0]}, mul_fr1);
    multiplexer2_24bits     multi3(fr2, {1'b1, i_data_a[22:0]}, {1'b1, i_data_b[22:0]}, mul_fr2);

    shr_8bits               shr1(sh_buf, sh_fr1, fr1, sh1);
    float_adder             fla(ss, exs, frs, fr1s, fr2s, ex1, sh_fr1, fr2);
    float_rounder           flr(rexs, rfrs, fr1s, ss, exs, sh_buf, frs);

    assign result           = {ss, rexs, rfrs[22:0]};

endmodule

module float_adder #(parameter DATA_WIDTH = 24
)(
    output ss,
    output [7:0] exs,
    output [DATA_WIDTH-1 : 0] s,
    input   sa, sb,
    input  [7:0] ex,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire signed [31 : 0] tmpw;

    reg tmpss;
    reg [7:0] tmpex;
    reg signed [31 : 0] tmpa, tmpb, tmps, ttmps;

    assign tmpw = tmpa + tmpb;
    assign ss = tmpss;
    assign exs = tmpex;
    assign s = ttmps;
    

    integer i, j;

    always @(a or b) begin
        tmpa = sa ? ~a+1 : a;
        tmpb = sb ? ~b+1 : b;
        tmpex = ex;

        if (tmpw >= 0) begin
            tmps = tmpw;
            tmpss = 0;
        end
        else begin
            tmps = ~tmpw + 1;
            tmpss = 1;
        end
    end

    always @(tmps) begin
        i = 32'h00000000;
        j = 32'h00800000;
        if (tmps[24]) begin
            tmpex = ex + 1;
            ttmps = tmps >> 1;
        end
        else begin
            while ((j & tmps) == 0) begin
                j = j >> 1;
                i = i + 1;
            end

            tmpex = tmpex - i;
            ttmps = tmps << i;
        end
    end

endmodule

module float_rounder #(parameter DATA_WIDTH = 24
)(
    output [7:0] rexs,
    output [DATA_WIDTH-1:0] rfrs,
    input s1, ss,
    input [7:0] exs,
    input [DATA_WIDTH-1:0] fr1_buf, frs
) ;

    wire r, s, l;
    reg [7:0] tmpex;
    reg [DATA_WIDTH:0] tmps;

    assign r = fr1_buf[DATA_WIDTH-1];
    assign s = fr1_buf[DATA_WIDTH-2:0] > 0;
    assign l = frs[0];

    assign rexs = tmpex;
    assign rfrs = tmps[DATA_WIDTH-1:0];

    always @(s1 or ss or fr1_buf or frs or exs) begin

        tmpex = exs;
        tmps = frs;

        if (r == 1 && s == 1) begin
            if (s1 == ss) begin
                tmps = tmps + 1;
                if (tmps[24] == 1) begin
                    tmpex = tmpex + 1;
                    tmps  = tmps >> 1;
                end
            end
            else begin
                tmps = tmps - 1;
                if (tmps[23] == 0) begin
                    tmpex = tmpex - 1;
                    tmps  = tmps << 1;
                end
            end
        end
        else if (l == 1 && r == 1 && s == 0) begin
            if (s1 == ss) begin
                tmps = tmps + 1;
                if (tmps[24] == 1) begin
                    tmpex = tmpex + 1;
                    tmps  = tmps >> 1;
                end
            end
        end
    end

endmodule

module add_signed_9bits #(parameter DATA_WIDTH = 9
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    wire [DATA_WIDTH-1:0] tmp;

    assign tmp = a + b;

    assign s = tmp;

endmodule

module sub_signed_9bits #(parameter DATA_WIDTH = 9
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a, 
    input  [DATA_WIDTH-1 : 0] b
) ;

    add_signed_9bits adds(s, a, ~b+1);

endmodule

module multiplexer2_8bits #(parameter DATA_WIDTH = 8
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a,
    input  [DATA_WIDTH-1 : 0] b,
    input   select
) ;

    assign s[0] = (~select & a[0]) | (select & b[0]);
    assign s[1] = (~select & a[1]) | (select & b[1]);
    assign s[2] = (~select & a[2]) | (select & b[2]);
    assign s[3] = (~select & a[3]) | (select & b[3]);
    assign s[4] = (~select & a[4]) | (select & b[4]);
    assign s[5] = (~select & a[5]) | (select & b[5]);
    assign s[6] = (~select & a[6]) | (select & b[6]);
    assign s[7] = (~select & a[7]) | (select & b[7]);

endmodule

module multiplexer2_24bits #(parameter DATA_WIDTH = 24
)(
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a,
    input  [DATA_WIDTH-1 : 0] b,
    input   select
) ;


    assign s[0] = (~select & a[0]) | (select & b[0]);
    assign s[1] = (~select & a[1]) | (select & b[1]);
    assign s[2] = (~select & a[2]) | (select & b[2]);
    assign s[3] = (~select & a[3]) | (select & b[3]);
    assign s[4] = (~select & a[4]) | (select & b[4]);
    assign s[5] = (~select & a[5]) | (select & b[5]);
    assign s[6] = (~select & a[6]) | (select & b[6]);
    assign s[7] = (~select & a[7]) | (select & b[7]);
    assign s[8] = (~select & a[8]) | (select & b[8]);
    assign s[9] = (~select & a[9]) | (select & b[9]);
    assign s[10] = (~select & a[10]) | (select & b[10]);
    assign s[11] = (~select & a[11]) | (select & b[11]);
    assign s[12] = (~select & a[12]) | (select & b[12]);
    assign s[13] = (~select & a[13]) | (select & b[13]);
    assign s[14] = (~select & a[14]) | (select & b[14]);
    assign s[15] = (~select & a[15]) | (select & b[15]);
    assign s[16] = (~select & a[16]) | (select & b[16]);
    assign s[17] = (~select & a[17]) | (select & b[17]);
    assign s[18] = (~select & a[18]) | (select & b[18]);
    assign s[19] = (~select & a[19]) | (select & b[19]);
    assign s[20] = (~select & a[20]) | (select & b[20]);
    assign s[21] = (~select & a[21]) | (select & b[21]);
    assign s[22] = (~select & a[22]) | (select & b[22]);
    assign s[23] = (~select & a[23]) | (select & b[23]);

endmodule

module shr_8bits #(parameter DATA_WIDTH = 24, SH_WIDTH = 8
)(
    output [DATA_WIDTH-1 : 0] s_buf,
    output [DATA_WIDTH-1 : 0] s,
    input  [DATA_WIDTH-1 : 0] a,
    input  [SH_WIDTH-1 : 0] b
) ;

    reg [2*DATA_WIDTH-1 : 0] tmp;
    reg [SH_WIDTH-1 : 0]   bits;

    assign {s, s_buf} = tmp;

    always @(a or b) begin
        tmp = {a, 24'h000000};
        bits = b;

        tmp = tmp >> bits;
    end

endmodule

module control1(
    output ex1, fr1, fr2,
    output [7:0] sh1,
    input [8:0] ex_dif
) ;

    wire ge0;
    wire signed [8:0] ex_dif_tmp;
    reg [7:0] sh;

    assign ex_dif_tmp = ex_dif;

    assign ge0 = ex_dif_tmp >= 0;
    assign ex1 = ~ge0;
    assign fr1 = ge0;
    assign fr2 = ~ge0;
    assign sh1 = sh;

    always @(ex_dif) begin
        if (ge0)
            sh = ex_dif;
        else
            sh = ~ex_dif + 1;
    end

endmodule
