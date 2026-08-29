`timescale 1ns / 1ps
module RegisterWB(input logic sys_clk, input logic rst_n, input logic [6:0] opcode, input logic [4:0] dest_addr, input logic [2:0] funct3in,
                  output logic [4:0] reg_addr, output logic w_en, output logic [31:0] w_data,
                  input logic [31:0] exec_out, input logic [31:0] mem_load_data);
        always_ff @(posedge sys_clk ) begin
            if(~rst_n)begin
                reg_addr <= 5'b0;
                w_en <= 1'b0;
                w_data <= 32'b0;
            end else begin
                //theres only a few special cases we need to consider, rest can follow the default case
                case(opcode)
                    //Blank Instruction
                    7'b0000000:begin
                        w_en <= 1'b0;
                        reg_addr <= 5'b0;
                        w_data <= 32'b0;
                    end
                    //Load type instructions
                    7'b0000011:begin
                        w_en <= 1'b1;
                        reg_addr <= dest_addr;
                        case(funct3in)
                            3'b000:  w_data <= {{24{mem_load_data[7]}}, mem_load_data[7:0]}; // LB 
                            3'b100:  w_data <= {24'b0, mem_load_data[7:0]};                  // LBU
                            3'b001:  w_data <= {{16{mem_load_data[15]}}, mem_load_data[15:0]};// LH 
                            3'b101:  w_data <= {16'b0, mem_load_data[15:0]};                 // LHU
                            3'b010:  w_data <= mem_load_data;                               // LW
                            default: w_data <= mem_load_data;
                        endcase
                    end
                    //Store type Instruction, do nothing
                    7'b0100011:begin
                        w_en <= 1'b0;
                        reg_addr <= 5'b0;
                        w_data <= 32'b0;
                    end
                    //Branch type Instruction, do nothing
                    7'b1100011:begin
                        w_en <= 1'b0;
                        reg_addr <= 5'b0;
                        w_data <= 32'b0;
                    end
                    //JAL, JALR, LUI, and AUIPC are all also covered by this
                    default:begin
                        reg_addr <= dest_addr;
                        w_en <= 1'b1;
                        w_data <= exec_out;
                    end
                endcase
            end
        end
endmodule