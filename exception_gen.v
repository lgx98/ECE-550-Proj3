`include "config.v"
module exception_gen (input ctrl_alu,
                      input ctrl_addi,
                      input ovf,
                      input [4:0] aluop,
                      output reg ctrl_ex,
                      output reg [31:0] data_excode);
    always @(*) begin
        ctrl_ex    = 1'b0;
        data_excode = 32'h00000000;
        if (ovf) begin
            if (ctrl_addi) begin
                ctrl_ex    = 1'b1;
                data_excode = 32'h00000002;
            end
            else
            begin
                if (ctrl_alu) begin
                    if (aluop == `ALUADD) begin
                        ctrl_ex    = 1'b1;
                        data_excode = 32'h00000001;
                    end
                    else
                        if (aluop == `ALUSUB) begin
                            ctrl_ex    = 1'b1;
                            data_excode = 32'h00000003;
                        end
                end
            end
        end
    end
endmodule
