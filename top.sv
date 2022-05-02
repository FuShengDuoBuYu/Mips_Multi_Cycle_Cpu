module top(
    input logic clk, reset, 
    output logic [31:0] writedata, adr, 
    output logic memwrite
);
    logic [31:0] readdata;
    
    // instantiate processor and memory
    mips mips(clk, reset, adr, writedata, memwrite, readdata);
    mem mem(clk, memwrite, adr, writedata, readdata);
endmodule