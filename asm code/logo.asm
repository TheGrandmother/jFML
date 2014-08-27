< graphics.asm
< std.math.asm
JSR graphics.Clear

//sprite_address
//x0
//y0
//width
//height
//new_width
//new_height

//MOV logo.image_height s
//MOV 200 s
//MOV logo.image_height s
//MOV logo.image_width  s
//MOV 10 s
//MOV 10 s
//MOV logo.image_start s
//JSR graphics.DrawScaledSprite
//JSR graphics.UpdateAndWait

JMP logo.ESCAPE
#logo.INIT
	@logo.angle
	@logo.x_pos
	@logo.y_pos
	MOV 0xFFF $std.screen.color
	MOV std.screen.height s
	MOV std.screen.width s
	MOV 0 s
	MOV 0 s
	JSR graphics.FillRectangle

	MOV 200 $logo.x_pos
	MOV 130 $logo.y_pos
	MOV 0 $logo.angle
	RET

#logo.StepOnce
	JSR logo.Turn
	MOV 25 s
	JSR std.WaitMilli
	ADD $logo.angle 7
	MOV s $logo.angle
	RET

#looplikeyoumeanit
	JSR logo.Turn
	MOV 25 s
	JSR std.WaitMilli
	ADD $logo.angle 7
	MOV s $logo.angle
	//JSR graphics.Clear
	JMP looplikeyoumeanit

#logo.Turn
	ADD $logo.angle 90
	JSR std.math.Sin
	MUL s logo.image_width
	DIV s std.math.Sin.max_value
	MOV s x
	SNE x 0
		MOV 1 x			//Avoid divide by zero

	SGR x 1
		JMP logo.Turn.flippside
	MOV x s
	MOV logo.image_height s
	MOV x s
	MOV logo.image_height s
	MOV logo.image_width  s
	MOV $logo.y_pos s
	DIV x 2
	DIV logo.image_width 2
	SUB s s
	ADD s $logo.x_pos
	//MOV $logo.x_pos s
	MOV logo.image_start s
	JSR graphics.DrawScaledSprite
	JSR graphics.UpdateAndWait
	MOV s x

	MOV 0xFFF $std.screen.color

	ADD $logo.y_pos logo.image_height
	//MOV std.screen.height s

	DIV x 2
	DIV logo.image_width 2
	SUB s s
	ADD s $logo.x_pos
	ADD s x

	MOV $logo.y_pos s

	DIV x 2
	DIV logo.image_width 2
	SUB s s
	ADD s $logo.x_pos

	JSR graphics.FillRectangle

	RET
	#logo.Turn.flippside
	MOV x s
	JSR std.Abs
	MOV s x
	MOV x s
	MOV logo.image_height s
	MOV x s
	MOV logo.image_height s
	MOV logo.image_width  s
	MOV $logo.y_pos s
	DIV x 2
	DIV logo.image_width 2
	SUB s s
	ADD s $logo.x_pos
	//MOV $logo.x_pos s
	MOV logo.flipped_image_start s
	JSR graphics.DrawScaledSprite
	JSR graphics.UpdateAndWait
	MOV s x

		MOV 0xFFF $std.screen.color

	ADD $logo.y_pos logo.image_height
	//MOV std.screen.height s

	DIV x 2
	DIV logo.image_width 2
	SUB s s
	ADD s $logo.x_pos
	ADD s x

	MOV $logo.y_pos s

	DIV x 2
	DIV logo.image_width 2
	SUB s s
	ADD s $logo.x_pos

	JSR graphics.FillRectangle

	RET

!logo.image_width = 215
!logo.image_height = 192
#logo.image_start
< logo.mem
NOP
#logo.flipped_image_start
< logoflipped.mem
NOP
#logo.ESCAPE
