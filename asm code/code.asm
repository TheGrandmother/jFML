< graphics.asm
< std.io.asm

@code.start_line
@code.end_line
@code.line
@code.column
@code.color
JMP code.ESCAPE
#code.PlayScene

	JSR graphics.Clear
	MOV 0 $code.start_line
	MOV 60 $code.end_line
	MOV 0 $code.line
	MOV 0 $code.column
	JSR std.io.INIT


	MOV code.image_height s
	MOV code.image_width s
	MOV 70 s
	MOV 350 s
	MOV code.image_start s
	JSR graphics.DrawSprite
	JSR graphics.UpdateAndWait
	//MOV 0x000 $code.color
	MOV 0x000 $std.io.text_color
	#lewp

			MUL $code.line code.line_width
			ADD s $code.column
			ADD s code.text_start
			MOV $s x

			SNE	x 0					//Shit be null terminated
				JMP code.next_line

			MOV x s
			JSR std.io.PrintCharacter
			//INCREMENT THE CHAR POS
			ADD $std.io.x_pos std.io.char_width_increment
			MOV s $std.io.x_pos

			INC $code.column
			JMP lewp

			#code.next_line
			JSR std.io.NewLine
			INC $code.line
			MOV 0 $code.column
			//Compute color here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			SUB $code.line $code.start_line
			MOV s x
			SGR x 30
				JMP code.skip1
			SUB 60 x
			MOV s x
			#code.skip1
			ADD x code.color_table
			MOV $s $std.io.text_color



			SEQ $code.line $code.end_line
				JMP lewp
			//RESTART
			JSR graphics.Update

			MOV 0x000 $std.screen.color
			MOV 479 s
			MOV 357 s
			MOV 0 s
			MOV 0 s
			JSR graphics.FillRectangle

			//JSR graphics.Clear

			MOV 0x000 $std.io.text_color
			INC $code.start_line
			INC $code.start_line
			INC $code.start_line
			INC $code.end_line
			INC $code.end_line
			INC $code.end_line

			MOV $code.start_line $code.line
			JSR std.io.INIT
			MUL $code.end_line code.line_width
			ADD code.text_start s
			SLE	s code.text_end
				RET
			JMP lewp





JMP lewp


NOP
!code.line_width = 60
#code.text_start
< text.mem
#code.text_end
NOP
!code.image_width = 285
!code.image_height = 325
#code.image_start
< lamp.mem





#code.color_table
:0x300
:0x400
:0x510
:0x510
:0x610
:0x720
:0x720
:0x820
:0x830
:0x931
:0xa31
:0xa41
:0xb41
:0xb41
:0xc41
:0xc51
:0xd51
:0xd51
:0xd51
:0xe61
:0xe61
:0xe71
:0xf72
:0xf72
:0xf92
:0xf93
:0xf94
:0xfa5
:0xfc6
:0xfe6
:0xfe6

#code.color_table_end
NOP
#code.ESCAPE

