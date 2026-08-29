`timescale 1ns / 1ps
module MemoryStoreLoad(input logic sys_clk, input logic rst_n, input logic [3:0] opType, input logic [6:0] memopcode_in, input logic [2:0] funct3in,
                        input logic [31:0] execute_out, input logic [4:0] rd_in,  input logic [31:0] rs2,
                        output logic [1:0] w_en, output logic r_en, output logic [31:0] r_addr, output logic [31:0] w_addr, output lofic [31:0] w_data,
                        output logic [4:0] rd_out, output logic [6:0] memopcode_out, output logic [31:0] exec_out_pipeline, 
                        output logic [2:0] memfunct3out);
    always_ff @(posedge sys_clk ) begin
        if(~rst_n)begin
            rd_out <= 5'b0;
            loaded_word <= 32'b0;
            w_en <= 1'b0;
            r_en <= 1'b0;
            r_addr <= 32'b0;
            w_addr <= 32'b0;
            w_data <= 32'b0;
            memopcode_out <= 7'b0;
            exec_out_pipeline <= 32'b0;
            memfunct3out <= 3'b0;
        end else begin
            memopcode_out <= memopcode_in;
            exec_out_pipeline <= execute_out;
            memfunct3out <= funct3in;
            case(opType[3:2])
                //Load Type Instruction
                2'b10:begin
                    rd_out <= rd_in;
                    w_en <= 2'b00;
                    r_en <= 1'b1;
                    r_addr <= execute_out;
                    w_addr <= 32'b0;
                    w_data <= 32'b0; 
                end
                //Store Type Instruction
                2'b11:begin
                    rd_out <= rd_in;
                    r_en <= 1'b0;
                    r_addr <= 32'b0;
                    w_addr <= execute_out;
                    w_data <= rs2;
                    case(opType[1:0])
                        //Store Byte
                        2'b00:begin
                            w_en <= 2'b01;
                        end
                        //Store Half
                        2'b01:begin
                            w_en <= 2'b10;
                        end
                        //Store Whole Word
                        2'b10:begin
                            w_en <= 2'b11;
                        end
                        default:begin
                            w_en <= 2'b00;
                        end
                    endcase
                end
                default:begin
                    rd_out <= rd_in;
                    w_en <= 1'b0;
                    r_en <= 1'b0;
                    r_addr <= 32'b0;
                    w_addr <= 32'b0;
                    w_data <= 32'b0;
                end
            endcase
        end  
    end
endmodule