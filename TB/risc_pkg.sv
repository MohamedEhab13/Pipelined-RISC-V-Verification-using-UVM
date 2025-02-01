package risc_pkg;

     localparam [6:0] lw    = 7'b0000011 ,
	              imm   = 7'b0010011 ,
		      auipc = 7'b0010111 ,
		      sw    = 7'b0100011 ,
		      arith = 7'b0110011 ,
		      lui   = 7'b0110111 ,
	              brnch = 7'b1100011 ,
		      jalr  = 7'b1100111 , 
		      jal   = 7'b1101111 ;
 
					  
    localparam [2:0] add = 3'b000 ,
	             sub = 3'b000 ,
                     sll = 3'b001 ,
                     slt = 3'b010 ,
                     Xor = 3'b100 , 
                     srl = 3'b101 , 
	             sra = 3'b101 ,
                     Or  = 3'b110 ,
                     And = 3'b111 ;


     localparam [2:0] beq = 3'b000 , 
                      bne = 3'b001 ,
                      blt = 3'b100 ,
                      bge = 3'b101 ;


     typedef enum logic [5:0] {LW,SW,
                               ADDI,SLLI,SLTI,XORI,SRLI,SRAI,ORI,ANDI,
                               AUIPC,LUI,
                               ADD,SUB,SLL,SLT,XOR,SRL,SRA,OR,AND,
                               BEQ,BNE,BLT,BGE,
                               JALR,JAL,
                               RESET, UNKNOWN} instr_type;


endpackage 
