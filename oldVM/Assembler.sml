(* PKD 2014 group 27
	Henrik Sommerland, Oskar Ahlberg, Aleksander Lundquist
*)


(*
	This is the code for the assembler.
	I know its not the prettiest one.
	I have found some inconsistent use of the word "token" in this code.
	So one should read trough it carefully. A token is not neccesarily a
	object of the token type. I should have paid more carfull attention to
	this when i first wrote the code.
*)

(*This ugly but it was the only workaround to 
	read files from different directories*)
val current_dir = OS.FileSys.getDir();
OS.FileSys.chDir("Utills");
use "OpcodeResolve.sml"; (*allso imports StringUtills.sml*)
use "IO.sml";
OS.FileSys.chDir(current_dir);

structure Assembler = 
struct

(*
	REPRESENTATION CONVENTION:
		Label is a lebel pointer
		Value is a value pointer
		NULL is no pointer.
	REPRESENTATION INVARIANT:
		If any of the int options are SOME(int) the pointer will have been resolved.
*)
	datatype pointer = Label of (string * (int option)) | Value of (string * (int option)) | NULL;
	
	(* 
	REPRESENTATION CONVENTION: 
		Ic is a token representing an instruction code.
		Arg is a token representing an arbitrary data.
		Ref is a token reffering to a pointer
	REPRESENTATION INVARIANT:  
		Ic is always a valid instruction in accordance with the VM specifications
		Ref is alway a pointer wich is declared somwhere within the file.
	*)
	datatype token = Ic of int | Ref of string | Arg of int;
	
	exception SYNTAX of string
	exception ASSEMBLER of string
	
	(*
		The SML plugin for eclipse bitches about some #"" things.
		and yes i know its ugly
		*)
	val comment_flag = 37 (* Char.ord(#"%")*)
	val label_flag = 35 (*Char.ord(#"#")*)
	val value_flag = 64 (*Char.ord(#"@")*)
	val address_flag = 36 (*Char.ord(#"$")*) 
	val data_flag = 58 (*Char.ord(#":")*) 
	val base_adress = 0
	
	(* getTokenName token
		TYPE: token -> string
		PRE: 	None
		POST:	Returns the name of the pointer if the token is a reference
					raises a ASSEMBLER exception otherwise.
	*)
	fun getTokenName(Ref(name)) = name
	|getTokenName(_) = raise ASSEMBLER "Token is not a Reference"
	
	(* getTokenType token
		TYPE: token -> string
		PRE: 	None
		POST: Returns a string corresponding to the type of token
	*)
	fun getTokenType(Ref(_)) = "Pointer"
	|getTokenType(Arg(_)) = "Argument"
	|getTokenType(Ic(_)) = "Instruction"
	
	(* getTokenValue  token
		TYPE:	token -> int
		PRE: 	None
		POST:	Returns the value of the token if it is a token of argument type or instruction
					raises a ASSEMBLER exception otherwise
	*)
	fun getTokenValue(Arg(a)) = a
	|getTokenValue(Ic(a)) = a
	|getTokenValue(_) = raise ASSEMBLER "Cant get value from a refference"
	
	(* getPointerName pointer
		TYPE:	pointer -> string
		PRE:	None
		POST:	Returns the name of the pointer. 
					Raises an ASSEMBLER exception if pointer is a NULL pointer 
	*)
	fun getPointerName(Label(name,_)) = name
	|getPointerName(Value(name,_)) = name
	|getPointerName(NULL) = raise ASSEMBLER "Got NULL?\n"
	
	(* getPointerAddress pointer
		TYPE:	pointer -> int
		PRE:	None
		POST:	Returns the address of the token. Will rasie a OPTION exception if address is NONE.
					Will raise a ASSEMBLER exception if pointer is NULL
	*)
	fun getPointerAddress(Label(_,a)) = Option.valOf(a)
	|getPointerAddress(Value(_,a)) = Option.valOf(a)
	|getPointerAddress(_) = raise ASSEMBLER "Got NULL?\n"
	
	 
	(* setPointerAddress(pointer, address)
		TYPE: pointer * int -> pointer
		PRE:	NONE
		POST:	Will set the address of pointer to the address given as a argument.
					Will raise an ASSEMBLER if pointer is NULL.
	*)
	fun setPointerAddress(Label(name,_),a) = Label(name,SOME(a))
	|setPointerAddress(Value(name,_),a) = Value(name,SOME(a))
	|setPointerAddress(NULL,a) = raise ASSEMBLER "Got NULL?\n"
	
		(*
			Yes i know that this is ugly but life sucks without side-effects.
			
			The Intermediate structure gets built up in the wrong order. The first lines will end upp on the bottom of the lists.
			This is not the worst thing in the world. One just has to take it into account.
			
			The entries in label_list and value_list are in the same order (but reversed) as they appeared in the file.
		*)
		structure Inter =
		struct
			
			(* 
				REPRESENTATION CONVENTION: 
					I(label_list,value_list,token_list,currennt_label,address).
					label_list is a list of label pointers
					value_list is a list of value pointers
					token_list is a list of (pointer_name,offsett,token) tuples
					current_label is the last label declaration wich the assembler found or it is NULL before any
						label declaration have been made
					address is the current rellative adress.
   			REPRESENTATION INVARIANT:  
					current_label is the last label declaration wich the assembler found or NULL if no declaration has been found.
					Address is always greater or equal to zero.
					No two (pointer_name,offsett,token) ahve the same pointer_name and offsett
 			*)
			datatype inter = I of ((pointer list) * (pointer list) * ((string*int*token) list) * pointer * int)
			
			
			val initial = I([],[],[],NULL,0)
			
			(* getLabelList intermediate_structure
				TYPE: Inter.inter -> pointer list
				PRE: 	NONE
				POST:	Returns the label_list from the intermediate_structure
			*)
			fun getLabelList(I(label_list,value_list,token_list,current_label,address)) = label_list
			
			(* getValueList intermediate_structure
				TYPE: Inter.inter -> pointer list
				PRE: 	NONE
				POST:	Returns the value_list from the intermediate_structure
			*)
			fun getValueList(I(label_list,value_list,token_list,current_label,address)) = value_list
			
			(* getLabelList intermediate_structure
				TYPE: Inter.inter -> (string * int * token) list
				PRE: 	NONE
				POST:	Returns the token_list from the intermediate_structure
			*)
			fun getTokenList(I(label_list,value_list,token_list,current_label,address)) = token_list
			
			(* getCurrentLabel intermediate_structure
				TYPE: Inter.inter -> pointer
				PRE: 	NONE
				POST:	Returns the current_label from the intermediate_structure
			*)
			fun getCurrentLabel(I(label_list,value_list,token_list,current_label,address)) = current_label


			(* setCurrentLabel(intermediate_structure,new_label)
				TYPE: (Inter.inter * pointer) -> Inter.inter
				PRE:	None
				POST:	Returns a new intermediate_structure with its current_label changed to new_label
			*)
			fun setCurrentLabel(I(label_list,value_list,token_list,current_label,address), a) = I(label_list,value_list,token_list,a,address)

			(* addLabel (intermediate_structure,label)
				TYPE: (Inter.inter * pointer ) -> Inter.inter
				PRE: 	None
				POST: prepends label to the label_list of the intermediate_structure
			*)
			fun addLabel(I(label_list,value_list,token_list,current_label,address), a) =I(a::label_list,value_list,token_list,current_label,address)
			
			(* addLabel (intermediate_structure,value)
				TYPE: (Inter.inter * pointer ) -> Inter.inter
				PRE: 	None
				POST: prepends value to the value_list of the intermediate_structure
			*)
			fun addValue(I(label_list,value_list,token_list,current_label,address), a) =I(label_list,a::value_list,token_list,current_label,address)
			
			(* addToken (intermediate_structure, token)
				TYPE: (Inter.inter * token ) -> Inter.inter 
				PRE: 	None
				POST:	Adds the token to the token_list of intermediate_structure. 
							Increments the address and allso set the offsett of the the 
							entry to the token list depinding on weather or not we have encountered a new token.
							Raises a a SYNTAX error if current_label is NULL.
			*)
			fun addToken(I(label_list,value_list,token_list,NULL,address), a) = raise SYNTAX "Cant use NULL pointer\n"
			|addToken(I(label_list,value_list,[],Label(current_pointer_name,i),address), a) = (*When list is empty*)
				I(label_list,value_list, [(current_pointer_name,0,a)], Label(current_pointer_name,i),address+1)
			|addToken(I(label_list,value_list,(pointer_name,n,t) :: rest,Label(current_pointer_name,i),address), a) =
				if current_pointer_name <> pointer_name then
					I(label_list,value_list, (current_pointer_name,0,a) :: ((pointer_name,n,t) :: rest), Label(current_pointer_name,i),address+1) (*if we change pointer*)
				else
					I(label_list,value_list, ((pointer_name,n+1,a) :: ((pointer_name,n,t) :: rest)), Label(current_pointer_name,i),address+1)
			|addToken(_,_) = raise ASSEMBLER "Something went horribly wrong :(" (*This is just a catch all clause. Should never happen.*)
			
			(* getTokenPointer intermediate_structure
				TYPE: Inter.inter -> string
				PRE:	NONE
				POST:	Gets the name of the (name,offsett,token) tupen at the head of the token_list.
							Will raise an ASSEMBLER exception if the token_list is empty.
			*)
			fun getTokenPointer(I(label_list,value_list,(name,offs,tok) :: token_list ,current_label,address)) = name
			|getTokenPointer(I(label_list,value_list,[],current_label,address)) = raise ASSEMBLER "Tried to get name from empty token list"
			
			(* dumpPointerList pointer_list
				TYPE: pointer list -> unit
				PRE:	None
				POST:	Prints the pointer_list in a nicely formatted way.
				INVARIANT: Length of the pointer_list
			*)
			fun dumpPointerList([]) = ()
			|dumpPointerList(pointer :: rest) = 
			let
				val address = Int.toString(getPointerAddress(pointer)) handle Option.Option => "NONE"
			in
				(print ("(" ^ getPointerName(pointer) ^ "," ^ address ^ ")\n"); dumpPointerList(rest))
			end
			
			(* dumpTokenList intermediate_structure
				TYPE:	Inter.inter -> unit
				PRE:	None
				POST:	Prints the token_list of the intermediate_structure in a nicely formatted fashion.
				INVARIANT: Length of the pointer_list
			*)
			fun dumpTokenList(i) = 
				let
					val token_list = List.rev(getTokenList(i))
					
					(* makePretty s
						TYPE: string -> string
						PRE:	None
						POST:	Padds the string with zeroes on the left to make it length 6 or more.
					*)
					fun makePretty(s) = 
						case String.size(s) of
						1 => "00000"^s
						|2 => "0000"^s
						|3 => "000"^s
						|4 => "00"^s
						|5 => "0"^s
						|_ => s
					
					(* printPretty s
						TYPE: (string * int * token) list -> unit
						PRE:	NONE
						POST:	Print a list of (name,offset,token) elements in a nicely formatted way.
					*)
					fun printPretty ([]) = ()
					|printPretty((p,n,Ic(i))::xs) = (print (p ^"+"^ Int.toString(n)^": "^ makePretty(Int.toString(i))  ^"\n"); printPretty(xs))
					|printPretty((p,n,Ref(s))::xs) = (print (p ^"+"^ Int.toString(n)^": "^ s  ^"\n"); printPretty(xs))
					|printPretty((p,n,Arg(i))::xs) = (print (p ^"+"^ Int.toString(n)^": "^ makePretty(Int.toString(i))  ^"\n"); printPretty(xs)) 
				in
					printPretty(token_list)
				end
		end
	
	val initial = Inter.initial
	
	
	(* dumpTokenList intermediate_structure
		TYPE:	Inter.inter -> unit
		PRE:	None
		POST:	Prints the token_list of the intermediate_structure in a nicely formatted fashion.
	*)
	fun dumpTokenList(i) = Inter.dumpTokenList(i)
	(*error (line_number, message,cause)
		TYPE: int * string * string -> unit
		PRE:	None
		POST:	Prints a nicely formatted error message giving information about at what line
					the error occured, a message regarding the type of the error and what caused the error.	
	*)
	fun error(line_number,message,cause) = "\nSYNTAX ERROR!\n" ^ message ^ " at line: " ^ Int.toString(line_number) ^ "\n"
				^ "Caused by: "  ^ cause ^"\n"

	(* scanLine (line, intermediate_structure,line_lumber)
		TYPE: string * Inter.inter * int -> Inter.inter
		PRE: None
		POST:	Scans one line and resolves it into a token and adds it to the token_list of the intermediate_structure.
					Allso handles value and label declarations and modifys the intermediate_structure.
					Increments the line_number accordingly for debuging purposes.
					Raises SYNTAX or ASSEMBLER if the line is malformed or invalid.
	*)
	fun scanLine(line, i, l)  =
		let
			val line = StringUtills.trim(line)
			val line_head = 
				if String.explode(line) <> [] then
					Char.ord(List.hd(String.explode(line)))
				else
					comment_flag
			val line_tail = 
				if line <> "" then
					String.implode(List.tl(String.explode(line)))
				else
					""
					
			(* resolveToken string
				TYPE: string -> pointer option
				POST: Converts a string into a token. This only works on non register arguments. Returns
							NONE if the string is registry type argument.
							raises a SYNTAX exception if the argument is mallformed.
			*)
			fun resolveToken("x") = NONE
			|resolveToken("y") = NONE
			|resolveToken("s") = NONE
			|resolveToken("$x") = NONE
			|resolveToken("$y") = NONE
			|resolveToken("q1") = NONE
			|resolveToken("q2") = NONE
			|resolveToken(a) =
				let
					val char_list = String.explode(a)
					val assert_length = 
						if Char.ord(List.hd(char_list)) = address_flag then
							(List.length(char_list) >= 2) orelse (print (error(l,"Mallformed argument",line));raise SYNTAX "")
						else
							(List.length(char_list) >= 1) orelse (print (error(l,"Mallformed argument",line));raise SYNTAX "")
				in
					if (List.hd(char_list) = #"-") orelse (List.all (fn x => Char.isDigit(x)) char_list)  then
							SOME(Arg(Option.valOf(Int.fromString(a))))
					else 
						if Char.ord(List.hd(char_list)) = address_flag then
							if (List.all (fn x => Char.isDigit(x)) (List.tl(char_list)))  then
								SOME(Arg(Option.valOf(Int.fromString( String.implode(List.tl(char_list)) ))))
							else
								SOME(Ref(String.implode(List.tl(char_list))))
						else
							SOME(Ref(String.implode(char_list)))
				end

		in
		(
			case line_head of
				37 => i	(*Line is a comment*)
				|35 => (*Line is a label*)(
					let
						val assert_length = (StringUtills.words(line_tail) = 1) orelse (print (error(l,"Mallformed label assignemnt",line));raise SYNTAX "")
					in
						Inter.setCurrentLabel(Inter.addLabel(i,Label(line_tail,NONE)),Label(line_tail,NONE))
					end
					
				)
				|64 => (*Line is a value*)(
					let
						val assert_length = (StringUtills.words(line_tail) = 1) orelse (print (error(l,"Mallformed value assignment",line));raise SYNTAX "")
					in
						Inter.addValue(i,Value(line_tail,NONE))
					end
				)
				
				|58 => (*Line is data*)(
					let
						val assert_length = (StringUtills.words(line_tail) = 1) orelse (print (error(l,"Mallformed value assignment",line));raise SYNTAX "")
						val data = Int.fromString(line_tail)
					in
						case data of
						SOME(n) => Inter.addToken(i,Arg(n))
						|NONE => (print (error(l,"Data is not an integer",line));raise SYNTAX "")
					end
				)
				|_ =>  (*Line is magic*)(
					let
						(*<operation> <write> <read>*)
						val expression = StringUtills.spaceSplit(line)
						val number_of_args = Resolve.numberOfArgs(List.hd(expression))
						val assert_length = (number_of_args = (List.length(expression)-1)) orelse (print (error(l,"To many arguments",line));raise SYNTAX "")

					in
						case expression of
						(*NO ARGUMENT*)
						[m] => 
							Inter.addToken(i,Ic(Resolve.mnemonic(m)))
						(*SINGLE ARGUMENT*)
						|[m,w] => 
							let
								val assert_argument = Resolve.isValidWrite(m,Resolve.write(w)) orelse  (print (error(l,"Forbidden write argument",line));raise SYNTAX "")
								val assert_no_s = (w <> "$s") orelse  (print (error(l,"Can't use stack as pointer",line));raise SYNTAX "")
								val instruction = Inter.addToken(i,Ic(Resolve.mnemonic(m) + Resolve.write(w)))
								
							in
								if resolveToken(w) = NONE then
									instruction
								else
									Inter.addToken(instruction,Option.valOf(resolveToken(w)))
							end
						(*TWO ARGUMENTS*)
						|[m,r,w] => 
							let
								val assert_argument_write = Resolve.isValidWrite(m,Resolve.write(w)) orelse 
										(print (error(l,"First argument is forbidden",line));raise SYNTAX "")
										
								val assert_argument_read = Resolve.isValidRead(m,Resolve.read(r)) orelse  
										(print (error(l,"Second argument is forbidden",line));raise SYNTAX "")
										
								val assert_no_s = ((w <> "$s") andalso (r <> "$s")) orelse  
										(print (error(l,"Can't use stack as pointer",line));raise SYNTAX "")
										
								val instruction = Inter.addToken(i,Ic(Resolve.mnemonic(m) + Resolve.write(w)+Resolve.read(r)))
								
							in
									case (resolveToken(w),resolveToken(r)) of
									(SOME(a),NONE) => Inter.addToken(instruction,Option.valOf(resolveToken(w)))
									|(NONE,SOME(a)) => Inter.addToken(instruction,Option.valOf(resolveToken(r)))
									|(NONE,NONE) => instruction
									|(_,_) => (print (error(l,"Cant use two non register arguments",line));raise SYNTAX "")
									
							end
						|_ => raise ASSEMBLER "This hould not have happened....." (*Catch all clause*)
					end
				)
		)
		end
	
	(* scanList (line_list,intermediate_structure,line_number)
		TYPE: string list * Inter.inter * int -> Inter.inter
		PRE: 	none
		POST:	Converts a list of strings into an intermediate structure.
		INVARIANT:	Length of line_list
	*)
	fun scanList([],i,n) = i
	|scanList(x::xs,i,n) =scanList(xs,scanLine(x,i,n),n+1)
	handle Resolve.RESOLVE msg => (print (error(n,msg,x));raise ASSEMBLER "";i)
	
	(* duplicateSearch intermediate_structure
		TYPE: Inter.inter -> unit
		PRE:	None
		POST:	Asserts that there are no duplicate references.
					Returns unit if all is well
					Raises an ASSEMBLER exception otherwise.
		INVARIANT: length of label_list and value_list
	*)

	fun duplicateSearch(i) =
		let
			val concattenation = (List.map (fn x => getPointerName(x)) (Inter.getLabelList(i))) @ (List.map getPointerName (Inter.getValueList(i)))

			(* count (a,l)
				TYPE: (a'' * a'' list)
				PRE:	None
				POST:	counts the number of times a appears in l
				INVARIANT: Length of l
			*)
			fun count(a,[]) = 0
			|count(a,x::xs) = 
				if a  = x then
					1 + count(a,xs)
				else
					count(a,xs)
			
			(* detectPointerCollision pointer_list
				TYPE: pointer list -> ()  
				PRE: 	None
				POST:	Asserts that there are no duplicate references.
							Returns unit if all is well
							Raises an ASSEMBLER exception otherwise.
				INVARIANT: length of pointer_list
			*)
			fun detectPointerCollision([]) = ()
			|detectPointerCollision(pointer :: rest) =
				if count(pointer,concattenation) = 1 then
					detectPointerCollision(rest)
				else
					raise ASSEMBLER (pointer ^ " is not unique")
					
		in
			detectPointerCollision(concattenation)
		end
	
	(* resolveAddresses(intermediate_structure,base_address)
		TYPE: Inter.inter * a' -> (int * token) list
		PRE:	None
		POST:	Resolves all of the labels and values in the intermediate structure.
					The first label wil be at base_address. 
	*)
	fun resolveAddresses(i,base_address) =
		let
			
			val token_list = List.rev(Inter.getTokenList(i))
			val value_list = List.rev(Inter.getValueList(i))
			val label_list = List.rev(Inter.getLabelList(i))
			
			(* resolveLabels(label_list,token_list,current_label,current_address)
				TYPE: pointer_list *  (string * int * token) * pointer * int -> pointer list
				PRE:	Current label should be NULL at the start, current_address should be the base_address at start.
				POST:	Returns a list of all the labels in the label_list with all their addresses resolved.
							Raises a ASSEMBLER exception if there are unresolved addresses when the funtion terminates.
				INVARIANT: Length of label_list.
			*)
			fun resolveLabels([],[],current_label,current_adress) = []
			|resolveLabels(label_list,[],current_label,current_adress) = []
			|resolveLabels(label_list as (label :: rest_label),token_list as ((token as (name,offs,tok)) :: rest_token),NULL,current_adress) = 
				setPointerAddress(label,current_adress) :: resolveLabels(rest_label,rest_token,label,current_adress+1)
			|resolveLabels([],token_list as ((token as (name,offs,tok)) :: rest_token),current_label,current_adress) =
				if getPointerName(current_label) = name then
						resolveLabels(label_list,rest_token,current_label,current_adress+1)
					else 
						raise ASSEMBLER ("Found uninitialized label " ^ name) 
			|resolveLabels(label_list as (label :: rest_label),token_list as ((token as (name,offs,tok)) :: rest_token),current_label,current_adress) =
				if getPointerName(current_label)  =  name then
					resolveLabels(label_list,rest_token,current_label,current_adress+1)
				else 
					setPointerAddress(label,current_adress) :: resolveLabels(rest_label,rest_token,label,current_adress+1)
						
			val resolved_labels = resolveLabels(label_list,token_list,NULL,base_adress)

			(* firstPass(resolved_labels,token_list)
				TYPE: pointer list * (string * int * token) list -> (int * token) list  
				PRE: 	None
				POST:	Returns a list of (address,token) tupels 
				INVARIANT: Length of resolved_labels.
			*)
			fun firstPass(resolved_labels,[]) =[]
			|firstPass(resolved_labels,((label_name,offs,Ref(name)) :: token_rest)) = 
				(*This is the case where the token is a ponter*)
				let
					val label_address = getPointerAddress(Option.valOf(List.find (fn x => (label_name = getPointerName(x))) resolved_labels))
					val arg_address = (List.find (fn x => (name = getPointerName(x))) resolved_labels)
					handle Option => raise ASSEMBLER ("Couldnt find label: " ^ label_name ^ " or " ^ name)
				in
					case arg_address of (*check if pointer has been resolved.*)
					NONE => (label_address+offs,Ref(name)) :: firstPass(resolved_labels,token_rest)
					|SOME(a) => (label_address+offs,Ic(getPointerAddress(a))) :: firstPass(resolved_labels,token_rest) 
				end
			|firstPass(resolved_labels,((label_name,offs,a) :: token_rest)) = 
				let
					val label_address = getPointerAddress(Option.valOf(List.find (fn x => (label_name = getPointerName(x))) resolved_labels))
					handle Option => raise ASSEMBLER ("Couldnt find label: " ^ label_name)
				in
					(label_address+offs, a : token) :: firstPass(resolved_labels,token_rest) 
				end
			
			val pass1 = firstPass(resolved_labels,token_list)
			
			(* Without the +1 the values would lie within the program.*)
			val max_address = #1(List.last(pass1)) + 1
			
			(* resolveValues(value_list,address)
				TYPE: pointer list * int -> pointer list
				PRE:	Base address must lie after the last instruction
				POST:	Returns a list of all the values with their addresses resolved.
				INVARIANT: Length of value_list
			*)
			fun resolveValues([],address) = []
			|resolveValues(value :: rest,address) =
			setPointerAddress(value,address) :: resolveValues(rest,address+1)
			
			val resolved_values = resolveValues(value_list,max_address)
			
			(* secondPass (resolved_values,token_list)
				TYPE: (pointer list  * (int * token) list ) -> (int * token) list
				PRE:	None
				POST:	Returns a list where all tokens of reference types have been replaced with
							have been replaced with a token of argument type with the correct address as the argument.
							Will raise ASSEMBLER if a unresolved pointer is encoutered
				INVARIANT:
			*)
			fun secondPass(resolved_values,[]) = []
			|secondPass(resolved_values,(addr,Ref(name)) :: rest) =
				let
					val value_address = getPointerAddress(Option.valOf(List.find (fn x => (name = getPointerName(x))) resolved_values))
					handle Option => raise ASSEMBLER ("Couldnt find value " ^ name)
				in
					(addr,Arg(value_address)) :: secondPass(resolved_values,rest)
				end
			|secondPass(resolved_values,(addr,t) :: rest) =
				(addr,t) :: secondPass(resolved_values,rest)
			
			val pass2 = secondPass(resolved_values,pass1)

		in
			pass2
		end
	
	(* finalize token_list
		TYPE: (int * token) list -> int list
		PRE:	None
		POST:	Returns a list off integers with the first element being the starting address of the program and all consecutive
					elements are the numerical values corresponding to the instructions and arguments given by the values of the token_list.
					Will raise an ASSEMBLER exception if it finds unresolved pointers.
		INVARIANT:Length of token list
	*)
	fun finalize(token_list) = 
		let
			val start_address = #1(List.hd(token_list))
			fun finalize'([]) = []
			|finalize'((_,Ref(_)) ::rest) = raise ASSEMBLER "Not all refferences where resolved"
			|finalize'((_,tok) ::rest) = getTokenValue(tok) :: finalize'(rest)
		in
			start_address :: finalize'(token_list)
		end
	
	(* assemble(input_file,output_file,base_address,verbose)
		TYPE:	string * string * 'a * bool -> unit
		PRE:	base_address must be >= 0
		POST:	Reads a assembly file, assembles that and prints the
					assembled code to  output_file.
					The base_address will be the starting adress of the program.
					If verbose is true the assembler will produce output about what its doing.
		SIDE-EFFECTS: Reads and writes to files.
	*)
	fun assemble(input_file,output_file,base_address,verbose)=
		let
			fun msg(true,m) = print(m)
			|msg(false,_) = ()
		
			(*read input*)
			val input_list = IO_Handler.fileToLineList(input_file)
			val verb = msg(verbose,"Read input file.\n")
			
			(*do tokenization*)
			val intermediate_state = scanList(input_list,initial,1);
			val verb = msg(verbose,"Lexical analysis completed.\n")
			val duplicates = duplicateSearch(intermediate_state)  
			(*handle ASSEMBLER msg => (Inter.dumpPointerList(Inter.getLabelList(intermediate_state) @ Inter.getValueList(intermediate_state));raise ASSEMBLER "")*)
				
			(*resolve adresses*)
			val resolved_code = resolveAddresses(intermediate_state,base_address)
			val verb = msg(verbose,"Resloved addresses like a boss.\n")
			
			(*finalize*)
			val finalized_code = finalize(resolved_code)
			val verb = msg(verbose,"finalized code!.\n")
			
		in
			(*output*)
			IO_Handler.writeIntListFile(output_file,finalized_code)
		end
end;

Assembler.assemble("in.asm","out.fml",0,true);