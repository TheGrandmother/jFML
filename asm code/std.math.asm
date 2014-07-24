! std.math.max_int = 2147483647

#std.math.INIT

JMP std.math.ESCAPE




// multiplicand is on top
// dividend
// divisor
#std.math.frac

HLT
!std.math.Sin.max_value = 255
#std.math.Sin
	@arg
	MOV s $arg
	LES $arg 0
	JOO std.math.Sin.less_than_zero
		MOD $arg 360
		MOV s $arg
		JMP std.math.Sin.resolve

	#std.math.Sin.less_than_zero
		MUL $arg -1
		MOD s 360
		SUB 360 s
		MOV s $arg


	#std.math.Sin.resolve
	 SGR $arg 90
	 JMP std.math.Sin.0to90
	 SGR $arg 180
	 JMP std.math.Sin.90to180
	 SGR $arg 270
	 JMP std.math.Sin.180to270
	 JMP std.math.Sin.270to360

	#std.math.Sin.0to90
		ADD std.math.sin_table $arg
		MOV $s s
		RET
	#std.math.Sin.90to180
		SUB 180 $arg
		ADD s std.math.sin_table
		MOV $s s
		RET
	#std.math.Sin.180to270
		SUB $arg 180
		ADD s std.math.sin_table
		MOV $s s
		MUL s -1
		RET
	#std.math.Sin.270to360
		SUB 360 $arg
		ADD s std.math.sin_table
		MOV $s s
		MUL s -1
		RET




	//Lets
	RET
HLT

//n mod m
//n
//m
	#std.math.UnsignedMod
	@std.math.UnsignedMod.n
	@std.math.UnsignedMod.m
	MOV s $std.math.UnsignedMod.n
	MOV s $std.math.UnsignedMod.m
	LES $std.math.UnsignedMod.n 0
	JOO std.math.UnsignedMod.less
		MOD $std.math.UnsignedMod.n $std.math.UnsignedMod.m
		RET
	#std.math.UnsignedMod.less
		MOD $std.math.UnsignedMod.n $std.math.UnsignedMod.m
		SUB $std.math.UnsignedMod.m s
		RET







#std.math.sin_table
< sin.mem
#std.math.sin_table_end
NOP
#std.math.ESCAPE

