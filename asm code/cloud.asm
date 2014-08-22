< std.constants.asm
< std.asm
< graphics.asm

@cloud.step
@cloud.max_step
@cloud.color_table+48
@cloud.x_pos
@cloud.y_pos

JSR graphics.Clear
JSR cloud.ComputeTable
MOV 0 $cloud.step
MOV 1000 $cloud.max_step
#liup
JSR cloud.DoWalk
MOV 0 $cloud.step

JMP liup
HLT

#cloud.DoWalk
	MOV 0 $cloud.step
	DIV std.screen.width 2
	MOV s $cloud.x_pos
	DIV std.screen.height 2
	MOV s $cloud.y_pos
	#cloud.DoWalk.loop
		//MUL $cloud.step 48
		//DIV s $cloud.max_step
		//ADD s cloud.color_table
		//MOV $s $std.screen.color

		JSR cloud.GetAndAlterColour

		MOV $cloud.y_pos s
		MOV $cloud.x_pos s
		JSR graphics.QuickPutPixel
		JSR graphics.UpdateAndWait

		JSR std.Random
		JSR std.Abs
		MOD s 3
		SUB s 1
		ADD s $cloud.x_pos
		MOV s $cloud.x_pos

		JSR std.Random
		JSR std.Abs
		MOD s 3
		SUB s 1
		ADD s $cloud.y_pos
		MOV s $cloud.y_pos

		INC $cloud.step
		SGR $cloud.step $cloud.max_step
			JMP cloud.DoWalk.loop
		RET

#cloud.GetAndAlterColour
	@cloud.original
	@cloud.new
	@cloud.table
	MUL $cloud.y_pos std.screen.width
	ADD s $cloud.x_pos
	ADD s std.screen.start
	MOV $s $cloud.original

	MUL $cloud.step 48
	DIV s $cloud.max_step
	ADD s cloud.color_table
	MOV $s $cloud.table

	SFT $cloud.original -8
	AND s 0x00F
	SFT $cloud.table -8
	AND s 0x00F
	ADD s s
	MOV s x
	SLE x 0xF
		MOV 0xF x
	SFT x 8
	OOR s $cloud.new
	MOV s $cloud.new

	SFT $cloud.original -4
	AND s 0x00F
	SFT $cloud.table -4
	AND s 0x00F
	ADD s s
	MOV s x
	SLE x 0xF
		MOV 0xF x
	SFT x 4
	OOR s $cloud.new
	MOV s $cloud.new

	SFT $cloud.original 0
	AND s 0x00F
	SFT $cloud.table 0
	AND s 0x00F
	ADD s s
	MOV s x
	SLE x 0xF
		MOV 0xF x
	SFT x 0
	OOR s $cloud.new
	MOV s $cloud.new



	MOV $cloud.new $std.screen.color

	RET

#cloud.ComputeTable
	@cloud.ComputeTable.index
	MOV 0 $cloud.ComputeTable.index
	#cloud.ComputeTable.loop

		SGR $cloud.ComputeTable.index 15
			JMP cloud.ComputeTable.less_then_16

		SGR $cloud.ComputeTable.index 31
			JMP cloud.ComputeTable.less_then_32

		SGR $cloud.ComputeTable.index 47
			JMP cloud.ComputeTable.less_then_48

		RET

		#cloud.ComputeTable.less_then_16
			ADD $cloud.ComputeTable.index cloud.color_table
			MOD $cloud.ComputeTable.index 16
			SFT s 8
			MOV s $s
			INC $cloud.ComputeTable.index
			JMP cloud.ComputeTable.loop


		#cloud.ComputeTable.less_then_32
			ADD $cloud.ComputeTable.index cloud.color_table
			MOD $cloud.ComputeTable.index 16
			SFT s 4
			OOR s 0xF00
			MOV s $s
			INC $cloud.ComputeTable.index
			JMP cloud.ComputeTable.loop

		#cloud.ComputeTable.less_then_48
			ADD $cloud.ComputeTable.index cloud.color_table
			MOD $cloud.ComputeTable.index 16
			OOR s 0xFF0
			MOV s $s
			INC $cloud.ComputeTable.index
			JMP cloud.ComputeTable.loop
