module datapath(
    input logic clk, reset,
    input logic pcen, irwrite, 
    input logic regwrite,
    input logic alusrca, iord, memtoreg, regdst,
    input logic [2:0] alusrcb, // ANDI
    input logic [1:0] pcsrc, 
    input logic [2:0] alucontrol,
    input logic [1:0] lb, // LB/LBU
    output logic [5:0] op, funct,
    output logic zero,
    output logic [31:0] adr, writedata, 
    input logic [31:0] readdata
);

    logic [4:0] writereg;
    logic [31:0] pcnext, pc;
    logic [31:0] instr, data, srca, srcb;
    logic [31:0] a;
    logic [31:0] aluresult, aluout;
    logic [31:0] signimm; // the sign-extended imm
    logic [31:0] zeroimm; // the zero-extended imm
    // ANDI
    logic [31:0] signimmsh; // the sign-extended imm << 2
    logic [31:0] wd3, rd1, rd2;
    logic [31:0] memdata, membytezext, membytesext; // LB / LBU
    logic [7:0] membyte; // LB / LBU

    // op和funct
    assign op = instr[31:26];
    assign funct = instr[5:0];
    // datapath
    flopenr #(32) pcreg(clk, reset, pcen, pcnext, pc);
    mux2 #(32) adrmux(pc, aluout, iord, adr);
    flopenr #(32) instrreg(clk, reset, irwrite, readdata, instr);
    
    // changes for LB / LBU
    flopr #(32) datareg(clk, reset, memdata, data); 
    mux4 #(8) lbmux(readdata[31:24], readdata[23:16], readdata[15:8],readdata[7:0], aluout[1:0], membyte);
    zeroext8_32 lbze(membyte, membytezext);
    signext8_32 lbse(membyte, membytesext);
    mux3 #(32) datamux(readdata, membytezext, membytesext, lb, memdata);
    
    mux2 #(5) regdstmux(instr[20:16], instr[15:11], regdst, writereg);
    mux2 #(32) wdmux(aluout, data, memtoreg, wd3);
    regfile rf(clk, regwrite, instr[25:21], instr[20:16], writereg, wd3, rd1, rd2);
    signext se(instr[15:0], signimm);
    zeroext ze(instr[15:0], zeroimm); // ANDI
    sl2 immsh(signimm, signimmsh);
    flopr #(32) areg(clk, reset, rd1, a);
    flopr #(32) breg(clk, reset, rd2, writedata);
    mux2 #(32) srcamux(pc, a, alusrca, srca);
    mux5 #(32) srcbmux(writedata, 32'b100, signimm, signimmsh,zeroimm, alusrcb, srcb);
    alu alu(srca, srcb, alucontrol,aluresult, zero);
    flopr #(32) alureg(clk, reset, aluresult, aluout);
    mux3 #(32) pcmux(aluresult, aluout,
    {pc[31:28], instr[25:0], 2'b00}, 
    pcsrc, pcnext);
endmodule