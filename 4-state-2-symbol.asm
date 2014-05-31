#sof
% lets start the head at 150
MOV 500 y
@steps
JMP stateA
:9999999

#stateA
MOV $y x
BEQ x 0
JMP A_read_1
JMP A_read_0
#A_read_0
MOV 1 $y
INC y
JMP stateB
#A_read_1
MOV 1 $y
DEC y
JMP stateB

#stateB
MOV $y x
BEQ x 0
JMP B_read_1
JMP B_read_0
#B_read_0
MOV 1 $y
DEC y
JMP stateA
#B_read_1
MOV 0 $y
DEC y
JMP stateC

#stateC
MOV $y x
BEQ x 0
JMP C_read_1
JMP C_read_0
#C_read_0
MOV 1 $y
INC y
JMP halt_state
#C_read_1
MOV 1 $y
DEC y
JMP stateD

#stateD
MOV $y x
BEQ x 0
JMP D_read_1
JMP D_read_0
#D_read_0
MOV 1 $y
INC y
JMP stateD
#D_read_1
MOV 0 $y
INC y
JMP stateA

#halt_state
HLT
