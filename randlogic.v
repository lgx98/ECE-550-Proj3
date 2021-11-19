`include "config.v"
`define macro
module randlogic (input [4:0] inst_opcode,
                  output reg [`W_RANDLOGIC-1:0] ctrl_out);
    always @(*) begin
        ctrl_out = `NOP;
        case (inst_opcode)
            5'b00000: // alu
                ctrl_out = (1<<`REGWE)|(1<<`ALU);
            5'b00001: // j
                ctrl_out = (1<<`IMM2PC);
            5'b00010: // bne
                ctrl_out = (1<<`BNE)|(1<<`CONDB);
            5'b00011: // jal
                ctrl_out = (1<<`REGWE)|(1<<`IMM2PC)|(1<<`JAL);
            5'b00100: // jr
                ctrl_out = (1<<`REG2PC);
            5'b00101: // addi
                ctrl_out = (1<<`REGWE)|(1<<`IMMADD)|(1<<`ADDI);
            5'b00110: // blt
                ctrl_out = (1<<`BLT)|(1<<`CONDB);
            5'b00111: // sw
                ctrl_out = (1<<`IMMADD)|(1<<`MEMWE);
            5'b01000: // lw
                ctrl_out = (1<<`REGWE)|(1<<`IMMADD)|(1<<`MEM2REG);
            5'b10101: // setx
                ctrl_out = (1<<`SETX)|(1<<`REGWE);
            5'b10110: // bex
                ctrl_out = (1<<`BEX)|(1<<`CONDB);
            default:
                ctrl_out = `NOP;
        endcase
    end
endmodule
