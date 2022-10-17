%include "in_out.asm"
section .data

 filename db 'testfile-a.txt',0
 filename2 db 'testfie-aout.txt',0
 bufferlen dq 200
 null dq 0


 ;constants
 const1 db ' ',0
 const2 db ',',0
 const3 db 0x0a,0


 reg_ db "al",0,0,"ax",0,0,"eax",0,"rax",0, "cl",0,0,"cx",0,0,"ecx",0,"rcx",0, "dl",0,0,"dx",0,0,"edx",0,"rdx",0, "bl",0,0,"bx",0,0,"ebx",0, "rbx","0", "ah",0,0,"sp",0,0,"esp",0,"rsp",0, "ch",0,0,"bp",0,0,"ebp",0,"rbp",0, "dh",0,0,"si",0,0,"esi",0,"rsi",0, "bh",0,0,"di",0,0,"edi",0,"rdi",0
 endreg_ db 0,0,0,0
 nreg_ db "r8b",0,"r8w",0, "r8d",0,"r8",0,0, "r9b",0,"r9w",0,"r9d",0,"r9",0,0, "r10b","r10w","r10d","r10",0, "r11b","r11w","r11d","r11",0, "r12b","r12w","r12d","r12",0, "r13b","r13w","r13d","r13",0, "r14b","r14w","r14d","r14",0,"r15b","r15w","r15d","r15",0
 endnreg_ db 0,0,0,0

 inst_ db "mov",0,0b10001000, "add",0,0b00000000, "adc",0,0b00010000, "sub",0,0b00101000, "sbb",0,0b00011000, "and",0,0b00100000, "or",0,0,0b00001000, "xor",0,0b00110000,"cmp",0,0b00111000, "test",0b10000100, "xchg",0b10000100, "xadd",0b11000000,"imul",0b10101100, "idiv",0b11110100,"bsf",0,0b10111100, "bsr",0,0b10111101
 endinst_ db 0,0,0,0
 
 hexnum_ db "0",0,"1",0,"2",0,"3",0,"4",0,"5",0,"6",0,"7",0,"8",0,"9",0,"a",0,"b",0,"c",0,"d",0,"e",0,"f",0
 zero db "0",0
 one db "1",0
 ;ent db 'add byte ptr [rdx],bl',0 
 ;mod db 0

 const66 db 0x66,0
 const67 db 0x67,0
 opsize db 0 ;0->8, 1->16, 2->32, 3->64
 addsize db 2 ; 2->32, 3->64 

 opincludenew db 1 ;1->new reg used
 W db 0
 D db 0
 BREX db 0
 WREX db 0
 RREX db 0
 XREX db 0
 ; isinornot
 b67 db 0
 b66 db 0
 brex db 0
 bbop db 0
 bopc db 1
 bmod db 0
 bsib db 0
 bdis db 0
 badd db 0
 bimm db 0

section .bss
 ent: resb 200 ; assembly code
 entptr: resq 1

 boolcode:resb 200 ;disassembeled
 boolcodeptr: resq 1


 buffer: resb 200
 FD: resq 1
 bufferptr: resq 1
 buffer2: resb 400
 FD2: resq 1
 buffer2ptr: resq 1
 entrwriteptr: resq 1
 



 inst: resb 10
 op1: resb 20
 op2: resb 20
 op1code: resb 1 ; xxxcccdd
 op2code: resb 1 ; xxxcccdd
 op1state: resb 1 ;3-> new reg | 2-> old reg | 1-> imm | 0-> mem
 op2state: resb 1 ;3-> new reg | 2-> old reg | 1-> imm | 0-> mem
 totallen: resb 1

 memoryinput: resb 20
 ptrsize: resb 1 ;0->byte | 1->word | 2->dword | 3->qword
 bisd: resb 1 ; xxxx|0000
 
 bisdb: resb 4
 bisdi: resb 4
 bisds: resb 1
 bisdd: resb 20

 bisdbcode: resb 1
 bisdscode: resb 1
 bisdicode: resb 1

 ;bisdb_code: resb 1
 ;bisdi_code: resb 1
 ;bisdd_code: resb 1
 ;inst: resb 5
 ;reg1: resb 20
 ;reg2: resb 20
 ;temp_disp: resb 88;????????????????
 ; ascii char in word
 inrex: resb 1
 inbop: resb 1
 inopc: resb 1
 inmod: resb 1
 ;
 inmod_02: resb 1
 inmod_25: resb 1
 inmod_58: resb 1


 ;
 insib: resb 1
 indis: resb 1
 inimm: resb 1
 inadd: resb 1
 
 wregcode: resb 1 
 ; converted ascii char in byte
 ;binrex: resb 1
 ;binopc: resb 1
 ;binmod: resb 1
 ;binsib: resb 1
 ;bindis: resb 10
 ;binadd: resq 1


section .text
 global _start
_start:

 %macro set 2
 ; %1 <- %2
 ; movsb rdi <- rsi
 ;??rdx
 ;mov rsi, %2
 ;call GetStrlen
 mov rcx, 50
 mov rdi, %1
 mov rsi, %2
 cld
 rep movsb
 %endmacro

 call readandrun
 call makecodeforeach
 call writeanddone


 ;call split
 ;call preprint

 ;call lexrex
 ;call stating
 ;call setinstcode
 ;call codeg
 ;call print
 ;mov rsi, op1
 ;call findreg
 ;mov rsi, op1
 ;call findnreg
 ;call writeNum


findreg:
 ; registername <- rsi
 ; rdi<-reg_
 ; index -> al
 mov rdi, reg_
 sub rdi, 4

 findreg1:
 xor rdx, rdx
 add rdi, 4
 cmp rdi, endreg_
 jge rfindreg1
 findreg11:
 cmp dl, 4
 je rfindreg11 
 mov al, byte [rsi+rdx]
 cmp byte [rdi+rdx], al
 jne findreg1
 inc dl
 jmp findreg11

 rfindreg11:
 sub rdi, reg_
 mov rax, rdi
 shr rax, 2
 jmp rfindreg

 rfindreg1:
 mov al, -1
 jmp rfindreg 

 rfindreg:
 ret 0

findnreg:
 ; registername <- rsi
 ; rdi<-nreg_
 ; index -> al
 mov rdi, nreg_
 sub rdi, 4

 findnreg1:
 xor rdx, rdx
 add rdi, 4
 cmp rdi, endnreg_
 jge rfindnreg1
 findnreg11:
 cmp dl, 4
 je rfindnreg11 
 mov al, byte [rsi+rdx]
 cmp byte [rdi+rdx], al
 jne findnreg1
 inc rdx
 jmp findnreg11

 rfindnreg11:
 mov rax, rdi
 sub rax, nreg_
 shr rax, 2
 jmp rfindnreg

 rfindnreg1:
 mov al, -1
 jmp rfindnreg 

 rfindnreg:
 ret 0


split:
 mov byte [totallen], 1
 mov rdi, ent
 mov rsi, inst
 split1:
 cmp byte [rdi], ' '
 je rsplit1
 cmp byte [rdi], 0
 je rslit
 mov al , byte [rdi]
 mov byte [rsi], al
 inc rdi
 inc rsi 
 jmp split1
 rsplit1:
 inc rdi
 mov rsi, op1
 split2:
 cmp byte [rdi], ','
 je rsplit2
 cmp byte [rdi], 0
 je rslit
 mov byte [totallen], 2
 mov al , byte [rdi]
 mov byte [rsi], al
 inc rdi
 inc rsi
 jmp split2
 rsplit2:
 inc rdi
 mov rsi, op2
 split3:
 cmp byte [rdi], 0
 je rsplit3
 mov byte [totallen], 3
 mov al , byte [rdi]
 mov byte [rsi], al
 inc rdi
 inc rsi
 jmp split3
 rsplit3:
 inc rdi

 rslit:
 ret 0

preprint:
 mov rsi, inst
 call printString
 call newLine

 mov rsi, op1
 call printString
 call newLine
 
 mov rsi, op2
 call printString
 call newLine
 
 mov ax, [totallen]
 call writeNum
 call newLine
 ret 0

 
stating:
 mov byte [op1state], 0
 mov byte [op2state], 0

 cmp byte [totallen], 3
 je stating3
 cmp byte [totallen], 2
 je stating2
 cmp byte [totallen], 1
 je rstating

 stating3:
 mov byte [op2state], 2 ;reg old
 mov rsi, op2
 call findreg
 mov byte [op2code], al
 cmp al, -1
 jne stating2

 mov byte [op2state], 3 ;reg new
 mov rsi, op2
 call findnreg
 mov byte [op2code], al
 cmp al, -1
 jne stating2

 mov byte [op2state], 1 ;imm
 cmp byte [op2], '0'
 je stating2

 mov byte [op2state], 0 ;mem
 
 stating2:
 mov byte [op1state], 2 ;reg old
 mov rsi, op1
 call findreg
 mov byte [op1code], al
 cmp al, -1
 jne rstating

 mov byte [op1state], 3 ;reg new
 mov rsi, op1
 call findnreg
 mov byte [op1code], al
 cmp al, -1
 jne rstating

 mov byte [op1state], 1 ;imm
 cmp byte [op1], '0'
 je rstating

 mov byte [op1state], 0 ;mem




 rstating:

 ret 0






codeg:


 cmp byte [totallen], 3
 je codeg3
 cmp byte [totallen], 2
 je codeg2
 cmp byte [totallen], 1
 je codeg1

 codeg1:
 call incgen_1
 jmp rcgen

 codeg2:
 call incgen_2
 jmp rcgen

 codeg3:
 call incgen_3
 jmp rcgen

 rcgen:

 ret 0


incgen_1:

 rincgen_10:
 cmp qword [inst], "stc"
 jne rincgen_11
 mov byte [inopc], 0hf9
 jmp rincgen_1

 rincgen_11:
 cmp qword [inst], "clc"
 jne rincgen_12
 mov byte [inopc], 0hf8
 jmp rincgen_1

 rincgen_12:
 cmp qword [inst], "std"
 jne rincgen_13
 mov byte [inopc], 0hfd
 jmp rincgen_1

 rincgen_13:
 cmp qword [inst], "cld"
 jne rincgen_14
 mov byte [inopc], 0hfc
 jmp rincgen_1

 rincgen_14:
 cmp qword [inst], "ret"
 jne rincgen_15
 mov byte [inopc], 0hc3
 jmp rincgen_1

 rincgen_15:
 cmp qword [inst], "syscall"
 mov byte [inbop], 0h0f
 mov byte [inopc], 0h05
 ;mov byte [inmod], 0hf8
 mov byte [bbop], 1
 ;mov byte [bmod], 1
 jmp rincgen_1
 

 
 ; if Lexed[0]=="stc":
 ; OneInstCode="f9"
 ; if Lexed[0]=="clc":
 ; OneInstCode="f8"
 ;if Lexed[0]=="std":
 ; OneInstCode="fd"
 ; if Lexed[0]=="cld":
 ; OneInstCode="fc"
 ; if Lexed[0]=="ret":
 ; OneInstCode=str("{0:02x}".format(int("11001011",2)))
 ;if Lexed[0]=="syscall":
 ; OneInstCode=str("{0:04x}".format(int("000011110000000111111000",2)))

 rincgen_1:
 ret 0 
 






incgen_2:
 cmp byte [op1state], 0
 je codeg2_0
 cmp byte [op1state], 1
 je codeg2_1
 jmp codeg2_2

 codeg2_0:
 ;mov rsi,op1
 ;call codethemem
 mov byte [W], 1
 cmp byte [ptrsize], 8
 jne codeg2_01
 mov byte [W], 1
 codeg2_01:
 cmp byte [ptrsize], 16
 jne rcodeg2_0
 mov byte [W], 1

 rcodeg2_0:
 jmp codeg20
 ; elif BoolRegisters[0]==0: #memory
 ; codeTheMemory(Lexed[1])
 ; W = "1"
 ; if PTR2Size=="8": W="0"
 ; elif PTR2Size=="16": Prefix_66+=PrefixOp[16]


 codeg2_1:
 mov byte [inmod_02], 0b00000000
 mov rsi, op1
 call GetStrlen
 ;rcx<-len
 shr rcx, 1
 jnc codeg2_10
 
 mov rsi, op1
 call GetStrlen
 mov rsi, op1
 mov byte [rsi+rcx], '0'
 codeg2_10:
 mov rsi, op1
 call GetStrlen
 mov rsi, op1
 mov byte [rsi+rcx], '0'
 inc rcx
 mov byte [rsi+rcx], 'x'
 rcodeg2_1:
 jmp codeg20
 ; elif BoolRegisters[0]==2: #imm
 ; Mod = "00"
 ; if(len(Lexed[2]))==3:
 ; Lexed[2]=+"0x"+ "0" + Lexed[2][2]
 ; elif len(Lexed[2])!=4:
 ; Lexed[2]=Lexed[2][:2]
 ; while len(Lexed[2])<=8:
 ; Lexed[2]="0"+Lexed[2]
 ; Lexed[2]="0x"+Lexed[2]
 ; HexData = Data2Hex(Lexed[1])

 codeg2_2:
 mov byte [inmod_02], 0b11000000
 mov byte [D], 0
 mov r8b, byte [op1code]
 mov byte [wregcode], r8b
 call fillw
 cmp byte [op1state], 3
 je codeg2_2nr
 codeg2_2r:
 mov r8b, byte [op1code]
 shr r8b, 2
 and r8b, 0b00000111
 mov byte [inmod_58], r8b
 mov byte [BREX], 0
 mov byte [brex], 1

 mov r8b, byte [op1code]
 and r8b, 0b00000011
 cmp r8b, 3
 jne rcodeg2_2
 mov byte [WREX], 1
 jmp rcodeg2_2
 codeg2_2nr:
 mov r8b, byte [op1code]
 shr r8b, 2
 and r8b, 0b00000011
 mov byte [inmod_58], r8b
 mov byte [BREX], 1
 mov byte [brex], 1

 mov r8b, byte [op1code]
 and r8b, 0b00000011
 cmp r8b, 1
 je rcodeg2_2
 cmp r8b, 2
 je rcodeg2_2
 ;ehink there should be an 0 check!
 mov byte [WREX], 1
 jmp rcodeg2_2

 rcodeg2_2:
 jmp codeg20

 ; if BoolRegisters[0]==1: #register
 ; Mod ="11"
 ; D = "0"
 ; W = fillW(Lexed[1]) #?
 ; if Lexed[1] in Registers:
 ; R_M = Registers[Lexed[1]]
 ; BREX = "0"
 ; if Lexed[1][0] == "r": WREX ="1"
 ; elif Lexed[1] in NewRegisters:
 ; R_M = NewRegisters[Lexed[1]]
 ; BREX = "1"
 ; if Lexed[1][-1]!="w" and Lexed[1][-1]!="d" : WREX ="1"
 codeg20:
 cmp qword [inst], "not"
 jne codeg21
 mov byte [inopc], 0b11110110
 mov byte [inmod_25], 0b00010000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg21:
 cmp qword [inst], "neg"
 jne codeg22
 mov byte [inopc], 0b11110110
 mov byte [inmod_25], 0b00011000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg22:
 cmp qword [inst], "inc"
 jne codeg23
 mov byte [inopc], 0b11111110
 mov byte [inmod_25], 0b00000000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg23:
 cmp qword [inst], "dec"
 jne codeg24
 mov byte [inopc], 0b11111110
 mov byte [inmod_25], 0b00001000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg24:
 cmp qword [inst], "shr"
 jne codeg25
 mov byte [inopc], 0b11010000
 mov byte [inmod_25], 0b00101000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg25:
 cmp qword [inst], "shl"
 jne codeg26
 mov byte [inopc], 0b11010000
 mov byte [inmod_25], 0b00100000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg26:
 cmp qword [inst], "idiv"
 jne codeg27
 mov byte [inopc], 0b11110110
 mov byte [inmod_25], 0b00111000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg27:
 cmp qword [inst], "imul"
 jne codeg28
 mov byte [inopc], 0b11110110
 mov byte [inmod_25], 0b00101000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg28: ;?
 cmp qword [inst], "jmp"
 jne codeg29
 mov byte [inopc], 0xfd
 mov byte [inmod_25], 0b00100000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg29: ;?
 cmp qword [inst], "j??"
 jne codeg2a
 mov byte [inopc], 0xf8
 mov byte [inmod_25], 0b00100000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg2a: ;?
 cmp qword [inst], "pop"
 jne codeg2b
 mov byte [inopc], 0xfd
 mov byte [inmod_25], 0b00000000
 mov byte [bmod], 1
 jmp rcodeg_2

 codeg2b: ;?
 cmp qword [inst], "push"
 ;jne codeg22
 mov byte [inopc], 0xf8
 mov byte [inmod_25], 0b00100000
 mov byte [bmod], 1
 jmp rcodeg_2

 ; if Lexed[0]=="not":
 ; #print(str("{0:03x}".format(int("1111011" + W + Mod + "010" + R_M , 2))))
 ; return str("{0:04x}".format(int("1111011" + W + Mod + "010" + R_M , 2)))
 ; 
 ; elif Lexed[0]=="neg":
 ; return str("{0:04x}".format(int("1111011" + W + Mod + "011" + R_M , 2)))

 ; elif Lexed[0]=="inc":
 ; return str("{0:04x}".format(int("1111111" + W + Mod + "000" + R_M , 2)))

 ; elif Lexed[0]=="dec":
 ;; return str("{0:04x}".format(int("1111111" + W + Mod + "001" + R_M , 2)))

 ; elif Lexed[0]=="shr":
 ; return str("{0:04x}".format(int("1101000" + W + Mod + "101" + R_M , 2)))

 ; elif Lexed[0]=="shl":
 ; return str("{0:04x}".format(int("1101000" + W + Mod + "100" + R_M , 2)))

 ; elif Lexed[0]=="idiv":
 ; return str("{0:04x}".format(int("1111011" + W + Mod + "111" + R_M , 2)))

 ; elif Lexed[0]=="imult":
 ; return str("{0:04x}".format(int("1111011" + W + Mod + "101" + R_M , 2)))

 ; elif Lexed[0]=="jmp":
 ; return str("{0:04x}".format(int("11101001")))
 ; return str("{0:04x}".format(int("11111111" + W + Mod + "100" + R_M , 2)))

 ; elif Lexed[0][:1]=="j":
 ; return str("{0:04x}".format(int("11101001")))
 ; return str("{0:04x}".format(int("11111111" + W + Mod + "100" + R_M , 2)))
 ; 
 ; elif Lexed[0]=="pop":
 ; if Lexed[1]=="rax": REXField=0
 ; if Lexed[1][0]=="r": WREX="0"
 ; if BoolRegisters[0]==1: return str("{0:02x}".format(int("01011" + R_M , 2)))
 ; if BoolRegisters[0]==0: return str("{0:04x}".format(int("10001111" + Mod + "000" + R_M , 2)))

 ; elif Lexed[0]=="push":
 ; if Lexed[1]=="rax": REXField=0
 ; if Lexed[1][0]=="r": WREX="0"
 ; if BoolRegisters[0]==1: return str("{0:02x}".format(int("01010" + R_M , 2)))
 ; if BoolRegisters[0]==0: return str("{0:04x}".format(int("11111111" + Mod + "110" + R_M , 2)))
 ;

 rcodeg_2:
 mov r8b, byte [inopc]
 add r8b, byte [W]
 mov byte [inopc], r8b
 ret 0




incgen_3:
 mov byte [bmod], 1
 cmp byte [op2state], 2
 jl incgen_31

 incgen_30: ; - | Reg 
 mov byte [D], 0
 cmp byte [op2state], 3
 je incgen_301
 incgen_300: ;- | old reg
 mov r8b, byte [op2code] ;move to reg_op
 shr r8b, 2
 and r8b, 0b00000111
 shl r8b, 3
 mov byte [inmod_25], r8b
 ;mov byte [inmod_25]
 mov byte[RREX], 0
 mov byte [brex], 1
 ;if Lexed[2][0] == "r": WREX ="1"
 jmp rincgen_301
 incgen_301: ; - | new reg
 mov r8b, byte [op2code] ;move to reg_op
 shr r8b, 2
 and r8b, 0b00000111
 shl r8b, 3
 mov byte [inmod_25], r8b
 ;mov byte [inmod_25]
 mov byte[RREX], 1
 mov byte [brex], 1
 ;if Lexed[2][-1]!="w" and Lexed[2][-1]!="d" : WREX ="1"

 rincgen_301:
 cmp byte [op1state], 2
 jl incgen_302

 call incgen_3_RR
 jmp rincgen_3
 incgen_302:
 call incgen_3_MR
 jmp rincgen_3


 incgen_31: ; reg | -
 mov byte [inmod_02], 0b10000000
 cmp byte [op2state], 1
 je incgen_32
 mov byte [D], 1
 cmp byte [op1state], 3
 je incgen_311
 incgen_310: ;- | old reg
 mov r8b, byte [op1code] ;move to reg_op
 shr r8b, 2
 and r8b, 0b00000111
 shl r8b, 3
 mov byte [inmod_25], r8b
 ;mov byte [inmod_25]
 mov byte[RREX], 0
 mov byte [brex], 1
 ;if Lexed[1][0] == "r": WREX ="1"
 jmp rincgen_311
 incgen_311: ; - | new reg
 mov r8b, byte [op1code] ;move to reg_op
 shr r8b, 2
 and r8b, 0b00000111
 shl r8b, 3
 mov byte [inmod_25], r8b
 ;mov byte [inmod_25]
 mov byte[RREX], 1
 mov byte [brex], 1
 ;if Lexed[1][-1]!="w" and Lexed[1][-1]!="d" : WREX ="1"
 rincgen_311:
 cmp byte [op2state], 1
 je incgen_312

 call incgen_3_RM
 jmp rincgen_3

 incgen_312:
 call incgen_3_RI
 jmp rincgen_3
 incgen_32:
 mov byte [D], 1
 jmp rincgen_3
 rincgen_3:
 ret 0




incgen_3_RR:
 mov byte [inmod_02], 0b11000000
 mov r8b, byte [op2code]
 mov byte [wregcode], r8b
 call fillw
 mov r8b, byte [op1code] ;move to R_M
 shr r8b, 2
 and r8b, 0b00000111
 mov byte [inmod_58], r8b
 mov byte [BREX], 0
 mov byte [brex], 1
 cmp byte [op1state], 3
 jne incgen_3_RR1
 mov byte [BREX], 1
 incgen_3_RR1:
 cmp qword [inst], "imul"
 jne rincgen_3_RR
 mov byte [inbop], 0h0f
 jmp rincgen_3_RR
 ; if Lexed[0]=="bsf" or Lexed[0]=="bsr":
 ;return str("{0:04x}".format(int(InstCode + Mod + Reg_Op + R_M, 2)))
 ;if Lexed[0]=="imul":
 ;return str("{0:04x}".format(int("10101111" + Mod + Reg_Op + R_M, 2)))
 ;return str("{0:04x}".format(int(InstCode + D + W + Mod + Reg_Op + R_M, 2)))
 rincgen_3_RR:
 ret 0
incgen_3_MR:
 ;codethemem(op1)
 mov qword [memoryinput], op1 
 call codebisd
 call codethemem
 mov byte [W], 1
 cmp word [ptrsize], 0
 jne incgen_3_MR1
 mov byte [W], 0
 incgen_3_MR1:
 cmp word [ptrsize], 1
 jne incgen_3_MR2
 mov byte [b66], 1
 incgen_3_MR2:
 ;if Lexed[0]=="bsf" or Lexed[0]=="bsr":
 ;return str("{0:04x}".format(int(InstCode + Mod + Reg_Op + R_M, 2)))
 ;return str("{0:04x}".format(int(InstCode + D + W + Mod + Reg_Op + R_M, 2)))
 ret 0

incgen_3_RI:
 mov byte [inmod_02], 0b11000000
 mov r8b, byte [op2code]
 mov byte [wregcode], r8b
 call fillw
 mov r8b, byte [op1code] ;move to R_M
 shr r8b, 2
 and r8b, 0b00000111
 mov byte [inmod_58], r8b
 mov byte [BREX], 0
 mov byte [brex], 1
 cmp byte [op1state], 3
 jne incgen_3_RR1
 mov byte [BREX], 1
incgen_3_RM:
 ;codethemem(op2)
 mov qword [inmod_02], 0b00000000
 mov qword [memoryinput], op2 
 call codebisd
 call codethemem
 mov r8b, byte [op1code]
 mov byte [wregcode], r8b
 call fillw
 cmp qword [inst], "imul"
 jne rincgen_3_RM
 mov byte [inbop], 0h0f
 jmp rincgen_3_RM
 rincgen_3_RM:
 ret 0

print:
 ;form inmod
 mov r8b, byte [inmod]
 add r8b, byte [inmod_02]
 add r8b, byte [inmod_25]
 add r8b, byte [inmod_58]
 mov byte [inmod], r8b

 ;form rex
 mov r8b, byte [inrex]
 add r8b, 0b01000000
 mov r9b, byte [BREX]
 add r8b, r9b 
 mov r9b, byte [XREX]
 shl r9b, 1
 add r8b, r9b 
 mov r9b, byte [RREX]
 shl r9b, 2
 add r8b, r9b 
 mov r9b, byte [WREX]
 shl r9b, 3
 add r8b, r9b 
 mov byte [inrex], r8b

 ;mov qword [boolcodeptr], boolcode
 mov r15, boolcode
 ;call GetStrlen
 ;add qword [boolcodeptr], rdx

 ;mov rdi, qword [boolcodeptr]
 ;mov [rdi], al
 ;inc qword [boolcodeptr]
 print67: 
 cmp byte [b67], 0
 je print66
 mov al, byte [const67]
 call printinbin

 print66: 
 cmp byte [b66], 0
 je printrex
 mov al, byte [const66]
 call printinbin

 printrex:
 cmp byte [brex], 0
 je printbop
 mov al, byte [inrex]
 call printinbin

 printbop:
 cmp byte [bbop], 0
 je printopc
 mov al, byte [inbop]
 call printinbin

 printopc:
 cmp byte [bopc], 0
 je printmod
 mov al, byte [inopc]
 call printinbin

 printmod:
 cmp byte [bmod], 0
 je printsib
 mov al, byte [inmod]
 call printinbin

 printsib:
 cmp byte [bsib], 0
 je printdis
 mov al, byte [insib]
 call printinbin

 printdis:
 cmp byte [bimm], 0
 je printadd
 mov al, byte [indis]
 call printinbin

 printadd:
 cmp byte [badd], 0
 je hprint
 mov al, byte [inadd]
 call printinbin



 hprint:
 call newLine
 mov byte [r15], ','
 inc r15


 hprint67:
 cmp byte [b67], 0
 je hprint66
 mov al, byte [const67]
 call printinhex

 hprint66: 
 cmp byte [b66], 0
 je hprintrex
 mov al, byte [const66]
 call printinhex

 hprintrex:
 cmp byte [brex], 0
 je hprintbop
 mov al, byte [inrex]
 call printinhex

 hprintbop:
 cmp byte [bbop], 0
 je hprintopc
 mov al, byte [inbop]
 call printinhex

 hprintopc:
 cmp byte [bopc], 0
 je hprintmod
 mov al, byte [inopc]
 call printinhex

 hprintmod:
 cmp byte [bmod], 0
 je hprintsib
 mov al, byte [inmod]
 call printinhex

 hprintsib:
 cmp byte [bsib], 0
 je hprintdis
 mov al, byte [insib]
 call printinhex

 hprintdis:
 cmp byte [bimm], 0
 je hprintadd
 mov al, byte [indis]
 call printinhex

 hprintadd:
 cmp byte [badd], 0
 je rprint
 mov al, byte [inadd]
 call printinhex

 rprint:
 ret 0


instcode:
 mov al, [inrex]
 mov bl, [BREX]
 add al, bl 

 mov bl, [XREX]
 shl bl, 1
 add al, bl

 mov bl, [RREX]
 shl bl, 2
 add al, bl

 mov bl, [WREX]
 shl bl, 3
 add al, bl

 add al, 0b01000000

 cmp byte [op2state], 1
 jne instcode1
 ADC:
 cmp qword [inst], "adc"
 jne ADD
 mov byte [inopc], 0b1000000

 mov bl, [W]
 add byte [inopc], bl

 mov bl, [inmod_02]
 add [inmod], bl 
 add byte [inmod], 0b00010000
 
 mov bl, [inmod_58]
 add [inmod], bl
 jmp rincgen_1
 ADD:
 ;f Lexed[1][0]=="a" or Lexed[1][1]=="a":

 instcode1:


 rinstcode:
 ret 0
setinstcode:
 ; registername <- rsi
 ; rdi<-reg_
 ; instcode -> al
 mov rsi, inst
 mov rdi, inst_
 sub rdi, 5

 setinstcode1:
 xor rdx, rdx
 add rdi, 5
 cmp rdi, endinst_
 jge rsetinstcode1
 setinstcode11:
 cmp dl, 4
 je rsetinstcode11 
 mov al, byte [rsi+rdx]
 cmp byte [rdi+rdx], al
 jne setinstcode1
 inc dl
 jmp setinstcode11

 rsetinstcode11: 
 add rdi, 4
 mov al, byte [rdi]
 mov byte [inopc], al
 jmp rsetinstcode

 rsetinstcode1:
 mov al, -1
 jmp rsetinstcode

 rsetinstcode:
 ret 0
fillw:
 ;input; wregcode->bin-reg-code
 ;output W
 push r8
 mov r8b, byte [wregcode]
 and r8b, 0b00000011
 cmp r8b, 0
 jne fillw16bit
 fillw8bit:
 mov byte [W], 0
 jmp rfillw
 fillw16bit:
 cmp r8b, 1
 jne fillw32bit
 mov byte [W], 1
 mov byte [b66], 1

 jmp rfillw
 fillw32bit:
 cmp r8b, 2
 jne fillw64bit
 mov byte [W], 1
 
 jmp rfillw
 fillw64bit:
 mov byte [W], 1
 jmp rfillw
 rfillw:
 pop r8
 ret 0


printinbin:
 ;input al
 mov rcx, 8
 printinbin1:
 cmp rcx, 0
 je rprintinbin

 shl al, 1
 jc printinbin11
 printinbin10:
 mov rsi, zero
 call printString
 mov byte [r15], '0'
 inc r15
 jmp rprintinbin1
 printinbin11:
 mov rsi, one
 call printString
 mov byte [r15], '1'
 inc r15
 jmp rprintinbin1
 
 rprintinbin1:
 dec rcx
 jmp printinbin1

 rprintinbin:
 ret 0


printinhex:
 ;input al
 push rax

 mov bl, al 
 and bl, 0b11110000
 shr bl, 3
 mov rsi, hexnum_
 add rsi, rbx 

 mov dl, byte [rsi]
 mov byte [r15], dl
 inc r15

 call printString
 
 mov bl, al 
 and bl, 0b00001111
 shl bl, 1
 mov rsi, hexnum_
 add rsi, rbx
 
 mov dl, byte [rsi]
 mov byte [r15], dl
 inc r15

 call printString

 pop rax
 ret 0

codethemem:
 cmp byte [bisd], 6
 je codethemem6
 cmp byte [bisd], 8
 je codethemem8
 cmp byte [bisd], 14
 je codethememe

 codethemem6:
 codethemem8:
 codethememe:

 mov rsi, bisdb
 call printString



 ;mov byte [inmod_02], 0b00000000
 
 mov rsi, bisdb
 call findreg
 mov byte [bisdbcode], al
 cmp al, -1
 je codethememe1
 shr al, 2
 mov byte [inmod_58], al 
 ;M64 = 0
 mov byte [BREX], 0
 mov byte [brex], 1

 jmp rcodethemem
 codethememe1:
 mov rsi, bisdb
 call findnreg
 mov byte [bisdbcode], al
 shr al, 2
 mov byte [inmod_58], al 
 ;M64 = 1
 mov byte [BREX], 1
 mov byte [brex], 1

 jmp rcodethemem



 rcodethemem:
 ret 0
codebisd:
 ; memoryinput <-
 mov r11, qword [memoryinput]
 
 codebisd1:
 cmp byte [r11], '['
 je codebisd2
 inc r11
 jmp codebisd1

 codebisd2:
 inc r11
 mov r12, r11

 codebisd3:
 cmp byte [r12], '*'
 je codebisdA

 cmp byte [r12], '+'
 je codebisdB

 cmp byte [r12], ']'
 je codebisdC

 inc r12
 jmp codebisd3
 codebisdA:

 jmp rcodebisd
 codebisdB:

 jmp rcodebisd
 codebisdC:
 mov byte [bisd], 6
 mov r13, bisdb
 mov rdx, 0
 codebisdCset:
 cmp r11, r12
 je rcodebisdCset
 mov al, byte [r11]
 mov byte [r13], al

 inc r11
 inc r13 
 jmp codebisdCset

 rcodebisdCset:
 jmp rcodebisd
 rcodebisd:
 ret 0


makecode:

 call newLine
 mov rsi, ent
 call printString
 call newLine

 call split
 call preprint

 ;call lexrex
 call stating
 call setinstcode
 call codeg
 call print

 rmakecode:
 ret 0




makecodeforeach:
 ;call readandrun
 
 mov qword [bufferptr], buffer
 mov qword [buffer2ptr], buffer2
 mov qword [entrwriteptr], ent
 makecodeforeachloop:
 mov r11, qword [bufferptr]
 cmp byte [r11] ,0
 je compbuffer
 
 cmp byte [r11] ,0x0a
 je compbuffer

 mov r11, qword [bufferptr]
 mov r10, qword [entrwriteptr]
 mov al, byte [r11]
 mov byte [r10], al

 inc qword [bufferptr]
 inc qword [entrwriteptr]

 jmp makecodeforeachloop
 compbuffer:
 call makecode
 
 mov qword [buffer2ptr], buffer2
 mov rdi, buffer2
 call GetStrlen
 add qword [buffer2ptr], rdx 
 mov qword [boolcodeptr], boolcode
 set qword [buffer2ptr], qword [boolcodeptr]

 mov qword [buffer2ptr], buffer2
 mov rdi, buffer2
 call GetStrlen
 add qword [buffer2ptr], rdx 
 mov qword [boolcodeptr], boolcode
 set qword [buffer2ptr], const3

 mov qword [ent], 0
 mov qword [ent+4], 0
 mov qword [ent+8], 0
 mov qword [ent+12], 0
 mov qword [ent+16], 0

 mov qword [boolcode], 0
 mov qword [boolcode+4], 0
 mov qword [boolcode+8], 0
 mov qword [boolcode+12], 0
 mov qword [boolcode+16], 0
 mov qword [boolcode+20], 0
 mov qword [boolcode+24], 0
 mov qword [boolcode+28], 0
 mov qword [boolcode+32], 0
 mov qword [boolcode+36], 0

 mov byte [b67], 0
 mov byte [b66 ], 0
 mov byte [brex], 0
 mov byte [bbop], 0
 mov byte [bopc], 1
 mov byte [bmod], 0
 mov byte [bsib],0
 mov byte [bdis],0
 mov byte [badd],0
 mov byte [bimm],0

 mov byte [opsize], 0 ;0->8, 1->16, 2->32, 3->64
 mov byte [addsize],2 ; 2->32, 3->64 

 mov byte [opincludenew],1 ;1->new reg used
 mov byte [W], 0
 mov byte [D], 0
 mov byte [BREX], 0
 mov byte [WREX], 0
 mov byte [RREX], 0
 mov byte [XREX], 0




 mov r11, qword [bufferptr]
 cmp byte [r11] ,0
 je rcode2buffer
 inc qword [bufferptr]

 mov qword [entrwriteptr], ent
 jne makecodeforeachloop 
 rcode2buffer:
 

 ret 0



readandrun:
 mov rdi, filename
 call openFile
 mov [FD], rax 

 mov rdi, [FD]
 mov rsi, buffer
 mov rdx, 200
 call readFile
 
 mov rdi, rsi
 call printString

 mov rdi, [FD]
 call closeFile

 ;call newLine
 ;mov qword [bufferptr], buffer
 ;mov rsi, [bufferptr]
 ;call printString
 ;call newLine

 ret 0


writeanddone:
 ;call newLine
 call newLine
 mov rsi, buffer2
 call printString
 ;call newLine
 
 mov rdi, buffer2
 call GetStrlen

 mov rdi, filename2
 call createFile
 mov [FD2], rax 

 mov rdi, [FD2]
 mov rsi, buffer2
 ;mov rdx, rdx
 call writeFile

 mov rdi, [FD2]
 call closeFile

 ret 0



openFile:
 mov rax, 2
 mov rsi, 0q000002
 syscall 
 ret 0

createFile:
 mov rax, 85
 mov rsi, 0q400 | 0q200
 syscall
 ret 0

readFile:
 mov rax, 0
 syscall 
 ret 0
closeFile:
 mov rax, 3
 syscall 
 ret 0

writeFile:
 mov rax, 1
 syscall
 ret 0



