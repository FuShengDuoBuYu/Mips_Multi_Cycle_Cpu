module controller(
    input logic clk, reset,
    input logic [5:0] op, funct,
    input logic zero,
    output logic pcen, memwrite, irwrite, regwrite,
    output logic alusrca, iord, 
    output logic memtoreg, regdst,
    output logic [2:0] alusrcb, // ANDI 
    output logic [1:0] pcsrc,
    output logic [2:0] alucontrol,
    output logic [1:0] lb
); // LB/LBU
    logic [2:0] aluop;
    logic branch, pcwrite;
    logic bne; // BNE
    // Main Decoder and ALU Decoder subunits.
    maindec md(
        clk, reset, op,
        pcwrite, memwrite, irwrite, regwrite,
        alusrca, branch, iord, memtoreg, regdst, 
        alusrcb, pcsrc, aluop, bne, lb
    ); //BNE, LBU
    aludec ad(funct, aluop, alucontrol);
    assign pcen = pcwrite | (branch & zero) | (bne & ~zero); // BNE
endmodule