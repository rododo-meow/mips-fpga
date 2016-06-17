main:   lui $16, 0x0
		lui $17, 0xf000 #SEG
		lui $18, 0xf200 #SW_l
		lui $1, 0
		lui $2, 0
		jal printt

loop:   lw $1, 40($18)
		lw $2, 40($18)
		srl $1, $1, 5
		andi $2, $2, 0x1f
		add $16, $1, $2
		sll $1, $1, 16
		sll $2, $2, 8
		or $1, $1, $2
		or $1, $1, $16
		jal printt
		j loop


printt:  sw $1, 24($17)
	 	jr $ra