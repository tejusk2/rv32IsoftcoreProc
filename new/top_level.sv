`timescale 1ns / 1ps
module top_level(
        input logic sys_clk_p,
        input logic sys_clk_n,
        input logic rst_pb
    );
    //signals
    logic sys_clk;
    //Instruction Cache Signals
    logic [1:0] w_en; 
    logic r_en;
    logic [31:0] instruction_write_addr; 
    logic [31:0] program_counter;
    logic [31:0] pcnext;
    logic [31:0] inram_data_in; 
    logic [31:0] inram_data_out;
    //Register File Signals
    logic [4:0] register_file_write_addr;
    logic register_file_write_enable;
    logic [31:0] register_file_write_data;
    logic [4:0] register_file_read1;
    logic [4:0] register_file_read2;
    logic [31:0] register_file_readout1;
    logic [31:0] register_file_readout2;
    //Instruction Decode Signals
    logic [4:0] destination_register;
    logic [31:0] immediate;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    //Execute Stage Signals
    logic [31:0] execute_out;
    logic [3:0] memOpType;
    logic [4:0] dest_exec; //pipeline register so that RD doesn't get overwritten
    logic [31:0] registerSource2;
    logic [6:0] opcode_out;
    logic [31:0] rs2_exec_out;
    logic [2:0] execfunct3out;
    logic [31:0] pc_out_exec;
    //Memory Stage Signals
    logic [4:0] dest_mem; //another pipline register for destination
    logic [1:0] ram_w_en;
    logic ram_r_en;
    logic [31:0] ram_w_addr;
    logic [31:0] ram_r_addr;
    logic [31:0] ram_w_data;
    logic [31:0] ram_r_data;
    logic [6:0] memopcode_out;
    logic [31:0] exec_out_pipeline;
    logic [2:0] memfunct3out;
    //Flush Controller Signals
    logic [31:0] flush_controlled_ifid_instruction;
    logic [6:0] flush_controlled_idex_opcode;
    logic branch_flush;
    //Forwarding Controller Signals
    logic [31:0] fu_controlled_rs1;
    logic [31:0] fu_controlled_rs2;
    //Load Hazard Control Signals
    logic [31:0] pc_out_fetch;
    logic [31:0] pc_out_decode;
    logic hazardPCSel;
    logic [31:0] muxed_pcsel;
    logic flush;

    assign muxed_pcsel = (hazardPCSel) ? pc_out_decode : pc_out_exec;
    assign flush = branch_flush | hazardPCSel;

    //Clock Setup
    IBUFDS #(
        .DIFF_TERM("FALSE"),
        .IBUF_LOW_PWR("TRUE")
    ) ibufds_sys_clk (
        .O(sys_clk),
        .I(sys_clk_p),
        .IB(sys_clk_n)
    );
    // 32 * 4096 BRAM Memory for Instructions
    xilinx_simple_dual_port_bram #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(12)
    ) instructionRAM (
        .clk(sys_clk),
        .en_a(w_en),
        .en_b(1),
        .we_a(w_en),
        .addr_a(instruction_write_addr),
        .addr_b(program_counter),
        .din_a(inram_data_in),
        .dout_b(inram_data_out)
    );
    // 32 * 2^14 BRAM Memory for Storage
    xilinx_simple_dual_port_bram #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(14)
    ) storageRAM (
        .clk(sys_clk),
        .en_a(ram_w_en),
        .en_b(ram_r_en),
        .we_a(ram_w_en),
        .addr_a(ram_w_addr),
        .addr_b(ram_r_addr),
        .din_a(ram_w_data),
        .dout_b(ram_r_data)
    );
    //instruction fetch
    Instruction_Fetch inFetch(
        .program_counter(program_counter),
        .sys_clk(sys_clk),
        .rst_n(~rst_pb),
        .pcplusfour(pcnext),
        .pc_out_fetch(pc_out_fetch)
    );
    //register file
    RegisterFile regfile(
        .sys_clk(sys_clk),
        .rst_n(~rst_pb),
        .write_reg(register_file_write_addr),
        .w_en(register_file_write_enable),
        .w_data(register_file_write_data),
        .read_reg1(register_file_read1),
        .read_reg2(register_file_read2),
        .reg1(register_file_readout1),
        .reg2(register_file_readout2)
    );
    //instruction decode
    Instruction_Decode ins_decode(
        .sys_clk(sys_clk),
        .instruction(flush_controlled_ifid_instruction),
        .rst_n(~rst_pb),
        .rd(destination_register),
        .pc_fetch_in(pc_out_fetch),
        .pc_decode_out(pc_out_decode),
        .imm(immediate),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .rs1(register_file_read1),
        .rs2(register_file_read2)
    );
    //execute
    Execute execute_stage(
        .sys_clk(sys_clk),
        .rst_n(rst_pb),
        .rdDecode(destination_register),
        .program_counter(program_counter),
        .pcnext(pcnext),
        .register1val(fu_controlled_rs1),
        .register2val(fu_controlled_rs2),
        .immediate(immediate),
        .opcode(flush_controlled_idex_opcode),
        .funct3(funct3),
        .funct7(funct7),
        .opcode_out(opcode_out),
        .execute_out(execute_out),
        .rdExec(dest_exec),
        .memOpType(memOpType),
        .rs2(rs2_exec_out),
        .execfunct3out(execfunct3out),
        .pc_out(pc_out_exec),
        .branch_flush(branch_flush)
    );
    //Memory
    MemoryStoreLoad memCtrl(
        .sys_clk(sys_clk),
        .rst_n(~rst_pb),
        .opType(memOpType),
        .execute_out(execute_out),
        .memopcode_in(opcode_out),
        .rd_in(dest_exec),
        .funct3in(execfunct3out),
        .rs2(rs2_exec_out),
        .w_en(ram_w_en),
        .r_en(ram_r_en),
        .r_addr(ram_r_addr),
        .w_addr(ram_r_addr),
        .w_data(ram_w_data),
        .rd_out(dest_mem),
        .memopcode_out(memopcode_out),
        .exec_out_pipeline(exec_out_pipeline),
        .memfunct3out(memfunct3out)
    );
    //Register Write Back
    RegisterWB reg_write_back(
        .sys_clk(sys_clk),
        .rst_n(~rst_pb),
        .opcode(memopcode_out),
        .dest_addr(dest_mem),
        .funct3in(memfunct3out),
        .exec_out(exec_out_pipeline),
        .mem_load_data(ram_r_data),
        .reg_addr(register_file_write_addr),
        .w_en(register_file_write_enable),
        .w_data(register_file_write_data)
    );
    //program counter register
    PCreg progcount(
        .sys_clk(sys_clk),
        .rst_n(~rst_pb),
        .pcnext(muxed_pcsel),
        .pc(program_counter)
    );
    //hardware flush for branch mispredicts
    Flush flusher(
        .sys_clk(sys_clk),
        .rst_n(~rst_pb),
        .branch_taken(flush),
        .ifid_instruction(inram_data_out),
        .idexopcode(opcode),
        .flushed_ifid(flush_controlled_ifid_instruction),
        .flushed_idex(flush_controlled_idex_opcode)
    );
    //Forwarding Unit to fix hazards
    ForwardingMultiplexer forwarding_unit(
        .idexrs1(register_file_read1),
        .idexrs2(register_file_read2),
        .exmem_rd(dest_exec),
        .memwb_rd(dest_mem),
        .exmem(execute_out),
        .memwb(exec_out_pipeline),
        .regfile_rs1(register_file_readout1),
        .regfile_rs2(register_file_readout2),
        .rs1(fu_controlled_rs1),
        .rs2(fu_controlled_rs2)
    );
    //Load Hazard Stall Unit
    LoadHazardUnit loadhazardstall(
        .idexrs1(register_file_read1),
        .idexrs2(register_file_read2),
        .exmemrd(dest_exec),
        .exemopcodein(opcode_out),
        .hazard(hazardPCSel)
    );


endmodule