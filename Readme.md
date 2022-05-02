# 实验名称 32位多周期处理器的设计



## 郭仲天 19307110250 2022/5/2

## 实验内容

1.阅读教材内容,完成MIPS多周期处理器设计

2.新增加诸多指令,如bne,ori等

2.用教材测试代码,测试上述设计

3.~~在开发板上实现两位正整数加法运算,如12+34 = 046~~

---

## 实验概述

### 实现的指令

|           指令名称            | 指令类型 | 共计 |
| :---------------------------: | :------: | :--: |
| <font color="red">srlv</font> | R型指令  |  1   |
|              slt              | R型指令  |  2   |
|              add              | R型指令  |  3   |
|              sub              | R型指令  |  4   |
|              or               | R型指令  |  5   |
|              and              | R型指令  |  6   |
| <font color="red">addi</font> | I型指令  |  7   |
| <font color="red">ori</font>  | I型指令  |  8   |
| <font color="red">andi</font> | I型指令  |  9   |
| <font color="red">xori</font> | I型指令  |  10  |
| <font color="red">bne</font>  | I型指令  |  11  |
|              beq              | I型指令  |  12  |
|              lw               | I型指令  |  13  |
|              sw               | I型指令  |  14  |
|  <font color="red">lb</font>  | I型指令  |  15  |
| <font color="red">lbu</font>  | I型指令  |  16  |
|             jump              | J型指令  |  17  |

### 实验限制

由于疫情,我们无法拿到开发板进行实验,因此此处对开发板的IO写了也无济于事,如果本学期可以拿到开发板再补上好了

---

## 实验过程

### 第一部分 设计含基本指令的多周期cpu

#### 设计思路

多周期cpu的设计,难点不仅在数据通路上,同样也在主控制器的状态转换图上.

首先,我们先获取基本指令的cpu的状态图和数据通路如下:

##### FSM图

![FSM](C:\Users\fengchuiyusan\Desktop\FSM.jpg)

##### 数据通路

![datapath](C:\Users\fengchuiyusan\Desktop\datapath.jpg)



##### 其他

- 于是我们按照这个FSM图和数据路径,便得到可以支持**lw,sw,R-type,beq**等指令的多周期cpu了
- 我在设计多周期cpu时,是将许多指令统一后一起写代码的,故综合和仿真图就在下面给出了

---

### 第二部分 扩展多周期cpu的指令并用测试程序测试

#### 设计思路

##### FSM图

本次对多周期cpu的改造,主要加入了以下指令

- bne
- lb
- lbu
- andi
- ori
- xori
- srlv
- ...

于是根据这些指令,扩展FSM图,生成新的FSM图如下:(控制信号的值在此处省略):

![1651460557495644284230480292951](C:\Users\fengchuiyusan\Downloads\1651460557495644284230480292951.jpg)

对应的**状态转换代码及控制信号**如下:

```systemverilog
	//状态转换
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
    //===================================================================
    //各个控制信号
    assign {
        pcwrite, memwrite, irwrite, regwrite, 
        alusrca, branch, iord, memtoreg, regdst, 
        bne, // BNE
        alusrcb, pcsrc, 
        aluop,lb
    } = controls;
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
```

##### 数据通路(datapath)

根据我们刚刚扩展的指令,扩展完各个字段后,得到datapath的结构如下:

![image-20220502110915980](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502110915980.png)

(由于lbu和lb指令以及addi等指令,加入了许多扩展模块,如**zeroext8_32,zeroext,signext8_32**等等)

##### 测试设计思路

- 我们根据mips的指令,分别设计其中的命令,程序通过计算执行指令,只有当所有的指令执行正确时才会

得到正确的结果,我们将指令作为16进制的代码存储在文件中让程序去执行

- 在这个基准程序中,我们分别测试了**addi,or,and,beq,slt,sub,sw,lw,j,xori,srlv,bne,lbu,ori**等指令的执行正确性
- 测试基准程序如下:
- ![image-20220502111516187](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502111516187.png)

---

#### 系统框图

我们按照设计将各个模块写好并连接后,可以得到如下的程序代码结构:

![image-20220502111821077](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502111821077.png)

于是我们对这些代码查看**综合原理图**,如下所示:

![image-20220502111917792](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502111917792.png)

**Controller结构图:**

![image-20220502112008088](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502112008088.png)

**datapath结构图**

在上文中已给出,此处不再赘述



可以看出,整个cpu的结构和我们预期设计是一样的

---

#### 方案说明

我们在进行指令的扩展时,最重要的便是写出该新指令的状态转换图,从而才可以在状态机中加入该指令的执行状态.

---

#### 测试代码(注:memfile.dat等测试文件在

**LAB3_Multi_cycle_cpu\LAB3_Multi_cycle_cpu.sim\sim_1\behav\xsim)**

memfile.dat中的即为测试设计中提到的测试的指令的**16进制数据**

```
                                    20020005
                                    3443fefe
                                    00431006
                                    08000006
                                    2263000e
                                    10420003
                                    2063000c
                                    201f0014
                                    08000005
                                    2067fff7
                                    38e6ff07
                                    14670003
                                    00e6302a
                                    10800001
                                    20050000
                                    acc7005f
                                    ac020068
                                    8c020064
                                    9003006b
                                    08000015
                                    20020001
                                    00434022
                                    ac08006c
```

按照测试设计中提到的,如果所有代码运行成功,将会**在地址108处写入数据0xFE0B**

测试代码如下:

```systemverilog
module testbench();
    logic clk;
    logic reset;
    logic [31:0] writedata, dataadr;
    logic memwrite;

    logic [31:0] cycle;
    logic succeed;
    // 实例化
    top test(clk, reset, writedata, dataadr, memwrite);
    // 初始化
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
    // 校验结果
    always @(negedge clk)
        begin
            if(memwrite & dataadr == 108) begin
            if(writedata == 65035) // 65035=0xFE0B
                $display("============Simulation succeeded=================");
            else 
                begin
                    $display("Simulation failed");
                end
            $stop;
        end
    end
endmodule
```

可以看出,如果最终所有指令跑通,则应该会输出***Simulation succeeded***的字样

最终,我们进行仿真,可以得到如下结果

![image-20220502120547077](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502120547077.png)

![image-20220502120800386](C:\Users\fengchuiyusan\AppData\Roaming\Typora\typora-user-images\image-20220502120800386.png)

根据如上图示结果,我们可以知道多周期cpu设计成功

---

### 问题解决

#### 问题一

###### 问题描述

在扩展srlv指令时,需要进行移位

在进行移位操作时,verilog并不支持logic到logic的移位,如下:

```verilog
//以下操作并不允许
logic [31:0] A,B;
A >> B[4:0]
//必须是移位整数位
A >> 5;
```

###### 解决方案

由于这个原因,查找了许久都没能找到verilog的类型转换,最终选择采用switch case语句实现srlv指令

```verilog
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
```

#### 问题二

###### 问题描述

alu操作有很多并未用到,如A&(~B),为了适应扩展多周期cpu指令的需求,则需要给alu多加好几位操作码

###### 解决方案

因此修改了部分alu的功能码对应的功能,以更好的进行计算

**修改后的alu操作码和功能对应关系如下:**

| ALU操作码 | 操作名称 | 符号表示  |
| :-------: | :------: | :-------: |
|    000    |    与    |    A&B    |
|    001    |    或    |   A\|B    |
|    010    |    加    |    A+B    |
|    011    |   异或   |    A^B    |
|    100    |   右移   | B>>A[4:0] |
|    101    |   或非   |  A\|(~B)  |
|    110    |    减    |    A-B    |
|    111    |   SLT    | (A<B)?1:0 |

#### 问题三

###### 问题描述

由于扩展指令,状态图中的各个状态种类繁多,用01表示难以辨别

###### 解决方案

故使用参数名称进行数字的替代,如下所示

```verilog
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
```

---

### 实验总结

多周期的cpu设计,随着指令的条数增加,状态转换图也会逐渐变得复杂,因此在理解多周期cpu的基础上,如何清晰的将状态转换图(FSM)画出并实现是cpu设计的关键

在设计好FSM后,只需按照对应的FSM设计出datapath,再将各个模块连接起来即可