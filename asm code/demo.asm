< scroller.asm
< graphics.asm
< twister.asm

JSR graphics.Clear
JSR graphics.UpdateAndWait

JSR scroller.INIT
JSR twister.INIT


#lewp
	JSR scroller.step_once
	JSR twister.step_once

	JSR graphics.UpdateAndWait
	//JSR scroller.Clear
	JSR twister.Clear
	JMP lewp
