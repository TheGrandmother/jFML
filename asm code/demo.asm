< scroller.asm
< graphics.asm
< twister.asm
< sprites.asm
< fader.asm

JSR graphics.Clear
JSR graphics.UpdateAndWait


@demo.timer
@demo.timer2
#demo.MAIN

	JSR scroller.INIT
	JSR twister.INIT
	MOV $std.timer_address $demo.timer
	#demo.scene1
		JSR demo.TwistAndScroll
		SUB $std.timer_address $demo.timer
		SGR s 1000
			JMP demo.scene1

	JSR sprites.INIT
	MOV $std.timer_address $demo.timer
	MOV $std.timer_address $demo.timer2
	#demo.scene2
		JSR sprites.step_once
		JSR sprites.ClearBalls

		SUB $std.timer_address $demo.timer2
		SGR s 4000
			JMP demo.scene2.skip_inc

		JSR sprites.IncFreq
		MOV $std.timer_address $demo.timer2

		#demo.scene2.skip_inc
		SUB $std.timer_address $demo.timer
		SGR s 50000
			JMP demo.scene2

	JSR fader.INIT
	MOV $std.timer_address $demo.timer
	#demo.scene3
		JSR fader.step_once
		SUB $std.timer_address $demo.timer
		SGR s 25000
			JMP demo.scene3

	HLT

#demo.TwistAndScroll

	JSR scroller.step_once
	JSR twister.step_once
	JSR graphics.UpdateAndWait
	JSR scroller.Clear
	JSR twister.Clear

	RET
