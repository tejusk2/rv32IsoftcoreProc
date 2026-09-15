`timescale 1ns / 1ps
module ForwardingMultiplexer(input logic [4:0] idexrs1, input logic [4:0] idexrs2, input logic [4:0] exmem_rd, input logic [4:0] memwb_rd,
                            input logic [31:0] exmem, input logic [31:0] memwb, input logic [31:0] regfile_rs1, input logic [31:0] regfile_rs2,
                            output logic [31:0] rs1, output logic [31:0] rs2);
        always_comb begin
            if (idexrs1 != 5'd0 && idexrs1 == exmem_rd) begin
                rs1 = exmem;
            end else if (idexrs1 != 5'd0 && idexrs1 == memwb_rd) begin
                rs1 = memwb;
            end else begin
                rs1 = regfile_rs1;
            end

            if (idexrs2 != 5'd0 && idexrs2 == exmem_rd) begin
                rs2 = exmem;
            end else if (idexrs2 != 5'd0 && idexrs2 == memwb_rd) begin
                rs2 = memwb;
            end else begin
                rs2 = regfile_rs2;
            end
        end
endmodule