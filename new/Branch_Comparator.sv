`timescale 1ns / 1ps
module Branch_Comparator(input logic [31:0] val1, input logic [31:0] val2, input logic [2:0] funct3, output logic logical_out);
    logic out;
    assign logical_out = out;
    always_comb begin
        case(funct3)
            //BEQ
            3'b000:begin
                out = (val1 == val2);
            end
            //BNE
            3'b001:begin
                out = (val1 != val2);
            end
            //BLT
            3'b100:begin
                out = ($signed(val1 )< $signed(val2));
            end
            //BGE
            3'b101:begin
                out = ($signed(val1) >= $signed(val2));
            end
            //BLTU
            3'b110:begin
                out = (val1 < val2);
            end
            //BGEU
            3'b111:begin
                out = (val1 >= val2);
            end
            //default to avoid latches
            default:begin
                out = 1'b0;
            end
        endcase
    end
endmodule