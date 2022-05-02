module maindec(
    input clk, reset, 
    input [5:0] op, 
    output pcwrite, memwrite, irwrite, regwrite,
    output alusrca, branch, iord, memtoreg, regdst,
    output [2:0] alusrcb, // ANDI
    output [1:0] pcsrc, 
    output [2:0] aluop, 
    output bne, // BNE
    output [1:0] lb
); // LB/LBU
    typedef enum logic [4:0] {
        FETCH, DECODE, MEMADR, 
        MEMRD, MEMWB, MEMWR, RTYPEEX, RTYPEWB, BEQEX, 
        ADDIEX, ADDIWB, JEX, ANDIEX, ANDIWB,
        ORIEX,ORIWB,
        XORIEX,XORIWB,
        BNEEX, LBURD, LBRD} statetype;

    statetype [4:0] state, nextstate;
    //操作码
    parameter RTYPE = 6'b000000;
    parameter LW = 6'b100011;
    parameter SW = 6'b101011;
    parameter BEQ = 6'b000100;
    parameter ADDI = 6'b001000;
    parameter J = 6'b000010;
    parameter BNE = 6'b000101;
    parameter LBU = 6'b100100;
    parameter LB = 6'b100000;
    parameter ANDI = 6'b001100;
    parameter ORI = 6'b001101;
    parameter XORI = 6'b001110;
    logic [19:0] controls; // ANDI, BNE, LBU, ORI,XORI
    // 状态寄存器
    always_ff @(posedge clk or posedge reset)
        if(reset) state <= FETCH;
        else state <= nextstate;
    
    // 下一个state
    always_comb
        case(state)
            FETCH: nextstate <= DECODE;
            DECODE: 
                case(op)
                    LW: nextstate <= MEMADR;
                    SW: nextstate <= MEMADR;
                    LB: nextstate <= MEMADR; // LB
                    LBU: nextstate <= MEMADR; // LBU
                    RTYPE: nextstate <= RTYPEEX;
                    BEQ: nextstate <= BEQEX;
                    ADDI: nextstate <= ADDIEX;
                    J: nextstate <= JEX;
                    BNE: nextstate <= BNEEX; // BNE
                    ANDI: nextstate <= ADDIEX; // ANDI
                    ORI : nextstate <= ORIEX; // ORI
                    XORI: nextstate <= XORIEX; //XORI
                    default: nextstate <= FETCH; 
            endcase
            MEMADR: 
                case(op)
                    LW: nextstate <= MEMRD;
                    SW: nextstate <= MEMWR;
                    LBU: nextstate <= LBURD; // LBU
                    LB: nextstate <= LBRD; // LB
                    default: nextstate <= FETCH; 
                endcase
            MEMRD: nextstate <= MEMWB;
            MEMWB: nextstate <= FETCH;
            MEMWR: nextstate <= FETCH;
            RTYPEEX: nextstate <= RTYPEWB;
            RTYPEWB: nextstate <= FETCH;
            BEQEX: nextstate <= FETCH;
            ADDIEX: nextstate <= ADDIWB;
            ADDIWB: nextstate <= FETCH;
            JEX: nextstate <= FETCH;
            ANDIEX: nextstate <= ANDIWB; // ANDI
            ANDIWB: nextstate <= FETCH; // ANDI
            ORIEX: nextstate <= ORIWB; //ORI
            ORIWB: nextstate <= FETCH; //ORI
            XORIEX: nextstate <= XORIWB; //XORI
            XORIWB: nextstate <= FETCH; //XORI
            BNEEX: nextstate <= FETCH; // BNE
            LBURD: nextstate <= MEMWB; // LBU
            LBRD: nextstate <= MEMWB; // LB
            default: nextstate <= FETCH; 
     endcase
    //输出controls信号
    assign {
        pcwrite, memwrite, irwrite, regwrite, 
        alusrca, branch, iord, memtoreg, regdst, 
        bne, // BNE
        alusrcb, pcsrc, 
        aluop,lb
    } = controls; // LBU
    always_comb
        case (state)
            FETCH: controls <= 20'b1010_00000_0_00100_000_00;
            DECODE: controls <= 20'b0000_00000_0_01100_000_00;
            MEMADR: controls <= 20'b0000_10000_0_01000_000_00;
            MEMRD: controls <= 20'b0000_00100_0_00000_000_00;
            MEMWB: controls <= 20'b0001_00010_0_00000_000_00;
            MEMWR: controls <= 20'b0100_00100_0_00000_000_00;
            RTYPEEX: controls <= 20'b0000_10000_0_00000_010_00;
            RTYPEWB: controls <= 20'b0001_00001_0_00000_000_00;
            BEQEX: controls <= 20'b0000_11000_0_00001_001_00;
            ADDIEX: controls <= 20'b0000_10000_0_01000_000_00;
            ADDIWB: controls <= 20'b0001_00000_0_00000_000_00;
            JEX: controls <= 20'b1000_00000_0_00010_000_00;
            ANDIEX: controls <= 20'b0000_10000_0_10000_011_00; // ANDI
            ANDIWB: controls <= 20'b0001_00000_0_00000_000_00; // ANDI
            ORIEX: controls <= 20'b0000_10000_0_10000_100_00;  //ORI
            ORIWB: controls <= 20'b0001_00000_0_00000_000_00;  //ORI
            XORIEX: controls <= 20'b0000_10000_0_10000_101_00;  //XORI
            XORIWB: controls <= 20'b0001_00000_0_00000_000_00;  //XORI
            BNEEX: controls <= 20'b0000_10000_1_00001_001_00; // BNE
            LBURD: controls <= 20'b0000_00100_0_00000_000_01; // LBU
            LBRD: controls <= 20'b0000_00100_0_00000_000_10; // LB
            default: controls <= 20'b0000_xxxxx_x_xxxxx_xxx_xx;
        endcase 
endmodule