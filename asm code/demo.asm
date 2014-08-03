< scroller.asm
< graphics.asm
< twister.asm
< sprites.asm
< fader.asm
< code.asm
< stars.asm
< swipe.asm

JSR graphics.Clear
JSR graphics.UpdateAndWait


@demo.timer
@demo.timer2
#demo.MAIN

	JSR scroller.INIT
	JSR twister.INIT
	MOV $std.timer_address $demo.timer

	#demo.scene1
		JSR scroller.Clear
		JSR twister.Clear
		JSR scroller.step_once
		JSR twister.step_once
		JSR graphics.UpdateAndWait



		SUB $std.timer_address $demo.timer
		SGR s 500
			JMP demo.scene1

	MOV 0xFFF s
	JSR swipe.Swipe

	JSR sprites.INIT
	MOV $std.timer_address $demo.timer
	MOV $std.timer_address $demo.timer2

	#demo.scene2
		JSR sprites.step_once
		JSR sprites.ClearBalls

		SUB $std.timer_address $demo.timer2
		SGR s 500
			JMP demo.scene2.skip_inc

		JSR sprites.IncFreq
		MOV $std.timer_address $demo.timer2

		#demo.scene2.skip_inc
		SUB $std.timer_address $demo.timer
		SGR s 1000
			JMP demo.scene2


	MOV 0x000 s
	JSR swipe.SwipeUp


	JSR fader.INIT
	MOV $std.timer_address $demo.timer
	#demo.scene3
		JSR fader.step_once
		SUB $std.timer_address $demo.timer
		SGR s 1000
			JMP demo.scene3

	JSR stars.PlayScene

	JSR code.PlayScene

	HLT

#demo.TwistAndScroll

	JSR scroller.step_once
	JSR twister.step_once
	JSR graphics.UpdateAndWait
	JSR scroller.Clear
	JSR twister.Clear

	RET
