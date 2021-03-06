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
@std.io.text_color

JSR std.io.INIT
JMP std.io.ESCAPE

#std.io.INIT
	MOV 0xFFF $std.io.text_color
	MOV std.io.charset_start $std.io.char_pointer
	MOV std.io.line_margin $std.io.x_pos
	MOV 0 $std.io.y_pos
	RET



#std.io.SetupKeyHandler
	ADD std.irq_table_start 1
	MOV std.io.KeyHandler $s
	RET

//Ascii value for char is on stack.
#std.io.PrintCharacter
@std.io.PrintCharacter.char_pointer
@std.io.PrintCharacter.char_end
@std.io.PrintCharacter.x
@std.io.PrintCharacter.y
	MOV s x
	SGR x 32
		RET //Skip if space
	SNE x 10 //new_line
		JMP std.io.PrintCharacter.line_feed
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
		MOV $s x
		SNE x 0
			JMP std.io.PrintCharacter.skip

		MOV $std.io.text_color $std.screen.color
		MOV $std.io.PrintCharacter.y s
		MOV $std.io.PrintCharacter.x s
		//JSR graphics.PutPixel
		JSR graphics.QuickPutPixel

		#std.io.PrintCharacter.skip
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

	#std.io.PrintCharacter.line_feed
		JSR std.io.NewLine
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

	MOV x s
	MOV y s
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

//Prints a decimal number.
//This subroutine is shit. It only prints the last 9 digits of any number :/
#std.io.PrintDecimal
	@std.io.PrintDecimal.n
	@std.io.PrintDecimal.factor
	@std.io.PrintDecimal.leading_zero
	@std.io.PrintDecimal.tmp
	! std.io.PrintDecimal.minus_sign = 45
	! std.io.PrintDecimal.digits_start = 48

	MOV s $std.io.PrintDecimal.n
	MOV 1_000_000_000 $std.io.PrintDecimal.factor
	MOV 1 $std.io.PrintDecimal.leading_zero
	MOV 0 $std.io.PrintDecimal.tmp


	SEQ $std.io.PrintDecimal.n 0
		JMP std.io.PrintDecimal.not_zero
	MOV 48 s
	JSR std.io.PrintCharacter
	JSR std.io.Forward
	RET


	#std.io.PrintDecimal.not_zero
	SLE $std.io.PrintDecimal.n 0
		JMP std.io.PrintDecimal.positive_skip

	MOV $std.io.PrintDecimal.n s
	JSR std.Abs
	MOV s $std.io.PrintDecimal.n
	MOV std.io.PrintDecimal.minus_sign s
	JSR std.io.PrintCharacter
	JSR std.io.Forward

	#std.io.PrintDecimal.positive_skip

	#std.io.PrintDecimal.loop

		DIV $std.io.PrintDecimal.factor 10
		DIV $std.io.PrintDecimal.n $std.io.PrintDecimal.factor
		MUL $std.io.PrintDecimal.factor s
		SUB $std.io.PrintDecimal.n s
		DIV s s
		MOV s $std.io.PrintDecimal.tmp

		SUB $std.io.PrintDecimal.tmp 0
		SUB $std.io.PrintDecimal.leading_zero 1
		EQL s s
		SNE s 1
			JMP std.io.PrintDecimal.skip_print

		MOV 0 $std.io.PrintDecimal.leading_zero

		ADD $std.io.PrintDecimal.tmp std.io.PrintDecimal.digits_start
		JSR std.io.PrintCharacter
		JSR std.io.Forward

		#std.io.PrintDecimal.skip_print

		DIV $std.io.PrintDecimal.factor 10
		MOV s $std.io.PrintDecimal.factor

		SEQ $std.io.PrintDecimal.factor 1
			JMP std.io.PrintDecimal.loop
		RET








#std.io.ESCAPE


