module testbench();
    logic clk;
    logic reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;

    logic [31:0] cycle;
    logic succeed;
    // 实例�?
    top test(clk, reset, writedata, dataadr, memwrite);
    // 初始�?
    initial
        begin
            reset <= 1; # 12; reset <= 0;
            cycle <= 1;
            succeed <= 0;
        end
    // 时钟
    always
        begin
            clk <= 1; # 5; clk <= 0; # 5;
            cycle <= cycle + 1;
        end
    // �?查结�?
    always @(negedge clk)
        begin
            if(memwrite & dataadr == 108) begin
            if(writedata == 65035) // 65035=0xFE0B
                $display("============Simulation succeeded=================");
            else 
                begin
                    $display("Simulation failed");
                end
            
        end
    end
endmodule