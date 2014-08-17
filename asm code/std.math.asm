! std.math.max_int = 2147483647
#std.math.INIT

JMP std.math.ESCAPE

!std.math.Sin.max_value = 255
//Returns Floor[Sin(s)*255] where s is in degrees
#std.math.Sin
	@std.math.Sin.tmp
	MOV s $std.math.Sin.tmp
	MOD $std.math.Sin.tmp 360
	SLE $std.math.Sin.tmp 0
		JMP std.math.Sin.resolve
	ADD 360 s
	#std.math.Sin.resolve
	ADD s std.math.sin_table
	MOV $s s
	RET

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

