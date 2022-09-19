#####################################################
# Retorna uma direçao nos registradores a0 e a1 a partir
# da tecla que foi pressionada, da seguinte forma:
# keyCode | a0 | a1
#    'W'  | 0  | -1
#    'A'  | -1  | 0
#    'S'  | 0  | 1
#    'D'  | 1  | 0
# Caso keyCode nao seja uma das letras acima retorna
# GET_DIR_EXCEPTION no a0.
#####################################################
# a0 = keyCode
#####################################################
GET_DIR_FROM_KEY:
	li t0, 'W'
	bne, a0, t0, notW_get_dir_from_key
	li a0, 0
	li a1, -1
	ret
notW_get_dir_from_key:
	li t0, 'A'
	bne, a0, t0, notA_get_dir_from_key
	li a0, -1
	li a1, 0
	ret
notA_get_dir_from_key:
	li t0, 'S'
	bne, a0, t0, notS_get_dir_from_key
	li a0, 0
	li a1, 1
	ret
notS_get_dir_from_key:
	li t0, 'D'
	bne, a0, t0, notD_get_dir_from_key
	li a0, 1
	li a1, 0
	ret
notD_get_dir_from_key:
	li a0, GET_DIR_EXCEPTION
	ret

#######################################################
# Movimenta o cursor de acordo com a tecla pressionada.
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
	sb t2, 0(t0)


	# return
	lw ra, 0(sp)
	addi sp, sp, 4
	ret
