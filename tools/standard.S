main: jal test
dead: j dead
test: lui $1, 0xf000
jr $ra
