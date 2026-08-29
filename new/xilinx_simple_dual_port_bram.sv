`timescale 1ns / 1ps

(* ram_style = "block" *)
module xilinx_simple_dual_port_bram #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 12
)(
    input  logic                    clk,
    input  logic                    en_a,
    input  logic                    en_b,
    input  logic [1:0]              we_a,
    input  logic [ADDR_WIDTH-1:0]   addr_a,
    input  logic [ADDR_WIDTH-1:0]   addr_b,
    input  logic [DATA_WIDTH-1:0]   din_a,
    output logic [DATA_WIDTH-1:0]   dout_b
);

    localparam int RAM_DEPTH = 1 << ADDR_WIDTH;
    logic [DATA_WIDTH-1:0] ram [RAM_DEPTH-1:0];

    logic [ADDR_WIDTH-1:0] addr_b_reg;
    initial begin
        ram = '{default: 0};
    end

    // Port A: Write Interface
    always_ff @(posedge clk) begin
        if (en_a) begin
            if (we_a == 2'b11) begin
                ram[addr_a] <= din_a;
            end else if(we_a == 2'b10)begin
                ram[addr_a][15:0] <= din_a[15:0];
            end else if(we_a == 2'b01)begin
                ram[addr_a][7:0] <= din_a[7:0];
            end
        end
    end

    // Port B: Read Interface
    always_ff @(posedge clk) begin
        if (en_b) begin
            addr_b_reg <= addr_b;
        end
    end

    assign dout_b = ram[addr_b_reg];

endmodule