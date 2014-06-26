#sof
@timer_bit
MOV 90004 s
MOV s $timer_bit
@screen_start
MOV 80000 s
MOV s $screen_start
@screen_end
MOV 90000 x
MOV x $screen_end

@random
MOV $timer_bit x
MOV $x s
MOV s $random
@rng_modulo
MOV 147483613 s
MOV s $rng_modulo
@rng_multiplier
MOV 4824871 s
MOV s $rng_multiplier
@rng_increment
MOV 72 s
MOV s $rng_increment
@wait_constant
MOV 100000 s
MOV s $wait_constant
@update_bit
MOV 90001 s
MOV s $update_bit

#start
MOV $screen_start y
MOV $first_frame x
#lewp

MOV $x s
MOV s $y
INC x
INC y
BEQ y 90000
JMP lewp

MOV $update_bit x
MOV 1 s
MOV 1 $x
JSR wait
MOV 1 s
ADD s $frame_index
MOV s y
MOV y $frame_index
MUL y $frame_length
ADD s $first_frame
MOV s x
MOV $screen_start y

MOV $frame_index s
BEQ s 11
JMP lewp
MOV 0 s
MOV s $frame_index
MOV $screen_start y
MOV $first_frame x


JMP lewp

HLT





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
MOV $random s
MUL s $rng_multiplier
ADD s $rng_increment
MOD s $rng_modulo
MOV s $random
MOV $random s
RET


:999999
@frame_number
@frame_index
#movie_length
:11
#first_frame
:100000
#frame_length
:10000
#screen_width
:100
#screen_size
:100
@color
@color_1
@color_2
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




