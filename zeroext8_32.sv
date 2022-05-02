//用于lbu
module zeroext8_32(
    input logic [7:0] a,
    output logic [31:0] y
);
    assign y = {24'b0, a};
endmodule