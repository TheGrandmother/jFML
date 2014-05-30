(* PKD 2014 group 27
	Henrik Sommerland, Oskar Ahlberg, Aleksander Lundquist
*)

use "StringUtills.sml";
(*
	Lets use this file for IO handling!
*)

structure IO_Handler =
struct
	exception IO_HANDLING of string
	
	(*
		Reads a file and otputs a list of all its lines with the "\n" removed
		
		Arguments:
			file =	The filepath to the file to be read.
	*)
	fun fileToLineList(file) = 
		let
			val instream = TextIO.openIn file
			
			fun fileToList(ins) =
				case TextIO.inputLine(ins) of
				SOME(a) => (StringUtills.removeNewLine(a) :: fileToList(ins))
				|NONE => (TextIO.closeIn(ins);[]);
		in
			fileToList(instream)
		end
		
	(*
		Reads a file consisting only of lines containing a single integer and creates a list of those integers.
		Dissregards empty  lines.
		it will trow an exception and crash if a line not containing only a single integer or a line containg
		some mumbojumo is found.
		
		Arguments:
			file =	The filepath to the file to be read.
	*)
		fun fileToIntList(file) = 
		let
			
			val instream = TextIO.openIn file;
			fun fileToList(ins) =
				case TextIO.inputLine(ins) of
				SOME(a) => (
					if a <> "" then
						case Int.fromString(StringUtills.trim(StringUtills.removeNewLine(a))) of
						SOME(i) => i :: fileToList(ins)
						|NONE => raise IO_HANDLING "Non integer entry was found"
					else
						fileToList(ins)
					)
				|NONE => (TextIO.closeIn(ins);[])
		in
			fileToList(instream)
		end
		
		(*
			Creates a int list file.
		*)
		fun writeIntListFile(file_name,int_list) =
			let
				val outstream = TextIO.openOut file_name
				fun writeIntList([]) = TextIO.closeOut(outstream)
				|writeIntList(l::ls) = (TextIO.output(outstream,Int.toString(l) ^ "\n"); writeIntList(ls))
			in
			(
				writeIntList(int_list)
			)
			end;

end