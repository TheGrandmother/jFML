#sof
@screen_start
MOV 80000 x
MOV x $screen_start
@screen_end
MOV 90000 x
MOV x $screen_end
@update_bit
MOV 90001 x
MOV x $update_bit
@random
MOV 153148 x
MOV x $random
@rng_modulo
MOV 16775215 x
MOV x $rng_modulo
@rng_multiplier
MOV 11406715 x
MOV x $rng_multiplier
@rng_increment
MOV 1282013 x
MOV x $rng_increment
@wait_constant
MOV 50 x
MOV x $wait_constant


% Program plots pixels at random
#start
% Start by getting new random number
JSR rng
MOV $random s
JSR abs
MOD s 10000
ADD $screen_start s
MOV s y
MOV 255 s
MOV s $y
MOV 1 s
MOV $update_bit x
MOV s $x
JSR wait
JMP start

#rng
MOV $random s
MUL s $rng_multiplier
ADD s $rng_increment
MOD s $rng_modulo
MOV s $random
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


