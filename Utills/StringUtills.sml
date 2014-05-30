(* PKD 2014 group 27
	Henrik Sommerland, Oskar Ahlberg, Aleksander Lundquist
*)

structure StringUtills =
struct
	exception SYNTAX of string
	
	
	val space = 32 (*Char.ord(#" ")*)
	
	
	(* flatten l
		TYPE: 'a list list -> 'a list
		PRE: 	None
		POST: Flattens l
		EXAMPLE:	flatten[[1,2],[3,4]] = [1,2,3,4]
		VARIANT:	Length of l
	*)
	fun flatten l =
	let
		fun flatten' ([],[],A) = List.rev(A)
			|flatten' (x::xs,[],A) = flatten'(xs,x,A)
			|flatten' (x,y::ys,A) = flatten'(x,ys,y::A)
	in
		flatten'(l,[],[])
	end 
	
	(* spaceSplit s
		TYPE: string -> string list
		PRE:	None
		POST:	Splits s into substrings at every s
		EXAMPLE: spaceSplit("lol fail") = ["lol","fail"]
	*)
	fun spaceSplit("") = []
	|spaceSplit(s) = 
		let
			(* split (l,A1,A2)
				TYPE: char list * char list * string list -> string list
				PRE:	A1 and A2 should be [] at start
				POST: Splits s into substrings at every s. A1 and A2 are accumulators.
			*)
			fun split([],A1,A2) = List.rev(String.implode(List.rev(A1)) :: A2)
			|split(x::xs,A1,A2)  =
				if (Char.ord(x) = 32) then
					split(xs,[],String.implode(List.rev(A1)) :: A2)
				else
					split(xs,x::A1,A2)
		in
			List.filter (fn x => x <> "") (split(String.explode(s),[],[]))
		end
	
	(* trim s
		TYPE: string -> string
		PRE: None
		POST: Removes all leading and trailing spaces. 
					Replaces all runns of white spaces with a single space
		EXAMPLE: trim "   lol   fail   " =  "lol fail"
	*)
	fun trim("") = ""
	|trim(s) = 
		let
			(* trim' (c, A1,A2, i)
				TYPE: (char list * char list * char list, int) -> char list list
				PRE:	i should be 1 and A1,A2 should be nil.
				POST:	Partitions a char list into sublists containing at most one #" ".
							A1,A2 and i are there just as accumulators and keep track of weather
							or not its in a run of white space characters.
				VARIANT:	Length of c
			*)
			fun trim'([],A1,A2,1) = List.rev(A2)
			|trim'([],A1,A2,0) = List.rev(List.rev(A1)::A2)
			|trim'(x :: xs,A1,A2,0) =
				if Char.ord(x) = space then
					trim'(xs,x::[],List.rev(A1)::A2,1)
				else
					trim'(xs,x::A1,A2,0)
			|trim'(x :: xs,A1,A2,1) =
				if Char.ord(x) = space then
					trim'(xs,A1,A2,1)
				else
					trim'(xs,x::[],List.rev(A1)::A2,0)
			|trim'(_,_,_,_) = raise SYNTAX "Some thing odd happened \n" (*Catch all clause*)
		in
			String.implode(flatten(trim'(String.explode(s),[],[],1)))
		end
		
	(* words s
		TYPE: string -> int
		PRE:	None
		POST:	Conts the number of words in a string.
		Example: words("  lol  fail at   life  ") = 4
	*)
	fun words(s) = List.length(spaceSplit(trim(s)))
	
	(* removeNewLine s
		TYPE:	string -> string
		PRE: 	s should end with "\n"
		POST:	removes the last two characters in s
		NOTE:	This a mighty ugly hack. We just assume thet the string
					will end with \n. Wich it will when using the IO funtions.
	*)
	fun removeNewLine(s) = String.substring(s,0,String.size(s)-1)


end


