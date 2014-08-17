< graphics.asm
< std.io.asm


JSR graphics.Clear
@greets.x_start
@greets.y_start
@greets.ascii_value
@greets.age
@greets.time_table+26 	//Contains the time left for all chars.
@greets.table_index
@greets.step
@greets.end
! greets.max_age = 26
! greets.table_length = 26
! greets.interval = 7

MOV 170 $greets.x_start
MOV 90 $greets.y_start
MOV 0 $greets.step

//JSR greets.PlayScene
//HLT

#laupi
	JSR greets.DrawTable
	JSR graphics.UpdateAndWait
	INC $greets.step
	MOD $greets.step greets.interval
	SEQ s 0
		JMP laupi
	JSR greets.PopulateTable
	SNE $greets.end 1
		HLT
	JMP laupi


JMP laupi
MOV 29 $greets.age
JMP laupi
HLT

#greets.PopulateTable
	@greets.PopulateTable.ascii
	ADD $greets.table_index greets.text_start
	MOV $s $greets.PopulateTable.ascii

	SNE $greets.PopulateTable.ascii 0
		JMP greets.PopulateTable.skip

	SNE $greets.PopulateTable.ascii 32
		JMP greets.PopulateTable.skip

	SUB $greets.PopulateTable.ascii 97
	ADD s greets.time_table
	MOV 26 $s

	#greets.PopulateTable.skip

	SNE $greets.PopulateTable.ascii 0
		MOV 1 $greets.end

	INC $greets.table_index

	RET






#greets.DrawTable
	@greets.DrawTable.index

	MOV 0 $greets.DrawTable.index
	#greets.DrawTable.loop
		ADD $greets.DrawTable.index greets.time_table
		MOV $s $greets.age

		SNE $greets.age 0
			JMP greets.DrawTable.skip

		MOV $greets.DrawTable.index s
		JSR greets.DrawChar

		DEC $greets.age
		ADD $greets.DrawTable.index greets.time_table
		MOV $greets.age $s

		#greets.DrawTable.skip
		INC $greets.DrawTable.index
		SEQ $greets.DrawTable.index greets.table_length
			JMP greets.DrawTable.loop
	RET



//ascii <-top
#greets.DrawChar
	@greets.DrawChar.char_number
	@greets.DrawChar.x_pos
	@greets.DrawChar.y_pos
	@greets.DrawChar.color
	@greets.DrawChar.x_start
	@greets.DrawChar.x_end
	@greets.DrawChar.y_start
	@greets.DrawChar.y_end
	@greets.DrawChar.x_offs
	@greets.DrawChar.y_offs
	@greets.DrawChar.char_row
	@greets.DrawChar.char_column

	! greets.DrawChar.width_increment = 57
	! greets.DrawChar.char_width = 55
	! greets.DrawChar.char_height = 60
	! greets.DrawChar.chars_per_line = 5

	! greets.DrawChar.ascii_start = 97

	//SUB s greets.DrawChar.ascii_start
	MOV s $greets.DrawChar.char_number

	DIV $greets.DrawChar.char_number greets.DrawChar.chars_per_line
	MOV s $greets.DrawChar.char_row

	MOD $greets.DrawChar.char_number greets.DrawChar.chars_per_line
	MOV s  $greets.DrawChar.char_column

	MUL $greets.DrawChar.char_column greets.DrawChar.width_increment
	MOV s $greets.DrawChar.x_start

	MUL $greets.DrawChar.char_row greets.DrawChar.char_height
	MOV s $greets.DrawChar.y_start

	ADD $greets.DrawChar.y_start greets.DrawChar.char_height
	MOV s $greets.DrawChar.y_end

	ADD $greets.DrawChar.x_start greets.DrawChar.char_width
	MOV s $greets.DrawChar.x_end

	MOV $greets.DrawChar.x_start $greets.DrawChar.x_pos
	MOV $greets.DrawChar.y_start $greets.DrawChar.y_pos

	//SNE $greets.DrawChar.asci_value 0
	//	RET


	#greets.DrawChar.outer_loop
		#greets.DrawChar.inner_loop
		MUL $greets.DrawChar.y_pos greets.image_width
		ADD $greets.DrawChar.x_pos s
		ADD greets.image_start s
		MOV $s $greets.DrawChar.color

		SNE $greets.DrawChar.color 0
			JMP greets.DrawChar.skip

		//Put color changing function here
		JSR greets.Glow

		//MOV $greets.DrawChar.color $std.screen.color

		ADD $greets.DrawChar.y_pos $greets.y_start
		ADD $greets.DrawChar.x_pos $greets.x_start
		JSR graphics.QuickPutPixel



		#greets.DrawChar.skip
		INC $greets.DrawChar.x_pos
		SEQ $greets.DrawChar.x_pos $greets.DrawChar.x_end
			JMP greets.DrawChar.inner_loop
	MOV $greets.DrawChar.x_start $greets.DrawChar.x_pos
	INC $greets.DrawChar.y_pos
	SLE $greets.DrawChar.y_pos $greets.DrawChar.y_end
		RET
	JMP greets.DrawChar.outer_loop


//age <- top
#greets.Glow

	@greets.Glow.age
	@greets.Glow.new

	SUB greets.map_height $greets.age
	MOV s $greets.Glow.age

	SLE $greets.age 3
		JMP greets.Glow.no_skip

	MOV 0 $std.screen.color
	RET

	#greets.Glow.no_skip
		AND $greets.DrawChar.color 0x00F
		MUL $greets.Glow.age greets.map_width
		ADD s greets.map_start
		ADD s s
		MOV $s $greets.Glow.new

		AND $greets.DrawChar.color 0x0F0
		SFT s -4
		MUL $greets.Glow.age greets.map_width
		ADD s greets.map_start
		ADD s s
		MOV $s s
		SFT s 4
		OOR s $greets.Glow.new
		MOV s $greets.Glow.new

		AND $greets.DrawChar.color 0xF00
		SFT s -8
		MUL $greets.Glow.age greets.map_width
		ADD s greets.map_start
		ADD s s
		MOV $s s
		SFT s 8
		OOR s $greets.Glow.new
		MOV s $std.screen.color


		RET













#greets.text_start
: "this is a story all about my life how my world got flipped uppside down"
: "in west philladelphia born and raised on the playground i was spending most of my days"
: "i got in one little fight and my mother got scared"
: "she said you are moving to your uncle and untie in bell air    "
NOP


! greets.image_width = 285
! greets.image_height = 300
#greets.image_start
< greets.mem
NOP
! greets.map_height = 29
! greets.map_width = 16
#greets.map_start
< glowmap.mem


