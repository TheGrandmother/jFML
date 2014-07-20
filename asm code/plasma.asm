< graphics.asm
< std.math.asm
@x_pos
@y_pos
@x_orig
@y_orig
@noise_x_offs
@factor_thing
@another_thing
@x_size
@y_size

JSR graphics.Clear
MOV 0xFFF s
DIV s 2
MOV s $factor_thing
MOV 0 $x_orig
MOV 0 $y_orig
MOV 0 $x_pos
MOV 0 $y_pos
MOV 0 $noise_x_offs
MOV 0 $another_thing
MOV 10 $x_size
MOV 10 $y_size
#loop
		MOV $y_pos s
		MOV $x_pos s
		JSR plasma.NoisyFunction
		JSR graphics.SetColor
		MOV $y_pos s
		MOV $x_pos s
		JSR graphics.PutPixel
		INC $x_pos
		ADD $x_orig $x_size
		SEQ $x_pos s
		JMP loop
	MOV $x_orig $x_pos
	INC $y_pos
	ADD $y_orig $y_size
	SEQ $y_pos s
	JMP loop
DEC $y_orig
DEC $x_orig
MOV $y_orig s
MOV $x_orig s
MOV 0 $std.screen.color
JSR graphics.PutPixel
INC $y_orig
INC $x_orig

JSR graphics.UpdateAndWait
//JSR graphics.Clear
ADD 1 $noise_x_offs
MOV s $noise_x_offs
MOV $x_orig $x_pos
MOV $y_orig $y_pos
INC $y_orig
INC $x_orig
MOV $another_thing s
MUL s 5
JSR std.math.Sin
DIV s 80
ADD s $x_orig
MOV s $x_orig
INC $another_thing
INC $x_size
INC $y_size
JMP loop
HLT
	

//x
//y
#plasma.NoisyFunction
	@noisy.x_pos
	@noisy.y_pos
	MOV s $noisy.x_pos
	MOV s $noisy.y_pos
	//MOV $noisy.x_pos s
	MOV $noise_x_offs s
	JSR std.math.Sin
	
	ADD s $noisy.x_pos
	JSR std.math.Sin
	MOV s x
	MOV $noisy.y_pos s
	MUL s 1
	JSR std.math.Sin
	ADD s x
	MUL s $factor_thing
	DIV s 510
	ADD s $factor_thing
	RET


