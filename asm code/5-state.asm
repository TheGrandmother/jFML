#sof
% lets start the head at 150
MOV 50000 y
@steps
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
JMP stateC

#stateB
MOV $y x
BEQ x 0
JMP B_read_1
JMP B_read_0
#B_read_0
MOV 1 $y
INC y
JMP stateC
#B_read_1
MOV 1 $y
INC y
JMP stateB

#stateC
MOV $y x
BEQ x 0
JMP C_read_1
JMP C_read_0
#C_read_0
MOV 1 $y
INC y
JMP stateD
#C_read_1
MOV 0 $y
DEC y
JMP stateE

#stateD
MOV $y x
BEQ x 0
JMP D_read_1
JMP D_read_0
#D_read_0
MOV 1 $y
DEC y
JMP stateA
#D_read_1
MOV 1 $y
DEC y
JMP stateD

#stateE
MOV $y x
BEQ x 0
JMP E_read_1
JMP E_read_0
#E_read_0
MOV 1 $y
INC y
JMP halt_state
#E_read_1
MOV 0 $y
DEC y
JMP stateA


#halt_state
HLT
