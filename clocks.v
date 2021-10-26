module clocks (
    input clk_in,
    input rst,
    output [7:0] clk_out
);
    // make sure that the negedge of rst is on a clk posedge
    reg sync_rstN;
    wire sync_rst;
    assign sync_rst = ~ sync_rstN;
    always @(posedge clk_in or posedge rst) begin
        if (rst) begin
            sync_rstN = 1'b0;
        end else begin
            sync_rstN = 1'b1;
        end
    end
    
    reg [1:0] grey_cnt;
    always @(posedge clk_in or posedge sync_rst) begin
        if (sync_rst)
            grey_cnt<=2'b00;
        else begin
            grey_cnt[1]<=~grey_cnt[0];
            grey_cnt[0]<=grey_cnt[1];
        end
    end
    
    reg [1:0] grey_cntN;
    always @(negedge clk_in or posedge sync_rst) begin
        if (sync_rst)
            grey_cntN<=2'b00;
        else begin
            grey_cntN[1]<=~grey_cntN[0];
            grey_cntN[0]<=grey_cntN[1];
        end
    end
    assign clk_out = {~grey_cnt[0],~grey_cntN[0],~grey_cnt[1],~grey_cntN[1],grey_cnt[0],grey_cntN[0],grey_cnt[1],grey_cntN[1]};
endmodule