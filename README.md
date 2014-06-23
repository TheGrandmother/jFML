jFML
==
A java implementation of the FML machine which i have designed.

Basic Usage
-----
Run the VFml class.
To see a very basic little example just hit the "Assemble And Load" button in the lower left corner. 
Choose the cloud.asm file. Then just hit "Run".
The "Assemble And Load" button assembles the chosen file. generates a output file with the same name but with a .fml file extension and then loads the assembled program into memory address 0.

A more thorough usage guide will appear sometime in the future.
Once I'm satisfied with the entire ISA i will write a proper documentation but the crap below here will serve as a general description of how the VM works.


Short ISA description
-------
	Each instruction is a 16-bit word.
	An instruction may have at most two arguments.<br>
	An instruction may carry up to two non registry arguments.<br>
		These will be placed after the instruction in memory.<br>
		In the case of only one non register argument this will be placed immediately after<br>
		the instruction. In the case of two non registry arguments the first address after<br>
		the instruction will be the first argument and the next will be the second.<br>

####Instruction encoding bits:<br>
	0-3.	These specify the second argument(a2)<br>
	4-7.	These specify the first argument (a1)<br>
	8-11.	These specify the operation to be done<br>
	12-15.	These specify the action to be taken.<br>

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
 13 | XOR
	
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
 EQL | s := a1 == a2  
 GRT | s := a1 > a2   
 LES | s := a1 < a2   
 AND | s := a1 and a2 
 OOR | s := a1 or a2  
 XOR | s := a1 xor a2 
 NOT | s := not a1    
 NOT | (s := a1 << a2) if a2 < 0 othewrwise (s := a1 >> -a2)    
 JMP | Jump to a1           
 JSR | Jump to subroutine at a1              
 RET | Return from subroutine               
 SEQ | Skip on a1 == a2
 SGR | Skip on a1 > a2
 SLE | Skip on a1 < a2
 JOO | Jump to a1 if s == 1
 JOZ | Jump to a1 if s == 0
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

All references except constants can be augmented with a +n. 
This means that it should reserve that address and the n next addresses.
EX: #here+100
Will make sure that the assembler puts nothing but
zeroes for 100 addresses after the address of the #here label




