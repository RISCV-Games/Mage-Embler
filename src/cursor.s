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
# Inicializa o trail do cursor com sua posição inicial.
#########################################################
INIT_CURSOR_TRAIL:
	la t0, CURSOR_POS
	lb t1, 0(t0)
	lb t2, 1(t0)
	li t3, -1
	la t4, CURSOR_TRAIL
	sb t1, 0(t4)
	sb t2, 1(t4)
	sb t3, 2(t4)
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

	# se cursor nao mexeu seta a0 = 0
	add a0, a0, a1

	# t1 = min(CURSOR_MAX_X, t1), t1 = max(0, t1)
	blt t1, zero, x_min_move_cursor
	li t6, CURSOR_MAX_X
	bgt t1, t6, x_max_move_cursor
x_max_back_move_cursor:

	# t2 = min(CURSOR_MAX_Y, t2), t2 = max(0, t2)
	blt t2, zero, y_min_move_cursor
	li t6, CURSOR_MAX_Y
	bgt t2, t6, y_max_move_cursor
y_max_back_move_cursor:

	# (cursorX, cursorY) = (t1, t2)
	sb t1, 0(t0)
	sb t2, 1(t0)

	# return
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

x_max_move_cursor:
	mv t1, t6 
	mv a0, zero
	j x_max_back_move_cursor

x_min_move_cursor:
	mv t1, zero
	mv a0, zero
	j x_max_back_move_cursor

y_min_move_cursor:
	mv t2, zero
	mv a0, zero
	j y_max_back_move_cursor

y_max_move_cursor:
	mv t2, t6
	mv a0, zero
	j y_max_back_move_cursor