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
	li a4, CURSOR_ANIM_DELAY
	jal DRAW_ANIMATION_TILE

	lw ra, 0(sp)
	addi sp, sp, 4
	ret

#########################################################
# Inicializa o path do cursor com um -1 no CURSOR_TRAIL
#########################################################
INIT_CURSOR_PATH:
	li t0, -1
	la t1, CURSOR_TRAIL
	sb t0, 0(t1)
	ret

#######################################################
# Movimenta o cursor de acordo com a tecla pressionada.
# Retorna 0 quando o cursor nao foi movimentado.
#######################################################
# a0 = keyCode
#####################################################
MOVE_CURSOR:
	addi sp, sp, -4
	sw ra, 0(sp)

	# (a0, a1) = (deltaX, deltaY)
	jal GET_DIR_FROM_KEY

	# (t1, t2) = (x, y)
	la t0, CURSOR_POS
	lb t1, 0(t0)
	lb t2, 1(t0)

	# (t1, t2) = (x + deltaX, y + deltaY)
	add t1, t1, a0
	add t2, t2, a1

	# (cursorX, cursorY) = (t1, t2)
	sb t1, 0(t0)
	sb t2, 1(t0)

	# se cursor nao mexeu seta a0 = 0
	add a0, a0, a1

	# return
	lw ra, 0(sp)
	addi sp, sp, 4
	ret