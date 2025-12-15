`timescale 1ns / 1ps

module testbench ();
    logic clk;
    logic reset;
    logic [31:0] cycle_count;

    top cpu (
        .clk  (clk),
        .reset(reset)
    );

    initial begin
        $readmemh("instructions.hex", cpu.imem.InstructionRam);
        clk   = 1;
        reset = 1;
        #201 reset = 0;
        cycle_count = 0;
    end
    always #50 clk = ~clk;

    always @(posedge clk) begin
        cycle_count <= cycle_count + 1;
    end

    int i;
    integer file_handle;
    always @(cpu.IF_pc) begin
        if (cpu.IF_pc == 32'h44) begin
            file_handle = $fopen("results.txt", "a");
            $fwrite(file_handle, "%d\n", cycle_count);
            $finish;
        end
    end

endmodule
