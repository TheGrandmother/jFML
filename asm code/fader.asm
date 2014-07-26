< std.asm
< std.constants.asm
< graphics.asm

@fader.address
@fader.index
@fader.step
@fader.steps

MOV 0 $fader.step
MOV 10 $fader.steps
#lewp

	JSR fader.DrawImage
	JSR graphics.UpdateAndWait
	INC $fader.step
	SLE $fader.step $fader.steps
		HLT

JMP lewp


#fader.DrawImage
@fader.DrawImage.r
@fader.DrawImage.b
@fader.DrawImage.g
MOV 0 $fader.index

	#fader.DrawImage.loop

		ADD $fader.index fader.image_start
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
		MOV s x

		#fader.DrawImage.skip
		ADD $fader.index std.screen.start
		MOV x $s

		INC $fader.index

		SLE $fader.index std.screen.size
			RET
		JMP fader.DrawImage.loop




#fader.image_start
<hacked.mem
