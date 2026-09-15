`timescale 1ns / 1ps
module Instruction_Decode(input logic sys_clk, input logic [31:0]instruction,input logic rst_n,
                        input logic [31:0] pc_fetch_in,
                        output logic [31:0] pc_decode_out,
                        output logic [4:0] rd, output logic [31:0] imm,
                        output logic [6:0] opcode, output logic [2:0] funct3, output logic [6:0] funct7,
                        output logic [4:0] rs1, output logic [4:0] rs2);
    always_ff @( posedge sys_clk ) begin
        if(~rst_n)begin
            rs1 <= 5'b0;
            rs2 <= 5'b0;
            rd <= 5'b0;
            imm <= 32'b0;
            opcode <= 7'b0;
            funct3 <= 3'b0;
            funct7 <= 7'b0;
            pc_decode_out <= 32'b0;
        end else begin
            pc_decode_out <= pc_fetch_in;
            opcode <= instruction[6:0];
            case (instruction[6:0])
                //R Type instruction, set immediate to zero and grab the register values
                7'b0110011:begin
                    imm <= 32'b0;
                    rs1 <= instruction[19:15];
                    rs2 <= instruction[24:20];
                    rd <= instruction[11:7];
                    funct3 <= instruction[14:12];
                    funct7 <= instruction[31:25];
                end
                //I type instructions, use concatenation to sign extend the immediate
                7'b0010011:begin
                    imm <= { {20{instruction[31]}}, instruction[31:20] };
                    rs1 <= instruction[19:15];
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= instruction[14:12];
                    funct7 <= 7'b0;
                end
                7'b0000011:begin
                    imm <= { {20{instruction[31]}}, instruction[31:20] };
                    rs1 <= instruction[19:15];
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= instruction[14:12];
                    funct7 <= 7'b0;
                end
                //S type instructions
                7'b0100011:begin
                    imm <= { {20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                    rs1 <= instruction[19:15];
                    rs2 <= instruction[24:20];
                    rd <= 5'b0;
                    funct3 <= instruction[14:12];
                    funct7 <= 7'b0;
                end
                //B Type Instructions
                7'b1100011:begin
                    imm <= { {20{instruction[31]}},instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                    rs1 <= instruction[19:15];
                    rs2 <= instruction[24:20];
                    rd <= 5'b0;
                    funct3 <= instruction[14:12];
                    funct7 <= 7'b0;
                end
                //Jump and Link Instruction
                7'b1101111:begin
                    imm <= {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                    rs1 <= 5'b0;
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= 3'b0;
                    funct7 <= 7'b0;
                end
                //Jump and Link Reg
                7'b1100111:begin
                    imm <= { {20{instruction[31]}}, instruction[31:20] };
                    rs1 <= instruction[19:15];
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= instruction[14:12];
                    funct7 <= 7'b0;
                end
                //Load Upper Immediate - U type
                7'b0110111:begin
                    imm <= { {12{instruction[31]}}, instruction[31:12] };
                    rs1 <= 5'b0;
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= 3'b0;
                    funct7 <= 7'b0;
                end
                //Add Upper Immediate to PC - U Type
                7'b0010111:begin
                    imm <= { {12{instruction[31]}}, instruction[31:12] };
                    rs1 <= 5'b0;
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= 3'b0;
                    funct7 <= 7'b0;
                end
                //Env Types - I type
                7'b1110011:begin
                    imm <= { {20{instruction[31]}}, instruction[31:20] };
                    rs1 <= instruction[19:15];
                    rs2 <= 5'b0;
                    rd <= instruction[11:7];
                    funct3 <= instruction[14:12];
                    funct7 <= 7'b0;
                end
                default:begin
                    imm <= 32'b0;
                    rs1 <= 5'b0;
                    rs2 <= 5'b0;
                    rd <= 5'b0;
                    funct3 <= 3'b0;
                    funct7 <= 7'b0;
                end
            endcase
        end
    end
    
endmodule