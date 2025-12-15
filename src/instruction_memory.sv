/**
* @file instruction_memory.sv
* Implements the instruction memory used by the processor.
*/

module instruction_memory (
    input  logic [31:0] read_address,
    output logic [31:0] instruction
);

    logic [31:0] InstructionRam[255:0];

    // Instructions are aligned on pc multiples of 4, so drop the lowest
    // 2 bits to get the index
    assign instruction = InstructionRam[{2'b00, read_address[31:2]}];

endmodule
