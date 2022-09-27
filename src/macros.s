########## Put the buffer to draw on register #########
.macro GET_BUFFER_TO_DRAW(%reg)
	addi sp, sp, -4
	sw s11, 0(sp)

	la %reg, FRAME_TO_DRAW
	lb %reg, 0(%reg)
	slli %reg, %reg, 20
	li s11, BUFFER_ADRESS
	add %reg, s11, %reg

	lw s11, 0(sp)
	addi sp, sp, 4
.end_macro

######### Verifica se eh a DE1-SoC ###############
.macro DE1(%reg,%salto)
	li %reg, 0x10008000	# carrega tp
	bne gp, %reg, %salto	# Na DE1 gp = 0 ! Não tem segmento .extern
.end_macro
