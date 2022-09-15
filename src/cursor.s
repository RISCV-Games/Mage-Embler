#########################################################
#	Desenha o cursor em CURSOR_POS.                        
#########################################################
DRAW_CURSOR:
	addi sp, sp, -4
	sw ra, 0(sp)

	la a0, CURSOR_IMG
	la a1, CURSOR_ANIM
	la t0, CURSOR_POS
	lbu a2, 0(t0)
	lbu a3, 1(t0)
	jal DRAW_ANIMATION_TILE

	lw ra, 0(sp)
	addi sp, sp, 4
	ret