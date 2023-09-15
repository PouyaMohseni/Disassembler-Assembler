
MCode = ""

Field67 = False
Field66 = False
FieldREX = False
FieldBackOp = False
FieldOpCode = True
FieldModRM = False
FieldSIB = False
FieldDisp = False
FieldData = False

InField67 = ""
InField66 = ""
InFieldBackOp = ""
InFieldREX = ""
InFieldOpCode = ""
InFieldModRM = ""
InFieldSIB = ""
InFieldDisp = ""
InFieldData = ""

AddressSize = "32"
OperandSize = "32"
COperand =""
Reg1 = ""
Reg2 = ""
MemoryAccess = ""
W = "0"

Registers = {"0008":"al", "00016":"ax", "00032":"eax", "00064":"rax",
             "0018":"cl", "00116":"cx", "00132":"ecx", "00164":"rcx",
             "0108":"dl", "01016":"dx", "01032":"edx", "01064":"rdx",
             "0118":"bl", "01116":"bx", "01132":"ebx", "01164":"rbx",
             "1008":"ah", "10016":"sp", "10032":"esp", "10064":"rsp",
             "1018":"ch", "10116":"bp", "10132":"ebp", "10164":"rbp",
             "1108":"dh", "11016":"si", "11032":"esi", "11064":"rsi",
             "1118":"bh", "11116":"di", "11132":"edi", "11164":"rdi"
             }
NewRegisters = {"0008":"r8b", "00016":"r8w", "00032":"r8d", "00064":"r8",
              "0018":"r9b", "00116":"r9w",  "00132":"r9d",  "00164":"r9",
             "0108":"r10b", "01016":"r10w", "01032":"r10d", "01064":"r10",
             "0118":"r11b", "01116":"r11w", "01132":"r11d", "01164":"r11",
             "1008":"r12b", "10016":"r12w", "10032":"r12d", "10064":"r12",
             "1018":"r13b", "10116":"r13w", "10132":"r13d", "10164":"r13",
             "1108":"r14b", "11016":"r14w", "11032":"r14d", "11064":"r14",
             "1118":"r15b", "11116":"r15w", "11132":"r15d", "11164":"r15",
             }
def cut67():
    global MCode
    global Field67
    global InField67
    if MCode[:2]=="67":
        Field67 = True
        InField67 = str(bin(int(MCode[:2],16)))[2:].zfill(8)
        MCode = MCode[2:]
        
def cut66():
    global MCode
    global Field66
    global InField66
    if MCode[:2]=="66":
        Field66 = True
        InField66 = str(bin(int(MCode[:2],16)))[2:].zfill(8)
        MCode = MCode[2:]

def cutREX():
    global MCode
    global FieldREX
    global InFieldREX
    
    if len(MCode)>2 and MCode[0]=="4":
        FieldREX = True
        InFieldREX = str(bin(int(MCode[:2],16)))[2:].zfill(8)
        MCode = MCode[2:]

def cutBackOp():
    global MCode
    global FieldBackOp
    global InFieldBackOp
    if MCode[:2]=="0f":
        FieldBackOp = True
        InFieldBackOp = MCode[:2]
        MCode = MCode[2:]

    
def cutOpCode():
    global MCode
    global InFieldOpCode

    InFieldOpCode = str(bin(int(MCode[:2],16)))[2:].zfill(8)

    MCode = MCode[2:]

def cutModRM():
    global MCode
    global FieldModRM
    global InFieldModRM
    if InFieldOpCode[:4]=="1011" and InFieldOpCode[4:]!="1100" and InFieldOpCode[4:]!="1101":
        return
    if len(MCode)>0:
        FieldModRM = True
       
        InFieldModRM = str(bin(int(MCode[:2],16)))[2:].zfill(8)
        MCode = MCode[2:]

def cutSIB():
    global MCode
    global FieldSIB
    global InFieldSIB
    global InFieldModeRM
    if len(MCode)>0:
        if InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="100":
            FieldSIB = True
           
            InFieldSIB = str(bin(int(MCode[:2],16)))[2:].zfill(8)
            MCode = MCode[2:]
            
        elif InFieldModRM[:2]=="01" and InFieldModRM[-3:]=="100":
            FieldSIB = True
            InFieldSIB = str(bin(int(MCode[:2],16)))[2:].zfill(8)
            MCode = MCode[2:]
            
        elif InFieldModRM[:2]=="10" and InFieldModRM[-3:]=="100":
            FieldSIB = True
            InFieldSIB = str(bin(int(MCode[:2],16)))[2:].zfill(8)
            MCode = MCode[2:]

        
            
def cutDisp():
    global MCode
    global FieldDisp
    global InFieldDisp
    global InFieldModRM
 
    if len(MCode)>0:
     
        if InFieldModRM[:2]=="01": #8bit Disp
            FieldDisp = True
            InFieldDisp = "0x" + MCode[:2]
            MCode = MCode[2:]

        elif InFieldModRM[:2]=="10": #32bit Disp
            FieldDisp = True
            InFieldDisp = "0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
            MCode = MCode[8:]
        

        elif InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="100" and InFieldSIB[-3:]=="101":
            FieldDisp = True
            InFieldDisp = "0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
            if InFieldDisp=="0x00000000": InFieldDisp="0x0"
            MCode = MCode[8:]
           

        elif InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="101":
            FieldDisp = True
            InFieldDisp = "0x" + MCode[6:8]+MCode[4:6]+MCode[2:4]+MCode[:2]
            if InFieldDisp=="0x00000000": InFieldDisp="0x0"
            MCode = MCode[8:]
        
        elif InFieldOpCode[:7]=="1100000" and InFieldModRM[2:5]=="100":
            FieldDisp = True
            InFieldDisp = "0x" + MCode[:2]
            MCode = MCode[2:]
        elif InFieldOpCode[:7]=="1100000" and InFieldModRM[2:5]=="101":
            FieldDisp = True
            InFieldDisp = "0x" + MCode[:2]
            MCode = MCode[2:]


def cutData():
    global MCode
    global FieldData
    global InFieldData
    if len(MCode)>0:
        FieldData = True
        for i in range(0,len(MCode),2):
            InFieldData = MCode[:2] + InFieldData
            MCode = MCode[2:]
    
        InFieldData = "0x" + InFieldData.strip("0")
   



def findReg(RegCode, Size, REX, NewReg = 3):
    if FieldREX:
        
        if NewReg == "3":
            NewReg = REX[5]
        else:
              NewReg = REX[NewReg]
        if NewReg=="0":

            return Registers[RegCode+Size]
        else:
            
            return NewRegisters[RegCode+Size]
            
    else:
        
        return Registers[RegCode+Size]


def addDisplacement():
    global InFieldDisp
    if FieldDisp:
        if InFieldDisp[2:].strip("0")=="":
            InFieldDisp = "0x0"
        return InFieldDisp
    return ""


def PTRDefinition():
    if Field66:
        return "WORD"
    elif W=="0":
        return "BYTE"
    elif W=="1" and FieldREX==False:
        return "DWORD"
    elif W=="1" and InFieldREX[4]=="0":
        return "DWORD"
    elif W=="1" and InFieldREX[4]=="1":
        return "QWORD"
    else:
        return "XWOED"



    
def shootReg():
    global MemoryAccess
    #print("im very here!")
    if FieldREX:
        if InFieldREX[5]=="0":
            MemoryAccess = Registers[InFieldModRM[-3:]+OperandSize]
            return Registers[InFieldModRM[-3:]+OperandSize]
        else:
            MemoryAccess = NewRegisters[InFieldModRM[-3:]+OperandSize]
            return NewRegisters[InFieldModRM[-3:]+OperandSize]
            
    else:
        MemoryAccess = Registers[InFieldModRM[-3:]+OperandSize]
        return Registers[InFieldModRM[-3:]+OperandSize]

    
def shootSIB():
    global MemoryAccess
    global InFieldModRM
    MemoryAccess = PTRDefinition()
    MemoryAccess += " PTR ["
    if not (InFieldSIB[-3:]=="101" and InFieldModRM[:2]=="00"):
        MemoryAccess += findReg(InFieldSIB[-3:], AddressSize, InFieldREX,7)
    else:
        1
    if not (InFieldSIB[2:5]=="100" and InFieldModRM[:2]=="00"):
        if MemoryAccess[-1]!="[": MemoryAccess+="+" 
        MemoryAccess += findReg(InFieldSIB[2:5], AddressSize, InFieldREX,6)
        if InFieldSIB[:2]=="00":
            MemoryAccess += "*1"
        elif InFieldSIB[:2]=="01":
            MemoryAccess += "*2"
        elif InFieldSIB[:2]=="10":
            MemoryAccess += "*4"
        elif InFieldSIB[:2]=="11":
            MemoryAccess += "*8"

    else:
        #???
        1

    if len(MemoryAccess)>0:
        if MemoryAccess[-1]!="[": MemoryAccess+="+"
        MemoryAccess += addDisplacement()

        MemoryAccess += "]"



def shootDirectAccess():
    global MemoryAccess
    MemoryAccess = "["+addDisplacement()+"]"
    return MemoryAccess
    
def shootMemory():
    global MemoryAccess
    global InFieldModRM
    #if
    
    if InFieldModRM[:2]=="11":
        MemoryAccess = findReg(InFieldModRM[-3:], OperandSize, InFieldREX,7)
    else:
        if InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="100":
           
            return shootSIB()
        
        elif InFieldModRM[:2]=="00" and InFieldModRM[-3:]=="101":
            return shootDirectAccess()

        elif InFieldModRM[:2]=="10" and InFieldModRM[-3:]=="100":
        
            return shootSIB()
        
        elif InFieldModRM[:2]=="01" and InFieldModRM[-3:]=="100":
         
            return shootSIB()

        elif InFieldModRM[:2]=="01" :
            MemoryAccess = PTRDefinition()
            MemoryAccess += " PTR ["
            MemoryAccess += findReg(InFieldModRM[-3:], AddressSize, InFieldREX,7)
            MemoryAccess += "+"
            MemoryAccess += addDisplacement()
            MemoryAccess += "]"
            return MemoryAccess
        
        elif InFieldModRM[:2]=="10":
            MemoryAccess = PTRDefinition()
            MemoryAccess += " PTR ["
            MemoryAccess += findReg(InFieldModRM[-3:], AddressSize, InFieldREX,7)
            MemoryAccess += "+"
            MemoryAccess += addDisplacement()
            MemoryAccess += "]"
            return MemoryAccess
        
        else:
            MemoryAccess = PTRDefinition()
            MemoryAccess += " PTR ["
            MemoryAccess += findReg(InFieldModRM[-3:], AddressSize, InFieldREX,7)
            MemoryAccess += "]"
            return MemoryAccess

        
def fixAddSize():
    global AddressSize
    if not Field67: AddressSize="64"

    
def fixOpSize():
    global OperandSize
    if Field66:
        OperandSize = "16"
    elif W=="0":
        
        OperandSize = "8"
    elif W=="1" and FieldREX==False:
        OperandSize = "32"
        
    elif W=="1" and InFieldREX[4]=="0":
       
        OperandSize = "32"
    elif W=="1" and InFieldREX[4]=="1":
        OperandSize = "64"
    else:
        OperandSize = "99"

 
    
def fixSize():
    fixAddSize()
    fixOpSize()


        
def deCode():
    global MCode
    global Field67
    global InField67
    global Field66
    global InField66
    global FieldREX
    global InFieldREX
    global FieldOpCode
    global InFieldOpCode
    global FieldModRM
    global InFieldModRM
    global FieldSIB
    global InFieldSIB
    global FieldModDisp
    global InFieldModDisp
    global FieldModData
    global InFieldModData

    global COperand
    global Reg1
    global Reg2
    global W

  
    cut67()
   
    cut66()
   
    cutREX()
 
    cutBackOp()
    cutOpCode()

    cutModRM()
 
    cutSIB()
    
    cutDisp()
 
    cutData()
  
    '''
    print("InField67: ",Field67,
          "InField66: ",Field66,
          "InFieldREX: ",FieldREX,
          "InFieldOpCode: ",FieldOpCode,
          "InFieldModRM: ",FieldModRM,
          "InFieldSIB: ",FieldSIB,
          "InFieldDisp: ",FieldDisp,
          "InFieldData: ",FieldData)

    print("InField67: ",InField67,
          "InField66: ",InField66,
          "InFieldREX: ",InFieldREX,
          "InFieldOpCode: ",InFieldOpCode,
          "InFieldModRM: ",InFieldModRM,
          "InFieldSIB: ",InFieldSIB,
          "InFieldDisp: ",InFieldDisp,
          "InFieldData: ",InFieldData)
    
    '''
    W = InFieldOpCode[-1]
    if InFieldOpCode[:4]=="1011": W = InFieldOpCode[4]
    fixSize()

    #STC
    if InFieldOpCode=="11111001":
        COperand = "stc"

    #CLC
    if InFieldOpCode=="11111000":
        COperand = "clc"

    #STD
    if InFieldOpCode=="11111101":
        COperand = "std"

    #CLD
    if InFieldOpCode=="11111100":
        COperand = "cld"

    #ADC
    elif InFieldOpCode[:6]=="000100":
        COperand = "adc"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
    elif InFieldOpCode[:6]=="100000" and InFieldModRM[2:5]=="010":
        COperand = "adc"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
            Reg2 = InFieldData
        else:
            shootMemory()
            Reg1 = MemoryAccess
            Reg2 = InFieldData

    #ADD
    elif InFieldOpCode[:6]=="000000":
        COperand = "add"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

    elif InFieldOpCode[:6]=="100000" and InFieldModRM[2:5]=="000":
        COperand = "add"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
            Reg2 = InFieldData
        else:
            shootMemory()
            Reg1 = MemoryAccess
            Reg2 = InFieldData

    #AND
    elif InFieldOpCode[:6]=="001000":
        COperand = "and"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

    elif InFieldOpCode[:6]=="100000" and InFieldModRM[2:5]=="100":
        COperand = "and"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
            Reg2 = InFieldData
        else:
            shootMemory()
            Reg1 = MemoryAccess
            Reg2 = InFieldData
        
    #CMP
    elif InFieldOpCode[:6]=="001110":
        COperand = "cmp"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

    elif InFieldOpCode[:6]=="100000":
        COperand = "cmp"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess


    #DIV
    elif InFieldOpCode[:7]=="1111011" and InFieldModRM[2:5]=="110":
        COperand = "div"
        
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess

        
    #IDIV
    elif InFieldOpCode[:7]=="1111011" and InFieldModRM[2:5]=="111":
        COperand = "idiv"
        
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess


    #MUL
    elif InFieldOpCode[:7]=="1111011" and InFieldModRM[2:5]=="100":
        COperand = "mul"
        
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess


    #IMUL
    elif InFieldOpCode[:7]=="1111011" and InFieldModRM[2:5]=="101":
        COperand = "imul"
        
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess

            
    elif FieldBackOp and InFieldOpCode[:8]=="10101111":
        COperand = "imul"
        Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess


    elif InFieldOpCode[:6]=="011010":
        COperand = "imul"

        
    #JMP
    elif InFieldOpCode[:8]=="11111111" and 0:
        COperand = "jmp"
        Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess

            
    #MOV
    elif InFieldOpCode[:6]=="100010":
        COperand = "mov"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
        
    elif InFieldOpCode[:6]=="110001":
        COperand = "mov"

    elif InFieldOpCode[:6]=="101000": #TO AX, ...
        COperand = "mov"

    elif not(FieldBackOp) and InFieldOpCode[:4]=="1011":
        COperand = "mov"
        Reg1 = findReg(InFieldOpCode[-3:],OperandSize,InFieldREX,7)
        Reg2 = InFieldData
        
    #sub
    elif InFieldOpCode[:6]=="001010":
        COperand = "sub"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

            
    #sbb
    elif InFieldOpCode[:6]=="00010":
        COperand = "add"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

    
    #XOR
    elif InFieldOpCode[:6]=="001100":
        COperand = "xor"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)

    #XCHG
    elif InFieldOpCode[:6]=="100001":
        COperand = "xchg"
        if InFieldOpCode[6]=="0": #second oprand is reg
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg2 = MemoryAccess
            #print(reg2)
        else:
            shootMemory()
            Reg1 = MemoryAccess
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
    elif InFieldOpCode[:5]=="10010":
        COperand = "xchg"
        Reg1 = findReg(InFieldOpCode[5:],OperandSize,InFieldREX,7)
        Reg2 = findReg("000",OperandSize,InFieldREX,5)
        print(Reg2)


    #TEST
    elif InFieldOpCode[:6]=="100001":
        COperand = "test"
        if InFieldOpCode[6]=="0": #second oprand is reg
            #print(55,OperandSize)
            Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
            
            shootMemory()
            Reg1 = MemoryAccess
            #print(Reg1)
            
        else:
            shootMemory()
            Reg2 = MemoryAccess
            Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,7)
    elif InFieldOpCode[:6]=="111101" and InFieldModRM[2:5]=="000":
        COperand = "test"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess
    elif InFieldOpCode[:6]=="101010":
        Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)

    #XADD
    elif FieldBackOp and InFieldOpCode[:7]=="1100000":
        COperand = "xadd"
        Reg2 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:

            shootMemory()
            Reg1 = MemoryAccess
  

    #dec
    elif InFieldOpCode[:5]=="01001":
        COperand = "dec"
        Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)


    elif InFieldOpCode[:7]=="1111111" and InFieldModRM[2:5]=="001":
        COperand = "dec"
        shootMemory()
        Reg1 = MemoryAccess

        
    #inc
    elif InFieldOpCode[:5]=="01000":
        COperand = "inc"
        Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)

    elif InFieldOpCode[:7]=="1111111" and InFieldModRM[2:5]=="000":
        COperand = "inc"
        shootMemory()
        Reg1 = MemoryAccess


    #shl
    elif InFieldOpCode[:6]=="110100" and InFieldModRM[2:5]=="100":
        COperand = "shl"
        if InFieldOpCode[6]=="1":
            Reg2 = "cl"
        else:
            Reg2 = "1"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg1 = MemoryAccess

            
    elif InFieldOpCode[:7]=="1100000" and InFieldModRM[2:5]=="100":
        COperand = "shl"
        Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        Reg2 = addDisplacement()

    
    #shr
    elif InFieldOpCode[:6]=="110100" and InFieldModRM[2:5]=="101":
        COperand = "shr"
        if InFieldOpCode[6]=="1":
            Reg2 = "cl"
        else:
            Reg2 = "1"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg1 = MemoryAccess

            
    elif InFieldOpCode[:7]=="1100000" and InFieldModRM[2:5]=="101":
        COperand = "shr"
        Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        Reg2 = addDisplacement()


    #neg
    elif InFieldOpCode[:6]=="111101" and InFieldModRM[2:5]=="011":
        COperand = "neg"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg1 = MemoryAccess

            
    #not
    elif InFieldOpCode[:6]=="111101" and InFieldModRM[2:5]=="010":
        COperand = "not"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg1 = MemoryAccess 
    #call
    elif InFieldOpCode[:8]=="11111111" and InFieldModRM[2:5]=="010":
        COperand = "call"
        if InFieldModRM[:2] == "11":
            Reg1 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg1 = MemoryAccess

            
    elif InFieldOpCode[:8]=="10011010":
        COperand = "call"
        shootMemory()
        Reg1 = MemoryAccess

        
    elif InFieldOpCode[:8]=="11101000":
        COperand = "call"
        shootMemory()
        Reg1 = MemoryAccess
        

    #ret
    elif InFieldOpCode[:8]=="11000011":
        COperand = "ret"
    elif InFieldOpCode[:8]=="11000010":
        COperand = "ret"
        shootMemory()
        Reg1 = MemoryAccess


    #syscall
    elif FieldBackOp and InFieldOpCode=="00000101":
        COperand = "syscall"


    #bsf
    elif FieldBackOp and InFieldOpCode=="10111100":
        COperand = "bsf"
        Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess


    #bsr
    elif FieldBackOp and InFieldOpCode=="10111101":
        COperand = "bsf"
        Reg1 = findReg(InFieldModRM[2:5],OperandSize,InFieldREX,5)
        if InFieldModRM[:2] == "11":
            Reg2 = findReg(InFieldModRM[5:],OperandSize,InFieldREX,7)
        else:
            shootMemory()
            Reg2 = MemoryAccess
    #push-pop
    
    fullcode=COperand
    if len(Reg1)>0:
        fullcode+=" "+Reg1
    if len(Reg2)>0:
        if len(Reg1)>0:fullcode+=","
        else: fullcode+=" "
        fullcode+=Reg2
    print(fullcode)

    

# A Simple Test:
Codes = ["678b148d00000000", "678b948d06555555", "4f0fbc5ca016", "67033c23", "678b1408", "678b540855", \
         "678b148d000000", "678b148d06000000", "678b548d00", "678b148b", "678b548d06", "678b948d06555555", \
         "8b14251e555555", "6703151e555555", "4939d0", "4185d0", "66ba5213", "6601c1", "88f8", "00c1", \
         "6601c1", "033b", "034651"]

for MCode in Codes:
    deCode()
