//用于lb
module signext8_32(
    input logic [7:0] a,
    output logic [31:0] y
);
    assign y = {{24{a[7]}}, a};
endmodule