`timescale 1ns / 1ps
module LoadHazardUnit(input logic [4:0] idexrs1, input logic [4:0] idexrs2, input logic exmemrd [4:0], input logic [6:0] exmemopcodein,
                      output logic hazard);
    always_comb begin
        if(exmemopcodein == 7'b0000011)begin
            if(idexrs1 == exmemrd || idexrs2 == exmemrd)begin
                hazard = 1'b1;
            end else begin
                hazard = 1'b0;
            end
        end else begin
            hazard = 1'b0;
        end
        
    end
endmodule