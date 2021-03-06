< graphics.asm
< std.math.asm
@plasma.x_pos
@plasma.y_pos
@plasma.phase

@plasma.x_start
@plasma.x_end
@plasma.y_start
@plasma.y_end
@plasma.x_size
@plasma.y_size
@plasma.step
@plasma.color_table+50
!plasma.lookup_table = 0xA00_000	//Let us just pray to Turing that there is no data here
JSR graphics.Clear
MOV 000 $plasma.x_start
MOV 320 $plasma.x_size
ADD $plasma.x_start $plasma.x_size
MOV s $plasma.x_end

MOV 000 $plasma.y_start
MOV 240 $plasma.y_size
ADD $plasma.y_start $plasma.y_size
MOV s $plasma.y_end

JSR plasma.ComputeColorTable
JSR plasma.GenerateLookupTable
MOV 1 $plasma.d
MOV 0 $plasma.step
MOV 0  $plasma.phase
JSR graphics.Clear

#laupozarus
	JSR plasma.StepOnce
	ADD $plasma.step 5
	MOV s $plasma.step
	JSR graphics.Update

JMP laupozarus


#plasma.StepOnce
	@plasma.StepOnce.temp_x
	@plasma.StepOnce.temp_y
	MOV 0xABCD y
	MOV $plasma.x_start $plasma.x_pos
	MOV $plasma.y_start $plasma.y_pos
	#plasma.Step.outer_loop
		#plasma.Step.inner_loop

			JSR plasma.GetColor
			MUL $plasma.y_pos 2
			MOV s $plasma.StepOnce.temp_y
			MUL $plasma.x_pos 2
			MOV s $plasma.StepOnce.temp_x

			MUL $plasma.StepOnce.temp_y std.screen.width
			ADD $plasma.StepOnce.temp_x std.screen.start
			ADD s s
			MOV $std.screen.color $s

			INC $plasma.StepOnce.temp_y

			MUL $plasma.StepOnce.temp_y std.screen.width
			ADD $plasma.StepOnce.temp_x std.screen.start
			ADD s s
			MOV $std.screen.color $s

			INC $plasma.StepOnce.temp_x

			MUL $plasma.StepOnce.temp_y std.screen.width
			ADD $plasma.StepOnce.temp_x std.screen.start
			ADD s s
			MOV $std.screen.color $s

			DEC $plasma.StepOnce.temp_y

			MUL $plasma.StepOnce.temp_y std.screen.width
			ADD $plasma.StepOnce.temp_x std.screen.start
			ADD s s
			MOV $std.screen.color $s



			INC $plasma.x_pos
			SEQ $plasma.x_pos $plasma.x_end
				JMP plasma.Step.inner_loop
		INC $plasma.y_pos
		MOV $plasma.x_start $plasma.x_pos
		SEQ $plasma.y_pos $plasma.y_end
			JMP plasma.Step.outer_loop
	RET


#plasma.GetColor
	!plasma.max_value = 1792
	@plasma.d
	@plasma.freq
	MUL $plasma.y_pos std.screen.width
	ADD s $plasma.x_pos
	ADD s plasma.lookup_table
	MOV $s s							//get shit in lookup table

	MUL $plasma.step 2
	ADD s $plasma.x_pos
	MOD s 360
	ADD s std.math.sin_table
	MOV $s s
	MUL s 3

	MUL 5 $plasma.step
	ADD s $plasma.x_pos
	MUL s 2
	ADD s $plasma.y_pos
	MOD s 360
	ADD s std.math.sin_table
	MOV $s s

	ADD s s
	ADD s s

	MUL s 48
	DIV s plasma.max_value

	MOV s x				//INLINED
	MOV x s
	SGR x 0
	MUL s -1

	ADD s plasma.color_table
	MOV $s $std.screen.color

	RET


#plasma.GenerateLookupTable
	MOV 0x7AB1E y
	MOV 0xFFF $std.screen.color
	@plasma.GenerateLookupTable.x_pos
	@plasma.GenerateLookupTable.y_pos
	MOV 0 $plasma.GenerateLookupTable.y_pos
	MOV 0 $plasma.GenerateLookupTable.x_pos
	#plasma.GenerateLookupTable.outer_loop
		#plasma.GenerateLookupTable.inner_loop




			MUL $plasma.GenerateLookupTable.y_pos std.screen.width
			ADD s $plasma.GenerateLookupTable.x_pos
			ADD s plasma.lookup_table
			JSR plasma.GenerateLookupTable.StaticFunction
			MOV s $s



			INC $plasma.GenerateLookupTable.x_pos
			SEQ $plasma.GenerateLookupTable.x_pos std.screen.width
				JMP plasma.GenerateLookupTable.inner_loop
		MOV 0 $plasma.GenerateLookupTable.x_pos
		INC $plasma.GenerateLookupTable.y_pos
		SEQ $plasma.GenerateLookupTable.y_pos std.screen.height
			JMP plasma.GenerateLookupTable.outer_loop
	RET




	#plasma.GenerateLookupTable.StaticFunction
		MUL $plasma.GenerateLookupTable.x_pos 3
		JSR std.math.Sin

		MUL $plasma.GenerateLookupTable.y_pos 3
		ADD s 90
		JSR std.math.Sin

		MUL 2 $plasma.y_pos
		MUL 2 $plasma.x_pos
		ADD s s
		JSR std.math.Sin

		ADD s s
		ADD s s
		RET





#plasma.ComputeColorTable
	@plasma.ComputeColorTable.index
	MOV 0 $plasma.ComputeColorTable.index
	#plasma.ComputeColorTable.loop

		SGR $plasma.ComputeColorTable.index 15
			JMP plasma.ComputeColorTable.less_then_16

		SGR $plasma.ComputeColorTable.index 31
			JMP plasma.ComputeColorTable.less_then_32

		SGR $plasma.ComputeColorTable.index 47
			JMP plasma.ComputeColorTable.less_then_48

		RET

		#plasma.ComputeColorTable.less_then_16
			ADD $plasma.ComputeColorTable.index plasma.color_table
			MOD $plasma.ComputeColorTable.index 16
			SFT s 8
			MOV s $s
			INC $plasma.ComputeColorTable.index
			JMP plasma.ComputeColorTable.loop


		#plasma.ComputeColorTable.less_then_32
			ADD $plasma.ComputeColorTable.index plasma.color_table
			MOD $plasma.ComputeColorTable.index 16
			SFT s 4
			OOR s 0xF00
			MOV s $s
			INC $plasma.ComputeColorTable.index
			JMP plasma.ComputeColorTable.loop

		#plasma.ComputeColorTable.less_then_48
			ADD $plasma.ComputeColorTable.index plasma.color_table
			MOD $plasma.ComputeColorTable.index 16
			OOR s 0xFF0
			MOV s $s
			INC $plasma.ComputeColorTable.index
			JMP plasma.ComputeColorTable.loop
