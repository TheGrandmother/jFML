#sof
@screen_start
MOV 80000 x
MOV x $screen_start
@screen_end
MOV 90000 x
MOV x $screen_end

@random
MOV 342 x
MOV x $random
@rng_modulo
MOV 147483613 x
MOV x $rng_modulo
@rng_multiplier
MOV 4824871 x
MOV x $rng_multiplier
@rng_increment
MOV 72 x
MOV x $rng_increment
@wait_constant
MOV 5000 x
MOV x $wait_constant
@update_bit
MOV 90001 x
MOV x $update_bit

#start
JSR rng
JSR abs
MOD s 3
SUB s 1
MOV $y_pos x
ADD x s
MOV s $y_pos

JSR rng
JSR abs
MOD s 3
SUB s 1
MOV $x_pos x
ADD x s
MOV s $x_pos
MOV $y_pos s
MOV $x_pos s

JSR get_pixel
MOV s $color_1


JSR rng
JSR abs
MOD s 3
SUB s 1
MOV s $y_dir


JSR rng
JSR abs
MOD s 3
SUB s 1
MOV s $x_dir


% update temp position
MOV $y_pos s
ADD s $y_dir
MOV s $y_temp

MOV $x_pos s
ADD s $x_dir
MOV s $x_temp






MOV $y_temp s
MOV $x_temp s
JSR get_pixel
MOV s $color_2

MOV $color_1 s
JSR set_color
MOV $y_temp s
MOV $x_temp s
JSR put_pixel

MOV $color_2 s
JSR set_color
MOV $y_pos s
MOV $x_pos s
JSR put_pixel

MOV 1 s
MOV $update_bit x
MOV s $x

MOV $x_pos s
BEQ s 0
JMP skip1
MOV 50 s
MOV s $x_pos
#skip1
MOV $x_pos s
BEQ s 100
JMP skip2
MOV 50 s
MOV s $x_pos
#skip2
MOV $y_pos s
BEQ s 0
JMP skip3
MOV 50 s
MOV s $y_pos
#skip3
MOV $y_pos s
BEQ s 100
JMP skip4
MOV 50 s
MOV s $y_pos
#skip4
JSR wait

JMP start




#set_color
MOV s $color
RET

% x is on top and y is on bottom
#put_pixel
MOV s x
MUL s 100
ADD s x
ADD $screen_start s
MOV s y
MOV $color x
MOV x $y
RET

% x is on top and y is on bottom
#get_pixel
MOV s x
MUL s 100
ADD s x
ADD $screen_start s
MOV s y
MOV $y s
RET

#abs
MOV s x
LES x 0
BEQ s 0
JMP abs_neg
JMP abs_pos
#abs_neg
MUL x -1
RET
#abs_pos
MOV x s
RET

#wait
%MOV x s
%MOV y s
MOV 0 x
#wait_loop
INC x
BEQ x $wait_constant
JMP wait_loop
%MOV s y
%MOV s x
RET

#rng
MOV $time x
ADD $x $random
MUL s $rng_multiplier
ADD s $rng_increment
MOD s $rng_modulo
MOV s $random
MOV $random s
RET


:999999
@color
@color_1
@color_2
#time
:90004
#x_temp
:0
#y_temp
:0
#x_pos
:50
#y_pos
:50
#x_dir
:0
#y_dir
:0




