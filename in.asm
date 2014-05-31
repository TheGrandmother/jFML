#sof
MOV 80000 y

#loop
MOV 255 $y
INC y
BEQ y 90000
JMP loop
HLT
