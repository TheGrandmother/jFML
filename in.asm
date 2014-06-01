#sof
@screen_start
MOV 80000 x
MOV x $screen_start
@screen_end
MOV 90000 x
MOV x $screen_end

@random
MOV 153148 x
MOV x $random
@rng_modulo
MOV 147483647 x
MOV x $rng_modulo
@rng_multiplier
MOV 48271 x
MOV x $rng_multiplier
@rng_increment
MOV 0 x
MOV x $rng_increment
@wait_constant
MOV 100 x
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
JSR inc_pixel
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



#rng
MOV $random s
MUL s $rng_multiplier
ADD s $rng_increment
MOD s $rng_modulo
MOV s $random
MOV $random s
RET

% x is on top and y is on bottom
#put_pixel
MOV s x
MUL s 100
ADD s x
ADD $screen_start s
MOV s y
MOV 175 $y
RET

% x is on top and y is on bottom
#inc_pixel
MOV s x
MUL s 100
ADD s x
ADD $screen_start s
MOV s y
MOV $y s
ADD s 10
MOV s $y
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
MOV x s
MOV y s
MOV 0 x
#wait_loop
INC x
BEQ x $wait_constant
JMP wait_loop
MOV s y
MOV s x
RET


#x_pos
:50
#y_pos
:50
#x_dir
:0
#y_dir
:0



