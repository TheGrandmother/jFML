#graphics.INIT
MOV 0xBABE y
JSR graphics.UpdateAndWait
JMP graphics.ESCAPE
//HLT

#startpenis





HLT



//stack order is x0 y0 x1 y1
#graphics.DrawLine
	@graphics.DrawLine.x0
	@graphics.DrawLine.y0
	@graphics.DrawLine.x1
	@graphics.DrawLine.y1
	MOV s $graphics.DrawLine.x0
	MOV s $graphics.DrawLine.y0
	MOV s $graphics.DrawLine.x1
	MOV s $graphics.DrawLine.y1

	@graphics.DrawLine.dx
	@graphics.DrawLine.dy
	SUB $graphics.DrawLine.x1 $graphics.DrawLine.x0
	JSR std.Abs
	MOV s $graphics.DrawLine.dx

	SUB $graphics.DrawLine.y1 $graphics.DrawLine.y0
	JSR std.Abs
	MOV s $graphics.DrawLine.dy

	@graphics.DrawLine.sx
	LES $graphics.DrawLine.x0 $graphics.DrawLine.x1
	JOZ graphics.DrawLine.skip1
		MOV 1 $graphics.DrawLine.sx
		JMP graphics.DrawLine.skip2
		#graphics.DrawLine.skip1
		MOV -1 $graphics.DrawLine.sx
		#graphics.DrawLine.skip2

	@graphics.DrawLine.sy
	LES $graphics.DrawLine.y0 $graphics.DrawLine.y1
	JOZ graphics.DrawLine.skip3
		MOV 1 $graphics.DrawLine.sy
		JMP graphics.DrawLine.skip4
		#graphics.DrawLine.skip3
		MOV -1 $graphics.DrawLine.sy
		#graphics.DrawLine.skip4

	@graphics.DrawLine.err
	SUB $graphics.DrawLine.dx  $graphics.DrawLine.dy
	MOV s $graphics.DrawLine.err

	#graphics.DrawLine.loop
		MOV $graphics.DrawLine.y0 s
		MOV $graphics.DrawLine.x0 s
		JSR graphics.PutPixel


RET
HLT


#graphics.Update
	MOV 1 $std.screen.update_bit
	RET
HLT

//Color is on stack
//If color is greater than 0xFFF it will be set to 0xFFF
//IF color is less than 0x000 it will be set to 0x000
#graphics.SetColor
	MOV s x
	SLE x 0xFF
	MOV 0xFF $std.screen.color
	SGR x 0x00
	MOV 0x00 $std.screen.color
	MOV x $std.screen.color
	RET
HLT


//color is on top
//Only the used bitts are set the others are masked out
#graphics.SetRed
	MOV s x
	SLE x 0xF
	MOV 0xF x
	MOV x s
	SFT s 8
	AND s 0xF00
	MOV s x
	AND $std.screen.color 0x0FF
	OOR s x
	MOV s $std.screen.color
	RET
HLT

//color is on top
//Only the used bitts are set the others are masked out
#graphics.SetGreen
	MOV s x
	SLE x 0xF
	MOV 0xF x
	SFT s 4
	AND s 0x0F0
	MOV s x
	AND $std.screen.color 0xF0F
	OOR s x
	MOV s $std.screen.color
	RET
HLT
//color is on top
//Only the used bitts are set the others are masked out
#graphics.SetBlue
	MOV s x
	SLE x 0xF
	MOV 0xF x
	AND s 0x00F
	MOV s x
	AND $std.screen.color 0xFF0
	OOR s x
	MOV s $std.screen.color
	RET
HLT


#graphics.UpdateAndWait
	MOV 1 $std.screen.update_bit
	#graphics.UpdateAndWait.loop
	SEQ $std.screen.update_bit 0
	JMP graphics.UpdateAndWait.loop
	RET

#graphics.Clear
	MOV 0xC0FFE y
	@graphics.Clear.tmp
	mov std.screen.start x
	//mov 0 $std.screen.color
	#graphics.Clear.loop
		MOV 0 $x
		INC x
		SEQ x std.screen.end
		JMP graphics.Clear.loop
		RET


//X is on top. Y is on bottom
#graphics.PutPixel
	MOV s x
	MOV s y
	GRT x std.screen.width
	JOO graphics.PutPixel.x_out_of_bounds
	ADD x std.screen.start
	MOV s x
	GRT y std.screen.height
	JOO graphics.PutPixel.y_out_of_bounds
	MUL y std.screen.width
	ADD s x
	MOV $std.screen.color $s
	RET
	HLT
	#graphics.PutPixel.x_out_of_bounds
		RET
		HLT
	#graphics.PutPixel.y_out_of_bounds
		RET
		HLT

//X is on top. Y is on bottom
#graphics.GetPixel
	MOV s x
	MOV s y
	GRT x std.screen.width
	JOO graphics.PutPixel.x_out_of_bounds
	ADD x std.screen.start
	MOV s x
	GRT y std.screen.height
	JOO graphics.PutPixel.y_out_of_bounds
	MUL y std.screen.width
	ADD s x
	MOV $s s
	RET
	HLT
	#graphics.GetPixel.x_out_of_bounds
		MOV s x
		MOV 0 s
		RET
		HLT
	#graphics.GetPixel.y_out_of_bounds
		MOV 0 s
		RET
		HLT


#graphics.ESCAPE
