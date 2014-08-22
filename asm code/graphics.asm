//This is a halfdone graphics library.
< std.constants.asm
< std.asm
NOP
< std.io.asm
NOP
#graphics.INIT
MOV 0xBABE y
JSR graphics.UpdateAndWait
JMP graphics.ESCAPE

#graphics.Update
	MOV 1 $std.screen.update_bit
	RET
HLT

#graphics.UpdateAndWait
	MOV 1 $std.screen.update_bit
	#graphics.UpdateAndWait.loop
	SEQ $std.screen.update_bit 0
	JMP graphics.UpdateAndWait.loop
	RET

//Color is on stack
//If color is greater than 0xFFF it will be set to 0xFFF
//IF color is less than 0x000 it will be set to 0x000
#graphics.SetColor
	MOV s x
	SLE x 0xFF
	MOV 0xFF $std.screen.color
	SGR x 0x00
	MOV 0x00 $std.screen.color
	MOV x $std.screen.color
	RET
HLT


//color is on top
//Only the used bitts are set the others are masked out
#graphics.SetRed
	MOV s x
	SLE x 0xF
	MOV 0xF x
	MOV x s
	SFT s 8
	AND s 0xF00
	MOV s x
	AND $std.screen.color 0x0FF
	OOR s x
	MOV s $std.screen.color
	RET
HLT

//color is on top
//Only the used bitts are set the others are masked out
#graphics.SetGreen
	MOV s x
	SLE x 0xF
	MOV 0xF x
	SFT s 4
	AND s 0x0F0
	MOV s x
	AND $std.screen.color 0xF0F
	OOR s x
	MOV s $std.screen.color
	RET
HLT
//color is on top
//Only the used bitts are set the others are masked out
#graphics.SetBlue
	MOV s x
	SLE x 0xF
	MOV 0xF x
	AND s 0x00F
	MOV s x
	AND $std.screen.color 0xFF0
	OOR s x
	MOV s $std.screen.color
	RET
HLT




#graphics.Clear

	@graphics.Clear.tmp
	mov std.screen.start x
	#graphics.Clear.loop
		MOV 0 $x
		INC x
		SEQ x std.screen.end
		JMP graphics.Clear.loop
		RET


#graphics.QuickPutPixel
	//MOV s x
	//MOV s y
	ADD s std.screen.start
	MOV s x
	MUL s std.screen.width
	ADD s x
	MOV $std.screen.color $s
	RET

//#graphics.QuickPutPixel
//	MOV s x
//	MOV s y
//	ADD x std.screen.start
//	MOV s x
//	MUL y std.screen.width
//	ADD s x
//	MOV $std.screen.color $s
//	RET

// x <- Top
// y
#graphics.PutPixel
	@graphics.PutPixel.x_pos
	@graphics.PutPixel.y_pos
	MOV s $graphics.PutPixel.x_pos
	MOV s $graphics.PutPixel.y_pos

	SLE $graphics.PutPixel.x_pos std.screen.width					//Check that x is in bounds
		JMP graphics.PutPixel.x_out_of_bounds

	SGR $graphics.PutPixel.x_pos 0
		JMP graphics.PutPixel.x_out_of_bounds

	SLE $graphics.PutPixel.y_pos std.screen.height					//Check that y is in bounds
		JMP graphics.PutPixel.y_out_of_bounds

	SGR $graphics.PutPixel.y_pos 0									//Check that y is in bounds
		JMP graphics.PutPixel.y_out_of_bounds

	MUL $graphics.PutPixel.y_pos std.screen.width
	ADD s $graphics.PutPixel.x_pos
	ADD s std.screen.start
	MOV $std.screen.color $s				//addr = y*width+x
	RET

	#graphics.PutPixel.x_out_of_bounds
		RET

	#graphics.PutPixel.y_out_of_bounds
		RET


//X is on top. Y is on bottom
#graphics.GetPixel
	MOV s x
	MOV s y
	GRT x std.screen.width
	JOO graphics.PutPixel.x_out_of_bounds
	ADD x std.screen.start
	MOV s x
	GRT y std.screen.height
	JOO graphics.PutPixel.y_out_of_bounds
	MUL y std.screen.width
	ADD s x
	MOV $s s
	RET
	HLT
	#graphics.GetPixel.x_out_of_bounds
		MOV s x
		MOV 0 s
		RET
		HLT
	#graphics.GetPixel.y_out_of_bounds
		MOV 0 s
		RET
		HLT

//x0
//y0
//x1
//y1
@graphics.FillRectangle.x0
@graphics.FillRectangle.y0
@graphics.FillRectangle.x1
@graphics.FillRectangle.y1
@graphics.FillRectangle.x_pos
@graphics.FillRectangle.y_pos
#graphics.FillRectangle
	MOV s $graphics.FillRectangle.x0
	MOV s $graphics.FillRectangle.y0
	MOV s $graphics.FillRectangle.x1
	MOV s $graphics.FillRectangle.y1


	//Need to do some bounds checking
	SLE $graphics.FillRectangle.y1 std.screen.height
		MOV std.screen.height $graphics.FillRectangle.y1

	SLE $graphics.FillRectangle.x1 std.screen.width
		MOV std.screen.width $graphics.FillRectangle.x1

	SGR $graphics.FillRectangle.y0 0
		MOV 0 $graphics.FillRectangle.y0

	SGR $graphics.FillRectangle.x0 0
		MOV 0 $graphics.FillRectangle.x0

	MOV $graphics.FillRectangle.x0 $graphics.FillRectangle.x_pos
	MOV $graphics.FillRectangle.y0 $graphics.FillRectangle.y_pos

	#graphics.FillRectangle.outer
		SLE $graphics.FillRectangle.y_pos $graphics.FillRectangle.y1
			RET
		#graphics.FillRectangle.inner

			ADD $graphics.FillRectangle.x_pos std.screen.start
			MUL $graphics.FillRectangle.y_pos std.screen.width
			ADD s s
			MOV $std.screen.color $s

			INC $graphics.FillRectangle.x_pos
			SGR $graphics.FillRectangle.x_pos $graphics.FillRectangle.x1
				JMP graphics.FillRectangle.inner

		MOV $graphics.FillRectangle.x0 $graphics.FillRectangle.x_pos
		INC $graphics.FillRectangle.y_pos
		//SGR $graphics.FillRectangle.y_pos $graphics.FillRectangle.y1
			JMP graphics.FillRectangle.outer
	RET

//sprite_address
//x0
//y0
//width
//height
//Draws the desired image. Uses blitting. Black pixels are not drawn "transparent".
//Does not draw if pixel if sprite is out of bounds
#graphics.DrawSprite
	@graphics.DrawSprite.sprite_address
	@graphics.DrawSprite.x0
	@graphics.DrawSprite.y0
	@graphics.DrawSprite.x1
	@graphics.DrawSprite.y1
	@graphics.DrawSprite.width
	@graphics.DrawSprite.height
	@graphics.DrawSprite.x_pos
	@graphics.DrawSprite.y_pos


	MOV s $graphics.DrawSprite.sprite_address
	MOV s $graphics.DrawSprite.x0
	MOV s $graphics.DrawSprite.y0
	MOV s $graphics.DrawSprite.width
	MOV s $graphics.DrawSprite.height
	MOV 0 $graphics.DrawSprite.x_pos
	MOV 0 $graphics.DrawSprite.y_pos

	ADD $graphics.DrawSprite.x0 $graphics.DrawSprite.width
	MOV s $graphics.DrawSprite.x1

	ADD $graphics.DrawSprite.y0 $graphics.DrawSprite.height
	MOV s $graphics.DrawSprite.y1

	SUB $graphics.DrawSprite.x0 1
	SGR s 0												//We need to do it like this since SGR is not inclusive
		RET

	SUB $graphics.DrawSprite.y0 1
	SGR s 0
		RET

	SLE $graphics.DrawSprite.x1 std.screen.width
		RET

	SLE $graphics.DrawSprite.y1 std.screen.height
		RET												//Assert that sprite will not lie outside screen

	#graphics.DrawSprite.outer_loop
		SNE $graphics.DrawSprite.y_pos $graphics.DrawSprite.height
			RET											//We put the break codition here instead.

		#graphics.DrawSprite.inner_loop
			MUL $graphics.DrawSprite.y_pos $graphics.DrawSprite.width
			ADD s $graphics.DrawSprite.x_pos
			ADD s $graphics.DrawSprite.sprite_address
			MOV $s x									//Compute address

			SNE x 0										//Dont draw if black
				JMP graphics.DrawSprite.skip

			MOV x $std.screen.color

			ADD $graphics.DrawSprite.y_pos $graphics.DrawSprite.y0
			ADD $graphics.DrawSprite.x_pos $graphics.DrawSprite.x0
			JSR graphics.QuickPutPixel

			#graphics.DrawSprite.skip

			INC $graphics.DrawSprite.x_pos

			SEQ $graphics.DrawSprite.x_pos $graphics.DrawSprite.width
				JMP graphics.DrawSprite.inner_loop

		MOV 0 $graphics.DrawSprite.x_pos

		INC $graphics.DrawSprite.y_pos

		JMP graphics.DrawSprite.outer_loop


//sprite_address  <- top
//x0
//y0
//width
//height
//new_width
//new_height
//Draws the desired image. Uses blitting. Black pixels are not drawn "transparent".
//Does not draw if pixel if sprite is out of bounds
#graphics.DrawScaledSprite
	@graphics.DrawScaledSprite.sprite_address
	@graphics.DrawScaledSprite.x0
	@graphics.DrawScaledSprite.y0
	@graphics.DrawScaledSprite.x1
	@graphics.DrawScaledSprite.y1
	@graphics.DrawScaledSprite.w0
	@graphics.DrawScaledSprite.h0
	@graphics.DrawScaledSprite.w1
	@graphics.DrawScaledSprite.h1
	@graphics.DrawScaledSprite.x_pos
	@graphics.DrawScaledSprite.y_pos


	MOV s $graphics.DrawScaledSprite.sprite_address
	MOV s $graphics.DrawScaledSprite.x0
	MOV s $graphics.DrawScaledSprite.y0
	MOV s $graphics.DrawScaledSprite.w0
	MOV s $graphics.DrawScaledSprite.h0
	MOV s $graphics.DrawScaledSprite.w1
	MOV s $graphics.DrawScaledSprite.h1

	MOV 0 $graphics.DrawScaledSprite.x_pos
	MOV 0 $graphics.DrawScaledSprite.y_pos

	ADD $graphics.DrawScaledSprite.x0 $graphics.DrawScaledSprite.w1
	MOV s $graphics.DrawScaledSprite.x1

	ADD $graphics.DrawScaledSprite.y0 $graphics.DrawScaledSprite.h1
	MOV s $graphics.DrawScaledSprite.y1

	SUB $graphics.DrawScaledSprite.x0 1
	SGR s 0												//We need to do it like this since SGR is not inclusive
		RET

	SUB $graphics.DrawScaledSprite.y0 1
	SGR s 0
		RET

	SLE $graphics.DrawScaledSprite.x1 std.screen.width
		RET

	SLE $graphics.DrawScaledSprite.y1 std.screen.height
		RET												//Assert that sprite will not lie outside screen

	#graphics.DrawScaledSprite.outer_loop

		#graphics.DrawScaledSprite.inner_loop

			//First we must compute the corresponding pixel in the sprites bitmap
			//SUB $graphics.DrawScaledSprite.w0 1
			MUL $graphics.DrawScaledSprite.x_pos $graphics.DrawScaledSprite.w0
			DIV s $graphics.DrawScaledSprite.w1
			MOV s x									// (x*(w0-1))/w1

			//SUB $graphics.DrawScaledSprite.h0 1
			MUL $graphics.DrawScaledSprite.y_pos  $graphics.DrawScaledSprite.h0
			DIV s $graphics.DrawScaledSprite.h1
			MOV s y									// (y*(h0-1))/h1


			MUL y $graphics.DrawScaledSprite.w0
			ADD x s
			ADD s $graphics.DrawScaledSprite.sprite_address
			MOV $s x

			SNE x 0										//Dont draw if black
				JMP graphics.DrawScaledSprite.skip

			//MOV x $std.screen.color

			ADD $graphics.DrawScaledSprite.y_pos $graphics.DrawScaledSprite.y0
			MUL s std.screen.width
			ADD $graphics.DrawScaledSprite.x_pos $graphics.DrawScaledSprite.x0
			ADD s s
			ADD s std.screen.start
			MOV x $s
			//JSR graphics.QuickPutPixel
			//JSR graphics.UpdateAndWait

			#graphics.DrawScaledSprite.skip

			INC $graphics.DrawScaledSprite.x_pos

			SEQ $graphics.DrawScaledSprite.x_pos $graphics.DrawScaledSprite.w1
				JMP graphics.DrawScaledSprite.inner_loop

		MOV 0 $graphics.DrawScaledSprite.x_pos

		INC $graphics.DrawScaledSprite.y_pos

		SEQ $graphics.DrawScaledSprite.y_pos $graphics.DrawScaledSprite.h1
			JMP graphics.DrawScaledSprite.outer_loop	//We put the break codition here instead.
		RET
		JMP graphics.DrawScaledSprite.outer_loop




//x0 <- TOP
//y0
//x1
//y1
#graphics.Line
	@graphics.Line.x0
	@graphics.Line.y0
	@graphics.Line.x1
	@graphics.Line.y1
	@graphics.Line.dx
	@graphics.Line.dy
	@graphics.Line.err
	@graphics.Line.e2
	@graphics.Line.sx
	@graphics.Line.sy

	MOV s $graphics.Line.x0
	MOV s $graphics.Line.y0
	MOV s $graphics.Line.x1
	MOV s $graphics.Line.y1


	SUB $graphics.Line.x1 $graphics.Line.x0
	JSR std.Abs
	MOV s $graphics.Line.dx 				//dx = abs(x1-x0)

	SUB $graphics.Line.y1 $graphics.Line.y0
	JSR std.Abs
	MOV s $graphics.Line.dy					//dy = abs(y1-y0)

	MOV 1 $graphics.Line.sx
	SLE $graphics.Line.x0 $graphics.Line.x1	//if (x0 < y0) then sx := 1 else sx := -1
		MOV -1 $graphics.Line.sx

	MOV 1 $graphics.Line.sy
	SLE $graphics.Line.y0 $graphics.Line.y1 //if y0 < y1 then sy := 1 else sy := -1
		MOV -1 $graphics.Line.sy

	SUB $graphics.Line.dx $graphics.Line.dy
	MOV s $graphics.Line.err				//err := dx-dy

	#graphics.Line.loop

		MOV 123456 s
		JSR std.io.PrintDecimal
		JSR std.io.NewLine
		JSR graphics.UpdateAndWait

		//Do bounds checkign
		// This should preferably be moved outside of the loop.
		SGR $graphics.Line.x0 -1			// must skip on 0
			RET

		SGR $graphics.Line.y0 -1			// must skip on 0
			RET

		SLE $graphics.Line.x0 std.screen.width
			RET

		SLE $graphics.Line.y0 std.screen.height
			RET

		//MOV $graphics.Line.y0 s
		//MOV $graphics.Line.x0 s
		//JSR graphics.QuickPutPixel			//No need for boundcheks
		MUL $graphics.Line.y0 std.screen.width
		ADD s std.screen.start
		ADD s $graphics.Line.x0
		MOV $std.screen.color $s

		SUB $graphics.Line.y1 $graphics.Line.y0
		SUB $graphics.Line.x1 $graphics.Line.x0
		ADD s s
		SNE s 0								//if x0 = x1 and y0 = y1 exit loop
			RET

		MUL $graphics.Line.err 2
		MOV s $graphics.Line.e2 			// e2 := 2*err

		MUL $graphics.Line.dy -1
		SGR $graphics.Line.e2 s				// if e2 > -dy then
			JMP graphics.Line.skip1

		SUB $graphics.Line.err $graphics.Line.dy
		MOV s $graphics.Line.err			// err := err - dy

		ADD $graphics.Line.x0 $graphics.Line.sx
		MOV s $graphics.Line.x0				//x0 := x0 + sx

		//End if
		#graphics.Line.skip1


		SLE $graphics.Line.e2 $graphics.Line.dx	// if e2 > dx then
			JMP graphics.Line.skip2

		ADD $graphics.Line.err $graphics.Line.dx
		MOV s $graphics.Line.err			// err := err + dx

		ADD $graphics.Line.y0 $graphics.Line.sy
		MOV s $graphics.Line.y0				//y0 := y0 + sy

		//End if
		#graphics.Line.skip2

		JMP graphics.Line.loop












#graphics.ESCAPE
