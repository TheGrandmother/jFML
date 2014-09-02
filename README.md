jFML
==
A java implementation of the FML machine which i have designed.

Basic Usage
-----
Run the VFml class. 
Press Ctrl+Alt+A to Assemble and load a file.
Press Ctrl+Alt+S to start the VM.
Hold Ctrl+Alt+D to see debug information.
Hold Ctrl+Alt+Q to pause the machine.


Short ISA description
-------
	Each instruction is a 16-bit word.
	An instruction may have at most two arguments.
	An instruction may carry up to two non registry arguments.
		These will be placed after the instruction in memory.
		In the case of only one non register argument this will be placed immediately after
		the instruction. In the case of two non registry arguments the first address after
		the instruction will be the first argument and the next will be the second.

####Instruction encoding bits:
	0-3.	These specify the second argument(a2)
	4-7.	These specify the first argument (a1)
	8-11.	These specify the operation to be done
	12-15.	These specify the action to be taken.

####Argument encodings:
	bits 0-1:
		00.	The stack
		01.	The X register
		10.	The Y register
		11.	a non-registry argument

	bit 2:
		0.	Use argument as value
		1. 	Use argument as address

	bit 3:
		0. Use argument
		1. Don't use argument *

		
####Operations:
 Operation Bits | Description
 ---------------|------------
 0 | NOP
 1 | INC
 2 | DEC
 3 | ADD
 4 | SUB
 5 | MUL
 6 | DIV
 7 | MOD
 8 | EQL
 9 | GRT
 10 | LES
 11 | AND
 12 | OOR
 13 | XOR
 14 | NOT
 15 | SFT

	
####Actions:
 Action Bits | Description
 ---------------|------------
 0 | NOP
 1 | JMP
 2 | JSR
 3 | RET
 4 | SEQ
 5 | SGR
 6 | SLE
 7 | JOO
 8 | JOZ
 9 | SOO
 10 | SOZ
 11 | HLT
 12 | MOV
 13 | SNE
#####Explanations:
						
  Menonic 	|   Description	      
-----------|----------------
 NOP | No Operation  
 MOV | Move a1 to a2 (a2 != n or $n)
 INC | Increment a1  
 DEC | Decrement a1  
 ADD | s := a1 | a2   
 SUB | s := a1 - a2   
 MUL | s := a1 * a2   
 DIV | s := a1 / a2   
 MOD | s := a1 % a2   
 EQL | s := a1 = a2  
 GRT | s := a1 > a2   
 LES | s := a1 < a2   
 AND | s := a1 and a2 
 OOR | s := a1 or a2  
 XOR | s := a1 xor a2 
 NOT | s := not a1    
 NOT | (s := a1 << a2) if a2 < 0 otherwise (s := a1 >> -a2)    
 JMP | Jump to a1           
 JSR | Jump to subroutine at a1              
 RET | Return from subroutine               
 SEQ | Skip on a1 = a2
 SNE | Skip on a1 != a2
 SGR | Skip on a1 > a2
 SLE | Skip on a1 < a2
 JOO | Jump to a1 if s = 1
 JOZ | Jump to a1 if s = 0
 SOO | Jump to subroutine a1 if s = 1
 SOZ | Jump to subroutine a1 if s = 0
 HLT | Halt 
 


Assembler
--------
Special charcters:<br>
&nbsp; &nbsp; &nbsp; &nbsp;\ &nbsp; &nbsp; &nbsp; &nbsp;Are considered comments and everything after this character will be ignored<br>
&nbsp; &nbsp; &nbsp; &nbsp;:&nbsp; &nbsp; &nbsp; &nbsp;This is raw data entry. Its address will correspond to where in the code they appear<br>
&nbsp; &nbsp; &nbsp; &nbsp;<&nbsp; &nbsp; &nbsp; &nbsp;Includes the file specified. Into the place where it was found.<br>
&nbsp; &nbsp; &nbsp; &nbsp;_&nbsp; &nbsp; &nbsp; &nbsp;Are blanks and will be ignored. (not the same as spaces)<br>
<br>

References:<br>
&nbsp; &nbsp; &nbsp; &nbsp;@&nbsp; &nbsp; &nbsp; &nbsp;Are pointers and they will be assigned an arbitrary address<br>
&nbsp; &nbsp; &nbsp; &nbsp;#&nbsp; &nbsp; &nbsp; &nbsp;Are labels and their address will correspond to where in the code they are<br>
&nbsp; &nbsp; &nbsp; &nbsp;!&nbsp; &nbsp; &nbsp; &nbsp;These are constants. The place where they are declared will not appear in the output<br>
<br>

Pointer declarations can be augmented with a + and then a number. This reserves that many addresses after the address given to the pointer.<br>
So @array+100 will allocate 99 addresses after the address given to the array pointer. This is used for handling arrays.



