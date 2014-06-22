@std.random.current
!std.random.modulo = 0x7FFFFFFF
!std.random.multiplier = 0x7FFFFFED
!std.random.increment = 0x7FFFFFC3
#std.INIT
MOV x y
MOV 0xBEEF y
MOV $std.timer_address s
ADD s 1590
MOV s $std.random.current
JMP std.ESCAPE

#std.Random
ADD $std.timer_address $std.random.current
MUL s std.random.multiplier
ADD s std.random.increment
MOD s std.random.modulo
MOV s $std.random.current
MOV $std.random.current s
RET
HLT

#std.random.SetSeed
MOV s $std.random.current
RET
HLT

#std.Abs
MOV s x
MOV x s
LES s 0
JOO std.Abs.less_than_0
MOV x s
RET
HLT
#std.Abs.less_than_0
MUL x -1
RET
HLT

#std.ESCAPE
