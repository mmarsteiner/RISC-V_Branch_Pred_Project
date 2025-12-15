module top (
    input logic clk,
    input logic reset
);

    logic [ 6:0] IF_opcode;
    logic [ 6:0] ID_opcode;
    logic [ 6:0] EX_opcode;
    logic [ 6:0] MEM_opcode;
    logic [ 6:0] WB_opcode;
    logic        EX_branch_taken;
    logic        EX_jump_taken;
    logic        ID_op2_sel;
    logic        wb_sel;
    logic        WB_reg_wr_enb;
    logic        pc_sel;


    logic [31:0] IF_pc;
    logic [31:0] ID_pc;
    logic [31:0] EX_pc;

    logic [31:0] IF_instr;
    logic [31:0] ID_instr;
    logic [31:0] EX_instr;
    logic [31:0] MEM_instr;
    logic [31:0] WB_instr;


    logic        ID_reg_read_enb_1;
    logic [ 4:0] ID_reg_read_addr1;

    logic        ID_reg_read_enb_2;
    logic [ 4:0] ID_reg_read_addr2;

    logic [31:0] ID_reg_read_data_1;
    logic [31:0] ID_reg_read_data_2;

    logic [31:0] EX_read_data_1;
    logic [31:0] EX_read_data_2;

    logic [31:0] MEM_read_data_2;


    logic [31:0] ID_imm;
    logic [31:0] IF_imm;
    logic [31:0] EX_imm;
    logic [31:0] left_shifted_imm;


    logic [31:0] MEM_reg_write_data;
    logic [31:0] WB_reg_write_data;

    logic        EX_reg_write_enb;
    logic [ 4:0] EX_reg_write_addr;

    logic        MEM_reg_write_enb;
    logic [ 4:0] MEM_reg_write_addr;

    logic        WB_reg_write_enb;
    logic [ 4:0] WB_reg_write_addr;


    logic [ 3:0] EX_alu_op;
    logic [ 3:0] EX_alu_func;
    logic [ 3:0] EX_alu_ctrl;
    logic [31:0] EX_alu_input_1;
    logic [31:0] EX_alu_input_2;
    logic [31:0] EX_alu_result;
    logic [31:0] MEM_alu_result;


    logic        dmem_write_enb;
    logic [31:0] dmem_read_data;

    logic        stall;
    logic [31:0] IF_branch_target;
    logic [31:0] EX_branch_target;
    logic [ 2:0] EX_funct3;

    logic        branch_pred_incorrect;
    //logic [31:0] branch_resolution_pc;
    logic [31:0] EX_jump_addr;


    localparam ALU = 7'b0110011;
    localparam ALUi = 7'b0010011;
    localparam LW = 7'b0000011;
    localparam SW = 7'b0100011;
    localparam BR = 7'b1100011;
    localparam JAL = 7'b1101111;
    localparam JALR = 7'b1100111;
    localparam AUIP = 7'b0010111;
    localparam LUI = 7'b0110111;

    // debug only
    assign EX_ALU = ((EX_opcode == ALU) || (EX_opcode == ALUi));
    assign EX_LW  = (EX_opcode == LW);
    assign EX_SW  = (EX_opcode == SW);
    assign EX_BR  = (EX_opcode == BR);
    assign EX_JMP = ((EX_opcode == JAL) || (EX_opcode == JALR));

    assign IF_BR  = (IF_opcode == BR);

    //---------------------------
    //      IF_pc mux
    //---------------------------
    always_ff @(posedge clk) begin
        if (reset) IF_pc <= 32'b0;
        else if (stall) begin
            IF_pc <= IF_pc;
        end else if (branch_pred_incorrect) begin
            if (IF_predict_branch) IF_pc <= EX_pc + 4;
            else IF_pc <= EX_branch_target;
        end else if (EX_jump_taken) begin
            IF_pc <= EX_jump_addr;
        end else if (IF_opcode == BR) begin
            IF_pc <= (predict_branch) ? IF_branch_target : IF_pc + 4;
        end else begin
            IF_pc <= IF_pc + 4;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) ID_pc <= 32'b0;
        else if (!stall) ID_pc <= IF_pc;
    end

    instruction_memory imem (
        .read_address(IF_pc),
        .instruction (IF_instr)
    );

    always_ff @(posedge clk) begin
        if (reset) EX_imm <= 32'b0;
        else EX_imm <= ID_imm;
    end

    assign IF_opcode  = IF_instr[6:0];
    assign ID_opcode  = ID_instr[6:0];
    assign EX_opcode  = EX_instr[6:0];
    assign MEM_opcode = MEM_instr[6:0];
    assign WB_opcode  = WB_instr[6:0];


    //--------------------------- 
    //     Control logic
    //--------------------------- 
    always_comb begin
        ID_op2_sel = ID_opcode == ALU || ID_opcode == BR;

        dmem_write_enb = MEM_opcode == SW;

        WB_reg_wr_enb   = WB_opcode == ALU || WB_opcode == ALUi || WB_opcode == LW || 
                          WB_opcode == JAL || WB_opcode == JALR || WB_opcode == AUIP;

        wb_sel = MEM_opcode == LW;

        pc_sel = !EX_branch_taken;
    end


    //----------------------------------------------------------------
    //   Instruction Fetch to Instruction Decode / Register Fetch
    //----------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            ID_instr <= 0;
        end else begin
            if (branch_pred_incorrect) ID_instr <= 32'h000013;
            else if (!stall) ID_instr <= IF_instr;  // IF_pc stalled
        end
    end

    assign ID_reg_read_addr1 = ID_instr[19:15];
    assign ID_reg_read_addr2 = ID_instr[24:20];

    always_comb begin
        case (ID_opcode)
            ALU, ALUi, LW, SW, BR, JALR: ID_reg_read_enb_1 = 1;  // types R, I, S, B
            default:                     ID_reg_read_enb_1 = 0;
        endcase
        case (ID_opcode)
            ALU, SW, BR: ID_reg_read_enb_2 = 1;  // types R, S, B
            default:     ID_reg_read_enb_2 = 0;
        endcase
    end

    register_file reg_file (
        .clock             (clk),
        .reset             (reset),
        .WB_reg_wr_enb     (WB_reg_write_enb),    // input
        .ID_reg_read_addr1 (ID_reg_read_addr1),   // input
        .ID_reg_read_addr2 (ID_reg_read_addr2),   // input
        .WB_reg_write_addr (WB_reg_write_addr),   // input
        .WB_reg_write_data (WB_reg_write_data),   // input
        .ID_reg_read_data_1(ID_reg_read_data_1),  // output
        .ID_reg_read_data_2(ID_reg_read_data_2)   // output
    );


    imm_selector imm_sel (
        .instr(ID_instr),  // input 
        .imm(ID_imm)  // combinatorial output
    );

    imm_selector IF_imm_sel (
        .instr(IF_instr),  // input 
        .imm(IF_imm)  // combinatorial output
    );




    always_comb begin
        if (EX_opcode == AUIP) begin
            EX_alu_input_1 = EX_pc;
        end else if (EX_opcode == LUI) begin
            EX_alu_input_1 = 0;
        end else if ((EX_opcode == JAL) || (EX_opcode == JALR)) begin
            EX_alu_input_1 = EX_pc + 4;
        end else begin
            EX_alu_input_1 = EX_read_data_1;  //ID_reg_read_data_1;
        end
    end


    //----------------------------------------------------------------

    assign EX_alu_op   = {EX_opcode[6], EX_opcode[5], EX_opcode[4], EX_opcode[2]};

    assign EX_alu_func = {EX_instr[30], EX_instr[14:12]};


    //-------------------------
    //        ALU CONTROL
    //-------------------------
    always_comb begin
        casez ({
            EX_alu_op, EX_alu_func
        })
            8'b0?00????: EX_alu_ctrl = 4'b0010;  // load/store word (ADD)
            8'b1?00????: EX_alu_ctrl = 4'b0110;  // beq (SUB)

            8'b0011????: EX_alu_ctrl = 4'b0010;  // ADD (AUIPC)
            8'b01100000: EX_alu_ctrl = 4'b0010;  // ADD
            8'b01101000: EX_alu_ctrl = 4'b0110;  // SUB
            8'b0010?000: EX_alu_ctrl = 4'b0010;  // ADDI

            8'b0?100111: EX_alu_ctrl = 4'b0000; // AND
            8'b0?100100: EX_alu_ctrl = 4'b0011; // XOR
            8'b0?10?110: EX_alu_ctrl = 4'b0001; // OR
            8'b0?10001?: EX_alu_ctrl = 4'b0111; // SLT
            default:    EX_alu_ctrl = 4'b0000;
        endcase
    end

    //-------------------------
    //        ALU
    //-------------------------
    always_comb begin
        case (EX_alu_ctrl)
            4'b0010: EX_alu_result = EX_alu_input_1 + EX_alu_input_2;
            4'b0110: EX_alu_result = EX_alu_input_1 - EX_alu_input_2;
            4'b0000: EX_alu_result = EX_alu_input_1 & EX_alu_input_2;
            4'b0001: EX_alu_result = EX_alu_input_1 | EX_alu_input_2;
            4'b0011: EX_alu_result = EX_alu_input_1 ^ EX_alu_input_2;
            4'b0111: EX_alu_result = (EX_alu_input_1 < EX_alu_input_2) ? 1 : 0;
            default: EX_alu_result = 0;
        endcase
    end
    //----------------------------------------------------------------


    //----------------------------------------------------------------
    //      Instruction Decode/Register Fetch to Execute
    //----------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            EX_instr       <= 0;
            EX_alu_input_2 <= 0;
            EX_read_data_1 <= 0;
            EX_read_data_2 <= 0;
            EX_pc          <= 0;
        end else begin
            //--------------------------------------
            if (branch_pred_incorrect) begin
                EX_instr <= 32'h000013;
            end else if (stall) begin
                EX_instr <= 32'h000013;
            end else begin
                EX_instr <= ID_instr;
            end
            //--------------------------------------

            EX_alu_input_2 <= ID_op2_sel ? ID_reg_read_data_2 : ID_imm;

            EX_read_data_1 <= ID_reg_read_data_1;
            EX_read_data_2 <= ID_reg_read_data_2;


            EX_pc          <= ID_pc;
        end
    end





    //------------------------------------
    //         branch_logic
    //------------------------------------

    assign EX_funct3 = EX_instr[14:12];

    always_comb begin
        if (EX_opcode == BR) begin
            case (EX_funct3)
                3'h0: EX_branch_taken = EX_read_data_1 == EX_read_data_2;
                3'h1: EX_branch_taken = EX_read_data_1 != EX_read_data_2;
                3'h4: EX_branch_taken = $signed(EX_read_data_1) < $signed(EX_read_data_2);
                3'h5: EX_branch_taken = $signed(EX_read_data_1) >= $signed(EX_read_data_2);
                3'h6: EX_branch_taken = EX_read_data_1 < EX_read_data_2;
                3'h7: EX_branch_taken = EX_read_data_1 >= EX_read_data_2;
                default: EX_branch_taken = 0;
            endcase
        end else begin
            EX_branch_taken = 0;
        end
    end  // always_comb


    assign EX_branch_target = EX_imm + EX_pc;

    // early branch target
    assign IF_branch_target = IF_imm + IF_pc;

    logic branch_pred_correct;
    logic IF_predict_branch;

    //----------------------------------------------------------------
    //               Branch resolution logic
    //----------------------------------------------------------------
    always_comb begin
        branch_pred_correct   = 0;
        branch_pred_incorrect = 0;
        if (EX_BR) begin
            if ((EX_branch_taken & IF_predict_branch) || (!EX_branch_taken & !IF_predict_branch))
                branch_pred_correct = 1;
            else branch_pred_incorrect = 1;
        end
    end

    logic [31:0] IF_branch_pc;

    //-------------------------------------------------
    //   capture IF branch info to be used later
    //-------------------------------------------------
    always_ff @(posedge clk) begin
        if (reset) begin
            IF_branch_pc <= 32'b0;
            IF_predict_branch <= 1'b0;
        end else if (IF_BR) begin
            IF_branch_pc <= IF_pc;
            IF_predict_branch <= predict_branch;
        end

    end

`ifdef ADAPTIVE
    adaptive_predictor #(
        .BITS(`NUM_BITS)
    ) u_adaptive_predictor (
        .clk          (clk),
        .reset        (reset),
        .predict_addr (IF_pc),
        .record_result(EX_BR),
        .resolve_addr (IF_branch_pc),
        .resolve_taken(branch_pred_correct),
        .prediction   (predict_branch)
    );
`else
    sat_cnt #(
        .BITS(`NUM_BITS)
    ) u_sat_cnt (
        .clk          (clk),
        .reset        (reset),
        .predict_addr (IF_pc),
        .record_result(EX_BR),
        .resolve_addr (EX_pc),                //IF_branch_pc),
        .resolve_taken(branch_pred_correct),
        .prediction   (predict_branch)
    );
`endif

    //------------------------------------
    //         jump_logic
    //------------------------------------
    always_comb begin
        if ((EX_opcode == JAL) || (EX_opcode == JALR)) begin
            EX_jump_taken = 1;
        end else begin
            EX_jump_taken = 0;
        end
    end  // always_comb


    assign EX_jump_addr = (EX_opcode == JAL) ? EX_pc + EX_imm : EX_read_data_1;




    //----------------------------------------------------------------
    //          Stall detector for avoiding data hazards
    //----------------------------------------------------------------
    reg_write_addr_enb_decoder EX_C_dest (
        .instr(EX_instr),
        .reg_write_enb(EX_reg_write_enb),
        .reg_write_addr(EX_reg_write_addr)
    );

    reg_write_addr_enb_decoder MEM_C_dest (
        .instr(MEM_instr),
        .reg_write_enb(MEM_reg_write_enb),
        .reg_write_addr(MEM_reg_write_addr)
    );

    reg_write_addr_enb_decoder WB_C_dest (
        .instr(WB_instr),
        .reg_write_enb(WB_reg_write_enb),
        .reg_write_addr(WB_reg_write_addr)
    );





    assign stall = ( (EX_reg_write_addr  == ID_reg_read_addr1) && (ID_reg_read_addr1 != 5'b0) && EX_reg_write_enb  && ID_reg_read_enb_1 ) ||
                   ( (MEM_reg_write_addr == ID_reg_read_addr1) && (ID_reg_read_addr1 != 5'b0) && MEM_reg_write_enb && ID_reg_read_enb_1 ) ||
                   ( (WB_reg_write_addr  == ID_reg_read_addr1) && (ID_reg_read_addr1 != 5'b0) && WB_reg_write_enb  && ID_reg_read_enb_1 ) ||
		   
                   ( (EX_reg_write_addr  == ID_reg_read_addr2) && (ID_reg_read_addr2 != 5'b0) && EX_reg_write_enb  && ID_reg_read_enb_2 ) ||
                   ( (MEM_reg_write_addr == ID_reg_read_addr2) && (ID_reg_read_addr2 != 5'b0) && MEM_reg_write_enb && ID_reg_read_enb_2 ) ||
                   ( (WB_reg_write_addr  == ID_reg_read_addr2) && (ID_reg_read_addr2 != 5'b0) && WB_reg_write_enb  && ID_reg_read_enb_2 );





    //-------------------------------   
    //     Execute to Memory
    //-------------------------------   
    always_ff @(posedge clk) begin
        if (reset) begin
            MEM_instr       <= 0;
            MEM_read_data_2 <= 0;
            MEM_alu_result  <= 0;
        end else begin
            MEM_instr       <= EX_instr;
            MEM_read_data_2 <= EX_read_data_2;
            MEM_alu_result  <= (EX_jump_taken) ? EX_jump_addr : EX_alu_result;
        end
    end


    data_memory dmem (
        .clock       (clk),
        .write_enable(dmem_write_enb),
        .address     (MEM_alu_result[13:0]),
        .write_data  (MEM_read_data_2),
        .read_data   (dmem_read_data)
    );


    assign MEM_reg_write_data = wb_sel ? dmem_read_data : MEM_alu_result;


    //-------------------------------   
    //    Memory to Write Back
    //-------------------------------   
    always_ff @(posedge clk) begin
        if (reset) begin
            WB_instr          <= 0;
            WB_reg_write_data <= 0;
        end else begin
            WB_instr          <= MEM_instr;
            WB_reg_write_data <= MEM_reg_write_data;
        end
    end


endmodule
