%include "in_out.asm"
section .data

 reg_ db "al",0,0,"ax",0,0,"eax",0,"rax",0, "cl",0,0,"cx",0,0,"ecx",0,"rcx",0, "dl",0,0,"dx",0,0,"edx",0,"rdx",0, "bl",0,0,"ax",0,0,"ebx",0, "rbx",0, "ah",0,0,"sp",0,0,"esp",0,"rsp",0, "ch",0,0,"bp",0,0,"ebp",0,"rbp",0, "dh",0,0,"si",0,0,"esi",0,"rsi",0, "bh",0,0,"di",0,0,"edi",0,"rdi",0
 nreg_ db "r8b",0,"r8w",0, "r8d",0,"r8",0,0, "r9b",0,"r9w",0,"r9d",0,"r9",0,0, "r10b","r10w","r10d","r10",0, "r11b","r11w","r11d","r11",0, "r12b","r12w","r12d","r12",0, "r13b","r13w","r13d","r13",0, "r14b","r14w","r14d","r14",0,"r15b","r15w","r15d","r15",0

 filename db 'testfile-disa.txt',0
 filename2 db 'testfie-disaout.txt',0
 bufferlen dq 200
 null dq 0

 bin67 db 0b01000011
 bin66 db 0b01000010
 
 opsize db 0 ;0->8, 1->16, 2->32, 3->64
 addsize db 2 ; 2->32, 3->64 
 w db 0
 ; isinornot
 b67 db 0
 b66 db 0
 brex db 0
 bbop db 0
 bopc db 0
 bmod db 0
 bsib db 0
 bdis db 0
 badd db 0

 operand1 db 4 ;0 X | 1 reg | 2 mem
 operand2 db 4 ;0 X | 1 reg | 2 mem
 ;way to treat operands
 toperand db 0 ; 0 -> no reg | 1 -> 1 reg/mem | 2 -> 2 regs normal | 2 -> 2 regs abnormal

 ;buffer db '48-44-4444-434'
 

 ;constant
 const1 db ' ',0
 const2 db ',',0
 const3 db 0xa,0
section .bss
 ent: resb 20 ; assembly code
 entptr: resq 1

 boolcode:resb 40 ;disassembeled
 boolcodeptr: resq 1


 buffer: resb 200
 FD: resq 1
 bufferptr: resq 1
 buffer2: resb 400
 FD2: resq 1
 buffer2ptr: resq 1
 entrwriteptr: resq 1
 
 ;code
 inst: resb 40
 trueinst: resb 40
 reg1: resb 40
 reg2: resb 40
 op1: resb 40
 op2: resb 40
 temp_disp: resb 88;????????????????
 ; ascii char in word
 inrex: resw 1
 inopc: resw 1
 inmod: resw 1
 insib: resw 1
 inimm: resq 1
 inadd: resq 1
 ; converted ascii char in byte
 binrex: resb 1
 binopc: resb 1
 binmod: resb 1
 binsib: resb 1
 bindis: resb 10
 binadd: resb 10
 ;take it easy
 temp_fr: resb 20
 temp_ma: resb 20
 ;temp_ma: resb 20
 _7binopc: resb 1
 _6binopc: resb 1
 _5binopc: resb 1
 _2binmod: resb 1
 _25binmod: resb 1
 _58binmod: resb 1
 _58binsib: resb 1
 _25binsib: resb 1
 _2binsib: resb 1
section .text
 global _start
_start:

 %macro set 2
 ; %1 <- %2
 ; movsb rdi <- rsi
 ;??rdx
 ;mov rsi, %2
 ;call GetStrlen
 mov rcx, 20
 mov rdi, %1
 mov rsi, %2
 cld
 rep movsb
 %endmacro



 call readandrun
 call makecodeforeach
 call writeanddone
 ;lea rax, [ent]
 ;mov [entptr], rax
 ;call lex
 ;call cgen
 ;set trueinst, inst
 ;call print
 ;call setreg
 ;call print
 ;call savecode
 ;call readandrun
 ;call writeanddone
 ret 0




cgen:
 mov rax, 0
 mov al, [binmod]
 and al, 0b00111000
 mov [_25binmod], al

 mov al, [_25binmod]
 call writeNum

 mov al, [binopc]
 and al, 0b11111110
 mov [_7binopc], al

 mov al, [binopc]
 and al, 0b11111100
 mov [_6binopc], al

 mov al, [binopc]
 and al, 0b11111000
 mov [_5binopc], al

 mov al, [binmod]
 and al, 0b11000000
 mov [_2binmod], al
 

 mov al, [binmod]
 and al, 0b00000111
 mov [_58binmod], al
 

 mov al, [binsib]
 and al, 0b00000111
 mov [_58binsib], al

 mov al, [binsib]
 and al, 0b00111000
 mov [_25binsib], al

 mov al, [binsib]
 and al, 0b11000000
 mov [_2binsib], al

 ; w initialization
 mov bl, [binopc]
 and bl, 0b00000001
 cmp bl, 0b00000001
 jne cgen1
 mov byte [w], 1
 cgen1:
 mov bl, [binopc]
 and bl, 0b11110000 ;thats wrong
 cmp bl, 0b01110000
 jne fixsize

 mov byte [w], 0
 mov bl, [binopc]
 and bl, 0b00001000
 cmp bl, 0b00001000
 jne cgen2
 mov byte [w], 1
 cgen2:
 
 fixsize:
 call fixopsize
 call fixaddsize

 ;W = InFieldOpCode[-1]
 ;if InFieldOpCode[:4]=="1011": W = InFieldOpCode[4]
 ;fixSize()
 
 
 STC:
 cmp byte [binopc], 0b11111001
 jne CLC
 mov byte [inst], 's'
 mov byte [inst+1], 't'
 mov byte [inst+2], 'c'
 jmp rcgen
 CLC:
 cmp byte [binopc], 0b11111000
 jne STD
 mov byte [inst], 'c'
 mov byte [inst+1], 'l'
 mov byte [inst+2], 'c'
 jmp rcgen
 STD:
 cmp byte [binopc], 0b11111101
 jne CLD
 mov byte [inst], 's'
 mov byte [inst+1], 't'
 mov byte [inst+2], 'd'
 jmp rcgen
 CLD:
 cmp byte [binopc], 0b11111100
 jne ADC1
 mov byte [inst], 'c'
 mov byte [inst+1], 'l'
 mov byte [inst+2], 'd'
 jmp rcgen

 ADC1:
 cmp byte [_6binopc], 0b00010000
 jne ADC2
 mov byte [inst], 'a'
 mov byte [inst+1], 'd'
 mov byte [inst+2], 'c'
 mov byte [toperand], 2
 jmp rcgen

 ADC2:
 cmp byte [_6binopc], 0b10000000
 jne ADD1
 cmp byte [_25binmod], 0b00010000
 jne ADD1
 mov byte [inst], 'a'
 mov byte [inst+1], 'd'
 mov byte [inst+2], 'c'
 mov byte [toperand], 3
 jmp rcgen

 ADD1:
 cmp byte [_6binopc] ,0b00000000
 jne ADD2
 mov byte [inst], 'a'
 mov byte [inst+1], 'd'
 mov byte [inst+2], 'd'
 mov byte [toperand], 2
 jmp rcgen
 
 ADD2:
 cmp byte [_6binopc] ,0b10000000
 jne AND1
 cmp byte [_25binmod],0b00000000
 jne AND1
 mov byte [inst], 'a'
 mov byte [inst+1], 'd'
 mov byte [inst+2], 'd'
 mov byte [toperand], 3
 jmp rcgen


 AND1:
 cmp byte [_6binopc] ,0b00100000
 jne AND2
 mov byte [inst], 'a'
 mov byte [inst+1], 'n'
 mov byte [inst+2], 'd'
 mov byte [toperand], 2
 jmp rcgen

 AND2:
 cmp byte [_6binopc] ,0b10000000
 jne CMP1
 cmp byte [_25binmod],0b00100000
 jne CMP1
 mov byte [inst], 'a'
 mov byte [inst+1], 'n'
 mov byte [inst+2], 'd'
 mov byte [toperand], 3
 jmp rcgen

 CMP1:
 cmp byte [_6binopc] ,0b00111000
 jne CMP2
 mov byte [inst], 'c'
 mov byte [inst+1], 'm'
 mov byte [inst+2], 'p'
 mov byte [toperand], 2
 jmp rcgen

 CMP2: ;should be checked
 cmp byte [_6binopc] ,0b10000000
 jne DIV
 ;cmp byte [_25binmod],0b00100000
 ;jne DIV
 mov byte [inst], 'c'
 mov byte [inst+1], 'm'
 mov byte [inst+2], 'p'
 mov byte [toperand], 3
 jmp rcgen

 DIV:
 cmp byte [_7binopc] ,0b11110110
 jne IDIV
 cmp byte [_25binmod],0b00110000
 jne IDIV
 mov byte [inst], 'd'
 mov byte [inst+1], 'i'
 mov byte [inst+2], 'v'
 mov byte [toperand], 2
 jmp rcgen

 
 IDIV:
 cmp byte [_7binopc] ,0b11110110
 jne MUL
 cmp byte [_25binmod],0b00111000
 jne MUL
 mov byte [inst], 'i'
 mov byte [inst+1], 'd'
 mov byte [inst+2], 'i'
 mov byte [inst+3], 'v'
 mov byte [toperand], 2
 jmp rcgen


 MUL:
 cmp byte [_7binopc] ,0b11110110
 jne IMUL1
 cmp byte [_25binmod],0b00100000
 jne IMUL1
 mov byte [inst], 'm'
 mov byte [inst+1], 'u'
 mov byte [inst+2], 'l'
 mov byte [toperand], 3
 jmp rcgen


 IMUL1:
 cmp byte [_7binopc] ,0b11110110
 jne IMUL2
 cmp byte [_25binmod],0b00101000
 jne IMUL2
 mov byte [inst], 'i'
 mov byte [inst+1], 'm'
 mov byte [inst+2], 'u'
 mov byte [inst+3], 'l'
 mov byte [toperand], 2
 jmp rcgen

 IMUL2:
 cmp byte [binopc] ,0b10101111
 jne JMP
 cmp byte [bbop],1
 jne JMP
 mov byte [inst], 'i'
 mov byte [inst+1], 'm'
 mov byte [inst+2], 'u'
 mov byte [inst+3], 'l'
 mov byte [toperand], 2
 jmp rcgen
 

 JMP:
 cmp byte [binopc], 0b11111111
 jne MOV
 mov byte [inst], 'j'
 mov byte [inst+1], 'm'
 mov byte [inst+2], 'p'
 mov byte [toperand], 3
 jmp rcgen

 MOV:
 cmp byte [_6binopc] ,0b10001000
 jne MOV1
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], 2
 jmp rcgen


 MOV1: 
 cmp byte [_6binopc], 0b11000100
 jne MOV2
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], -1
 jmp rcgen
 MOV2: 
 cmp byte [_6binopc], 0b10100000
 jne MOV3
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], -1
 jmp rcgen
 MOV3:
 mov al, [binopc]
 and al, 0b11110000
 cmp al, 0b10110000
 jne SUB
 cmp byte [bbop], 0
 je SUB
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], 6
 jmp rcgen


 SUB:
 cmp byte [_6binopc] ,0b00101000
 jne SBB
 mov byte [inst], 's'
 mov byte [inst+1], 'u'
 mov byte [inst+2], 'b'
 mov byte [toperand], 2
 jmp rcgen

 SBB:
 cmp byte [_6binopc] ,0b00101000
 jne XOR
 mov byte [inst], 's'
 mov byte [inst+1], 'b'
 mov byte [inst+2], 'b'
 mov byte [toperand], 2
 jmp rcgen
 
 XOR:
 cmp byte [_6binopc] ,0b00110000
 jne XCHG1
 mov byte [inst], 'x'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'r'
 mov byte [toperand], 2
 jmp rcgen
 
 XCHG1:
 cmp byte [_6binopc] ,0b10000100
 jne XCHG2
 mov byte [inst], 'x'
 mov byte [inst+1], 'c'
 mov byte [inst+2], 'h'
 mov byte [inst+3], 'g'
 mov byte [toperand], 2
 jmp rcgen

 XCHG2: 
 TSET:
 cmp byte [_6binopc] ,0b10000100
 jne TEST2
 mov byte [inst], 't'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 's'
 mov byte [inst+3], 't'
 mov byte [toperand], 2
 jmp rcgen

 ;else:
 ; shootMemory()
 ; Reg2 = MemoryAccess ??-----||
 ; Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,7)
 

 TEST2:
 cmp byte [_6binopc] ,0b11110100
 jne TEST3
 cmp byte [_25binmod], 0b00000000
 jne TEST3
 mov byte [inst], 't'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 's'
 mov byte [inst+3], 't'
 mov byte [toperand], 5
 jmp rcgen
 TEST3:
 cmp byte [_6binopc] ,0b10101000
 jne XADD
 mov byte [inst], 't'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 's'
 mov byte [inst+3], 't'
 mov byte [toperand], 8
 jmp rcgen

 XADD:
 cmp byte [_7binopc] ,0b11000000
 jne DEC
 cmp byte [bbop], 0
 je DEC
 mov byte [inst], 'x'
 mov byte [inst+1], 'a'
 mov byte [inst+2], 'd'
 mov byte [inst+3], 'd'
 mov byte [toperand], 12
 jmp rcgen
 ;#(cmp*-test-xadd)
 DEC:
 cmp byte [_5binopc] ,0b01001000
 jne DEC1
 mov byte [inst], 'd'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 'c'
 mov byte [toperand], 10
 jmp rcgen

 DEC1:
 cmp byte [_7binopc] ,0b11111110
 jne INC
 cmp byte [_25binmod] ,0b00001000
 jne INC
 mov byte [inst], 'd'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 'c'
 mov byte [toperand], 9
 jmp rcgen
 
 INC:
 cmp byte [_5binopc] ,0b01000000
 jne INC1
 mov byte [inst], 'i'
 mov byte [inst+1], 'n'
 mov byte [inst+2], 'c'
 mov byte [toperand], 10
 jmp rcgen

 INC1:
 cmp byte [_7binopc] ,0b11111110
 jne SHL
 cmp byte [_25binmod] ,0b00000000
 jne SHL
 mov byte [inst], 'i'
 mov byte [inst+1], 'n'
 mov byte [inst+2], 'c'
 mov byte [toperand], 9
 jmp rcgen 
 
 SHL:
 cmp byte [_6binopc] ,0b11010000
 jne SHL1
 cmp byte [_25binmod] ,0b00100000
 jne SHL1
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'l'
 mov byte [toperand], 11
 jmp rcgen

 SHL1:
 cmp byte [_7binopc] ,0b11000000
 jne SHR
 cmp byte [_25binmod] ,0b00001000
 jne SHR
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'l'
 mov byte [toperand], 8
 jmp rcgen
 
 SHR:
 cmp byte [_6binopc] ,0b11010000
 jne SHR1
 cmp byte [_25binmod] ,0b00101000
 jne SHR1 
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'r'
 mov byte [toperand], 11
 jmp rcgen

 SHR1:
 cmp byte [_7binopc] ,0b11000000
 jne NEG 
 cmp byte [_25binmod] ,0b00101000
 jne NEG
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'r'
 mov byte [toperand], 8
 jmp rcgen

 NEG:
 cmp byte [_6binopc] ,0b11110100
 jne NOT
 cmp byte [_25binmod] ,0b00011000
 jne NOT 
 mov byte [inst], 'n'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 'g'
 mov byte [toperand], 5
 jmp rcgen 

 NOT:
 cmp byte [_6binopc] ,0b11110100
 jne CALL 
 cmp byte [_25binmod] ,0b00010000
 jne CALL 
 mov byte [inst], 'n'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 't'
 mov byte [toperand], 5
 jmp rcgen 
 
 CALL:
 cmp byte [binopc] ,0b11111111
 jne CALL1
 cmp byte [_25binmod] ,0b00010000
 jne CALL1 
 mov byte [inst], 'c'
 mov byte [inst+1], 'a'
 mov byte [inst+2], 'l'
 mov byte [inst+3], 'l'
 mov byte [toperand], 5
 jmp rcgen 
 
 CALL1:
 cmp byte [binopc] ,0b10011010
 jne CALL2
 cmp byte [_25binmod] ,0b00010000
 jne CALL2
 mov byte [inst], 'c'
 mov byte [inst+1], 'a'
 mov byte [inst+2], 'l'
 mov byte [inst+3], 'l'
 mov byte [toperand], 9
 jmp rcgen 

 CALL2:
 cmp byte [binopc] ,0b10011010
 jne RET
 cmp byte [_25binmod] ,0b00010000
 jne RET 
 mov byte [inst], 'c'
 mov byte [inst+1], 'a'
 mov byte [inst+2], 'l'
 mov byte [inst+3], 'l'
 mov byte [toperand], 9
 jmp rcgen 

 RET:
 cmp byte [binopc] ,0b11000011
 jne RET1
 mov byte [inst], 'r'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 't'
 mov byte [toperand], 9
 
 jmp rcgen 
 RET1:
 cmp byte [binopc] ,0b11000010
 jne SYSCALL
 mov byte [inst], 'r'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 't'
 mov byte [toperand], 9
 jmp rcgen 

 SYSCALL:
 cmp byte [binopc] ,0b00000101
 jne BSF 
 cmp byte [bbop] ,1
 jne BSF 
 mov byte [inst], 's'
 mov byte [inst+1], 'y'
 mov byte [inst+2], 's'
 mov byte [inst+3], 'c'
 mov byte [inst+4], 'a'
 mov byte [inst+5], 'l'
 mov byte [inst+6], 'l'
 ;mov byte [toperand], 9
 jmp rcgen 

 BSF:
 cmp byte [binopc] ,0b10111100
 jne BSR
 cmp byte [bbop] ,1
 jne BSR 
 mov byte [inst], 'b'
 mov byte [inst+1], 's'
 mov byte [inst+2], 'f'
 mov byte [toperand], 3
 jmp rcgen 


 BSR: ;R OR F 
 cmp byte [binopc] ,0b10111101
 jne NXT
 cmp byte [bbop] ,1
 jne NXT
 mov byte [inst], 'b'
 mov byte [inst+1], 's'
 mov byte [inst+2], 'r'
 mov byte [toperand], 3
 jmp rcgen 
 
 ;#push-pop
 NXT:
 rcgen:
 ret 0

 ;#andso elif InFieldOpCode[:6]=="101011":
%ifdef document
 ???? elif InFieldOpCode[:6]=="011010":
 COperand = "imul"
 JMP:
 cmp [binopc], 0b11111111
 jne MOV
 mov byte [inst], 'j'
 mov byte [inst+1], 'm'
 mov byte [inst+2], 'p'
 mov byte [toperand], 3
 jmp rcgen

 elif InFieldOpCode[:8]=="11111111" and 0:
 COperand = "jmp"
 Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 if InFieldModRM[:2] == "11":
 Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
 else:
 shootMemory()
 Reg2 = MemoryAccess
 ;--
 MOV:
 cmp byte [_6binopc] ,0b10001000
 jne TEST2
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], 2
 jmp rcgen

 ;else:
 ; shootMemory()
 ; Reg2 = MemoryAccess ??-----||
 ; Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,7)
 
 MOV1:
 elif InFieldOpCode[:6]=="100010":
 COperand = "mov"
 if InFieldOpCode[6]=="0": #second oprand is reg
 Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 #InFieldModRM = InFieldModRM[:2] + InFieldModRM[5:8] + InFieldModRM[2:5]
 shootMemory()
 Reg1 = MemoryAccess
 
 else:
 shootMemory()
 Reg2 = MemoryAccess
 Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 MOV2: 
 cmp [_6binopc], 0b11000100
 jne MOV3
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], -1
 jmp rcgen
 MOV3: 
 cmp [_6binopc], 0b10100000
 jne MOV4
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], -1
 jmp rcgen
 MOV4:
 mov al, [binopc]
 and al, 0b11110000
 cmp al, 0b10110000
 jne SUB
 cmp [bbop], 0
 je SUB
 mov byte [inst], 'm'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'v'
 mov byte [toperand], 6
 jmp rcgen
 elif not(FieldBackOp) and InFieldOpCode[:4]=="1011":
 COperand = "mov"
 Reg1 = findReg(InFieldOpCode[-3:],OperandSize,InFieldREX,7)
 Reg2 = InFieldData
 
 SUB1:
 elif InFieldOpCode[:6]=="001010":
 COperand = "sub"
 if InFieldOpCode[6]=="0": #second oprand is reg
 Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 #InFieldModRM = InFieldModRM[:2] + InFieldModRM[5:8] + InFieldModRM[2:5]
 shootMemory()
 Reg1 = MemoryAccess
 
 else:
 shootMemory()
 Reg2 = MemoryAccess
 Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

 SUB:
 cmp byte [_6binopc] ,0b00101000
 jne SBB
 mov byte [inst], 's'
 mov byte [inst+1], 'u'
 mov byte [inst+2], 'b'
 mov byte [toperand], 2
 jmp rcgen

 SBB:
 cmp byte [_6binopc] ,0b00101000
 jne XOR
 mov byte [inst], 's'
 mov byte [inst+1], 'b'
 mov byte [inst+2], 'b'
 mov byte [toperand], 2
 jmp rcgen
 
 XOR:
 cmp byte [_6binopc] ,0b00110000
 jne XCHG1
 mov byte [inst], 'x'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 'r'
 mov byte [toperand], 2
 jmp rcgen
 
 XCHG1:
 cmp byte [_6binopc] ,0b10000100
 jne XCHG2
 mov byte [inst], 'x'
 mov byte [inst+1], 'c'
 mov byte [inst+2], 'h'
 mov byte [inst+3], 'g'
 mov byte [toperand], 2
 jmp rcgen

 XCHG2: 
 XCHG2: 
 elif InFieldOpCode[:5]=="10010":
 COperand = "xchg"
 Reg1 = findReg(InFieldOpCode[5:],OperandSize,InFieldREX,7)
 Reg2 = findReg("000",OperandSize,InFieldREX,5)
 print(Reg2)

 TSET:
 cmp byte [_6binopc] ,0b10000100
 jne TEST2
 mov byte [inst], 't'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 's'
 mov byte [inst+3], 't'
 mov byte [toperand], 2
 jmp rcgen

 ;else:
 ; shootMemory()
 ; Reg2 = MemoryAccess ??-----||
 ; Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,7)
 
 TEST2:
 TEST3:
 XADD:






 TEST2:
 cmp byte [_6binopc] ,0b11110100
 jne TEST3
 cmp byte [_25binmod], 0b00000000
 jne TEST3
 mov byte [inst], 't'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 's'
 mov byte [inst+3], 't'
 mov byte [toperand], 5
 jmp rcgen
 TEST3:
 cmp byte [_6binopc] ,0b10101000
 jne XADD
 mov byte [inst], 't'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 's'
 mov byte [inst+3], 't'
 mov byte [toperand], 8
 jmp rcgen

 XADD:
 cmp byte [_7binopc] ,0b11000000
 jne DEC
 cmp byte [bbop], 0
 je DEC
 mov byte [inst], 'x'
 mov byte [inst+1], 'a'
 mov byte [inst+2], 'd'
 mov byte [inst+3], 'd'
 mov byte [toperand], 12
 jmp rcgen
 ;#(cmp*-test-xadd)
 DEC1:
 cmp byte [_5binopc] ,0b01001000
 jne DEC1
 mov byte [inst], 'd'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 'c'
 mov byte [toperand], 10
 jmp rcgen

 DEC1:
 cmp byte [_7binopc] ,0b11111110
 jne INC
 cmp byte [_25binmod] ,0b00001000
 jne INC
 mov byte [inst], 'd'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 'c'
 mov byte [toperand], 9
 jmp rcgen
 
 INC:
 cmp byte [_5binopc] ,0b01000000
 jne INC1
 mov byte [inst], 'i'
 mov byte [inst+1], 'n'
 mov byte [inst+2], 'c'
 mov byte [toperand], 10
 jmp rcgen

 INC1:
 cmp byte [_7binopc] ,0b11111110
 jne SHL
 cmp byte [_25binmod] ,0b00000000
 jne SHL
 mov byte [inst], 'i'
 mov byte [inst+1], 'n'
 mov byte [inst+2], 'c'
 mov byte [toperand], 9
 jmp rcgen 
 
 SHL:
 cmp byte [_6binopc] ,0b11010000
 jne SHL1
 cmp byte [_25binmod] ,0b00100000
 jne SHL1
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'l'
 mov byte [toperand], 11
 jmp rcgen

 SHL1:
 cmp byte [_7binopc] ,0b11000000
 jne SHR
 cmp byte [_25binmod] ,0b00001000
 jne SHR
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'l'
 mov byte [toperand], 8
 jmp rcgen
 
 SHR:
 cmp byte [_6binopc] ,0b11010000
 jne SHR1
 cmp byte [_25binmod] ,0b00101000
 jne SHR1 
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'r'
 mov byte [toperand], 11
 jmp rcgen

 SHR1:
 cmp byte [_7binopc] ,0b11000000
 jne NEG 
 cmp byte [_25binmod] ,0b00101000
 jne NEG
 mov byte [inst], 's'
 mov byte [inst+1], 'h'
 mov byte [inst+2], 'r'
 mov byte [toperand], 8
 jmp rcgen

 NEG:
 cmp byte [_6binopc] ,0b11110100
 jne NOT
 cmp byte [_25binmod] ,0b00011000
 jne NOT 
 mov byte [inst], 'n'
 mov byte [inst+1], 'e'
 mov byte [inst+2], 'g'
 mov byte [toperand], 5
 jmp rcgen 

 NOT:
 cmp byte [_6binopc] ,0b11110100
 jne NEX 
 cmp byte [_25binmod] ,0b00010000
 jne NEX
 mov byte [inst], 'n'
 mov byte [inst+1], 'o'
 mov byte [inst+2], 't'
 mov byte [toperand], 5
 jmp rcgen 
 NEX:

%endif
setreg:


 cmp byte [toperand], 0
 je setreg0
 cmp byte [toperand], 1
 je setreg1
 cmp byte [toperand], 2
 je setreg2
 cmp byte [toperand], 3
 je setreg3
 cmp byte [toperand], 4
 je setreg4
 cmp byte [toperand], 5
 je setreg5
 cmp byte [toperand], 6
 je setreg6
 cmp byte [toperand], 7
 je setreg7
 cmp byte [toperand], 8
 je setreg8
 cmp byte [toperand], 9
 je setreg9
 cmp byte [toperand], 10
 je setrega
 cmp byte [toperand], 11
 je setregb
 cmp byte [toperand], 12
 je setregc

 setreg0:



 jmp rsetreg
 setreg1:
 mov al, [binopc]
 shr al, 1
 shr al, 1
 jc setreg11;error?
 mov al, [binmod]
 and al, 0b0011100
 shr al, 3 ;InFieldModRM[2:5]
 mov bl, [opsize]
 mov cl, 5
 call shootreg
 set reg1, temp_fr
 call check4mem
 set reg2, temp_ma
 
 jmp rsetreg 
 setreg11:
 call check4mem
 set reg1, temp_ma
 mov al, [_25binmod]
 mov bl, [opsize]
 mov cl, 5

 cmp byte [bdis], 0
 je setreg111
 setreg110:
 set temp_ma, bindis
 jmp rsetreg
 setreg111:
 call shootreg
 set reg2, temp_fr
 jmp rsetreg

 ;Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 ;shootMemory()
 ;Reg2 = MemoryAccess
 ;-----------------------
 ;shootMemory()
 ;Reg1 = MemoryAccess
 ;Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)


 jmp rsetreg
 setreg2:
 mov al, [binopc]
 shr al, 1
 shr al, 1
 jc setreg21;error?
 mov al, [_25binmod]
 shr al, 3 ;InFieldModRM[2:5]
 mov bl, [opsize]
 mov cl, 5
 
 cmp byte [bdis], 0
 je setreg121
 setreg120:
 set reg2, bindis
 jmp setreg122
 setreg121:
 call shootreg
 set reg2, temp_fr
 jmp setreg122

 setreg122:
 call check4mem
 set reg1, temp_ma
 
 jmp rsetreg 
 setreg21:
 call check4mem
 set reg2, temp_ma
 mov al, [_25binmod]
 and al, 0b0011100
 shr al, 3
 mov bl, [opsize]
 mov cl, 5
 call shootreg
 set reg1, temp_fr
 jmp rsetreg

 ;Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 ;shootMemory()
 ;Reg1 = MemoryAccess
 ;-----------------------
 ;shootMemory()
 ;Reg2 = MemoryAccess
 ;Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 setreg3:
 mov al, [_25binmod]
 shr al, 3 ;InFieldModRM[2:5]
 mov bl, [opsize]
 mov cl, 5
 call shootreg
 set reg1, temp_fr

 mov al, [_2binmod]
 cmp al, 0b11000000
 jne setreg31
 
 mov al, [_58binmod] ;InFieldModRM[2:5]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg2, temp_fr

 jmp rsetreg
 setreg31:
 call check4mem
 set reg2, temp_ma
 jmp rsetreg

 ;set reg1 <- temp_fr
 ;Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
 ;if InFieldModRM[:2] == "11":
 ;Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
 ;else:
 ;shootMemory()
 ;Reg2 = MemoryAccess

 setreg4:
 cmp byte [_2binmod], 0b11000000
 jne setreg41

 setreg40:
 mov al, [_58binmod] ;InFieldModRM[5:8]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 set reg2, inimm
 jmp rsetreg
 setreg41:
 call check4mem
 set reg1, temp_ma

 set reg2, binadd
 jmp rsetreg

 ;if InFieldModRM[:2] == "11":
 ;Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
 ;Reg2 = InFieldData
 ;else:
 ;shootMemory()
 ;Reg1 = MemoryAccess
 ;Reg2 = InFieldData
 setreg5:
 cmp byte [_2binmod], 0b11000000
 jne setreg51

 mov al, [_58binmod] ;InFieldModRM[5:]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg2, temp_fr

 jmp rsetreg
 setreg51:
 call check4mem
 set reg1, temp_ma

 jmp rsetreg
 setreg6:
 mov al, [_58binmod] ;InFieldModRM[5:8]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 set reg2, binadd

 jmp rsetreg

 ;Reg1 = findReg(InFieldOpCode[-3:],OperandSize,InFieldREX,7)
 ;Reg2 = InFieldData

 setreg7:
 mov al, [_58binmod] ;InFieldModRM[5:8]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 mov al, 0b00000000 ;000
 mov bl, [opsize]
 mov cl, 5
 call shootreg
 set reg2, temp_fr

 jmp rsetreg

 ;Reg1 = findReg(InFieldOpCode[5:],OperandSize,InFieldREX,7)
 ;Reg2 = findReg("000",OperandSize,InFieldREX,5)
 

 setreg8:
 mov al, [_58binmod] ;InFieldModRM[5:8]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 call adddisp
 set reg2, bindis

 jmp rsetreg
 ;Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
 ;Reg2 = addDisplacement()
 setreg9:
 call check4mem
 set reg1, temp_ma

 jmp rsetreg
 ;shootMemory()
 ;Reg1 = MemoryAccess
 setrega:
 mov al, [_58binmod] ;InFieldModRM[5:8]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 jmp rsetreg

 ;Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)

 setregb:

 mov al, [binopc]
 shr al, 1
 shr al, 1
 jc setregb1
 mov byte [reg2], 'c'
 mov byte [reg2+1], 'l'

 
 jmp setregb2 
 setregb1:
 mov byte [reg2], '1'

 setregb2:
 cmp byte [_2binmod], 0b11000000
 jne setregb3

 mov al, [_58binmod] ;InFieldModRM[5:8]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 jmp rsetreg
 setregb3:
 call check4mem
 set reg1, temp_ma

 jmp rsetreg
 ;if InFieldOpCode[6]=="1":
 ; Reg2 = "cl"
 ;else:
 ; Reg2 = "1"
 ;if InFieldModRM[:2] == "11":
 ; Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
 ;else:
 ; shootMemory()
 ; Reg1 = MemoryAccess


 setregc:
 mov al, [_25binmod]
 shr al, 3 ;InFieldModRM[2:5]
 mov bl, [opsize]
 mov cl, 5
 call shootreg
 set reg2, temp_fr

 mov al, [_2binmod]
 cmp al, 0b11000000
 jne setregc1
 
 mov al, [_58binmod] ;InFieldModRM[2:5]
 mov bl, [opsize]
 mov cl, 7
 call shootreg
 set reg1, temp_fr

 jmp rsetreg
 setregc1:
 call check4mem
 set reg1, temp_ma
 jmp rsetreg

 rsetreg:
 ret 0

 
 




lex:
 call lexb67
 ;------------------------
 call lexb66
 ;------------------------
 call lexbrex
 cmp byte [brex], 0
 je lex1
 mov bx, word [inrex]
 call tobin
 mov byte [binrex], bl
 ;------------------------
 lex1:
 call lexbbop
 ;------------------------
 call lexbopc
 cmp byte [bopc], 0
 je lex2
 mov bx, word [inopc]
 call tobin
 mov byte [binopc], bl
 ;------------------------
 lex2:
 call lexbmod
 cmp byte [bmod], 0
 je lex3
 mov bx, word [inmod]
 call tobin
 mov byte [binmod], bl
 ;------------------------
 lex3:
 call lexbsib
 cmp byte [bsib], 0
 je lex4
 mov bx, word [insib]
 call tobin
 mov byte [binsib], bl
 ;------------------------
 lex4:
 call lexbdis
 ;------------------------
 call lexbadd
 ;------------------------
 ret 0

lexb67:
 mov r8, qword [entptr]
 cmp word [r8], '67'
 jne rlexb67

 add qword [entptr], 2
 mov byte [b67], 1


 rlexb67:
 ret 0

lexb66:
 mov r8, qword [entptr]
 cmp word [r8], '66'
 jne rlexb66

 add qword [entptr], 2
 mov byte [b66], 1


 rlexb66:
 ret 0

lexbrex:

 mov r8, qword [entptr]
 mov rdi, r8
 call GetStrlen ;rdx<-strlen
 cmp rdx, 2
 jle rlexbrex
 cmp byte [r8], '4'
 jne rlexbrex

 mov dx, [r8]
 mov [inrex], dx
 add qword [entptr], 2
 mov byte [brex], 1

 rlexbrex:
 ret 0

lexbbop:
 mov r8, qword [entptr]
 cmp word [r8], '0f'
 jne rlexbbop

 add qword [entptr], 2
 mov byte [bbop], 1

 rlexbbop:
 ret 0


lexbopc:
 mov r8, qword [entptr]

 mov dx, [r8]
 mov [inopc], dx
 add qword [entptr], 2
 mov byte [bopc], 1

 rlexbopc:
 ret 0


lexbmod:
 mov r8, qword [entptr]

 mov al, [inopc]

 cmp al, 0x62 ;1011
 je rlexbmod
 cmp al, 0x63 ;1100
 je rlexbmod
 cmp al, 0x64 ;1101
 je rlexbmod

 mov rdi, r8
 call GetStrlen ;rdx<-strlen
 cmp rdx, 0
 jle rlexbmod
 mov dx, [r8]
 mov [inmod], dx
 add qword [entptr], 2
 mov byte [bmod], 1

 rlexbmod:
 ret 0


lexbsib:
 mov r8, qword [entptr]

 mov rdi, r8
 call GetStrlen ;rdx<-strlen
 cmp rdx, 0
 jle rlexbsib

 mov dl, [binmod]
 and dl, 0b00000111

 cmp dl, 0b00000100
 jne rlexbsib

 mov dl, [binmod]
 and dl, 0b11000000

 cmp dl, 0b11000000
 je rlexbsib

 mov dx, [r8]
 mov [inmod], dx
 add qword [entptr], 2
 mov byte [bsib], 1


 rlexbsib:
 ret 0


lexbdis:
 mov r8, qword [entptr]
 lea r11, [bindis]
 
 mov rdi, r8
 call GetStrlen ;rdx<-strlen
 cmp rdx, 0
 jle rlexbdis

 mov dl, [binmod]
 and dl, 0b11000000

 cmp dl, 0b01000000
 jne lexbdis1
 lexbdis0: 
 ;8bit Disp
 mov byte [bdis], 1
 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11

 mov r9b, byte [r8]
 mov byte [r11], r9b
 inc r11
 inc r8

 mov r9b, byte [r8]
 mov byte [r11], r9b
 inc r11
 inc r8

 add qword [entptr], 2

 jmp rlexbdis
 lexbdis1:
 cmp dl, 0b10000000
 jne lexbdis2
 ;32bit Disp
 ;"0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 mov byte [bdis], 1
 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11
 
 mov r9w, word [r8+6]
 cmp r9w, '00'
 je rsig11
 mov word [r11], r9w
 add r11, 2
 rsig11:
 mov r9w, word [r8+4]
 cmp r9w, '00'
 je rsig12
 mov word [r11], r9w
 add r11, 2
 rsig12:
 mov r9w, word [r8+2]
 mov word [r11], r9w
 add r11, 2

 mov r9w, word [r8]
 mov word [r11], r9w
 add r11, 2



 add qword [entptr], 8

 jmp rlexbdis
 lexbdis2:
 mov dl, [binmod]
 and dl, 0b11000111
 mov cl, [binsib]
 and dl, 0b00000111

 cmp dl, 0b00000100
 jne lexbdis3
 cmp cl, 0b00000101
 jne lexbdis3

 ;32bit Disp
 ;"0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 mov byte [bdis], 1
 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11
 
 mov r9w, word [r8+6]
 cmp r9w, '00'
 je rsig21
 mov word [r11], r9w
 add r11, 2
 rsig21:
 mov r9w, word [r8+4]
 cmp r9w, '00'
 je rsig22
 mov word [r11], r9w
 add r11, 2
 rsig22:
 mov r9w, word [r8+2]
 mov word [r11], r9w
 add r11, 2

 mov r9w, word [r8]
 mov word [r11], r9w
 add r11, 2

 add qword [entptr], 8

 jmp rlexbdis
 lexbdis3:
 mov dl, [binmod]
 and dl, 0b11000111

 cmp dl, 0b00000101
 jne lexbdis4

 ;32bit Disp
 ;"0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 mov byte [bdis], 1
 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11
 
 mov r9w, word [r8+6]
 cmp r9w, '00'
 je rsig31
 mov word [r11], r9w
 add r11, 2
 rsig31:
 mov r9w, word [r8+4]
 cmp r9w, '00'
 je rsig32
 mov word [r11], r9w
 add r11, 2
 rsig32:
 mov r9w, word [r8+2]
 mov word [r11], r9w
 add r11, 2

 mov r9w, word [r8]
 mov word [r11], r9w
 add r11, 2

 add qword [entptr], 8
 
 jmp rlexbdis

 lexbdis4:
 mov dl, [binmod]
 and dl, 0b00111000
 cmp dl, 0b00100000
 jne lexbdis5
 mov cl, [binopc]
 and cl, 0b11111110
 cmp cl, 0b11000000
 jne lexbdis5

 ;32bit Disp
 ;"0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 mov byte [bdis], 1
 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11

 mov r9b, byte [r8]
 mov byte [r11], r9b
 inc r11
 mov r9b, byte [r8+1]
 mov byte [r11], r9b
 inc r11

 add qword [entptr], 2
 
 jmp rlexbdis
 lexbdis5:
 mov dl, [binmod]
 and dl, 0b00111000
 cmp dl, 0b00101000
 ;jne rlexbdis
 mov cl, [binopc]
 and cl, 0b11111110
 cmp cl, 0b11000000
 ;jne rlexbdis

 ;32bit Disp
 ;"0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 mov byte [bdis], 1
 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11

 mov r9b, byte [r8]
 mov byte [r11], r9b
 inc r11
 mov r9b, byte [r8+1]
 mov byte [r11], r9b
 inc r11

 add qword [entptr], 2
 
 jmp rlexbdis
 rlexbdis:
 ret 0
 ;if len(MCode)>0:
 ; if InFieldModRM[:2]=="01": #8bit Disp
 ; FieldDisp = True
 ; InFieldDisp = "0x" + MCode[:2]
 ; MCode = MCode[2:]

 ; elif InFieldModRM[:2]=="10": #32bit Disp
 ; FieldDisp = True
 ; InFieldDisp = "0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 ; MCode = MCode[8:]

 ;elif InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="100" and InFieldSIB[-3:]=="101":
 ; FieldDisp = True
 ; InFieldDisp = "0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 ; if InFieldDisp=="0x00000000": InFieldDisp="0x0"
 ;MCode = MCode[8:]

 ; elif InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="101":
 ; FieldDisp = True
 ; InFieldDisp = "0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
 ; if InFieldDisp=="0x00000000": InFieldDisp="0x0"
 ; MCode = MCode[8:]

 ; elif InFieldOpCode[:7]=="1100000" and InFieldModRM[2:5]=="100":
 ; FieldDisp = True
 ; InFieldDisp = "0x" + MCode[:2]
 ; MCode = MCode[2:]

 ; elif InFieldOpCode[:7]=="1100000" and InFieldModRM[2:5]=="101":
 ; FieldDisp = True
 ; InFieldDisp = "0x" + MCode[:2]
 ; MCode = MCode[2:]




lexbadd:
 mov r8, qword [entptr]
 lea r11, [binadd]
 
 mov rdi, r8
 call GetStrlen ;rdx<-strlen
 cmp rdx, 0
 jle rlexbadd

 mov byte [r11], '0'
 inc r11
 mov byte [r11], 'x'
 inc r11 

 ;rdx <- lef size 
 xor rcx, rcx
 lexbadd1:
 cmp rdx, 0
 jle rlexbadd

 mov al, byte [r11]
 mov byte [binadd+rcx], al

 inc rcx 
 inc r11 
 dec rdx

 cmp rdx, 0
 jle lexbadd2 

 mov al, byte [r11]
 mov byte [binadd+rcx], al

 inc rcx 
 inc r11 
 dec rdx

 jmp lexbadd1

 lexbadd2:
 mov byte [binadd+rcx], '0'

 rlexbadd:
 ret 0



tobin:
 push ax
 mov ax, bx
 xchg al, ah
 sub al, 48
 sub ah, 48
 cmp al, 9
 jle tobin_skip1
 sub al, 39
 tobin_skip1:
 cmp ah, 9
 jle tobin_skip2
 sub ah, 39
 tobin_skip2:
 shl al, 4
 shr ax, 4
 xor rbx, rbx
 mov bl, al
 pop ax
 ret 0



print:
 mov rsi, trueinst
 call printString
 call newLine

 mov rsi, reg1
 call printString
 call newLine

 mov rsi, reg2
 call printString
 call newLine


 mov rsi, temp_ma
 call printString
 call newLine

 mov rsi, temp_fr
 call printString
 call newLine
 ret 0












findreg:
 cmp byte [brex], 0
 je findreg2
 findreg1:
 mov al, [binrex]
 and al, 0b00000100
 cmp al, 0b00000100
 je findreg12
 findreg11:
 mov bl, [_58binmod]
 shl bl, 2
 add bl, [opsize]
 mov rcx, temp_ma
 call registers

 mov bl, [_58binmod]
 shl bl, 2
 add bl, [opsize]
 mov rcx, temp_fr
 call registers
 jmp rfindreg
 findreg12:
 mov bl, [_58binmod]
 shl bl, 2
 add bl, [opsize]
 mov rcx, temp_ma
 call newregisters

 mov bl, [_58binmod]
 shl bl, 2
 add bl, [opsize]
 mov rcx, temp_fr
 call newregisters
 jmp rfindreg
 findreg2: ;cant undrestand here
 mov bl, [_58binmod]
 shl bl, 2
 add bl, [opsize]
 mov rcx, temp_ma
 call registers

 mov bl, [_25binmod]
 shl bl, 2
 add bl, [opsize]
 mov rcx, temp_fr
 call registers
 jmp rfindreg


 rfindreg:
 ret 0

 ;if FieldREX:
 ; if InFieldREX[5]=="0":
 ; MemoryAccess = Registers[InFieldModRM[-3:]+OperandSize]
 ; return Registers[InFieldModRM[-3:]+OperandSize]
 ;else:
 ; MemoryAccess = NewRegisters[InFieldModRM[-3:]+OperandSize]
 ; return NewRegisters[InFieldModRM[-3:]+OperandSize]
 
 ;else:
 ; MemoryAccess = Registers[InFieldModRM[-3:]+OperandSize]
 ; return Registers[InFieldModRM[-3:]+OperandSize]


registers:
 ;bl <- number of register
 ;rcx <- address
 mov r8, reg_
 lea rsi, [r8 + rbx*4]
 mov rdi, rcx
 mov rcx, 4
 cld
 repnz movsb
 ret 0

newregisters:
 ;bl <- number of register
 ;rcx <- address
 mov r8, nreg_
 lea rsi, [r8 + rbx*4]
 mov rdi, rcx
 mov rcx, 4
 cld
 repnz movsb
 ret 0


check4mem:
 cmp byte [_2binmod], 0b11000000
 jne check4mem1
 mov al, [_58binmod]
 mov bl, [opsize];might be addsize
 mov cl, 7
 call shootreg
 set temp_ma, temp_fr
 jmp rcheck4mem
 check4mem1:
 mov r8b, [binmod]
 and r8b, 0b11000111
 cmp r8b, 0b00000100
 jne check4mem11
 call shootsib
 jmp rcheck4mem
 check4mem11:
 cmp r8b, 0b00000101
 jne check4mem12
 call shootda
 jmp rcheck4mem
 check4mem12:
 cmp r8b, 0b10000100
 jne check4mem13
 call shootsib
 jmp rcheck4mem
 check4mem13:
 cmp r8b, 0b01000100
 jne check4mem14
 call shootda
 jmp rcheck4mem

 check4mem14:
 cmp byte [_2binmod], 0b01000000
 jne check4mem15
 ;dangrous stuff
 call ptrdef
 mov r15, temp_ma
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 
 mov al, [_58binmod]
 mov bl, [addsize]
 mov cl, 7
 call shootreg
 
 set r15, temp_fr;might be wrong
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 mov byte [r15], '+'
 inc r15
 call adddisp
 set r15, bindis
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 mov byte [r15], ']'
 inc r15
 jmp rcheck4mem

 check4mem15:
 cmp byte [_2binmod], 0b10000000
 jne check4mem16
 ;dangrous stuff
 call ptrdef
 mov r15, temp_ma
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 
 mov al, [_58binmod]
 mov bl, [addsize]
 mov cl, 7
 call shootreg
 
 set r15, temp_fr;might be wrong
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 mov byte [r15], '+'
 inc r15
 call adddisp
 set r15, bindis
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 mov byte [r15], ']'
 inc r15
 jmp rcheck4mem

 check4mem16:
 ;cmp byte [_2binmod], 0b10000000
 ;jne rcheck4mem
 ;dangrous stuff
 call ptrdef
 mov r15, temp_ma
 mov rdi, r15
 ;mov al, [rsi]
 call GetStrlen
 add r15, rdx
 
 mov al, [_58binmod]
 mov bl, [addsize]
 mov cl, 7
 call shootreg
 
 set r15, temp_fr;might be wrong
 mov rdi, r15
 call GetStrlen
 add r15, rdx
 mov byte [r15], ']'
 inc r15

 jmp rcheck4mem



 rcheck4mem:

 mov rax, 0
 mov al, [binmod]
 and al, 0b00111000
 mov [_25binmod], al

 mov al, [_25binmod]
 call writeNum

 mov al, [binopc]
 and al, 0b11111110
 mov [_7binopc], al

 mov al, [binopc]
 and al, 0b11111100
 mov [_6binopc], al

 mov al, [binopc]
 and al, 0b11111000
 mov [_5binopc], al

 mov al, [binmod]
 and al, 0b11000000
 mov [_2binmod], al
 

 mov al, [binmod]
 and al, 0b00000111
 mov [_58binmod], al
 

 mov al, [binsib]
 and al, 0b00000111
 mov [_58binsib], al

 mov al, [binsib]
 and al, 0b00111000
 mov [_25binsib], al

 mov al, [binsib]
 and al, 0b11000000
 mov [_2binsib], al


 ret 0

 ;if InFieldModRM[:2]=="11":
 ; MemoryAccess = findReg(InFieldModRM[-3:], OperandSize, InFieldREX,7)
 ;else:
 ; if InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="100":
 ; #print("A SIB")
 ; return shootSIB()
 ;
 ; elif InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="101":
 ; return shootDirectAccess()
 ;
 ; elif InFieldModRM[:2]=="10" and InFieldModRM[-3:]=="100":
 ; #print("one?")
 ; return shootSIB()
 ; 
 ; elif InFieldModRM[:2]=="01" and InFieldModRM[-3:]=="100":
 ; #print("one?")
 ; return shootSIB()

 ;elif InFieldModRM[:2]=="01" :
 ; MemoryAccess = PTRDefinition()
 ; MemoryAccess += " PTR ["
 ; MemoryAccess += findReg(InFieldModRM[-3:], AddressSize, InFieldREX,7)
 ;MemoryAccess += "+"
 ; MemoryAccess += addDisplacement()
 ; MemoryAccess += "]"
 ; return MemoryAccess
 ; 
 ; elif InFieldModRM[:2]=="10":
 ; MemoryAccess = PTRDefinition()
 ; MemoryAccess += " PTR ["
 ; MemoryAccess += findReg(InFieldModRM[-3:], AddressSize, InFieldREX,7)
 ; MemoryAccess += "+"
 ; MemoryAccess += addDisplacement()
 ; MemoryAccess += "]"
 ; return MemoryAccess
 
 ; else:
 ; MemoryAccess = PTRDefinition()
 ; MemoryAccess += " PTR ["
 ; MemoryAccess += findReg(InFieldModRM[-3:], AddressSize, InFieldREX,7)
 ; MemoryAccess += "]"
 ; return MemoryAcces



shootreg:
 ;al[3:0] <- reg code
 ;bl <- size
 ; binrex <- REX
 ;cl <- newreg
 cmp byte [brex], 1
 jne shootreg2 

 shootreg1:
 mov r9b, byte [binrex]
 cmp cl, 5
 jne shootreg12
 shootreg11:
 ;cl<-5
 and r9b, 0b00000100
 shr r9b, 2
 jmp rshootreg11
 shootreg12:
 cmp cl, 7;cl <- 7????
 jne shootreg13
 and r9b, 0b00000001
 ;
 jmp rshootreg11
 shootreg13:
 ;cl<-6
 jne shootreg11
 and r9b, 0b00000010
 shr r9b, 1
 jmp rshootreg11
 rshootreg11:
 cmp r9b, 0b00000000
 jne shootreg112

 shootreg111:
 ;might be wrong (no rex used)
 mov r10b, bl
 mov bl, al
 shl bl, 2
 add bl, r10b
 mov rcx, temp_fr
 call registers
 ;set temp_fm, 
 jmp rshootreg
 shootreg112:
 ;might be wrong (no rex used)
 mov r10b, bl
 mov bl, al
 shl bl, 2
 add bl, r10b
 mov rcx, temp_fr
 call newregisters;newew
 ;set temp_fm, 
 jmp rshootreg


 shootreg2:
 ;might be wrong (no rex used)
 mov r10b, bl
 mov bl, al
 shl bl, 2
 add bl, r10b
 mov rcx, temp_fr

 call registers
 ;set temp_fm, 

 rshootreg:
 ret 0




 ;def findReg(RegCode, Size, REX, NewReg = 3):
 ; if FieldREX:
 ; #print("REX",REX, NewReg,RegCode,Size)
 ; if NewReg == "3":
 ; NewReg = REX[5]
 ; else:
 ; NewReg = REX[NewReg]
 ; if NewReg=="0":
 ; #print(Registers[InFieldModRM[-3:]+Size])
 ; return Registers[RegCode+Size]
 ; else:
 ; #print(NewRegisters[InFieldModRM[-3:]+Size])
 ; return NewRegisters[RegCode+Size]
 ; 
 ;else:
 ; #print(Registers[RegCode+Size])
 ; return Registers[RegCode+Size]





shootda:

 ret 0

adddisp:

 ;if FieldDisp:
 ; if InFieldDisp[2:].strip("0")=="":
 ; InFieldDisp = "0x0"
 ; return InFieldDisp
 ;return ""
 ret 0

shootsib:
 call ptrdef
 cmp byte [_58binsib], 0b00000101
 jne shootsib0
 cmp byte[_2binmod], 0b00000000
 jne shootsib0
 jmp shootsib1
 shootsib0:
 mov al, [_58binsib]
 mov bl, [addsize]
 mov cl, 7
 call shootreg

 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen;may not work
 add r8, rdx
 set r8, temp_fr

 jmp shootsib2
 shootsib1:
 mov cl, cl ;???

 shootsib2:
 cmp byte [_25binsib], 0b00100000
 jne shootsib21
 cmp byte [_2binmod], 0b00000000
 jne shootsib21
 jmp shootsib22
 shootsib21:
 mov r8, temp_ma
 mov rdi, r8
 call GetStrlen;may not work
 add r8, rdx
 mov r10, r8
 sub r10, 1
 cmp byte [r10], '['
 je shootsib211
 mov byte [r8], '+'
 inc r8
 
 shootsib211:
 mov al, [_25binsib]
 shr al, 3
 mov bl, [addsize]
 mov cl, 6
 call shootreg

 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen;may not work
 add r8, rdx
 set r8, temp_fr

 cmp byte [_2binsib], 0b00000000
 jne shootsib212

 mov al, [_2binsib]
 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen
 add r8, rdx
 mov byte [r8], '*'
 inc r8
 mov byte [r8], '1'
 inc r8
 jmp shootsib3

 shootsib212:
 cmp byte [_2binsib], 0b01000000
 jne shootsib213

 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen
 add r8, rdx
 mov byte [r8], '*'
 inc r8
 mov byte [r8], '2'
 inc r8
 jmp shootsib3

 shootsib213:
 cmp byte [_2binsib], 0b01000000
 jne shootsib214

 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen
 add r8, rdx
 mov byte [r8], '*'
 inc r8
 mov byte [r8], '4'
 inc r8
 jmp shootsib3

 shootsib214:
 cmp byte [_2binsib], 0b1000000
 jne shootsib215

 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen
 add r8, rdx
 mov byte [r8], '*'
 inc r8
 mov byte [r8], '8'
 inc r8
 jmp shootsib3

 shootsib215:
 cmp byte [_2binsib], 0b11000000
 jne shootsib3

 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen
 add r8, rdx
 mov byte [r8], '*'
 inc r8
 mov byte [r8], '8'
 inc r8
 jmp shootsib3
 shootsib22:
 mov cl, cl ;???

 shootsib3: ;disp
 mov rdi, temp_ma
 mov r8, rdi
 call GetStrlen;may not work
 add r8, rdx
 mov r10, r8
 sub r10, 1
 cmp byte [r10], '['
 je shootsib31
 ;may not mov byte [r8], '+'
 ;inc r8
 shootsib31:
 ;add disp?
 mov byte [r8], ']'


 rshootsib:
 ret 0

 ; def shootSIB():
 ; MemoryAccess = PTRDefinition()
 ; MemoryAccess += " PTR ["
 ;if not (InFieldSIB[-3:]=="101" and InFieldModRM[:2]=="00"):
 ; MemoryAccess += findReg(InFieldSIB[-3:], AddressSize, InFieldREX,7)
 ; else:
 ; 1
 ; if not (InFieldSIB[2:5]=="100" and InFieldModRM[:2]=="00"):
 ; if MemoryAccess[-1]!="[": MemoryAccess+="+" 
 ; MemoryAccess += findReg(InFieldSIB[2:5], AddressSize, InFieldREX,6)
 ; if InFieldSIB[:2]=="00":
 ; MemoryAccess += "*1"
 ;elif InFieldSIB[:2]=="01":
 ; MemoryAccess += "*2"
 ; elif InFieldSIB[:2]=="10":
 ; MemoryAccess += "*4"
 ; elif InFieldSIB[:2]=="11":
 ; MemoryAccess += "*8"

 ; else:
 ; #but just do non
 ; 1
 ;if len(MemoryAccess)>0:
 ; if MemoryAccess[-1]!="[": MemoryAccess+="+"
 ; MemoryAccess += addDisplacement()
 ; MemoryAccess += "]"



ptrdef:
 mov r12, temp_ma
 cmp byte [b66], 1
 jne ptrdef1
 ptrdef0:
 mov byte [r12], 'W'
 inc r12
 mov byte [r12], 'O'
 inc r12
 mov byte [r12], 'R'
 inc r12
 mov byte [r12], 'D'
 inc r12

 jmp rptrdef
 ptrdef1:
 cmp byte [w], 0
 jne ptrdef2

 mov byte [r12], 'B'
 inc r12
 mov byte [r12], 'Y'
 inc r12
 mov byte [r12], 'T'
 inc r12
 mov byte [r12], 'E'
 inc r12

 jmp rptrdef 
 ptrdef2:
 cmp byte [brex], 0
 jne ptrdef3

 mov byte [r12], 'D'
 inc r12
 mov byte [r12], 'W'
 inc r12
 mov byte [r12], 'O'
 inc r12
 mov byte [r12], 'R'
 inc r12
 mov byte [r12], 'D'
 inc r12
 jmp rptrdef 

 ptrdef3:
 cmp byte [brex], 0
 jne ptrdef4

 mov byte [r12], 'D'
 inc r12
 mov byte [r12], 'W'
 inc r12
 mov byte [r12], 'O'
 inc r12
 mov byte [r12], 'R'
 inc r12
 mov byte [r12], 'D'
 inc r12
 jmp rptrdef 

 ptrdef4:
 cmp byte [brex], 0
 jne ptrdef5

 mov byte [r12], 'D'
 inc r12
 mov byte [r12], 'W'
 inc r12
 mov byte [r12], 'O'
 inc r12
 mov byte [r12], 'R'
 inc r12
 mov byte [r12], 'D'
 inc r12
 jmp rptrdef

 ptrdef5:
 mov byte [r12], 'W'
 inc r12
 mov byte [r12], 'O'
 inc r12
 mov byte [r12], 'R'
 inc r12
 mov byte [r12], 'D'
 inc r12
 jmp rptrdef

 rptrdef:

 mov byte [r12], ' '
 inc r12
 mov byte [r12], 'P'
 inc r12
 mov byte [r12], 'T'
 inc r12
 mov byte [r12], 'R'
 inc r12
 mov byte [r12], ' '
 inc r12
 mov byte [r12], '['
 inc r12


 
 ret 0

 ; def PTRDefinition():
 ; if Field66:
 ; return "WORD"
 ; elif W=="0":
 ; return "BYTE"
 ; elif W=="1" and FieldREX==False:
 ; return "DWORD"
 ; elif W=="1" and InFieldREX[4]=="0":
 ; return "DWORD"
 ;elif W=="1" and InFieldREX[4]=="1":
 ; return "QWORD"
 ; else:
 ; return "XWOED"




fixaddsize:
 cmp byte [b67], 0
 jne rfixaddsize
 mov byte [addsize], 3
 rfixaddsize:
 ret 0 

 ;def fixAddSize():
 ;if not Field67: AddressSize="64"

fixopsize:
 cmp byte [b66], 1
 jne fixopsize1
 fixopsize0:
 mov byte [opsize], 1
 jmp rfixopsize
 fixopsize1:
 cmp byte [w], 0
 jne fixopsize2

 mov byte [opsize], 0
 jmp rfixopsize
 fixopsize2:
 cmp byte [brex], 0
 jne fixopsize3

 mov byte [opsize], 2
 jmp rfixopsize
 fixopsize3:
 mov r8b, [binrex]
 and r8b, 0b00001000
 cmp r8b, 0b00001000
 je fixopsize4

 mov byte [opsize], 2
 jmp rfixopsize
 fixopsize4:
 mov byte [opsize], 3
 jmp rfixopsize

 rfixopsize:

 ret 0

 ;def fixOpSize():
 ; global OperandSize
 ;if Field66:
 ; OperandSize = "16"
 ; elif W=="0":
 ; OperandSize = "8"
 ; elif W=="1" and FieldREX==False:
 ; OperandSize = "32"
 ;elif W=="1" and InFieldREX[4]=="0":
 ; OperandSize = "32"
 ; elif W=="1" and InFieldREX[4]=="1":
 ; OperandSize = "64"
 ;else:
 ; OperandSize = "99"




savecode:
 mov qword [boolcodeptr], boolcode
 set qword [boolcodeptr], trueinst


 mov qword [boolcodeptr], boolcode
 mov rdi, boolcode
 call GetStrlen
 add qword [boolcodeptr], rdx

 set qword [boolcodeptr], const1
 add qword [boolcodeptr], 1

 set qword [boolcodeptr], reg1

 cmp byte [reg2], 0
 je savecode1 

 savecode0:

 mov qword [boolcodeptr], boolcode
 mov rdi, boolcode
 call GetStrlen
 add qword [boolcodeptr], rdx

 set qword [boolcodeptr], const2
 add qword [boolcodeptr], 1

 set qword [boolcodeptr], reg2

 savecode1: 
 mov rsi, boolcode
 call printString
 ret 0


makecode:

 call newLine
 mov rsi, ent
 call printString
 call newLine

 lea rax, [ent]
 mov [entptr], rax
 call lex
 call cgen
 set trueinst, inst
 ;call print
 call setreg
 ;call print
 call savecode

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



