< std.asm
< graphics.asm
< std.math.asm
< std.io.asm
! x_start = 640
! x_end = 0

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

#scroller.INIT

	JSR graphics.Clear
	SUB scroller.text_end scroller.text_start
	MOV s $scroller.text_length
	MOV 0 $scroller.step
	MOV 0 $scroller.index
	MOV 0 $scroller.start_index
	ADD 50 $scroller.start_index
	MOV s $scroller.end_index
	MOV 0 $scroller.angle
	DIV std.screen.height 2
	MOV s $scroller.y_pos
	MOV 100 $scroller.min_x
	SUB std.screen.width 14
	MOV s $scroller.x_pos
	MOV 0 $scroller.end_index
	RET


#scroller.Step
	#scroller.outer_loop
		#scroller.loop
			//ADD $angle 7
			ADD $scroller.x_pos 7
			MOV s $scroller.x_pos

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


			ADD s $scroller.y_pos

			MOV s $std.io.y_pos
			MOV $scroller.x_pos $std.io.x_pos

			ADD $scroller.index scroller.text_start
			MOV $s s
			JSR std.io.PrintCharacter


			INC $scroller.angle
			INC $scroller.index
			MOD $scroller.index $scroller.text_length
			MOV s $scroller.index

			SUB std.screen.width 10
			SGR $scroller.x_pos s
				JMP scroller.loop

		MOV 0 $scroller.angle
		INC $scroller.step
		//INC $end_index
		MUL $scroller.step 7
		SUB std.screen.width s
		MOV s $scroller.x_pos

		ADD $scroller.phase 3
		MOV s $scroller.phase

		SGR $scroller.x_pos $scroller.min_x
			JSR scroller.x_out_of_bounds

		MOV $scroller.start_index $scroller.index

		JSR graphics.UpdateAndWait
		//JSR graphics.Clear
		//JMP outer_loop
		RET

		#scroller.x_out_of_bounds
			INC $scroller.start_index
			MOD $scroller.start_index $scroller.text_length
			MOV s $scroller.start_index
			MOV $scroller.min_x $scroller.x_pos
			RET





#scroller.text_start
< demotext.mem
#scroller.text_end
