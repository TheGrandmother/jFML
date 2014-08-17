//This is a halfdone library of standard functions.

< std.constants.asm

@std.Random.current
!std.Random.modulo = 0x7FFFFFFF
!std.Random.multiplier = 0x7FFFFFED
!std.Random.increment = 0x7FFFFFC3
#std.INIT
MOV x y
MOV 0xBEEF y
MOV $std.timer_address s
ADD s 1591
MOV s $std.Random.current
JMP std.ESCAPE


//Time to wait in milliseconds is on stack
#std.WaitMilli
MOV $std.timer_address y
MOV s x
	#std.WaitMilli.loop
	SUB $std.timer_address y
	GRT s x
	SEQ s 1
	JMP std.WaitMilli.loop
	RET


#std.Random
	//ADD $std.timer_address $std.Random.current

	MUL $std.Random.current std.Random.multiplier
	ADD s std.Random.increment
	MOD s std.Random.modulo
	MOV s $std.Random.current
	MOV $std.Random.current s
	RET
HLT

//This random function generates random numbers which are
//equally distributed in a 2D space... and maybe higher dimension
#std.SafeRandom
	JSR std.Random
	DIV s 2
	JSR std.Random
	DIV s 2
	ADD s s
	MOD s std.Random.modulo

	RET

#std.random.SetSeed
MOV s $std.Random.current
RET
HLT

#std.Abs
	MOV s x
	MOV x s
	SGR x 0
		MUL s -1
	RET



#std.ESCAPE
