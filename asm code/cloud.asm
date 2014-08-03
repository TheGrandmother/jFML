< std.constants.asm
< std.asm
< graphics.asm
@x_pos
@y_pos
@x_middle
@y_middle
@inc
MOV 0xDEAD y
DIV std.screen.width 2
MOV s $x_pos
MOV $x_pos $x_middle
DIV std.screen.height 2
MOV s $y_pos
MOV $y_pos $y_middle
MOV 0x000 $std.screen.color
MOV 0xCAFE y
//JSR graphics.Clear
#start

//UPDATE PIXEL POSITION
	JSR std.Random
	JSR std.Abs
	MOD s 3
	SUB s 1
	ADD s $x_pos
	MOV s $x_pos
	JSR std.Random
	JSR std.Abs
	MOD s 3
	SUB s 1
	ADD s $y_pos
	MOV s $y_pos
	SLE $x_pos std.screen.width
	JMP out_of_bounds
	SGR $x_pos 0
	JMP out_of_bounds
	SLE $y_pos std.screen.height
	JMP out_of_bounds
	SGR $y_pos 0
	JMP out_of_bounds
	JMP skip_out_of_bounds
	#out_of_bounds
		MOV $x_middle $x_pos
		MOV $y_middle $y_pos
		ADD 1 $inc
		MOD s 2
		MOV s $inc
	#skip_out_of_bounds

//GET AND ALTER COLOR

	SEQ $inc 1
	JMP decrement_color
	#increment_color
	MOV $y_pos s
	MOV $x_pos s
	JSR graphics.GetPixel
	ADD s 0x112
	JSR graphics.SetColor
	JMP skip_colors
	#decrement_color
	MOV $y_pos s
	MOV $x_pos s
	JSR graphics.GetPixel
	SUB s 0x112
	JSR graphics.SetColor
	#skip_colors

//WRITE PIXEL TO SCREEN
	MOV $y_pos s
	MOV $x_pos s
	JSR graphics.PutPixel
	JSR graphics.Update
	//MOV 1 s
	//JSR std.WaitMilli
	//JSR graphics.UpdateAndWait
	JMP start
HLT

