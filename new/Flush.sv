`timescale 1ns / 1ps
//the purpose of this module is
module Flush(input logic sys_clk, input logic rst_n, input logic [31:0] ifid_instruction, input logic branch_taken, input logic [6:0] idexopcode,
            output logic [31:0] flushed_ifid, output logic [6:0] flushed_idex);
        
        always_ff @(posedge sys_clk) begin
            //the two earlier pipeline register are wrong, so we have to change the instructions to opcode 0 so they do nothing
            if(~rst_n || branch_taken)begin
                flushed_ifid <= 32'b0;
                flushed_idex <= 7'b0;
            end else begin
                flushed_ifid <= ifid_instruction;
                flushed_ifid <= idexopcode;
            end
        end
endmodule