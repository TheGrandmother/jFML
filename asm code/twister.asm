< std.asm
< std.math.asm
< graphics.asm
< std.io.asm



!c1 = 0x00F
!c2 = 0x008
!c3 = 0x0F0
!c4 = 0x080
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
@twister.color_map+300

JMP twister.ESCAPE

#twister.INIT
	JSR twister.ComputeColorMap
	MOV 1 $twister.toggle
	MOV 0 $twister.x1
	MOV 0 $twister.x2
	MOV 0 $twister.x3
	MOV 0 $twister.x4
	MOV 0 $twister.y_pos
	MOV 0 $twister.angle
	MOV 0 $twister.step
	MOV 5 $twister.factor
	MOV 80 $twister.offs
	RET
JSR graphics.Clear


#twister.step_once
	#twister.start
	JSR twister.AngleShift
	JSR twister.PlotPoints

	INC $twister.y_pos

	#twister.skip
	SEQ $twister.y_pos std.screen.height
		JMP twister.start

	MOV 0 $twister.y_pos
	//JSR graphics.UpdateAndWait
	RET
	HLT

#twister.Clear
	MOV 0x0F0 $std.screen.color
	MOV std.screen.height s
	MOV 140 s
	MOV 0 s
	MOV 0 s

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

		MUL $twister.temp_x twister.map_length
		DIV s $twister.line_length
		ADD s $twister.map_start
		MOV $s $std.screen.color	//Color = ((x * map_length) / line_length) + map_start

		MOV $twister.y_pos s
		ADD $twister.x_start $twister.temp_x
		JSR graphics.QuickPutPixel

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

! twister.min_r = 0x8
! twister.min_g = 0x2
! twister.min_b = 0x0
! twister.max_r = 0xF
! twister.max_g = 0xF
! twister.max_b = 0x2
! twister.map_length = 300
@twister.map_start
@twister.map_end
@twister.current_address
@twister.offs1
@twister.co
@twister.x_val
#twister.ComputeColorMap
	MOV twister.color_map $twister.map_start	//Compute addresses
	ADD twister.map_length $twister.map_start
	MOV s $twister.map_end

	MOV 0 $twister.x_val				// Init x

	#twister.ComputeColorMap.loop
		ADD $twister.x_val $twister.map_start
		MOV s $twister.current_address	// Get address

		//Compute red channel
		SUB twister.max_b twister.min_b		//Compute offset
		MUL $twister.x_val s
		DIV s twister.map_length
		ADD s twister.min_b 		//(offs*x)/length + min_color
		MOV s x

		//Compute green chanel
		SUB twister.max_g twister.min_g		//Compute offset
		MUL $twister.x_val s
		DIV s twister.map_length
		ADD s twister.min_g 		//(offs*x)/length + min_color
		SFT s 4
		OOR s x
		MOV s x

		//Compute green chanel
		SUB twister.max_r twister.min_r		//Compute offset
		MUL $twister.x_val s
		DIV s twister.map_length
		ADD s twister.min_r 		//(offs*x)/length + min_color
		SFT s 8
		OOR s x

		MOV $twister.current_address y
		MOV s $y				//Move to map

		INC $twister.x_val

		ADD $twister.x_val $twister.map_start
		SEQ s $twister.map_end
			JMP twister.ComputeColorMap.loop


		RET
#twister.ESCAPE
