//This is a half ready library for handling keyboard input and text output.

< std.constants.asm
< std.asm
< graphics.asm
!std.io.charset_start = 0xF4B_004
!std.io.charset_length = 3948
!std.io.charset_end = 0xF4B_F70
!std.io.char_length = 42
!std.io.char_height = 7
!std.io.char_width = 6
!std.io.ascii_start = 33
!std.io.char_height_increment = 8
!std.io.char_width_increment = 6
!std.io.line_margin = 3

!std.io.invalid_key = 65535
!std.io.key_value =  0xF4B_F71
!std.io.key_down = 0xF4B_F72



@std.io.char_pointer
@std.io.x_pos
@std.io.y_pos
#std.io.INIT
MOV 0xFEA1 y
MOV std.io.charset_start $std.io.char_pointer
MOV std.io.line_margin $std.io.x_pos
MOV 0 $std.io.y_pos
JMP std.io.ESCAPE


#std.io.SetupKeyHandler
	ADD std.irq_table_start 1
	MOV std.io.KeyHandler $s
	RET
MOV 0xAbed y
JSR graphics.Clear
JSR graphics.UpdateAndWait






HLT

//Ascii value for char is on stack.
#std.io.PrintCharacter
@std.io.PrintCharacter.char_pointer
@std.io.PrintCharacter.char_end
@std.io.PrintCharacter.x
@std.io.PrintCharacter.y
	MOV s x
	SGR x 32
	RET //Skip if space
	MOV x s
	SUB s 33
	MUL s std.io.char_length
	MOV s $std.io.PrintCharacter.char_pointer
	ADD $std.io.PrintCharacter.char_pointer $std.io.char_pointer
	MOV s $std.io.PrintCharacter.char_pointer
	ADD $std.io.PrintCharacter.char_pointer std.io.char_length
	MOV s $std.io.PrintCharacter.char_end
	MOV $std.io.x_pos $std.io.PrintCharacter.x
	MOV $std.io.y_pos $std.io.PrintCharacter.y
		#std.io.PrintCharacter.loop
		//set color and plot
		MOV $std.io.PrintCharacter.char_pointer s
		MOV $s $std.screen.color
		MOV $std.io.PrintCharacter.y s
		MOV $std.io.PrintCharacter.x s
		//JSR graphics.PutPixel
		JSR graphics.QuickPutPixel
		INC $std.io.PrintCharacter.x
		SUB $std.io.PrintCharacter.x $std.io.x_pos
		EQL s std.io.char_width
		JOZ std.io.PrintCharacter.x_in_bounds
		MOV $std.io.x_pos $std.io.PrintCharacter.x	//x is not in bounds
		INC $std.io.PrintCharacter.y
		#std.io.PrintCharacter.x_in_bounds
		INC $std.io.PrintCharacter.char_pointer
		SEQ $std.io.PrintCharacter.char_pointer $std.io.PrintCharacter.char_end
		JMP std.io.PrintCharacter.loop
		RET
	RET
HLT

#std.io.NewLine
	ADD $std.io.y_pos std.io.char_height_increment
	SLE s std.screen.height
	RET //Return if at end of screen.
	ADD $std.io.y_pos std.io.char_height_increment
	MOV s $std.io.y_pos
	MOV std.io.line_margin $std.io.x_pos
	RET
HLT

#std.io.Forward
	ADD $std.io.x_pos std.io.char_width_increment
	ADD s std.io.line_margin
	GRT s std.screen.width
	JOO std.io.Forward.NewLine
		ADD $std.io.x_pos std.io.char_width_increment
		MOV s $std.io.x_pos
		RET
	#std.io.Forward.NewLine
		JSR std.io.NewLine
		RET
HLT

#std.io.Home
	MOV std.io.line_margin $std.io.x_pos
	RET
HLT

#std.io.End
	SUB std.screen.width std.io.char_width_increment
	MOV s $std.io.x_pos

HLT

#std.io.KeyHandler
//	MOV 0xBABE y
//	MOV 33 s
//	JSR std.io.PrintCharacter
//	JSR graphics.UpdateAndWait
//	MOV 0xBABE y
//	HLT
//	RET
	MOV x s
	MOV y s
	MOV 0xBABE y
	EQL $std.io.key_value std.io.invalid_key
	JOO std.io.KeyHandler.ESCAPE
	LES $std.io.key_value 127
	GRT $std.io.key_value 31
	AND s s
	JOZ std.io.KeyHandler.Not_ASCII
	MOV $std.io.key_value s
	JSR std.io.PrintCharacter

	JSR graphics.UpdateAndWait
	JSR std.io.Forward


	#std.io.KeyHandler.Not_ASCII
	#std.io.KeyHandler.ESCAPE
	MOV s y
	MOV s x
	RET
HLT


#std.io.ESCAPE
