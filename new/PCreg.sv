`timescale 1ns / 1ps
module PCreg(input logic sys_clk, input logic rst_n, input logic [31:0] pcnext, output logic [31:0] pc);
    always_ff @(posedge sys_clk) begin
        if(~rst_n)begin
            pc <= 32'b0;
        end else begin
            pc <= pcnext;
        end
    end
endmodule