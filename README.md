# 8086 Disassembler-Assembler

## Overview

This project comprises both a Disassembler and an Assembler implemented in 8086 Assembly language and Python. These programs are designed to work with the 8086 Assembly language, a low-level programming language with a strong correspondence between its instructions and the machine code instructions of the 8086 architecture.

- An **assembler** is a tool for low-level programming. It takes basic computer instructions written in assembly language and converts them into binary patterns of bits that the computer's processor can execute. The assembler is responsible for translating human-readable assembly code into machine code that the computer can understand and execute.

- A **disassembler**, on the other hand, performs the inverse operation of an assembler. It takes machine code, represented as binary patterns of bits, and translates it back into human-readable assembly language. This is particularly useful for reverse engineering, debugging, and analyzing binary executables.

## Supported Instructions

Both the assembler and disassembler can understand and interpret the following instructions:
### Data Movement
| Instruction  | Description                     |
|--------------|---------------------------------|
| mov          | Move data between registers/memory |
| add          | Add two operands                |
| adc          | Add with carry                  |
| sub          | Subtract two operands           |
| sbb          | Subtract with borrow            |
| and          | Bitwise AND                     |
| or           | Bitwise OR                      |
| xor          | Bitwise XOR                     |
| dec          | Decrement                       |
| inc          | Increment                       |

### Logical and Arithmetic
| Instruction  | Description                     |
|--------------|---------------------------------|
| cmp          | Compare                         |
| test         | Logical AND                     |
| xchg         | Exchange values of two operands |
| xadd         | Atomic exchange and add         |
| imul         | Signed multiplication           |
| idiv         | Signed division                 |
| bsf          | Bit Scan Forward                |
| bsr          | Bit Scan Reverse                |
| stc          | Set Carry Flag                  |
| clc          | Clear Carry Flag                |
| std          | Set Direction Flag              |
| cld          | Clear Direction Flag            |
| shl          | Shift Left                      |
| shr          | Shift Right                     |
| neg          | Negate                          |
| not          | Bitwise NOT                     |

### Control Flow
| Instruction  | Description                     |
|--------------|---------------------------------|
| call         | Call a procedure                |
| ret          | Return from procedure           |
| syscall      | System Call                     |

### Stack Operations
| Instruction  | Description                     |
|--------------|---------------------------------|
| push         | Push value onto stack           |
| pop          | Pop value from stack            |

**Warning:** There may be some bugs in interpreting certain cases. Please use with caution.


