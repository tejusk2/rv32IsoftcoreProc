`timescale 1ns / 1ps
module Arithmetic_Unit(input logic [31:0] val1, input logic [31:0] val2, input logic option, output logic [31:0] out, output logic carryBit);
    logic [32:0] intermediate_out;
    assign carryBit = intermediate_out[32];
    assign out = intermediate_out[31:0];
    always_comb begin
        case(option)
            //Addition
            1'b0:begin
                intermediate_out = val1 + val2;
            end
            //Subtraction
            1'b1:begin
                intermediate_out = val1 - val2;
            end
            //default to avoid latches
            default:begin
                intermediate_out = val1 + val2;
            end
        endcase
    end
endmodule