`timescale 1ns / 1ps
module Instruction_Fetch(
        input logic [31:0] program_counter, input logic sys_clk, input logic rst_n,
        output logic [31:0] pcnext, output logic [31:0] pc_out_fetch
    );
    assign pcnext = program_counter + 32'd1;
    
    always_ff @(posedge sys_clk) begin
        if(~rst_n)begin
            pc_out_fetch <= 0;
        end else begin
            pc_out_fetch <= program_counter;
        end
    end
    
endmodule
