/**
* @file imm_selector.sv
* Module that extracts the immediate from an instruction.
*/

module imm_selector (
    input  logic [31:0] instr,
    output logic [31:0] imm
);

    logic [6:0] opcode;
    assign opcode = instr[6:0];
    logic [31:0] I_type_imm;
    logic [31:0] S_type_imm;
    logic [31:0] B_type_imm;
    logic [31:0] U_type_imm;
    logic [31:0] J_type_imm;
    assign I_type_imm = {{20{instr[31]}}, instr[31:20]};
    assign S_type_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign B_type_imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign U_type_imm = {instr[31:12], 12'b0};
    assign J_type_imm = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    always_comb begin
        casez (opcode)
            7'b00?0011, 7'b1100111: imm = I_type_imm;  // I Type
            7'b0100011: imm = S_type_imm;  // S Type
            7'b1100011: imm = B_type_imm;  // B Type
            7'b0?10111: imm = U_type_imm;  // U Type (no sign extension)
            7'b1101111: imm = J_type_imm;  // J Type
            default: imm = 0;
        endcase
    end

endmodule
