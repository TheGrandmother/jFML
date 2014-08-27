< graphics.asm
< std.asm

JSR graphics.Clear
#laup
MOV 0xFFF $std.screen.color
JSR std.Random
JSR std.Abs
MOD s 0xFFF
MOV s $std.screen.color
JSR std.Random
MOD s 480
JSR std.Abs
JSR std.Random
MOD s 640
JSR std.Abs
JSR std.Random
MOD s 480
JSR std.Abs
JSR std.Random
MOD s 640
JSR std.Abs
JSR graphics.Line
JSR graphics.Update
JMP laup

HLT


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
		SGR $graphics.Line.x0 -1			// must skip on 0
			RET

		SGR $graphics.Line.y0 -1			// must skip on 0
			RET

		SLE $graphics.Line.x0 std.screen.width
			RET

		SLE $graphics.Line.y0 std.screen.height
			RET

		MOV $graphics.Line.y0 s
		MOV $graphics.Line.x0 s
		JSR graphics.QuickPutPixel			//No need for boundcheks

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







