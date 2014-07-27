< std.asm
< std.constants.asm
< graphics.asm

@fader.address

@fader.step
@fader.steps
@fader.toggle

JMP fader.ESCAPE

#fader.INIT
	JSR graphics.Clear
	MOV 1 $fader.toggle
	MOV 0 $fader.step
	MOV 25 $fader.steps
	RET


#fader.step_once
	JSR fader.DrawImage
	JSR graphics.UpdateAndWait

	ADD $fader.steps -1
	SNE	$fader.step s
		MOV -1 $fader.toggle
	SNE	$fader.step 1
		MOV 1 $fader.toggle

	ADD $fader.step $fader.toggle
	MOV s $fader.step

	RET

#fader.DrawImage
@fader.DrawImage.r
@fader.DrawImage.b
@fader.DrawImage.g
@fader.DrawImage.x0
@fader.DrawImage.y0
@fader.DrawImage.x_pos
@fader.DrawImage.y_pos


MOV 220 $fader.DrawImage.x0
MOV 25 $fader.DrawImage.y0
MOV 0 $fader.DrawImage.x_pos
MOV 0 $fader.DrawImage.y_pos
#fader.DrawImage.outer_loop
	#fader.DrawImage.inner_loop

		MUL $fader.DrawImage.y_pos fader.image_width
		ADD s $fader.DrawImage.x_pos
		ADD s fader.image_start
		MOV $s x


		SNE x 0
			JMP fader.DrawImage.skip

		AND x 0xF00
		SFT s -8
		MOV s $fader.DrawImage.r

		AND x 0x0F0
		SFT s -4
		MOV s $fader.DrawImage.g

		AND x 0x00F
		MOV s $fader.DrawImage.b

		MUL $fader.step $fader.DrawImage.r
		DIV s $fader.steps
		MOV s $fader.DrawImage.r

		MUL $fader.step $fader.DrawImage.g
		DIV s $fader.steps
		MOV s $fader.DrawImage.g

		MUL $fader.step $fader.DrawImage.b
		DIV s $fader.steps
		MOV s $fader.DrawImage.b

		SFT  $fader.DrawImage.g 4
		OOR s $fader.DrawImage.b
		SFT  $fader.DrawImage.r 8
		OOR s s
		MOV s $std.screen.color

		ADD $fader.DrawImage.y_pos $fader.DrawImage.y0
		ADD $fader.DrawImage.x_pos $fader.DrawImage.x0
		JSR graphics.QuickPutPixel

		#fader.DrawImage.skip

		INC $fader.DrawImage.x_pos

		SEQ $fader.DrawImage.x_pos fader.image_width
			JMP fader.DrawImage.inner_loop

	MOV 0 $fader.DrawImage.x_pos
	INC $fader.DrawImage.y_pos
	SEQ  $fader.DrawImage.y_pos fader.image_height
		JMP fader.DrawImage.outer_loop
	RET




#fader.image_start
! fader.image_width = 173
! fader.image_height = 426
<neubauten.mem
NOP
#fader.ESCAPE
NOP
