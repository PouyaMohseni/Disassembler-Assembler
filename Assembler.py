
W = "" #8-16-32 bit registers
S = "" #sign
D = "" #Source

# REX prefixes for 64-bit mode
REXField ="0"
REX = "" #64bit mode
WREX = "0"
RREX = "0"
XREX = "0"
BREX = "0"

PTR2Size = "32"  # Default pointer size
SelfGenCode = ""  # Placeholder for generated code
OneInstCode = ""  # Placeholder for single instruction code

# Prefixes for different address and operand sizes
PrefixAdd = {64: "",32: "67"}
PrefixOp = {64: "",32: "",16: "01100110", 8: ""}
SIZEOF = {"BYTE":"8", "WORD":"16", "DWORD":"32", "QWORD":"64"}

# Opcode values for various instructions
OperandCode = {"mov":"100010", "add":"000000", "adc":"000100", "sub":"001010", "sbb":"000110",
               "and":"001000", "or":"000010", "xor":"001100", "dec":"", "inc":"",
               "cmp":"001110", "test":"100001", "xchg":"100001", "xadd":"110000",
               "imul":"101011", "idiv":"111101",
               "bsf":"10111100", "bsr":"10111101",
               "stc":""	,"clc":"", "std":"", "cld":"",	
               "jmp":"", "jcc":"",	
               "shl":"", "shr":"", "neg":"", "not":"",	
               "call":"", "ret":"", "syscall":"" ,"push":"", "pop":""}

# Operand codes for specific instructions
OperandImCode = {"add":"100000", "mov":"1100011", "adc":"100000"}
OperandAltCode = {"add":"00000", "mov":"100010", "jmp":"00110"}
Reg_OpCode = {"add":"010", "adc":"000","and":"100","or":"001"}
PreOpCode = "00001111"
PreOpEnable = "0"
Mod = "" #00, 01, 10, 11
Reg_Op = ""
R_M = ""
SIB = ""
PreCode = ""
HexData = ""
Prefix_66 = ""
Prefix_67 = ""
HexData = ""
DisplacementCode = ""
SibEnable = False
BoolRegisters = []
BinOperands = ["add","sub","mov","adc","cmp","test","imul","xadd","xor","sbb","or","cmp","test","xchg","xadd",
               "idiv"]
sInclude = ["add","adc"]
Registers = {"al":"000", "ax":"000", "eax":"000", "rax":"000",
             "cl":"001", "cx":"001", "ecx":"001", "rcx":"001",
             "dl":"010", "dx":"010", "edx":"010", "rdx":"010",
             "bl":"011", "bx":"011", "ebx":"011", "rbx":"011",
             "ah":"100", "sp":"100", "esp":"100", "rsp":"100",
             "ch":"101", "bp":"101", "ebp":"101", "rbp":"101",
             "dh":"110", "si":"110", "esi":"110", "rsi":"110",
             "bh":"111", "di":"111", "edi":"111", "rdi":"111",
             }
NewRegisters = {"r8w":"000", "r8d":"000", "r8":"000",
             "r9w":"001",    "r9d":"001", "r9":"001",
             "r10w":"010", "r10d":"010", "r10":"010",
             "r11w":"011", "r11d":"011", "r11":"011",
             "r12w":"100", "r12d":"100", "r12":"100",
             "r13w":"101", "r13d":"101", "r13":"101",
             "r14w":"110", "r14d":"110", "r14":"110",
             "r15w":"111", "r15d":"111", "r15":"111",
             }


Value2Scale = {"1":"00", "2":"01", "4":"10", "8":"11"}
#c = 2
def Data2Hex(Data):
    Hex = ""
    if Data[:2]=="0x":Data=Data[2:]
    for i in range(0,len(Data),2):
        Hex = (Data[i:i+2])+Hex
    return Hex

def fillS(Data,reg):
    return 0,Data

    
def SetPrefix_67(elem):
    global Prefix_67
    if elem in Registers:
        if elem[0]=="e": Prefix_67 = "01100111"
    elif elem[:2] == "0x":
        if len(elem)==6: Prefix_67 = "01100111"


def setMode (Add):
    return 1


def fillW(reg):
    #print(reg)
    if (reg[-1] == "l" or reg[-1] == "h"):
        #8bit
        return "0"
    elif (reg[0]=="e" or reg[-1]=="d"):
        #32bit
        return "1"
    elif ((reg[0] == "r" and reg[-1]=="x")or(reg[0] == "r" and reg[-1]=="p")or(reg[0] == "r" and reg[-1]=="i")):
        #64bit
        return "1"
    elif (reg[-1] =="x" or reg[-1] =="i" or reg[-1] =="p" or reg[-1] =="w"):
        #16bit
        global Prefix_66
        Prefix_66 += PrefixOp[16]
        return "1" #as w
    else:
        return "1"

        
def IsRegister (OP):
    global M64
    #print("OP IS: ",OP, OP in NewRegisters)
    if OP in Registers: return 1
    if OP in NewRegisters: return 1
    elif OP[:2] == "0x": return 2
    else: return 0

    
def lex(EX):
    if len(EX)==0:
        return []
    else:
        #print("not a Null")
        Lexed = EX.split(" ",1)
        if len(Lexed) == 1:
            return Lexed
        #elif len(Lexed) == 2:
            #return Lexed
        else:
            return [Lexed[0]]+(Lexed[1].split(",",1))

def memoryDecoder(Mem):
    global Mod
    global R_M
    global DisplacementCode
    global SIB
    global RREX
    global BREX
    global XREX
    M64 = 0 #64bit mode
    bisd = [0,0,0,0] #base index scale disp
    Base = ""
    Index = ""
    Scale = ""
    Disp =""
    Mem = Mem[1:-1]
    Mem = Mem.split("+")
    for i in range(len(Mem)):
        if "*" in Mem[i]:
            Index, Scale = Mem[i].split("*")
            Mem = Mem[:i]+Mem[i+1:]
            bisd[1] = 1
            bisd[2] = 1
            break

    if (len(Mem)>0):
        if Mem[0] in Registers or Mem[0] in NewRegisters:
            Base = Mem[0]
            bisd[0] = 1
            Mem = Mem[1:]
            
    if (len(Mem)>0):
        Disp = Mem[0]
        bisd[3] = 1
        Mem = []

    ############SET ADDRESS PREFIX
    SetPrefix_67([Base,Index,Scale,Disp][next(x[0] for x in enumerate(bisd) if x[1]==1)])



#################################[1,0,0,0]
    if bisd == [1,0,0,0]:
        Mod = "00"
        if Base in Registers:
            R_M = Registers[Base]
            M64 = 0
            BREX = "0"
        else:
            R_M = NewRegisters[Base]
            M64 = 1
            BREX = "1"
        #print(R_M)
        if M64==0:return("type1")
        else:return("type2")


            
#################################[1,0,0,1]
    elif bisd == [1,0,0,1]:
        #print("yay")
        if Base in Registers:
            R_M = Registers[Base]
            M64 = 0
            BREX = "0"
        else:
            R_M = NewRegisters[Base]
            M64 = 1
            BREX = "1"


        #8bit Disp########################
        if len(Disp)== 4:
            Mod = "01"
            DisplacementCode = Data2Hex(Disp)

            if M64==0:return("type3")
            else:return("type4")


            
        #16bit Disp3######################   
        elif len(Disp)== 6:
            Mod = "10"
            Disp = Disp[:2]+"0000"+Disp[2:]
            DisplacementCode = Data2Hex(Disp)
            
            if M64==0:return("type3")
            else:return("type4 ")

            
        #32bit Disp#######################
        elif len(Disp)== 10:
            Mod = "10"
            DisplacementCode = Data2Hex(Disp)
            
            if M64==0:return("type7")
            else:return("type8")

#################################[1,1,1,0]
    elif bisd == [1,1,1,0]:
        if Base!="ebp":
            Mod = "00"  #SIB
            R_M = "100" #SIB
            SIB += Value2Scale[Scale] #Scale
            if SIB: 2
            if Index in Registers:
                SIB += Registers[Index]
                M64 = 0
                XREX = "0"
            else:
                SIB += NewRegisters[Index]
                M64 = 1
                XREX = "1"
                
            if Base in Registers:
                SIB += Registers[Base]
                BREX = "0"
            else:
                SIB += NewRegisters[Base]
                M64 = 1
                BREX = "1"
            
        else:
            Mod = "01"  #SIB
            R_M = "100" #SIB
            DisplacementCode = Data2Hex("0000")
            SIB += Value2Scale[Scale] #Scale
            
            #print(SIB)
            if SIB: 2
            if Index in Registers:
                SIB += Registers[Index]
                M64 = 0
                XREX = "0"
            else:
                SIB += NewRegisters[Index]
                M64 = 1
                XREX = "1"
                
            if Base in Registers:
                SIB += Registers[Base]
                BREX = "0"
            else:
                SIB += NewRegisters[Base]
                M64 = 1
                BREX = "1"

        if M64==0:return("type9")
        else:return("type10")


        
#################################[1,1,1,1]
    elif bisd == [1,1,1,1]:
        #Mod = "00"  #SIB
        R_M = "100" #SIB
        SIB += Value2Scale[Scale] #Scale
        if Index in Registers:
            SIB += Registers[Index]
            M64 = 0
            XREX = "0"
        else:
            SIB += NewRegisters[Index]
            M64 = 1
            XREX = "1"
            
        if Base in Registers:
            SIB += Registers[Base]
            BREX = "0"
        else:
            SIB += NewRegisters[Base]
            M64 = 1
            BREX = "1"

        #8bit Disp########################
        if len(Disp)== 4:
            Mod = "01"
            DisplacementCode = Data2Hex(Disp)
            #print(DisplacementCode)
            if M64==0:return("type11")
            else:return("type12")


            
        #16bit Disp3######################   
        elif len(Disp)== 6:
            Mod = "10"
            Disp = Disp[:2]+"0000"+Disp[2:]
            DisplacementCode = Data2Hex(Disp)
            
            if M64==0:return("type11")
            else:return("type12 ")

            
        # 32bit Disp#######################
        elif len(Disp)== 10:
            Mod = "10"
            DisplacementCode = Data2Hex(Disp)
            #print(DisplacementCode)
            #print(R_M)
            
            if M64==0:return("type11")
            else:return("type12")
            


#################################[0,1,1,0]
    elif bisd == [0,1,1,0]:
        #disp will be added
        DisplacementCode = "00000000"
        Mod = "00" #no disp
        R_M = "100" #sib
        
        SIB += Value2Scale[Scale] #Scale
        if Index in Registers:
            SIB += Registers[Index]
            M64 = 0
            XREX="0"
        else:
            SIB += NewRegisters[Index]
            M64 = 1
            XREX="1"
            
        SIB += "101" #ebp
        if M64==0:return("type13")
        else:return("type14")



#################################[0,1,1,1]
    elif bisd == [0,1,1,1]:
        #disp should be extended
        Mod = "00"
        R_M = "100"
        DisplacementCode = Data2Hex(Disp[0:2]+"00000000"[:10-len(Disp)]+Disp[2:])
        #print(Disp[0:2]+"000000"[:10-len(Disp)]+Disp[2:],44,DisplacementCode)
        SIB += Value2Scale[Scale] #Scale
        if Index in Registers:
            SIB += Registers[Index]
            M64 = 0
            XREX="0"
        else:
            SIB += NewRegisters[Index]
            M64 = 1
            XREX="1"
            
        SIB += "101" #ebp
        
        if M64==0:return("type13")
        else:return("type14")


        
#################################[0,0,0,1]
    elif bisd == [0,0,0,1]:
        #no prefix 67
        Prefix67 = ""
        Mod = "00"
        R_M = "100"
        SIB += "00"
        SIB += "100"
        SIB += "101" #ebp
        DisplacementCode = Data2Hex(Disp)



#32bit coding
def code(Lexed):
    global Mod
    global W
    global D
    global R_M
    global Reg_Op
    global WREX
    global RREX
    global XREX
    global BREX
    global HexData
    global Prefix_66
    global BoolRegisters
    global SelfGenCode
    global OneInstCode
    global PreCode
    #BREX = "0"
    #XREX = "0"
    #print(Lexed)
    Operandsize = 0
    AddressSize = 0
    BoolRegisters = []
    Code = ""

    if Lexed[0]=="bsf" or Lexed[0]=="bsr" or Lexed[0]=="xadd": PreCode="0f"
    
    InstCode = OperandCode[Lexed[0]]
    #print(InstCode)
    if len(Lexed)==3:


        
########################################################binery operator
        BoolRegisters.append(IsRegister(Lexed[1]))
        BoolRegisters.append(IsRegister(Lexed[2]))
        if BoolRegisters[1]==1:
            D = "0"
            if Lexed[2] in Registers:
                Reg_Op = Registers[Lexed[2]]
                RREX = "0"
                if Lexed[2][0] == "r": WREX ="1"
            elif Lexed[2] in NewRegisters:
                Reg_Op = NewRegisters[Lexed[2]]
                RREX = "1"
                if Lexed[2][-1]!="w" and Lexed[2][-1]!="d" : WREX ="1"



#####################################Operator Reg, Reg
            if BoolRegisters[0]==1:
                Mod = "11"
                W = fillW(Lexed[2])
                if Lexed[1] in Registers:
                    R_M = Registers[Lexed[1]]
                    BREX = "0"
                elif Lexed[1] in NewRegisters:
                    R_M = NewRegisters[Lexed[1]]
                    BREX = "1"
                if Lexed[0]=="imul": PreCode="0f"
                if Lexed[0]=="bsf" or Lexed[0]=="bsr":
                    return str("{0:04x}".format(int(InstCode + Mod + Reg_Op + R_M, 2)))
                if Lexed[0]=="imul":
                    return str("{0:04x}".format(int("10101111" + Mod + Reg_Op + R_M, 2)))
                return str("{0:04x}".format(int(InstCode + D + W + Mod + Reg_Op + R_M, 2)))



#####################################Operator Memory,reg
            if BoolRegisters[0]==0:
                codeTheMemory(Lexed[1])
                W = "1"
                if PTR2Size=="8": W="0"
                elif PTR2Size=="16": Prefix_66+=PrefixOp[16]
                if Lexed[0]=="bsf" or Lexed[0]=="bsr":
                    return str("{0:04x}".format(int(InstCode + Mod + Reg_Op + R_M, 2)))
                return str("{0:04x}".format(int(InstCode + D + W + Mod + Reg_Op + R_M, 2)))
        elif BoolRegisters[0]==1:
            D = "1"
            #print("ano")
            if Lexed[1] in Registers:
                Reg_Op = Registers[Lexed[1]]
                RREX = "0"
                if Lexed[1][0] == "r": WREX ="1"
            elif Lexed[1] in NewRegisters:
                Reg_Op = NewRegisters[Lexed[1]]
                RREX = "1"
                if Lexed[1][-1]!="w" and Lexed[2][-1]!="d" : WREX ="1"


                
###################################Operator Reg , Imm
            if BoolRegisters[1]==2:
                #print("here")
                Mod = "11"
                #print("R_M: ",Reg_Op)
                R_M = Reg_Op
                Reg_Op = OperandCode[Lexed[0]] #code
                #InstCode = OperandImCode[Lexed[0]]
                if(len(Lexed[2]))==3:
                    Lexed[2]=+"0x"+ "0" + Lexed[2][2]
                elif len(Lexed[2])!=4:
                    Lexed[2]=Lexed[2][:2]
                    while len(Lexed[2])<=8:
                        Lexed[2]="0"+Lexed[2]
                    Lexed[2]="0x"+Lexed[2]
                HexData = Data2Hex(Lexed[2])#[2:]
                W = fillW(Lexed[1])
                return str("{0:04x}".format(int(InstCode + S + W + Mod + Reg_Op + R_M , 2)))



##################################Operator Reg memory
            else:
                codeTheMemory(Lexed[2])
                W = fillW(Lexed[1])
                if Lexed[0]=="imul": PreCode="0f"
                if Lexed[0]=="bsf" or Lexed[0]=="bsr":
                    return str("{0:04x}".format(int(InstCode + Mod + Reg_Op + R_M, 2)))
                if Lexed[0]=="bsf" or Lexed[0]=="bsr":
                    return str("{0:04x}".format(int(InstCode + Mod + Reg_Op + R_M, 2)))
                return str("{0:04x}".format(int(InstCode+D+W+Mod+Reg_Op+R_M,2)))
                
            #SetMode()
            #Set mode
        else:
            D="1"

    elif len(Lexed)==2:
#########################################################Unary Operator
        BoolRegisters.append(IsRegister(Lexed[1]))
        #print(BoolRegisters)
        if BoolRegisters[0]==1: #register
            Mod ="11"
            D = "0"
            W = fillW(Lexed[1]) #?
            #print(W)
            if Lexed[1] in Registers:
                R_M = Registers[Lexed[1]]
                BREX = "0"
                if Lexed[1][0] == "r": WREX ="1"
            elif Lexed[1] in NewRegisters:
                R_M = NewRegisters[Lexed[1]]
                BREX = "1"
                if Lexed[1][-1]!="w" and Lexed[1][-1]!="d" : WREX ="1"
                #print("imhere",WREX)
        elif BoolRegisters[0]==2: #imm
            Mod = "00"
            if(len(Lexed[2]))==3:
                Lexed[2]=+"0x"+ "0" + Lexed[2][2]
            elif len(Lexed[2])!=4:
                Lexed[2]=Lexed[2][:2]
                while len(Lexed[2])<=8:
                    Lexed[2]="0"+Lexed[2]
                Lexed[2]="0x"+Lexed[2]
            HexData = Data2Hex(Lexed[1])

        elif BoolRegisters[0]==0: #memory
            codeTheMemory(Lexed[1])
            W = "1"
            if PTR2Size=="8": W="0"
            elif PTR2Size=="16": Prefix_66+=PrefixOp[16]

        if Lexed[0]=="not":
            return str("{0:04x}".format(int("1111011" + W + Mod + "010" + R_M , 2)))
        
        elif Lexed[0]=="neg":
            return str("{0:04x}".format(int("1111011" + W + Mod + "011" + R_M , 2)))

        elif Lexed[0]=="inc":
            return str("{0:04x}".format(int("1111111" + W + Mod + "000" + R_M , 2)))

        elif Lexed[0]=="dec":
            return str("{0:04x}".format(int("1111111" + W + Mod + "001" + R_M , 2)))

        elif Lexed[0]=="shr":
            return str("{0:04x}".format(int("1101000" + W + Mod + "101" + R_M , 2)))

        elif Lexed[0]=="shl":
            return str("{0:04x}".format(int("1101000" + W + Mod + "100" + R_M , 2)))

        elif Lexed[0]=="idiv":
            return str("{0:04x}".format(int("1111011" + W + Mod + "111" + R_M , 2)))

        elif Lexed[0]=="imult":
            return str("{0:04x}".format(int("1111011" + W + Mod + "101" + R_M , 2)))

        elif Lexed[0]=="jmp":
            return str("{0:04x}".format(int("11101001")))
            return str("{0:04x}".format(int("11111111" + W + Mod + "100" + R_M , 2)))

        elif Lexed[0][:1]=="j":
            return str("{0:04x}".format(int("11101001")))
            return str("{0:04x}".format(int("11111111" + W + Mod + "100" + R_M , 2)))
        
        elif Lexed[0]=="pop":
            if Lexed[1]=="rax": REXField=0
            if Lexed[1][0]=="r": WREX="0"
            if BoolRegisters[0]==1: return str("{0:02x}".format(int("01011" + R_M , 2)))
            if BoolRegisters[0]==0: return str("{0:04x}".format(int("10001111" + Mod + "000" + R_M , 2)))

        elif Lexed[0]=="push":
            if Lexed[1]=="rax": REXField=0
            if Lexed[1][0]=="r": WREX="0"
            if BoolRegisters[0]==1: return str("{0:02x}".format(int("01010" + R_M , 2)))
            if BoolRegisters[0]==0: return str("{0:04x}".format(int("11111111" + Mod + "110" + R_M , 2)))
    else:
        if Lexed[0]=="stc":
            OneInstCode="f9"
        if Lexed[0]=="clc":
            OneInstCode="f8"
        if Lexed[0]=="std":
            OneInstCode="fd"
        if Lexed[0]=="cld":
            OneInstCode="fc"
        if Lexed[0]=="ret":
            OneInstCode=str("{0:02x}".format(int("11001011",2)))
        if Lexed[0]=="syscall":
            OneInstCode=str("{0:04x}".format(int("000011110000000111111000",2)))
            


def testCode(Lexed):
    global REXField
    if len(Lexed)>1:
        for i in range(len(Lexed[1])-1):
            if Lexed[1][i:i+3] in NewRegisters.keys():
                REXField = "1"
                return code(Lexed)
            if Lexed[1][i] == "r":
                REXField = "1"
                return code(Lexed)
    if len(Lexed)>2:     
        for i in range(len(Lexed[2])-2):
            if Lexed[2][i:i+3] in NewRegisters.keys():
                REXField = "1"
                return code(Lexed)
            if Lexed[2][i] == "r":
                REXField = "1"
                return code(Lexed)
        return code(Lexed)
        #print("NIIIIST")
        #print("NNNO")
    return code(Lexed)
def SetRREX():
    if D==1:
        1
def codeTheMemory(Lex):
    #print(Lex)
    global PTR2Size
    PTR2Size = SIZEOF[Lex.split(' ')[0]]
    #print("PTR",PTR2Size)
    state = memoryDecoder(Lex.split(' ')[2])

def codeGen(Inst):
    global REX
    global SIB
    global DisplacementCode
    global SelfGenCode
    Lexed = lex(Inst)
    MainCode = testCode(Lexed)
    Pre = Prefix_67+Prefix_66

    if(len(Pre)>0): Pre = str(hex(int(Pre,2)))[2:]
    if (REXField=="1"):
        REX = str(hex(int("0100"+WREX+RREX+XREX+BREX,2)))[2:]
    if len(SIB)>0: SIB=str("{0:04x}".format(int(SIB,2)))[2:]
    
    if Lexed[0]=="adc":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "010" + R_M,2)))[2:]
            if Lexed[1][0]=="a" or Lexed[1][1]=="a":
                SelfGenCode=str("{0:02x}".format(int("0001010" + W ,2)))[2:]

    if Lexed[0]=="add":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "000" + R_M,2)))[2:]
            if Lexed[1][0]=="a" or Lexed[1][1]=="a":
                SelfGenCode=str(hex(int("0000001" + W ,2)))[2:]

    if Lexed[0]=="and":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "100" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("0010010" + W ,2)))[2:]
                
    if Lexed[0]=="cmp":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "111" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("0011110" + W ,2)))[2:]

    if Lexed[0]=="mov":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1100011" + W + Mod + "000" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("1010000" + W ,2)))[2:]

    if Lexed[0]=="or":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "001" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str("{0:02x}".format(int("0000110" + W ,2)))[2:]

    if Lexed[0]=="sbb":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "011" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("0001110" + W ,2)))[2:]

    if Lexed[0]=="sub":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "101" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("0010110" + W ,2)))[2:]

    if Lexed[0]=="test":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1111011" + W + Mod + "000" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("1010100" + W ,2)))[2:]

    if Lexed[0]=="xor":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("1000000" + W + Mod + "110" + R_M,2)))[2:]
            if Lexed[1][0]=="a":
                SelfGenCode=str(hex(int("0011010" + W ,2)))[2:]
                
                

                
    if Lexed[0]=="imul":
        if BoolRegisters[1]==2:
            SelfGenCode=str(hex(int("01101001" + Mod + Reg + R_M,2)))[2:]
        if Lexed[1][0]=="a":
            SelfGenCode=str(hex(int("1111011" + W + Mod + "101" + R_M,2)))[2:]


    if Lexed[0]=="mov":
        if BoolRegisters==[1,2]:
            SelfGenCode=str(hex(int("1011" + W + R_M,2)))[2:]
    if SelfGenCode!="":
        return Pre+REX+PreCode+SelfGenCode+SIB+DisplacementCode+HexData
    if OneInstCode!="":
        return OneInstCode
    return Pre+REX+PreCode+MainCode+SIB+DisplacementCode+HexData

x = input("")
#print(codeGen(x))

