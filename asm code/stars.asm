< graphics.asm
< std.asm
 <std.math.asm

! stars.max_z = 20
! stars.number_of_stars = 1000
@ stars.x_list+1000
@ stars.y_list+1000
@ stars.z_list+1000
@ stars.dx
@ stars.dy
@ stars.angle
@ stars.timer
@ stars.timer2
@ stars.halfway
! stars.max_vel = 15

JMP stars.ESCAPE

#stars.PlayScene
	MOV 0 $stars.dx
	MOV 0 $stars.dy
	MOV 0 $stars.angle
	MOV 0 $stars.halfway
	JSR stars.RandomizeAll
	JSR graphics.Clear
	MOV $std.timer_address $stars.timer
	MOV $std.timer_address $stars.timer2
	JSR stars.LoadCodeBy

	#stars.loop
		SUB $std.timer_address $stars.timer
		GRT s 20000
		EQL $stars.halfway 0
		AND s s
		SEQ s 0
			JSR stars.LoadMusicBy

		SUB $std.timer_address $stars.timer
		GRT s 40000
		AND s $stars.halfway
		SEQ s 0
			RET

		JSR stars.Update
		JSR stars.DrawAll
		JSR graphics.UpdateAndWait
		JSR stars.ClearAll
		JSR stars.UpdateVector
		JMP stars.loop
	RET

HLT

#stars.UpdateVector
	MOV $stars.angle s
	JSR std.math.Sin
	MUL s stars.max_vel
	DIV s 255
	MOV s $stars.dx

	MOV $stars.angle s
	ADD s 90
	DIV s 2
	JSR std.math.Sin
	MUL s stars.max_vel
	DIV s 255
	MOV s $stars.dy

	INC $stars.angle
	RET



#stars.Update
	@stars.Update.index
	@stars.Update.new_x
	@stars.Update.new_y
	@stars.Update.new_dx
	@stars.Update.new_dy
	@stars.Update.z
	MOV 0 $stars.Update.index

	#stars.Update.loop
		ADD $stars.Update.index stars.z_list
		MOV $s $stars.Update.z

		ADD $stars.Update.z 2
		MUL s $stars.dx
		DIV s stars.max_z

		MOV s $stars.Update.new_dx

		ADD $stars.Update.z 2
		MUL s $stars.dy
		DIV s stars.max_z

		MOV s $stars.Update.new_dy

		ADD $stars.Update.index stars.x_list
		ADD $s $stars.Update.new_dx
		MOV s $stars.Update.new_x

		ADD $stars.Update.index stars.y_list
		ADD $s $stars.Update.new_dy
		MOV s $stars.Update.new_y

		MOV std.screen.width s
		MOV $stars.Update.new_x  s
		JSR std.math.UnsignedMod
		MOV s $stars.Update.new_x

		MOV std.screen.height s
		MOV $stars.Update.new_y  s
		JSR std.math.UnsignedMod
		MOV s $stars.Update.new_y

		ADD $stars.Update.index stars.x_list
		MOV $stars.Update.new_x $s

		ADD $stars.Update.index stars.y_list
		MOV $stars.Update.new_y $s

		INC $stars.Update.index
		SEQ $stars.Update.index stars.number_of_stars
			JMP stars.Update.loop
	RET




#stars.ClearAll
	@stars.ClearAll.index
	MOV 0 $stars.ClearAll.index
	MOV 0x000 $std.screen.color
	#stars.ClearAll.loop
		ADD $stars.ClearAll.index stars.y_list
		MOV $s s

		ADD $stars.ClearAll.index stars.x_list
		MOV $s s

		JSR graphics.PutPixel

		INC $stars.ClearAll.index

		SEQ $stars.ClearAll.index stars.number_of_stars
			JMP stars.ClearAll.loop
	RET

#stars.DrawAll
	@stars.DrawAll.index
	MOV 0 $stars.DrawAll.index
	MOV 0xFFF $std.screen.color
	#stars.DrawAll.loop
		ADD $stars.DrawAll.index stars.y_list
		MOV $s s

		ADD $stars.DrawAll.index stars.x_list
		MOV $s s

		JSR graphics.PutPixel

		INC $stars.DrawAll.index

		SEQ $stars.DrawAll.index stars.number_of_stars
			JMP stars.DrawAll.loop
	RET


#stars.RandomizeAll
	@stars.RandomizeAll.index
	MOV 0 $stars.RandomizeAll.index

	#stars.RandomizeAll.loop
		MOV $stars.RandomizeAll.index s
		JSR stars.Randomize

		INC $stars.RandomizeAll.index
		SEQ $stars.RandomizeAll.index stars.number_of_stars
			JMP stars.RandomizeAll.loop
	RET

//index
#stars.Randomize
	@stars.Randomize.index
	MOV s $stars.Randomize.index

	JSR std.Random

	MOD s std.screen.width
	MOV s x

	ADD $stars.Randomize.index stars.x_list
	MOV x $s

	JSR std.Random

	MOD s std.screen.height
	MOV s x

	ADD $stars.Randomize.index stars.y_list
	MOV x $s

	JSR std.Random
	MOD s stars.max_z
	JSR std.Abs
	MOV s x

	ADD $stars.Randomize.index stars.z_list
	MOV x $s

	RET


#stars.LoadCodeBy

	MOV stars.code_height s
	MOV stars.code_width s
	MOV 175 s
	MOV 70 s
	MOV stars.code_image_start s
	JSR graphics.DrawSprite

	RET

#stars.LoadMusicBy
	JSR graphics.Clear
	MOV 1 $stars.halfway

	MOV stars.music_height s
	MOV stars.music_width s
	MOV 175 s
	MOV 250 s
	MOV stars.music_image_start s
	JSR graphics.DrawSprite

	RET


#stars.code_image_start
! stars.code_width = 500
! stars.code_height = 118
< codeby.mem
NOP
! stars.music_width = 162
! stars.music_height = 118
#stars.music_image_start
< musicby.mem
NOP
#stars.ESCAPE














