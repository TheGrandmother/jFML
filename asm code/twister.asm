< std.asm
< std.math.asm
< graphics.asm
< std.io.asm



!c1 = 0x00F
!c2 = 0x008
!c3 = 0x0F0
!c4 = 0x080
!max_step = 20
!min_step = -20
!angle_factor = 10
@x1
@x2
@x3
@x4
@y_pos
@angle
@step
@toggle
@factor
@offs
@color_map+300

JSR twister.ComputeColorMap
MOV 1 $toggle
MOV 0 $x1
MOV 0 $x2
MOV 0 $x3
MOV 0 $x4
MOV 0 $y_pos
MOV 0 $angle
MOV 0 $step
MOV 4 $factor
MOV 320 $offs
JSR graphics.Clear


#start
		JSR twister.AngleShift
		JSR twister.PlotPoints

		INC $y_pos

		#twister.skip
		SEQ $y_pos std.screen.height
			JMP start





	MOV 0 $y_pos



	JSR graphics.UpdateAndWait
	MOV 0x000 $std.screen.color
	MOV std.screen.height s
	MOV 385 s
	MOV 0 s
	MOV 250 s

	JSR graphics.FillRectangle
	JMP start
	HLT





#twister.PlotPoints
	MOV $angle s
	JSR std.math.Sin
	DIV s $factor
	ADD s $offs
	MOV s $x1

	ADD $angle 90
	JSR std.math.Sin
	DIV s $factor
	ADD s $offs
	MOV s $x2

	ADD $angle 180
	JSR std.math.Sin
	DIV s $factor
	ADD s $offs
	MOV s $x3

	ADD $angle 270
	JSR std.math.Sin
	DIV s $factor
	ADD s $offs
	MOV s $x4

	MOV $x2 s
	MOV $x1 s
	JSR twister.Line

	MOV $x3 s
	MOV $x2 s
	JSR twister.Line


	MOV $x4 s
	MOV $x3 s
	JSR twister.Line


	MOV $x1 s
	MOV $x4 s
	JSR twister.Line


	RET


//p1
//p2
@temp_x
@x_end
@x_start
@line_length
#twister.Line

	MOV s $x_start
	MOV s $x_end

	SGR $x_end $x_start			//Skip if p2 < p1
		RET

	SUB $x_end $x_start
	MOV s $line_length			//Get length



	MOV 0 $temp_x
	#twister.Line.loop
		//MOV 0xBA116 y

		MUL $temp_x map_length
		DIV s $line_length
		ADD s $map_start
		MOV $s $std.screen.color	//Color = ((x * map_length) / line_length) + map_start

		MOV $y_pos s
		ADD $x_start $temp_x
		JSR graphics.QuickPutPixel

		INC $temp_x
		SEQ $temp_x $line_length
			JMP twister.Line.loop
		RET


#twister.AngleShift

	EQL $step max_step
	EQL $step min_step
	ADD s s
	EQL s 1
	JOZ twister.AngleShift.skip
		MUL $toggle -1
		MOV s $toggle
		SNE $step max_step
			SUB $step 2
		SNE $step min_step
			ADD $step 2
		//MOV 0 $step
		MOV s $step

	#twister.AngleShift.skip
	SNE $toggle -1
		JMP twister.AngleShift.decrease

	#twister.AngleShift.increase
	DIV $y_pos 2
	MUL s $step
	DIV s angle_factor
	MOV s $angle
	MOD $y_pos std.screen.height
	SNE s 0
		INC $step
	RET

	#twister.AngleShift.decrease
	DIV $y_pos 2
	MUL s $step
	DIV s angle_factor
	MOV s $angle
	MOD $y_pos std.screen.height
	SNE s 0
		DEC $step
	RET


! min_r = 0x8
! min_g = 0x2
! min_b = 0x0
! max_r = 0xF
! max_g = 0xF
! max_b = 0x2
! map_length = 300
@map_start
@map_end
@current_address
@offs1
@co
@x_val
#twister.ComputeColorMap
	MOV color_map $map_start	//Compute addresses
	ADD map_length $map_start
	MOV s $map_end

	MOV 0 $x_val				// Init x

	#twister.ComputeColorMap.loop
		ADD $x_val $map_start
		MOV s $current_address	// Get address

		//Compute red channel
		SUB max_b min_b		//Compute offset
		MUL $x_val s
		DIV s map_length
		ADD s min_b 		//(offs*x)/length + min_color
		MOV s x

		//Compute green chanel
		SUB max_g min_g		//Compute offset
		MUL $x_val s
		DIV s map_length
		ADD s min_g 		//(offs*x)/length + min_color
		SFT s 4
		OOR s x
		MOV s x

		//Compute green chanel
		SUB max_r min_r		//Compute offset
		MUL $x_val s
		DIV s map_length
		ADD s min_r 		//(offs*x)/length + min_color
		SFT s 8
		OOR s x

		MOV $current_address y
		MOV s $y				//Move to map

		INC $x_val

		//RET // FIIIIIIIIIIIIIIIIIIIIIIIIIIIX
		ADD $x_val $map_start
		SEQ s $map_end
			JMP twister.ComputeColorMap.loop


		RET









