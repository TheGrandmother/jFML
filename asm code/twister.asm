< std.asm
< std.math.asm
< graphics.asm
< std.io.asm


!twister.max_step = 20
!twister.min_step = -20
!twister.angle_factor = 10
@twister.x1
@twister.x2
@twister.x3
@twister.x4
@twister.y_pos
@twister.angle
@twister.step
@twister.toggle
@twister.factor
@twister.offs
@twister.start_row
@twister.end_row
@twister.done

JSR graphics.Clear
JSR twister.INIT
//#liup/
	//JSR twister.step_once
	//JSR graphics.UpdateAndWait
	//JSR twister.Clear
	//JMP liup



JMP twister.ESCAPE

#twister.INIT
	MOV 0xFFF $std.screen.color
	MOV std.screen.height s
	MOV std.screen.width s
	MOV 0 s
	MOV 0 s
	JSR graphics.FillRectangle

	MOV 1 $twister.toggle
	MOV 0 $twister.x1
	MOV 0 $twister.x2
	MOV 0 $twister.x3
	MOV 0 $twister.x4
	MOV 0 $twister.y_pos
	MOV 0 $twister.angle
	MOV 0 $twister.step
	MOV 3 $twister.factor
	MOV 320 $twister.offs
	MOV 0 $twister.start_row
	MOV std.screen.height $twister.end_row
	MOV 0 $twister.done
	RET
JSR graphics.Clear

#twister.PlayScene
	#twister.PlayScene.loop
	JSR twister.step_once
	JSR graphics.UpdateAndWait
	JSR twister.Clear
	SEQ $twister.done 1
		JMP twister.PlayScene.loop
	RET


#twister.step_once
	#twister.start
	JSR twister.AngleShift
	JSR twister.PlotPoints

	INC $twister.y_pos

	#twister.skip
	SEQ $twister.y_pos std.screen.height
		JMP twister.start

	MOV 0 $twister.y_pos
	ADD 15 $twister.start_row
	MOV s $twister.start_row
	ADD 15 $twister.end_row
	MOV s $twister.end_row

	SNE $twister.end_row twister.texture_height
		MOV 1 $twister.done

	//JSR graphics.UpdateAndWait
	RET
	HLT

#twister.Clear
	MOV 0xFFF $std.screen.color
	MOV std.screen.height s
	MOV 405 s
	MOV 0 s
	MOV 235 s
	JSR graphics.FillRectangle
	RET

#twister.PlotPoints
	MOV $twister.angle s
	JSR std.math.Sin
	DIV s $twister.factor
	ADD s $twister.offs
	MOV s $twister.x1

	ADD $twister.angle 90
	JSR std.math.Sin
	DIV s $twister.factor
	ADD s $twister.offs
	MOV s $twister.x2

	ADD $twister.angle 180
	JSR std.math.Sin
	DIV s $twister.factor
	ADD s $twister.offs
	MOV s $twister.x3

	ADD $twister.angle 270
	JSR std.math.Sin
	DIV s $twister.factor
	ADD s $twister.offs
	MOV s $twister.x4

	MOV $twister.x2 s
	MOV $twister.x1 s
	JSR twister.Line

	MOV $twister.x3 s
	MOV $twister.x2 s
	JSR twister.Line

	MOV $twister.x4 s
	MOV $twister.x3 s
	JSR twister.Line

	MOV $twister.x1 s
	MOV $twister.x4 s
	JSR twister.Line

	RET

//p1
//p2
@twister.temp_x
@twister.x_end
@twister.x_start
@twister.line_length
#twister.Line

	MOV s $twister.x_start
	MOV s $twister.x_end

	SGR $twister.x_end $twister.x_start			//Skip if p2 < p1
		RET

	SUB $twister.x_end $twister.x_start
	MOV s $twister.line_length			//Get length

	MOV 0 $twister.temp_x
	#twister.Line.loop
		//MOV 0xBA116 y

		ADD $twister.y_pos $twister.start_row
		MUL s twister.texture_width
		MUL $twister.temp_x twister.texture_width
		DIV s $twister.line_length
		ADD s s
		ADD s twister.texture_start

		MOV $s $std.screen.color	//Color = ((x * map_length) / line_length) + map_start

		//MOV $twister.y_pos s
		//ADD $twister.x_start $twister.temp_x
		//JSR graphics.QuickPutPixel

			MUL $twister.y_pos std.screen.width
			ADD s std.screen.start
			ADD $twister.x_start $twister.temp_x
			ADD s s
			MOV $std.screen.color $s

		INC $twister.temp_x
		SEQ $twister.temp_x $twister.line_length
			JMP twister.Line.loop
		RET

#twister.AngleShift

	EQL $twister.step twister.max_step
	EQL $twister.step twister.min_step
	ADD s s
	EQL s 1
	JOZ twister.AngleShift.skip
		MUL $twister.toggle -1
		MOV s $twister.toggle
		SNE $twister.step twister.max_step
			SUB $twister.step 2
		SNE $twister.step twister.min_step
			ADD $twister.step 2
		//MOV 0 $step
		MOV s $twister.step

	#twister.AngleShift.skip
	SNE $twister.toggle -1
		JMP twister.AngleShift.decrease

	#twister.AngleShift.increase
	DIV $twister.y_pos 2
	MUL s $twister.step
	DIV s twister.angle_factor
	MOV s $twister.angle
	MOD $twister.y_pos std.screen.height
	SNE s 0
		INC $twister.step
	RET

	#twister.AngleShift.decrease
	DIV $twister.y_pos 2
	MUL s $twister.step
	DIV s twister.angle_factor
	MOV s $twister.angle
	MOD $twister.y_pos std.screen.height
	SNE s 0
		DEC $twister.step
	RET



! twister.texture_width = 170
! twister.texture_height = 7500
# twister.texture_start
< twist.mem
#twister.texture_end
NOP





#twister.ESCAPE
