`include "config.v"

module regfile (input clk,
                input ctrl_we,
                input rst,
                input [4:0] addr_rd,
                input [4:0] addr_ra,
                input [4:0] addr_rb,
                input [31:0] data_rd,
                output [31:0] data_ra,
                output [31:0] data_rb);

    // Write port
    wire [31:0] ctrl_regwe;
    assign ctrl_regwe = ctrl_we ? (32'h00000001 << addr_rd) : 32'h00000000;

    // Registers
    wire [31:0] data_regout [31:0];

    // R0
    assign data_regout[0] = 32'h00000000;

    genvar i;
    generate
        for (i = 1; i < 32; i = i + 1) begin: gen_reg
            dffe_wers u_dffe_wers(
                .we(ctrl_regwe[i]),
                .din(data_rd),
                .qout(data_regout[i]),
                .clk(clk),
                .rst(rst)
            );
        end
    endgenerate

    // Read port A
    assign data_ra=data_regout[addr_ra];
    
    // Read port B
    assign data_rb=data_regout[addr_rb];
endmodule