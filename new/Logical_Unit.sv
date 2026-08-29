`timescale 1ns / 1ps
module Logical_Unit(input logic [31:0] val1, input logic [31:0] val2, input logic [1:0]option, output logic [31:0] out);
    always_comb begin
        case(option)
            //AND
            2'b00:begin
                out = val1 & val2;
            end
            //OR
            2'b01:begin
                out = val1 | val2;
            end
            //XOR
            2'b10:begin
                out = val1 ^ val2;
            end
            //default to avoid latches
            default:begin
                out = val1 & val2;
            end
        endcase
    end
endmodule