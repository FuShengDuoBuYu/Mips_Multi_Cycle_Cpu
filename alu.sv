module alu(
    input logic [31:0] A, B, 
    input logic [2:0] ALUcont, 
    output logic [31:0] result, 
    output logic zero
);
    always@(*)
        begin
            case(ALUcont)
                //AND
                3'b000:
                    begin
                        result=A&B;
                        zero=(result==0)?1:0;
                    end
                //OR
                3'b001:
                    begin
                        result=A|B;
                        zero=(result==0)?1:0;
                    end
                //+
                3'b010:
                    begin
                        result=A+B;
                        zero=(result==0)?1:0;
                    end
                //xor
                3'b011:
                    begin
                        result=A^B;
                        zero=(result==0)?1:0;
                    end
                //右移>>
                3'b100:
                    begin
                        case(A[4:0])
                            5'b00000:result=(B>>0);
                            5'b00001:result=(B>>1);
                            5'b00010:result=(B>>2);
                            5'b00011:result=(B>>3);
                            5'b00100:result=(B>>4);
                            5'b00101:result=(B>>5);
                            5'b00110:result=(B>>6);
                            5'b00111:result=(B>>7);
                            5'b01000:result=(B>>8);
                            5'b01001:result=(B>>9);
                            5'b01010:result=(B>>10);
                            5'b01011:result=(B>>11);
                            5'b01100:result=(B>>12);
                            5'b01101:result=(B>>13);
                            5'b01110:result=(B>>14);
                            5'b01111:result=(B>>15);
                            5'b10000:result=(B>>16);
                            5'b10001:result=(B>>17);
                            5'b10010:result=(B>>18);
                            5'b10011:result=(B>>19);
                            5'b10100:result=(B>>20);
                            5'b10101:result=(B>>21);
                            5'b10110:result=(B>>22);
                            5'b10111:result=(B>>23);
                            5'b11000:result=(B>>24);
                            5'b11001:result=(B>>25);
                            5'b11010:result=(B>>26);
                            5'b11011:result=(B>>27);
                            5'b11100:result=(B>>28);
                            5'b11101:result=(B>>29);
                            5'b11110:result=(B>>30);
                            5'b11111:result=(B>>31);
                        endcase
                        zero=(result==0)?1:0;
                    end
                //OR !B
                3'b101:
                    begin
                        result=A|(~B);
                        zero=(result==0)?1:0;
                    end
                //-
                3'b110:
                    begin
                        result=A-B;
                        zero=(A==B)?1:0;
                    end
                //SLT
                3'b111:
                    begin
                        result=(A<B)?1:0;
                        zero=(result==0)?1:0;
                    end
            endcase
        end
endmodule