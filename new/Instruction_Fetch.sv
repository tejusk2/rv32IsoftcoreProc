`timescale 1ns / 1ps
module Instruction_Fetch(
        input logic [31:0] program_counter, input logic sys_clk, input logic rst_n,
        output logic [31:0] pcnext, output logic [31:0] pc_out_fetch
    );
    always_ff @(posedge sys_clk) begin
        if(~rst_n)begin
            pcnext <= 0;
        end else begin
            pcnext <= program_counter + 32'd1;
        end
    end
endmodule
