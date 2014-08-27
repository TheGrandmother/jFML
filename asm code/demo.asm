//
// This is the main asm file for the silly little demo wich I have written for the FML machine
//

< graphics.asm
< sprites.asm
< fader.asm
< code.asm
< stars.asm
< swipe.asm
< twister.asm
< logo.asm
< plasma.asm
< greets.asm

JSR graphics.Clear
JSR graphics.UpdateAndWait


@demo.timer
@demo.timer2
#demo.MAIN


	JSR logo.INIT
	MOV $std.timer_address $demo.timer


	#demo.scene0
		JSR logo.StepOnce
		SUB $std.timer_address $demo.timer
		SGR s 14000
			JMP demo.scene0


	JSR twister.INIT
	#demo.scene1
		JSR twister.PlayScene

	//MOV 0xFFF s
	//JSR swipe.Swipe

	JSR sprites.INIT
	MOV $std.timer_address $demo.timer
	MOV $std.timer_address $demo.timer2

	#demo.scene2
		JSR sprites.step_once
		JSR sprites.ClearBalls

		SUB $std.timer_address $demo.timer2
		SGR s 3000
			JMP demo.scene2.skip_inc

		JSR sprites.IncFreq
		MOV $std.timer_address $demo.timer2

		#demo.scene2.skip_inc
		SUB $std.timer_address $demo.timer
		SGR s 20000
			JMP demo.scene2


	MOV 0x800 s
	JSR swipe.Swipe
	JSR graphics.Update

	JSR plasma.INIT
	MOV $std.timer_address $demo.timer

	#demo.scene3
	JSR plasma.StepOnce
	SUB $std.timer_address $demo.timer
	SGR s 15000
		JMP demo.scene3


	JSR fader.INIT
	MOV $std.timer_address $demo.timer
	#demo.scene4
		JSR fader.step_once
		SUB $std.timer_address $demo.timer
		SGR s 7000
			JMP demo.scene4

	JSR stars.PlayScene

	JSR graphics.Clear
	JSR graphics.Update
	JSR greets.INIT
	JSR greets.PlayScene

	//JSR code.PlayScene

	HLT

