# 8086 Disassembler-Assembler

## Overview

This project comprises both a Disassembler and an Assembler implemented in 8086 Assembly language and Python. Assembly language is a low-level programming language with a strong correspondence between its instructions and the architecture's machine code instructions.

- An **assembler** is a program that takes basic computer instructions and converts them into a pattern of bits that the computer's processor can use to perform its operations.

- A **disassembler** is a computer program that translates machine language into assembly language, which is the inverse operation to that of an assembler. It's different from a decompiler, which targets a high-level language.

## Supported Instructions

Both the assembler and disassembler can understand and interpret the following instructions:

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
| call         | Call a procedure                |
| ret          | Return from procedure           |
| syscall      | System Call                     |
| push         | Push value onto stack           |
| pop          | Pop value from stack            |

**Warning:** There may be some bugs in interpreting certain cases. Please use with caution.


