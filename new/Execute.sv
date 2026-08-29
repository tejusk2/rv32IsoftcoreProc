`timescale 1ns / 1ps
module Execute(input logic sys_clk, input logic rst_n, input logic [31:0] program_counter, input logic [31:0] pcnext, input logic [4:0] rdDecode,
               input logic [31:0] register1val, input logic [31:0] register2val, input logic [31:0] immediate,
               input logic [6:0] opcode, input logic [2:0] funct3, input logic [6:0] funct7, output logic [31:0] execute_out, output logic [4:0] rdExec,
               output logic [31:0] rs2, output logic [3:0] memOpType, output logic [6:0] opcode_out,
               output logic [2:0] execfunct3out, output logic [31:0]pc_out, output logic branch_flush);

            logic [31:0] muxedOutput;
            logic [31:0] muxedInput;
            logic useImmediate;
            logic addSubChoice;
            logic [31:0] addSubOutput;
            logic carryBit;
            logic [1:0] luChoice;
            logic [31:0] luOutput;
            logic [1:0] shiftChoice;
            logic [31:0] shiftOutput;
            logic branch_comparator_output;
            logic [31:0] PC_imm;
            logic [31:0] pc_seq;
            logic [3:0] mem_intm;
            //Immediate Type Multiplexer
            assign muxedInput = (useImmediate) ? immediate : register2val;
            //Arithmetic Unit, 0 is add, 1 is subtract
            Arithmetic_Unit addSubUnit(
            .val1(register1val),
            .val2(muxedInput),
            .option(addSubChoice),
            .out(addSubOutput),
            .carryBit(carryBit)
            );
            //Logical Unit, 0 is AND, 1 is OR, 2 is XOR
            Logical_Unit logicalUnit(
            .val1(register1val),
            .val2(muxedInput),
            .option(luChoice),
            .out(luOutput)
            );
            //Shift Unit, 0 is SLL, 1 is SRL, 2 is SRA
            Shift_Unit shiftUnit(
            .val1(register1val),
            .val2(muxedInput),
            .option(shiftChoice),
            .out(shiftOutput)
            );
            //Branch Comparator, funct3 decides - based on RISCV card
            Branch_Comparator bc(
                .val1(register1val),
                .val2(register2val),
                .funct3(funct3),
                .logical_out(branch_comparator_output)
            );
            //Combinational Logic to choose output
            always_comb begin
                addSubChoice = 1'b0;
                luChoice  = 2'b00;
                shiftChoice = 2'b00;
                muxedOutput = addSubOutput;
                useImmediate = 1'b0;
                PC_imm = pcnext;
                mem_intm = 4'b0000;
                branch_flush = 1'b0;
                case(opcode)
                    //R Type
                    7'b0110011:begin
                        useImmediate = 1'b0;
                        case(funct3)
                            //ADD
                            3'd0: begin
                                addSubChoice = (funct7[5]) ? 1'b1 : 1'b0;
                                muxedOutput = addSubOutput;
                            end
                            //SLL
                            3'd1:begin
                                shiftChoice = 2'b00;
                                muxedOutput = shiftOutput;
                            end
                            //SLT
                            3'd2:begin
                                addSubChoice = 1'b1;
                                //if they are not the same, then the sign bit of A is output, if same, then the MSB of diff is output
                                muxedOutput = (register1val[31] != register2val[31]) ? { {31{1'b0}} , register1val[31]} : { {31{1'b0}} , addSubOutput[31]};
                            end
                            //SLTU
                            3'd3:begin
                                addSubChoice = 1'b1;
                                muxedOutput = { {31{1'b0}} , ~carryBit};
                            end
                            //XOR
                            3'd4:begin
                                luChoice = 2'b10;
                                muxedOutput = luOutput;
                            end
                            //SRL SRA
                            3'd5:begin
                                shiftChoice = (funct7[5]) ? 2'b01 : 2'b10;
                                muxedOutput = shiftOutput;
                            end
                            //OR
                            3'd6:begin
                                luChoice = 2'b01;
                                muxedOutput = luOutput;
                            end
                            //AND
                            3'd7:begin
                                luChoice = 2'b00;
                                muxedOutput = luOutput;
                            end
                        endcase
                    end
                    //I type instructions, use concatenation to sign extend the immediate
                    7'b0010011:begin
                       useImmediate = 1'b1;
                       case(funct3)
                            //ADDI
                            3'd0: begin
                                addSubChoice = 1'b0;
                                muxedOutput = addSubOutput;
                            end
                            //SLLI
                            3'd1:begin
                                shiftChoice = 2'b00;
                                muxedOutput = shiftOutput;
                            end
                            //SLTI
                            3'd2:begin
                                addSubChoice = 1'b1;
                                //if they are not the same, then the sign bit of A is output, if same, then the MSB of diff is output
                                muxedOutput = (register1val[31] != immediate[31]) ? { {31{1'b0}} , register1val[31]} : { {31{1'b0}} , addSubOutput[31]};
                            end
                            //SLTUI
                            3'd3:begin
                                addSubChoice = 1'b1;
                                muxedOutput = { {31{1'b0}} , ~carryBit};
                            end
                            //XORI
                            3'd4:begin
                                luChoice = 2'b10;
                                muxedOutput = luOutput;
                            end
                            //SRLI SRAI
                            3'd5:begin
                                shiftChoice = (immediate[10]) ? 2'b01 : 2'b10;
                                muxedOutput = shiftOutput;
                            end
                            //ORI
                            3'd6:begin
                                luChoice = 2'b01;
                                muxedOutput = luOutput;
                            end
                            //ANDI
                            3'd7:begin
                                luChoice = 2'b00;
                                muxedOutput = luOutput;
                            end
                       endcase
                    end
                    //Load Word I Type
                    7'b0000011:begin
                        useImmediate = 1'b1;
                        addSubChoice = 1'b0;
                        muxedOutput = addSubOutput;
                        mem_intm = 4'b1000;
                    end
                    //S type instructions
                    7'b0100011:begin
                       useImmediate = 1'b1;
                       addSubChoice = 1'b0;
                       muxedOutput = addSubOutput;
                       mem_intm = {2'b11, funct3[1:0]};
                    end
                    //B Type Instructions
                    7'b1100011:begin
                       PC_imm = (branch_comparator_output) ? program_counter + immediate : program_counter;
                       branch_flush = 1'b1;
                    end
                    //Jump and Link Instruction
                    7'b1101111:begin
                       PC_imm = program_counter + immediate;
                       muxedOutput = pcnext;
                       branch_flush = 1'b1;
                    end
                    //Jump and Link Reg
                    7'b1100111:begin
                      PC_imm = register1val + immediate;
                      muxedOutput = pcnext;
                      branch_flush = 1'b1;
                    end
                    //Load Upper Immediate - U type
                    7'b0110111:begin
                      muxedOutput = immediate << 12;
                    end
                    //Add Upper Immediate to PC - U Type
                    7'b0010111:begin
                      muxedOutput = (immediate << 12) + program_counter;
                    end
                    //Env Types - I type
                    7'b1110011:begin
                      //Gonna DC this for now since it has no use at the moment
                      muxedOutput = addSubOutput;
                    end
                    default:begin
                        addSubChoice = 1'b0;
                        luChoice  = 2'b00;
                        shiftChoice = 2'b00;
                        muxedOutput = addSubOutput;
                        useImmediate = 1'b0;
                    end
                endcase
            end
            //Sequential Logic to Set Pipeline Registers and update PC
            always_ff @(posedge sys_clk) begin
                if(~rst_n)begin
                    pc_seq <= 32'b0;
                    execute_out <= 32'b0;
                    rdExec <= 5'b0;
                    rs2 <= 32'b0;
                    memOpType <= 4'b0000;
                    opcode_out <= 7'b0;
                    execfunct3out <= 3'b0;
                end else begin
                    pc_seq <= PC_imm;
                    execute_out <= muxedOutput;
                    rdExec <= rdDecode;
                    rs2 <= register2val;
                    memOpType <= mem_intm;
                    opcode_out <= opcode;
                    execfunct3out <= funct3;
                end
            end

endmodule