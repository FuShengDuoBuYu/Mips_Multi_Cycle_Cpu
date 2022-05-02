module mips(
    input logic clk, reset,
    output logic [31:0] adr, writedata,
    output logic memwrite,
    input logic [31:0] readdata);

    logic zero, pcen, irwrite, regwrite, alusrca, iord, memtoreg, regdst;    
    logic [2:0] alusrcb; // ANDI
    logic [1:0] pcsrc;
    logic [2:0] alucontrol;
    logic [5:0] op, funct;
    logic [1:0] lb; // LB/LBU
    controller c(
        clk, reset, op, funct, zero,
        pcen, memwrite, irwrite, regwrite,
        alusrca, iord, memtoreg, regdst, 
        alusrcb, pcsrc, alucontrol, lb
    );
    datapath dp(
        clk, reset, 
        pcen, irwrite, regwrite,
        alusrca, iord, memtoreg, regdst,
        alusrcb, pcsrc, alucontrol,
        lb, // LB/LBU
        op, funct, zero,
        adr, writedata, readdata
    );
endmodule