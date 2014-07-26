< std.asm
< graphics.asm
< std.math.asm
< std.io.asm

@scroller.angle
@scroller.phase
@scroller.start_index
@scroller.end_index
@scroller.index
@scroller.x_pos
@scroller.y_pos
@scroller.step
@scroller.text_length
@scroller.min_x

JMP scroller.ESCAPE

#scroller.INIT

	JSR graphics.Clear

	SUB scroller.text_end scroller.text_start
	MOV s $scroller.text_length			//Compute text length

	MOV 0 $scroller.step
	MOV 0 $scroller.index
	MOV 0 $scroller.start_index

	MOV 0 $scroller.angle

	DIV std.screen.height 2
	MOV s $scroller.y_pos				//starting y_position

	MOV 100 $scroller.min_x				//"Ending" position

	SUB std.screen.width 0
	MOV s $scroller.x_pos				//lets put a bit of offsett to the start.

	MOV 0 $scroller.end_index
RET

#scroller.step_once
	#scroller.loop

		ADD $scroller.x_pos 7
		MOV s $scroller.x_pos			//Increment x_pos

		MOV $scroller.angle s
		ADD s $scroller.phase
		MUL s 3
		JSR std.math.Sin
		DIV s 2
		MOV s x
		MOV $scroller.angle s
		ADD s $scroller.phase
		MUL s 9
		JSR std.math.Sin
		DIV s 8
		ADD s x
		ADD s $scroller.y_pos			//Get y offsett

		MOV s $std.io.y_pos				//Set charcter position
		MOV $scroller.x_pos $std.io.x_pos

		ADD $scroller.index scroller.text_start //Chose the appropriate character
		MOV $s s
		JSR std.io.PrintCharacter		//Print the character

		INC $scroller.angle
		INC $scroller.index

		MOD $scroller.index $scroller.text_length
		MOV s $scroller.index			//Have text loop

		SUB $std.screen.width 35
		SGR $scroller.x_pos s
			JMP scroller.loop			//Lopp while x_pos < width - 10

	MOV 0 $scroller.angle
	INC $scroller.step
	MUL $scroller.step 7
	SUB std.screen.width s
	MOV s $scroller.x_pos

	ADD $scroller.phase 3
	MOV s $scroller.phase

	SGR $scroller.x_pos $scroller.min_x
		JSR x_out_of_bounds

	MOV $scroller.start_index $scroller.index

	RET

	#x_out_of_bounds
		INC $scroller.start_index
		MOD $scroller.start_index $scroller.text_length
		MOV s $scroller.start_index
		MOV $scroller.min_x $scroller.x_pos
		RET
RET
#scroller.Clear
	MOV 0x00F $std.screen.color
	MOV	360 s	//y1
	MOV 639 s	//x1
	MOV 120 s	//y0
	MOV 100 s   //x0
	JSR graphics.FillRectangle
	RET


#scroller.text_start
< demotext.mem
#scroller.text_end

#scroller.ESCAPE
