JMP begin
#mod
:4326789
#increment
:336789
#multiplier
:254789
#seed
:3429
#begin
MOV $seed s
#loop
MUL $multiplier s
ADD s $increment
MOD s $mod
MOV s x
MOV x s
MOV x s
INC y
BEQ y 10
JMP loop
HLT

