module cpu #( // Do not modify interface
	parameter ADDR_W = 64,
	parameter INST_W = 32,
	parameter DATA_W = 64
)(
    input                   i_clk,
    input                   i_rst_n,
    input                   i_i_valid_inst, // from instruction memory
    input  [ INST_W-1 : 0 ] i_i_inst,       // from instruction memory
    input                   i_d_valid_data, // from data memory
    input  [ DATA_W-1 : 0 ] i_d_data,       // from data memory
    output                  o_i_valid_addr, // to instruction memory
    output [ ADDR_W-1 : 0 ] o_i_addr,       // to instruction memory
    output [ DATA_W-1 : 0 ] o_d_data,       // to data memory
    output [ ADDR_W-1 : 0 ] o_d_addr,       // to data memory
    output                  o_d_MemRead,    // to data memory
    output                  o_d_MemWrite,   // to data memory
    output                  o_finish
);

    reg [6:0] opcode;
    reg [4:0] rs1, rs2, rd;
    reg [2:0] fun3;
    reg [6:0] fun7;
    reg [12:0] imm;

    reg [DATA_W-1:0] x[0:31];

    reg [ADDR_W-1:0] o_i_addr_r;
    reg [DATA_W-1:0] o_d_data_r;
    reg [ADDR_W-1:0] o_d_addr_r;

    // signal
    reg o_i_valid_addr_r;
    reg o_d_MemRead_r;
    reg o_d_MemWrite_r;
    reg o_finish_r;

    assign o_i_valid_addr   = o_i_valid_addr_r;
    assign o_d_MemRead      = o_d_MemRead_r;
    assign o_d_MemWrite     = o_d_MemWrite_r;
    assign o_finish         = o_finish_r;

    always @(posedge i_clk) begin
        if (i_i_valid_inst) begin
            opcode  = i_i_inst[6:0];
            fun3    = i_i_inst[14:12];

            case(opcode)
                7'b0000011:     // ld
                begin 
                    rd                      = i_i_inst[11:7]; 
                    rs1                     = i_i_inst[19:15]; 
                    imm                     = i_i_inst[31:20];
                    o_d_addr_r              = x[rs1] + imm << 3;
                    o_d_MemRead_r           = 1'b1;
                end
                7'b0100011:     // sd
                begin 
                    rs1                     = i_i_inst[19:15]; 
                    rs2                     = i_i_inst[24:20]; 
                    imm[4:0]                = i_i_inst[11:7];
                    imm[11:5]               = i_i_inst[31:25];
                    o_d_addr_r              = x[rs1] + imm << 3;
                    o_d_data_r              = x[rs2];
                    o_d_MemWrite_r          = 1'b1;
                end
                7'b1100011:     // branch
                begin 
                    rs1                     = i_i_inst[19:15]; 
                    rs2                     = i_i_inst[24:20]; 
                    {imm[3:0], imm[10]}     = i_i_inst[11:7];
                    {imm[11], imm[9:4]}     = i_i_inst[31:25];

                    if ((fun3[0] && (rs1 != rs2)) || (!fun3[0] && (rs1 == rs2))) begin
                        o_i_addr_r          = imm << 1;
                        o_i_valid_addr_r    = 1;
                    end 
                    else begin
                        o_i_addr_r          = 0;
                        o_i_valid_addr_r    = 0;
                    end 
                end
                7'b0010011:     // RI
                begin
                    rd                      = i_i_inst[11:7]; 
                    rs1                     = i_i_inst[19:15]; 
                    imm                     = i_i_inst[31:20];

                    case(fun3)
                        3'b000: x[rd] = x[rs1] + imm;
                        3'b100: x[rd] = x[rs1] ^ imm;
                        3'b110: x[rd] = x[rs1] | imm;
                        3'b111: x[rd] = x[rs1] & imm;
                        3'b001: x[rd] = x[rs1] << imm;
                        3'b101: x[rd] = x[rs1] >> imm;
                    endcase
                end
                7'b0110011:     // R
                begin 
                    rd                      = i_i_inst[11:7];
                    rs1                     = i_i_inst[19:15]; 
                    rs2                     = i_i_inst[24:20]; 
                    fun7                    = i_i_inst[31:25];

                    case ({fun7, fun3})
                        10'b0000000000: x[rd] = x[rs1] + x[rs2]; 
                        10'b0100000000: x[rd] = x[rs1] - x[rs2]; 
                        10'b0000000100: x[rd] = x[rs1] ^ x[rs2]; 
                        10'b0000000110: x[rd] = x[rs1] | x[rs2]; 
                        10'b0000000111: x[rd] = x[rs1] & x[rs2]; 
                    endcase
                end
                7'b1111111:     // stop
                begin 
                    o_finish_r = 1'b1;
                end
            endcase 
        end
        else if (i_d_valid_data) begin
        end
    end

    always @(negedge i_clk) begin
        o_i_valid_addr_r    = 1'b0;
        o_d_MemRead_r       = 1'b0;
        o_d_MemWrite_r      = 1'b0;
    end

endmodule
