/**
* @file adaptive_predictor.sv
* Implements a two-level adaptive branch predictor.
*/

module adaptive_predictor #(
    parameter BITS
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] predict_addr,
    input  logic [31:0] resolve_addr,
    input  logic        record_result,
    input  logic        resolve_taken,
    output logic        prediction
);

    localparam POSSIBLE_HISTORIES = (1 << BITS);
    localparam COUNTER_INIT = (1 << (BITS - 1));

    // Local history for each possible branch address
    logic [BITS-1:0] history_table[255:0];
    // Saturating counter for each possible history of each possible address
    logic [BITS-1:0] pattern_table[255:0][POSSIBLE_HISTORIES-1:0];
    
    // Internal register that stores the current counter state for the branch
    // being resolved
    logic [BITS-1:0] resolve_counter;
    assign resolve_counter = pattern_table[resolve_addr][history_table[resolve_addr]];

    int i;
    int j;
    always @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 256; i++) begin
                history_table[i] <= {BITS{1'b0}};
                for (int j = 0; j <= POSSIBLE_HISTORIES - 1; j++) begin
                    pattern_table[i][j] <= COUNTER_INIT;
                end
            end
        end else if (record_result) begin
            // Update history table
            if (BITS == 1) begin
                history_table[resolve_addr] <= resolve_taken;
            end else begin
                history_table[resolve_addr] <= {history_table[resolve_addr][BITS-2:0], resolve_taken};
            end
            // Update pattern table
            if ( (!((resolve_counter == {BITS{1'b1}}) &&  resolve_taken)) &&
                    (!((resolve_counter == {BITS{1'b0}}) && !resolve_taken)) ) 
		 begin
                pattern_table[resolve_addr][history_table[resolve_addr]] <= resolve_counter + (resolve_taken ? 1 : -1);
            end
        end
    end

    assign prediction = pattern_table[predict_addr][history_table[predict_addr]][BITS-1];

endmodule
