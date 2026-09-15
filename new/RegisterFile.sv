`timescale 1ns / 1ps

module RegisterFile(input logic sys_clk, input logic rst_n, 
                    input logic [4:0] write_reg, input logic w_en, input logic [31:0] w_data,
                    input logic [4:0] read_reg1, input logic [4:0] read_reg2,
                        output logic [31:0] reg1, output logic [31:0] reg2); 
    //2D 32*32 unpacked array
    logic [31:0] reg_file [31:0] = '{default: 0}; 
    //sequential writing
    always_ff @(posedge sys_clk)begin
        if(~rst_n)begin
            reg_file[0][31:0] <= 32'b0;
        end else begin
            if(w_en)begin
                if(write_reg != 0)begin
                    reg_file[write_reg][31:0] <= w_data;
                end
            end
        end
    end
    //combinational reading
    always_comb begin
        reg1 = reg_file[read_reg1][31:0];
        reg2 = reg_file[read_reg2][31:0];
    end
endmodule