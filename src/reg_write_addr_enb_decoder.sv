/**
* @file reg_write_addr_enb_decoder.sv
* Used to decode which instructions need to write back to a register and to
* determine the register being written to.
*/

module reg_write_addr_enb_decoder (
    input  logic [31:0] instr,
    output logic        reg_write_enb,
    output logic [ 4:0] reg_write_addr
);

    localparam ALU = 7'b0110011;
    localparam ALUi = 7'b0010011;
    localparam LW = 7'b0000011;
    localparam SW = 7'b0100011;
    localparam BEQ = 7'b1100011;
    localparam JAL = 7'b1101111;
    localparam JALR = 7'b1100111;
    localparam AUIP = 7'b0010111;

    assign reg_write_addr = instr[11:7];

    logic [6:0] opcode;
    assign opcode = instr[6:0];

    always_comb begin
        if (reg_write_addr != 5'b00000) begin
            case (opcode)
                ALU, ALUi, LW, JALR, AUIP: reg_write_enb = 1;
                default:                   reg_write_enb = 0;
            endcase
        end else begin
            reg_write_enb = 0;
        end
    end

endmodule
