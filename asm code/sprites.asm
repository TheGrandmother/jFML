< graphics.asm
< std.asm
< std.math.asm

@sprites.angle
@sprites.x0
@sprites.y0

JSR graphics.Clear
MOV 0xFFF $std.screen.color
MOV std.screen.height s
MOV std.screen.width s
MOV 0 s
MOV 0 s
JSR graphics.FillRectangle
JSR graphics.UpdateAndWait

MOV 0 $sprites.angle

DIV std.screen.width 2
SUB s 20
MOV s $sprites.x0

DIV std.screen.height 2
SUB s 20
MOV s $sprites.y0

MOV sprites.width_table x
MOV sprites.width $x
INC x
MOV sprites.width $x
INC x
MOV sprites.width $x
INC x
MOV sprites.width $x

MOV sprites.height_table x
MOV sprites.height $x
INC x
MOV sprites.height $x
INC x
MOV sprites.height $x
INC x
MOV sprites.height $x

#sprites.step_once

	JSR sprites.UpdateCordinates
	JSR sprites.DrawBalls
	JSR graphics.UpdateAndWait
	INC $sprites.angle
	JSR sprites.ClearBalls
	JMP sprites.step_once





#sprites.ClearBalls				//heheheh
	@sprites.ClearBalls.x0
	@sprites.ClearBalls.y0
	@sprites.ClearBalls.x1
	@sprites.ClearBalls.y1

	MOV 0xFFF $std.screen.color

	ADD sprites.x_table 0
	ADD $s $sprites.x0
	MOV s $sprites.ClearBalls.x0
	ADD sprites.y_table 0
	ADD $s $sprites.y0
	MOV s $sprites.ClearBalls.y0
	ADD sprites.height_table 0
	ADD $sprites.ClearBalls.y0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.y1
	ADD sprites.width_table 0
	ADD $sprites.ClearBalls.x0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.x1
	MOV $sprites.ClearBalls.y1 s
	MOV $sprites.ClearBalls.x1 s
	MOV $sprites.ClearBalls.y0 s
	MOV $sprites.ClearBalls.x0 s
	JSR graphics.FillRectangle

	ADD sprites.x_table 1
	ADD $s $sprites.x0
	MOV s $sprites.ClearBalls.x0
	ADD sprites.y_table 1
	ADD $s $sprites.y0
	MOV s $sprites.ClearBalls.y0
	ADD sprites.height_table 1
	ADD $sprites.ClearBalls.y0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.y1
	ADD sprites.width_table 1
	ADD $sprites.ClearBalls.x0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.x1
	MOV $sprites.ClearBalls.y1 s
	MOV $sprites.ClearBalls.x1 s
	MOV $sprites.ClearBalls.y0 s
	MOV $sprites.ClearBalls.x0 s
	JSR graphics.FillRectangle

	ADD sprites.x_table 2
	ADD $s $sprites.x0
	MOV s $sprites.ClearBalls.x0
	ADD sprites.y_table 2
	ADD $s $sprites.y0
	MOV s $sprites.ClearBalls.y0
	ADD sprites.height_table 2
	ADD $sprites.ClearBalls.y0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.y1
	ADD sprites.width_table 2
	ADD $sprites.ClearBalls.x0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.x1
	MOV $sprites.ClearBalls.y1 s
	MOV $sprites.ClearBalls.x1 s
	MOV $sprites.ClearBalls.y0 s
	MOV $sprites.ClearBalls.x0 s
	JSR graphics.FillRectangle

	ADD sprites.x_table 3
	ADD $s $sprites.x0
	MOV s $sprites.ClearBalls.x0
	ADD sprites.y_table 3
	ADD $s $sprites.y0
	MOV s $sprites.ClearBalls.y0
	ADD sprites.height_table 3
	ADD $sprites.ClearBalls.y0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.y1
	ADD sprites.width_table 3
	ADD $sprites.ClearBalls.x0 $s
	ADD 1 s
	MOV s $sprites.ClearBalls.x1
	MOV $sprites.ClearBalls.y1 s
	MOV $sprites.ClearBalls.x1 s
	MOV $sprites.ClearBalls.y0 s
	MOV $sprites.ClearBalls.x0 s
	JSR graphics.FillRectangle










	RET

#sprites.DrawBalls
	MOV $sprites.width_table s
	MOV $sprites.height_table s
	MOV sprites.height s
	MOV sprites.width s
	ADD $sprites.y_table  $sprites.y0
	ADD $sprites.x_table  $sprites.x0
	MOV sprites.sprite_start s
	JSR graphics.DrawScaledSprite


	ADD sprites.width_table 1
	MOV $s s
	ADD sprites.height_table 1
	MOV $s s
	MOV sprites.height s
	MOV sprites.width s
	ADD sprites.y_table 1
	ADD $s  $sprites.y0
	ADD sprites.x_table 1
	ADD $s  $sprites.x0
	MOV sprites.sprite_start s
	JSR graphics.DrawScaledSprite

	ADD sprites.width_table 2
	MOV $s s
	ADD sprites.height_table 2
	MOV $s s
	MOV sprites.height s
	MOV sprites.width s
	ADD sprites.y_table 2
	ADD $s  $sprites.y0
	ADD sprites.x_table 2
	ADD $s  $sprites.x0
	MOV sprites.sprite_start s
	JSR graphics.DrawScaledSprite

	ADD sprites.width_table 3
	MOV $s s
	ADD sprites.height_table 3
	MOV $s s
	MOV sprites.height s
	MOV sprites.width s
	ADD sprites.y_table 3
	ADD $s  $sprites.y0
	ADD sprites.x_table 3
	ADD $s  $sprites.x0
	MOV sprites.sprite_start s
	JSR graphics.DrawScaledSprite


	RET

#sprites.UpdateCordinates
	@sprites.UpdateCordinates.factor
	@sprites.UpdateCordinates.sclaing_factor
	@sprites.UpdateCordinates.z_freq
	@sprites.UpdateCordinates.temp_x
	@sprites.UpdateCordinates.temp_y
	@sprites.UpdateCordinates.temp_z
	MOV 2 $sprites.UpdateCordinates.factor
	MOV 5 $sprites.UpdateCordinates.sclaing_factor
	MOV 91 $sprites.UpdateCordinates.z_freq

	//Ball1

	//x
	MOV $sprites.angle s
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_x

	//y
	MOV $sprites.angle s
	ADD $sprites.angle 90
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_y

	//z
	MOV $sprites.angle s
	MUL s $sprites.UpdateCordinates.z_freq
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_z
	MOV $sprites.UpdateCordinates.temp_z $sprites.z_table

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_x
	MOV s $sprites.x_table

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_y
	MOV s $sprites.y_table


	DIV $sprites.UpdateCordinates.temp_z $sprites.UpdateCordinates.sclaing_factor
	DIV 255 $sprites.UpdateCordinates.sclaing_factor
	SUB s 15
	ADD s s
	MOV s x
	//ADD x sprites.width
	MOV x $sprites.width_table
	//ADD x sprites.height
	MOV x $sprites.height_table


	//Ball2
	//x
	MOV $sprites.angle s
	ADD s 90
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_x

	//y
	MOV $sprites.angle s
	ADD $sprites.angle 180
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_y

	//z
	MOV $sprites.angle s
	ADD s 90
	MUL s $sprites.UpdateCordinates.z_freq
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_z
	MOV $sprites.UpdateCordinates.temp_z $sprites.z_table

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_x
	MOV s x
	ADD sprites.x_table 1
	MOV x $s

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_y
	MOV s x
	ADD sprites.y_table 1
	MOV x $s


	DIV $sprites.UpdateCordinates.temp_z $sprites.UpdateCordinates.sclaing_factor
	DIV 255 $sprites.UpdateCordinates.sclaing_factor
	SUB s 15
	ADD s s
	MOV s x
	//ADD x sprites.width
	ADD sprites.width_table 1
	MOV x $s
	//ADD x sprites.height
	ADD sprites.height_table 1
	MOV x $s

	//Ball3
	//x
	MOV $sprites.angle s
	ADD s 180
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_x

	//y
	MOV $sprites.angle s
	ADD $sprites.angle 270
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_y

	//z
	MOV $sprites.angle s
	ADD s 180
	MUL s $sprites.UpdateCordinates.z_freq
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_z
	MOV $sprites.UpdateCordinates.temp_z $sprites.z_table

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_x
	MOV s x
	ADD sprites.x_table 2
	MOV x $s

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_y
	MOV s x
	ADD sprites.y_table 2
	MOV x $s


	DIV $sprites.UpdateCordinates.temp_z $sprites.UpdateCordinates.sclaing_factor
	DIV 255 $sprites.UpdateCordinates.sclaing_factor
	SUB s 15
	ADD s s
	MOV s x
	//ADD x sprites.width
	ADD sprites.width_table 2
	MOV x $s
	//ADD x sprites.height
	ADD sprites.height_table 2
	MOV x $s


	//Ball4
	//x
	MOV $sprites.angle s
	ADD s 270
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_x

	//y
	MOV $sprites.angle s
	ADD $sprites.angle 360
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_y

	//z
	MOV $sprites.angle s
	ADD s 270
	MUL s $sprites.UpdateCordinates.z_freq
	JSR std.math.Sin
	DIV s $sprites.UpdateCordinates.factor
	MOV s $sprites.UpdateCordinates.temp_z
	MOV $sprites.UpdateCordinates.temp_z $sprites.z_table

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_x
	MOV s x
	ADD sprites.x_table 3
	MOV x $s

	DIV $sprites.UpdateCordinates.temp_z 2
	ADD s $sprites.UpdateCordinates.temp_y
	MOV s x
	ADD sprites.y_table 3
	MOV x $s


	DIV $sprites.UpdateCordinates.temp_z $sprites.UpdateCordinates.sclaing_factor
	DIV 255 $sprites.UpdateCordinates.sclaing_factor
	SUB s 15
	ADD s s
	MOV s x
	//ADD x sprites.width
	ADD sprites.width_table 3
	MOV x $s
	//ADD x sprites.height
	ADD sprites.height_table 3
	MOV x $s


	RET

@sprites.x_table+4
@sprites.y_table+4
@sprites.z_table+4
@sprites.width_table+4
@sprites.height_table+4

! sprites.width = 18
! sprites.height = 18
#sprites.sprite_start
< orb.mem
