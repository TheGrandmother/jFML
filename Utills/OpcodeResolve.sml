(* PKD 2014 group 27
	Henrik Sommerland, Oskar Ahlberg, Aleksander Lundquist
*)

use "StringUtills.sml";
structure Resolve =
struct
	exception SYNTAX of string
	exception RESOLVE of string
	
	(*
		¡MUY IMPORTANTE!
		All these functions MUST add here to the VM specifications	
	*)
	
	datatype opType = NOP | MOV| ARITH | LOGIC | JUMP | SPEC
	
	fun getType(i) =
		if i = 0 then NOP else
		if (i >= 1 andalso i <= 76) then MOV else
		if (i >= 100 andalso i <= 776) then ARITH else
		if (i >= 1000 andalso i <= 9076) then LOGIC else
		if (i >= 10000 andalso i <= 70000) then JUMP else
		if (i >= 100000 andalso i <= 300000) then SPEC else
		raise RESOLVE "Invalid opcode"
	
	
	fun reverseMnemonic(i) =
		if i = 0 then "NOP" else
		let
			val trimmed = (i div 100) * 100
		in
			case trimmed of
			0 		=>	"MOV"
			|100		=>	"INC"
			|200		=>	"DEC"
			|300		=>	"ADD"
			|400		=>	"SUB"
			|500		=>	"MUL"
			|600		=>	"DIV"
			|700		=>	"MOD"
			
			|1000		=>	"EQL"
			|2000		=>	"GRT"
			|3000		=>	"LES"
			|4000		=>	"BRL"
			|5000		=>	"BRR"
			|6000		=>	"AND"
			|7000		=>	"ORR"
			|8000		=>	"XOR"
			|9000		=>	"NOT"
			
			|10000		=>	"JMP"
			|20000		=>	"BEQ"
			|30000		=>	"BLE"
			|40000		=>	"BGR"
			|50000		=>	"JSR"
			|60000		=>	"RET"
			
			|100000		=>	"HLT"
			|200000		=>	"SEM"
			|300000		=>	"POP"
			|_ => raise RESOLVE (Int.toString(i) ^" is an invalid opcode")
		end
		
	fun checkArguments(i) =
		let
			val args = i - ((i div 100)*100)
		in
			case args of
			55 => raise RESOLVE (Int.toString(i) ^" has two non-register arguments")
			|58 => raise RESOLVE (Int.toString(i) ^" has two non-register arguments")
			|65 => raise RESOLVE (Int.toString(i) ^" has two non-register arguments")
			|68 => raise RESOLVE (Int.toString(i) ^" has two non-register arguments")
			|_ => ()
		end
		
	fun hasNonRegisterArgument(i) =
		let
			val read = i - ((i div 10)*10)
			val write = ((i - ((i div 100)*100)) div 10)
		in
			if (read = 5 orelse read = 6) then
				true
			else
				if write = 5 orelse write = 8 then
					true
				else
					false
		end
		
		fun popsStack(i) =  (i - ((i div 10)*10) = 2) orelse (i = 300000)

	
	(*
		You guys might want to write an inverse of this function to resolve valid arguments.
	*)
	fun mnemonic("NOP") = 000000
	|mnemonic("MOV") = 000000
	
	|mnemonic("INC") = 000100
	|mnemonic("DEC") = 000200
	|mnemonic("ADD") = 000300
	|mnemonic("SUB") = 000400
	|mnemonic("MUL") = 000500
	|mnemonic("DIV") = 000600
	|mnemonic("MOD") = 000700
	
	|mnemonic("EQL") = 001000
	|mnemonic("LES") = 002000
	|mnemonic("GRT") = 003000
	|mnemonic("BRL") = 004000
	|mnemonic("BRR") = 005000
	|mnemonic("AND") = 006000
	|mnemonic("ORR") = 007000
	|mnemonic("XOR") = 008000
	|mnemonic("NOT") = 009000
	
	|mnemonic("JMP") = 010000
	|mnemonic("BEQ") = 020000
	|mnemonic("BLE") = 030000
	|mnemonic("BGR") = 040000
	|mnemonic("JSR") = 050000
	|mnemonic("RET") = 060000
	
	|mnemonic("HLT") = 100000
	|mnemonic("SEM") = 200000
	|mnemonic("POP") = 300000
	|mnemonic(_) = raise RESOLVE "Unknown mnemonic!\n"
	
	(*
		This function is here to aid the assembler. 
		It could be used by the VM implementation to reverse instructions into opcodes
	*)
	fun read("x") = 0
	|read("y") = 1
	|read("s") = 2
	|read("$x") = 3
	|read("$y") = 4
	|read("") = 0
	|read(s) =
		let
			val head = Char.ord(List.hd(String.explode(s))); 
		in
			if (head = 36) orelse (head = 64) then (* 36 = "$" 64 = "@" *)
				5
			else
				6

		end
	
	(*
		This function is here to aid the assembler. 
		It could be used by the VM implementation to reverse instructions into opcodes
	*)
	fun write("x") = 0
	|write("y") = 10
	|write("s") = 20
	|write("$x") = 30
	|write("$y") = 40
	|write("q1") = 60
	|write("q2") = 70
	|write("") = 0
	|write(s) =
		let
			val head = Char.ord(List.hd(String.explode(s))); 
		in
			if (head = 36)then (* 36 = "$" 64 = "@" *)
				50
			else 
				80

		end
	
	fun resolveExpression([m]) = mnemonic(m)
	|resolveExpression([m,a1]) = mnemonic(m)+read(a1)
	|resolveExpression([m,a1,a2]) = mnemonic(m)+read(a1)+write(a2)
	|resolveExpression(_) = raise RESOLVE "Tried to parse an malformed expression\n"
	
	fun numberOfArgs("NOP") = 0
	|numberOfArgs("MOV") = 2
	
	|numberOfArgs("INC") = 1
	|numberOfArgs("DEC") = 1
	|numberOfArgs("ADD") = 2
	|numberOfArgs("SUB") = 2
	|numberOfArgs("MUL") = 2
	|numberOfArgs("DIV") = 2
	|numberOfArgs("MOD") = 2
	
	|numberOfArgs("EQL") = 2
	|numberOfArgs("LES") = 2
	|numberOfArgs("GRT") = 2
	|numberOfArgs("BRL") = 1
	|numberOfArgs("BRR") = 1
	|numberOfArgs("AND") = 2
	|numberOfArgs("ORR") = 2
	|numberOfArgs("XOR") = 2
	|numberOfArgs("NOT") = 1
	
	|numberOfArgs("JMP") = 1
	|numberOfArgs("BEQ") = 2
	|numberOfArgs("BLE") = 2
	|numberOfArgs("BGR") = 2
	|numberOfArgs("JSR") = 1
	|numberOfArgs("RET") = 0
	
	|numberOfArgs("HLT") = 0
	|numberOfArgs("SEM") = 0
	|numberOfArgs("POP") = 0
	|numberOfArgs(_) = raise RESOLVE "Tried to parse an malformed expression\n"
		
		fun validReadArguments("NOP") = [] 
		|validReadArguments("MOV") = [0,1,2,3,4,5,6]
		
		|validReadArguments("INC") = []
		|validReadArguments("DEC") = []
		|validReadArguments("ADD") = [0,1,2,3,4,5,6]
		|validReadArguments("SUB") = [0,1,2,3,4,5,6]
		|validReadArguments("MUL") = [0,1,2,3,4,5,6]
		|validReadArguments("DIV") = [0,1,2,3,4,5,6]
		|validReadArguments("MOD") = [0,1,2,3,4,5,6]
		
		|validReadArguments("EQL") = [0,1,2,3,4,5,6]
		|validReadArguments("LES") = [0,1,2,3,4,5,6]
		|validReadArguments("GRT") = [0,1,2,3,4,5,6]
		|validReadArguments("BRL") = [0,1,2,3,4,5,6]
		|validReadArguments("BRR") = [0,1,2,3,4,5,6]
		|validReadArguments("AND") = [0,1,2,3,4,5,6]
		|validReadArguments("ORR") = [0,1,2,3,4,5,6]
		|validReadArguments("XOR") = [0,1,2,3,4,5,6]
		|validReadArguments("NOT") = [0,1,2,3,4,5,6]
		
		|validReadArguments("JMP") = []
		|validReadArguments("BEQ") = [0,1,2,3,4,5,6]
		|validReadArguments("BLE") = [0,1,2,3,4,5,6]
		|validReadArguments("BGR") = [0,1,2,3,4,5,6]
		|validReadArguments("JSR") = [0,1,2,3,4,5,6]
		|validReadArguments("RET") = []
		
		|validReadArguments("HLT") = []
		|validReadArguments("SEM") = []
		|validReadArguments("POP") = []
		|validReadArguments(_) = raise RESOLVE "Tried to parse an malformed expression\n"


		fun validWriteArguments("NOP") = []
		|validWriteArguments("MOV") = [0,10,20,30,40,50,60,70]
		
		|validWriteArguments("INC") = [0,10]
		|validWriteArguments("DEC") = [0,10]
		|validWriteArguments("ADD") = [0,10,20,30,40,50,80]
		|validWriteArguments("SUB") = [0,10,20,30,40,50,80]
		|validWriteArguments("MUL") = [0,10,20,30,40,50,80]
		|validWriteArguments("DIV") = [0,10,20,30,40,50,80]
		|validWriteArguments("MOD") = [0,10,20,30,40,50,80]
		
		|validWriteArguments("EQL") = [0,10,20,30,40,50,80]
		|validWriteArguments("LES") = [0,10,20,30,40,50,80]
		|validWriteArguments("GRT") = [0,10,20,30,40,50,80]
		|validWriteArguments("BRL") = [0,10,20,30,40,50,80]
		|validWriteArguments("BRR") = [0,10,20,30,40,50,80]
		|validWriteArguments("AND") = [0,10,20,30,40,50,80]
		|validWriteArguments("ORR") = [0,10,20,30,40,50,80]
		|validWriteArguments("XOR") = [0,10,20,30,40,50,80]
		|validWriteArguments("NOT") = [0,10,20,30,40,50,80]
		
		|validWriteArguments("JMP") = [0,10,20,30,40,50,80]
		|validWriteArguments("BEQ") = [0,10,20,30,40,50,80]
		|validWriteArguments("BLE") = [0,10,20,30,40,50,80]
		|validWriteArguments("BGR") = [0,10,20,30,40,50,80]
		|validWriteArguments("JSR") = [0,10,20,30,40,50,80]
		|validWriteArguments("RET") = []
		
		|validWriteArguments("HLT") = []
		|validWriteArguments("SEM") = []
		|validWriteArguments("POP") = []
		|validWriteArguments(_) = raise RESOLVE "Tried to parse an malformed expression\n"
		
		local
			fun find([],a) = false
			|find(x::xs,a) = (a = x) orelse find(xs,a)
		in
			fun isValidRead(m,a) = find(validReadArguments(m),a)
			fun isValidWrite(m,a) = find(validWriteArguments(m),a)
		end

end
(*
val lame_test = Resolve.resolveExpression(StringUtills.spaceSplit("NOP"));
val lame_test = Resolve.resolveExpression(StringUtills.spaceSplit("MOV x [y]"));
val lame_test = Resolve.resolveExpression(StringUtills.spaceSplit("INC x"));
val lame_test = Resolve.resolveExpression(StringUtills.spaceSplit("BEQ s @bob"));
hmmmmmmmm .....*)
