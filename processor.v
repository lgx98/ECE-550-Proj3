`include "config.v"
/**
 * READ THIS DESCRIPTION!
 *
 * The processor takes in several inputs from a skeleton file.
 *
 * Inputs
 * clock: this is the clock for your processor at 50 MHz
 * reset: we should be able to assert a reset to start your pc from 0 (sync or
 * async is fine)
 *
 * Imem: input data from imem
 * Dmem: input data from dmem
 * Regfile: input data from regfile
 *
 * Outputs
 * Imem: output control signals to interface with imem
 * Dmem: output control signals and data to interface with dmem
 * Regfile: output control signals and data to interface with regfile
 *
 * Notes
 *
 * Ultimately, your processor will be tested by subsituting a master skeleton, imem, dmem, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file acts as a small wrapper around your processor for this purpose.
 *
 * You will need to figure out how to instantiate two memory elements, called
 * "syncram," in Quartus: one for imem and one for dmem. Each should take in a
 * 12-bit address and allow for storing a 32-bit value at each address. Each
 * should have a single clock.
 *
 * Each memory element should have a corresponding .mif file that initializes
 * the memory element to certain value on start up. These should be named
 * imem.mif and dmem.mif respectively.
 *
 * Importantly, these .mif files should be placed at the top level, i.e. there
 * should be an imem.mif and a dmem.mif at the same level as process.v. You
 * should figure out how to point your generated imem.v and dmem.v files at
 * these MIF files.
 *
 * imem
 * Inputs:  12-bit address, 1-bit clock enable, and a clock
 * Outputs: 32-bit instruction
 *
 * dmem
 * Inputs:  12-bit address, 1-bit clock, 32-bit data, 1-bit write enable
 * Outputs: 32-bit data at the given address
 *
 */
module processor(clock,
                 reset,            // I: A reset signal
                 address_imem,     // O: The address of the data to get from imem
                 q_imem,           // I: The data from imem
                 address_dmem,     // O: The address of the data to get or put from/to dmem
                 data,             // O: The data to write to dmem
                 wren,             // O: Write enable for dmem
                 q_dmem,           // I: The data from dmem
                 ctrl_writeEnable, // O: Write enable for regfile
                 ctrl_writeReg,    // O: Register to write to in regfile
                 ctrl_readRegA,    // O: Register to read from port A of regfile
                 ctrl_readRegB,    // O: Register to read from port B of regfile
                 data_writeReg,    // O: Data to write to for regfile
                 data_readRegA,    // I: Data from port A of regfile
                 data_readRegB);   // I: Data from port B of regfile
    // Control signals
    input clock, reset;
    
    // Imem
    output [11:0] address_imem;
    input [31:0] q_imem;
    
    // Dmem
    output [11:0] address_dmem;
    output [31:0] data;
    output wren;
    input [31:0] q_dmem;
    
    // Regfile
    output ctrl_writeEnable;
    output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
    output [31:0] data_writeReg;
    input [31:0] data_readRegA, data_readRegB;
    
    /* YOUR CODE STARTS HERE */
    wire clk, rst;
    assign clk = clock;
    assign rst = reset;
    
    //==>> Instruction Fetch <<== 
    wire ctrl_branch;
    wire [31:0] addr_pcin;
    wire [31:0] addr_branch;
    wire [31:0] addr_pcout;
    wire [31:0] addr_nxtpc;
    wire [31:0] inst;

    assign addr_nxtpc = addr_pcout + 32'h00000001;
    assign addr_pcin = ctrl_branch ? addr_branch : addr_nxtpc;
    
    dffe_wers pc(
    .we(1'b1),
    .din(addr_pcin),
    .qout(addr_pcout),
    .clk(clk),
    .rst(rst)
    );
    
    assign address_imem = addr_pcout[11:0];
    assign inst         = q_imem;
    
    //==>> Instruction Decode & Regfile <<== 
    // instruction fields
    wire [4:0] inst_opcode;
    wire [4:0] inst_rd;
    wire [4:0] inst_rs;
    wire [4:0] inst_rt;
    wire [4:0] inst_shamt;
    wire [4:0] inst_aluop;
    wire [16:0] inst_simm17;
    wire [26:0] inst_uimm27;
    // decoder output
    wire [`W_RANDLOGIC-1:0] ctrl_datapath;
    // immgen output
    wire [31:0] data_simm17x;
    wire [31:0] data_uimm27x;
    
    // regfile
    assign ctrl_writeEnable = ctrl_datapath[`REGWE];
    assign ctrl_writeReg    =
        ctrl_datapath[`JAL] ?
            `RRETADDR
        :
            ctrl_ex ?
                `RSTATUS
                :
                inst_rd;
    assign ctrl_readRegA    = inst_rs;
    assign ctrl_readRegB    = ctrl_datapath[`SW] ? inst_rd : inst_rt;
    assign inst_opcode      = inst[31:27];
    
    // random logic (decoder)
    assign inst_opcode = inst[31:27];
    assign inst_rd     = inst[26:22];
    assign inst_rs     = inst[21:17];
    assign inst_rt     = inst[16:12];
    assign inst_shamt  = inst[11:7];
    assign inst_aluop  = inst[6:2];
    assign inst_simm17 = inst[16:0];
    assign inst_uimm27 = inst[26:0];
    
    randlogic u_randlogic(
    .inst_opcode(inst_opcode),
    .ctrl_out(ctrl_datapath)
    );
    
    // immediate number generator
    assign data_simm17x = {{15{inst_simm17[16]}}, inst_simm17};
    assign data_uimm27x = {5'h00, inst_uimm27};
    
    //==>> Execution and Branch Address Calculation <<== 
    wire [31:0] data_operanda;
    wire [31:0] data_operandb;
    wire [4:0] ctrl_aluop;
    wire [31:0] data_aluout;
    wire ctrl_ne;
    wire ctrl_lt;
    wire ctrl_ovf;
    wire ctrl_condbr;
    wire ctrl_ex;
    wire [31:0] data_excode;
    
    assign ctrl_aluop    = ctrl_datapath[`IMMADD] ? `ALUADD : inst_aluop;
    assign data_operanda = data_readRegA;
    assign data_operandb = ctrl_datapath[`IMM2ALU] ? data_simm17x : data_readRegB;
    alu u_alu(
    .data_operandA(data_operanda),
    .data_operandB(data_operandb),
    .ctrl_ALUopcode(ctrl_aluop),
    .ctrl_shiftamt(inst_shamt),
    .data_result(data_aluout),
    .isNotEqual(ctrl_ne),
    .isLessThan(ctrl_lt),
    .overflow(ctrl_ovf));
    
    assign ctrl_condbr = (ctrl_datapath[`BNE]&&ctrl_ne)|(ctrl_datapath[`BLT]&&ctrl_lt);
    assign ctrl_branch = ctrl_datapath[`IMM2PC]|
        ctrl_datapath[`REG2PC]|
        ctrl_condbr;
    
    assign addr_branch =
        ctrl_condbr ?
            addr_nxtpc + data_simm17x
        :
            ctrl_datapath[`IMM2PC] ?
                data_uimm27x
            :
                data_operanda;
    
    exception_gen u_exception_gen(
        .ctrl_alu(ctrl_datapath[`ALU]),
        .ctrl_addi(ctrl_datapath[`ADDI]),
        .ovf(ctrl_ovf),
        .aluop(ctrl_aluop),
        .ctrl_ex(ctrl_ex),
        .data_excode(data_excode)
    );
    
    //==>> Data Memory Operation <<==
    wire [31:0] data_dmem;
    assign address_dmem = data_aluout[11:0];
    assign data = data_readRegB;
    assign wren = ctrl_datapath[`MEMWE];
    assign data_dmem = q_dmem;

    //==>> Register Write Back <<==
    assign data_writeReg =
        ctrl_datapath[`PC2RD] ?
            addr_nxtpc
        :
            ctrl_datapath[`MEM2REG] ?
                data_dmem
            :
                ctrl_ex ?
                    data_excode
                :
                    data_aluout;
endmodule
