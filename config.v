`ifndef _CONFIG_V_
`define _CONFIG_V_

`define RZERO 5'd0
`define RSTATUS 5'd30
`define RRETADDR 5'd31

`define ALUADD 5'b00000
`define ALUSUB 5'b00001

`define W_RANDLOGIC 32
`define NOP {`W_RANDLOGIC{1'b0}}
`define JR 0
`define REG2PC 0
`define JAL 1
`define PC2RD 1
`define IMM2PC 2
`define BLT 3
`define BNE 4
`define MEMWE 5
`define SW 5
`define MEM2REG 6
`define IMMADD 7
`define IMM2ALU 7
`define REGWE 8
`define ALU 9
`define ADDI 10
`define BEX 11
`define SETX 12
`define CONDB 13

`endif
