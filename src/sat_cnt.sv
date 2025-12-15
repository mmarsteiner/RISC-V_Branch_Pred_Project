/**
* @file sat_cnt.sv
* Implements a saturating counter branch predictor.
*/

module sat_cnt #(
    parameter BITS = 1
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] predict_addr,
    input  logic [31:0] resolve_addr,
    input  logic        record_result,
    input  logic        resolve_taken,
    output logic        prediction
);

    logic [BITS-1:0] prediction_table[127:0];

    int i;
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i <= 127; i = i + 1) begin
                prediction_table[i] <= {1'b1, {(BITS - 1) {1'b0}}};
            end
        end else if (record_result) begin

            if ( (!((prediction_table[resolve_addr] == {BITS{1'b1}}) &&  resolve_taken))    && 
                    (!((prediction_table[resolve_addr] == {BITS{1'b0}}) && !resolve_taken)) )
		 begin
                prediction_table[resolve_addr] <= prediction_table[resolve_addr] + (resolve_taken ? 1 : -1);
            end
        end
    end

    assign prediction = prediction_table[predict_addr][BITS-1];

endmodule
