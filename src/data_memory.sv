/**
* @file data_memory.sv
* Implements the data memory used by the processor.
*/

module data_memory (
    input  logic        clock,
    input  logic        write_enable,
    input  logic [13:0] address,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);

    logic [31:0] RAM [7919:0];

    assign read_data = RAM[address];

    always_ff @(posedge clock) begin
        if (write_enable) begin
            RAM[address] <= write_data;
        end
    end

endmodule
