/* This module implements a Width bit DFFE
 with Write Enable and Reset signals
 */
module dffe_wers #(parameter Width = 32)
                  (input we,                    // write enable
                   input [Width-1:0] din,       // data in
                   output reg [Width-1:0] qout, // data out
                   input clk,                   // clock
                   input rst);                  // async reset
    initial begin
        qout <= {Width{1'b0}};
    end
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            qout <= {Width{1'b0}};
        end else if (we) begin
            qout <= din;
        end
    end
endmodule
