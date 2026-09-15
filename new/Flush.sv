`timescale 1ns / 1ps
//the purpose of this module is
module Flush(input logic sys_clk, input logic rst_n, input logic [31:0] ifid_instruction, input logic branch_taken, input logic [6:0] idexopcode,
            input logic [4:0] idex_rd_addr, output logic [4:0] flushed_idex_rd,
            output logic [31:0] flushed_ifid, output logic [6:0] flushed_idex);
        
        always_comb begin
            //the two earlier pipeline register are wrong, so we have to change the instructions to register 0 writes so they do nothing
            if(branch_taken)begin
                flushed_ifid = 32'h00000033;
                flushed_idex = 7'b0110011;
                flushed_idex_rd = 5'b0;
            end else begin
                flushed_ifid = ifid_instruction;
                flushed_idex = idexopcode;
                flushed_idex_rd = idex_rd_addr;
            end
        end
endmodule