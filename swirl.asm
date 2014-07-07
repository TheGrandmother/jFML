< std.asm
< graphics.asm
! image_width = 300
! image_height = 299
@column
@shift
@image_pointer
@thing_pointer
@lol_counter
@x_pos
@y_pos

#swirl.start
MOV 1 $lol_counter
MOV 0 $shift
JSR graphics.Clear
@factor
#super_loop

MOV 0 $x_pos
MOV 0 $y_pos
MOV 0 $column
MOV 1 $factor
MOV 0 $lol_counter
MOV 0 $thing_pointer
//MOV $imgae_start $image_pointer
#big_loop
	MUL $column image_width
	ADD s image_start
	MOV s $image_pointer
	MOV 0 $thing_pointer
	SUB $shift $thing_pointer
	MOV s $thing_pointer
	#smal_loop
		MOV image_width s
		MOV $thing_pointer s
		JSR swirl.mod
		ADD s $image_pointer
		MOV $s s
		JSR graphics.SetColor
		MOV $y_pos s
		MOV $x_pos s
		JSR graphics.PutPixel
		INC $x_pos
		INC $thing_pointer
		SGR $x_pos image_width
		JMP smal_loop
	MOV 0 $x_pos
	INC $y_pos
	INC $column
	//MUL $lol_counter 2
	//MOV s $shift
	ADD $shift $factor
	MOV s $shift
	INC $lol_counter
	SGR $y_pos image_height
	JMP big_loop
JSR graphics.UpdateAndWait
//JSR graphics.Clear
MOV 0 $x_pos
MOV 0 $y_pos
MOV 0 $column
INC $shift
INC $shift
MOD $lol_counter 10
SNE s 0
INC $shift
INC $lol_counter
MOV 0 $thing_pointer
JMP big_loop

HLT




#small_loop_end



#swirl.end
HLT

// n mod m
//n is on top
#swirl.mod
MOV s x
MOV s y
LES x 0
JOO swirl.mod.less
MOD x y
RET
#swirl.mod.less
MOD x y
SUB y s
RET




HLT








HLT



#image_start
< we.mem
#image_end
NOP

