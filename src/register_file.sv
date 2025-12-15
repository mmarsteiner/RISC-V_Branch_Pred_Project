/**
* @file register_file.sv
* Represents the register file
*/

module register_file (
    input logic clock,
    input logic reset,
    input logic WB_reg_wr_enb,
    input logic [4:0] ID_reg_read_addr1,
    input logic [4:0] ID_reg_read_addr2,
    input logic [4:0] WB_reg_write_addr,
    input logic [31:0] WB_reg_write_data,
    output logic [31:0] ID_reg_read_data_1,
    output logic [31:0] ID_reg_read_data_2
);

    logic [31:0] registers[31:0];

    assign ID_reg_read_data_1 = registers[ID_reg_read_addr1];
    assign ID_reg_read_data_2 = registers[ID_reg_read_addr2];

    logic [31:0] x9;
    assign x9 = registers[9];
    logic [31:0] x1;
    assign x1 = registers[1];

    int i;
    always_ff @(posedge clock) begin
        if (reset) begin
            for (i = 0; i < 32; i++) begin
                registers[i] <= 32'b0;
            end
        end
        if (WB_reg_wr_enb && WB_reg_write_addr != 5'b0) begin
            registers[WB_reg_write_addr] <= WB_reg_write_data;
        end
    end

endmodule
