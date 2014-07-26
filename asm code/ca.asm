< std.asm
< graphics.asm
< std.math.asm
! width = 100
! height = 80
! size = 2
@ map+10000
@ display+10000
@ step
@ index

! ca.x_start = 540
! ca.y_start = 400

#START
JSR graphics.Clear
JSR ca.InitMap
MOV 0 $index
#loop
	MOV $index s
	JSR ca.UpdateLine
	JSR ca.UpdateDisplay
	JSR ca.DrawAll
	JSR graphics.Update
	INC $index
	MOD $index height
	MOV s $index
	JMP loop
HLT

#ca.DrawAll
	@ca.DrawAll.x_pos	//These Are display positions
	@ca.DrawAll.y_pos

	@ca.DrawAll.x		//These are map poisitions
	@ca.DrawAll.y

	MOV 0 $ca.DrawAll.x_pos
	MOV 0 $ca.DrawAll.y_pos
	MOV 0 $ca.DrawAll.x
	MOV 0 $ca.DrawAll.y
	#ca.DrawAll.outer_loop
			#ca.DrawAll.inner_loop
				MUL $ca.DrawAll.y  width
				ADD s $ca.DrawAll.x
				ADD s display						//Chage to display
				MOV $s s
				MUL 0xFFF s
				MOV s $std.screen.color
				//MOV x $std.screen.color



				ADD $ca.DrawAll.y_pos size
				ADD $ca.DrawAll.x_pos size
				MOV $ca.DrawAll.y_pos s
				MOV $ca.DrawAll.x_pos s
				JSR graphics.FillRectangle




				ADD $ca.DrawAll.x_pos size
				MOV s $ca.DrawAll.x_pos

				INC $ca.DrawAll.x

				SEQ $ca.DrawAll.x width
					JMP ca.DrawAll.inner_loop

		MOV 0 $ca.DrawAll.x

		MOV 0 $ca.DrawAll.x_pos

		ADD $ca.DrawAll.y_pos size
		MOV s $ca.DrawAll.y_pos

		INC $ca.DrawAll.y
		SEQ $ca.DrawAll.y height
			JMP ca.DrawAll.outer_loop
	RET


#ca.InitMap
	DIV width 2
	MOV s x

	SUB height 1
	MUL s width
	ADD x s
	ADD map s
	MOV 1 $s
	RET

#ca.FillRandom
	@ca.FillRandom.x
	MOV map $ca.FillRandom.x
		#ca.FillRandom.loop
			JSR std.Random
			MOD s 2
			MOV s x
			ADD $ca.FillRandom.x map
			MOV x $s

			INC $ca.FillRandom.x
			MUL width height
		SEQ $ca.FillRandom.x s
			JMP ca.FillRandom.loop
	RET




//y
#ca.UpdateLine
	@ca.UpdateLine.source
	@ca.UpdateLine.target
	@ca.UpdateLine.x
	@ca.UpdateLine.temp
	MOV s $ca.UpdateLine.target
	SUB $ca.UpdateLine.target 1
	MOV s x
	SGR x 0
		MOV height $ca.UpdateLine.source
	MOV x $ca.UpdateLine.source

	MOV 0 $ca.UpdateLine.x
		#ca.UpdateLine.loop
			MOV $ca.UpdateLine.source s
			MOV $ca.UpdateLine.x s
			JSR ca.Rule30
			MOV s $ca.UpdateLine.temp

			MUL $ca.UpdateLine.target width
			ADD $ca.UpdateLine.x s
			ADD map s
			MOV $ca.UpdateLine.temp $s

			INC $ca.UpdateLine.x
		SEQ $ca.UpdateLine.x width
			JMP ca.UpdateLine.loop
	RET






#ca.UpdateDisplay
	@ca.UpdateDisplay.source
	@ca.UpdateDisplay.target
	ADD $index 1
	MOV s $ca.UpdateDisplay.source
	MOV 0 $ca.UpdateDisplay.target

		#ca.UpdateDisplay.loop

			MOV $ca.UpdateDisplay.target s
			MOD $ca.UpdateDisplay.source height
			JSR ca.SwapLine

			INC $ca.UpdateDisplay.target
			INC $ca.UpdateDisplay.source

			MOD $ca.UpdateDisplay.source height

		SEQ s $index
			JMP ca.UpdateDisplay.loop

	SUB height 1
	MOV $index s
	JSR ca.SwapLine
	RET

//x
//y
#ca.Rule30
	@ca.Rule30.x
	@ca.Rule30.y
	//@ca.Rule30.middle_addr
	@ca.Rule30.p
	@ca.Rule30.q
	@ca.Rule30.r

	MOV s $ca.Rule30.x
	MOV s $ca.Rule30.y

	MUL $ca.Rule30.y width
	ADD s $ca.Rule30.x
	ADD s map
	MOV $s $ca.Rule30.q		//q = (y*width)+x+map

	MOV width s
	SUB $ca.Rule30.x 1
	JSR std.math.UnsignedMod
	ADD s map
	MUL $ca.Rule30.y width
	ADD s s
	MOV $s $ca.Rule30.p		//p = (y*width)+(Mod(x-1,width))+map

	MOV width s
	ADD $ca.Rule30.x 1
	JSR std.math.UnsignedMod
	ADD s map
	MUL $ca.Rule30.y width
	ADD s s
	MOV $s $ca.Rule30.q		//p = (y*width)+(Mod(x-1,width))+map

	MUL $ca.Rule30.q $ca.Rule30.r
	ADD $ca.Rule30.r s
	ADD $ca.Rule30.q s
	ADD $ca.Rule30.p s
	MOD s 2					//return Mod(p+q+r+q*r,2)
	RET

//Source
//Target
#ca.SwapLine
	@ca.SwapLine.x
	@ca.SwapLine.source_y
	@ca.SwapLine.target_y
	@ca.SwapLine.temp
	MOV s $ca.SwapLine.source_y
	MOV s $ca.SwapLine.target_y
	MOV 0 $ca.SwapLine.x

		#ca.SwapLine.loop
		MUL $ca.SwapLine.source_y width
		ADD s $ca.SwapLine.x
		ADD s map
		MOV $s $ca.SwapLine.temp

		MUL $ca.SwapLine.target_y width
		ADD s $ca.SwapLine.x
		ADD s display
		MOV $ca.SwapLine.temp $s

		INC $ca.SwapLine.x

		SEQ $ca.SwapLine.x width
			JMP ca.SwapLine.loop
		RET
