< graphics.asm

@swipe.speed

MOV 7 $swipe.speed
JMP swipe.ESCAPE

//color
#swipe.Swipe
	@swipe.Swipe.x_pos
	@swipe.Swipe.y_pos
	MOV s $std.screen.color

	MOV 0 $swipe.Swipe.x_pos
	MOV 0 $swipe.Swipe.y_pos

	#swipe.Swipe.outer_loop
		SNE $swipe.Swipe.y_pos std.screen.height
			RET

		#swipe.Swipe.inner_loop
			MUL $swipe.Swipe.y_pos std.screen.width
			ADD $swipe.Swipe.x_pos s
			ADD std.screen.start s
			MOV $std.screen.color $s

			INC $swipe.Swipe.x_pos

			SEQ $swipe.Swipe.x_pos std.screen.width
				JMP swipe.Swipe.inner_loop

		MOV 0 $swipe.Swipe.x_pos
		INC  $swipe.Swipe.y_pos
		MOD $swipe.Swipe.y_pos $swipe.speed
		SNE s 0
			JSR graphics.UpdateAndWait
		JMP swipe.Swipe.outer_loop

//color
#swipe.SwipeUp
	@swipe.SwipeUp.x_pos
	@swipe.SwipeUp.y_pos
	MOV s $std.screen.color

	MOV 0 $swipe.SwipeUp.x_pos
	MOV std.screen.height $swipe.SwipeUp.y_pos

	#swipe.SwipeUp.outer_loop
		SNE $swipe.SwipeUp.y_pos 0
			RET

		#swipe.SwipeUp.inner_loop
			MUL $swipe.SwipeUp.y_pos std.screen.width
			ADD $swipe.SwipeUp.x_pos s
			ADD std.screen.start s
			MOV $std.screen.color $s

			INC $swipe.SwipeUp.x_pos

			SEQ $swipe.SwipeUp.x_pos std.screen.width
				JMP swipe.SwipeUp.inner_loop

		MOV 0 $swipe.SwipeUp.x_pos
		DEC  $swipe.SwipeUp.y_pos
		MOD $swipe.SwipeUp.y_pos $swipe.speed
		SNE s 0
			JSR graphics.UpdateAndWait
		JMP swipe.SwipeUp.outer_loop

#swipe.ESCAPE


