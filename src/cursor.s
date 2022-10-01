#########################################################
# Desenha o cursor em CURSOR_POS. a0 determina
# se a cor do cursor será vermelha ou não
#########################################################
# a0 = attackMode
#########################################################
DRAW_CURSOR:
	addi sp, sp, -4
	sw ra, 0(sp)

	bne a0, zero, attack_mode_draw_cursor

	la a0, tiles
	la a1, CURSOR_ANIM
	la t0, CURSOR_POS
	lbu a2, 0(t0)
	lbu a3, 1(t0)
	li a4, CURSOR_ANIM_DELAY
	jal DRAW_ANIMATION_TILE

ret_draw_cursor:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

attack_mode_draw_cursor:
	la a0, tiles
	la a1, CURSOR_ATTACK_ANIM
	la t0, CURSOR_POS
	lbu a2, 0(t0)
	lbu a3, 1(t0)
	li a4, CURSOR_ANIM_DELAY
	jal DRAW_ANIMATION_TILE
	j ret_draw_cursor

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

	# MAKING_TRAIL = true
	la t0, MAKING_TRAIL
	li t1, 1
	sb t1, 0(t0)
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

#######################################################
# Movimenta o cursor de acordo com a tecla pressionada
# levando em consideracao uma lista de blocos atingiveis.
# A lista deve conter 0 se o cursor nao eh permitido
# naquele bloco e 1 caso contrario.
# Retorna 0 quando o cursor nao foi movimentado.
#######################################################
# a0 = keyCode
# a1 = limitation array address
#####################################################
MOVE_CURSOR_LIMITED:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)

	mv s0, a0
	mv s1, a1

	# (a0, a1) = (deltaX, deltaY)
	jal GET_DIR_FROM_KEY

	#(t0, t1) = (mouseX+deltaX, mouseY+deltaY)
	la t1, CURSOR_POS
	lb t0, 0(t1)
	lb t1, 1(t1)
	add t0, t0, a0
	add t1, t1, a1
	
	li t2, 20
	mul t1, t1, t2
	add t0, t0, t1
	add t0, t0, s1
	lb t0, 0(t0)

	beq t0, zero, not_move_cursor_limited
	mv a0, s0
	jal MOVE_CURSOR
	j ret_move_cursor_limited

not_move_cursor_limited:
	mv a0, zero

ret_move_cursor_limited:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	ret

#####################################################
# Desenha o caminho feito pelo cursor.
# O cursor é salvo como uma array de bytes na forma:
# x_0, y_0, x_1, y_1, ..., x_n, y_n, -1
#####################################################
DRAW_CURSOR_TRAIL:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw s0, 4(sp)

	# s0 = trail
	la s0, CURSOR_TRAIL

	# checks if first two trail positions are filled, if not return
	lb t0, 0(s0)
	li t2, -1
	beq t0, t2, ret_draw_cursor_trail
	lb t0, 2(s0)
	beq t0, t2, ret_draw_cursor_trail

	# if first two are filled draw the first trail tile
	jal GET_FIRST_TRAIL_TILE
	j draw_tile_draw_cursor_trail
	
loop_draw_cursor_trail:
	# if trail[i] == -1 then return
	lb t1, 0(s0)
	li t2, -1
	beq t1, t2, ret_draw_cursor_trail

	# if trail[i+1] == -1 then draw arrow
	lb t1, 2(s0)
	beq t1, t2, arrow_draw_cursor_trail

	# get correct tile to draw
	mv a0, s0
	jal GET_TRAIL_TILE

draw_tile_draw_cursor_trail:
	# Draw the tile
	mv a3, a0
	la a0, tiles
	lb a1, 0(s0)
	lb a2, 1(s0)
	jal RENDER_TILE

	addi s0, s0, 2
	j loop_draw_cursor_trail

arrow_draw_cursor_trail:
	# t0 = deltaX
	lb t0, 0(s0)
	lb t1, -2(s0)
	sub t0, t0, t1
	li t1, 1
	beq t0, t1, arrow_right_draw_cursor_trail
	li t1, -1
	beq t0, t1, arrow_left_draw_cursor_trail
	
	# t0 = deltaY
	lb t0, 1(s0)
	lb t1, -1(s0)
	sub t0, t0, t1
	li t1, 1
	beq t0, t1, arrow_down_draw_cursor_trail

	li a0, ARROW_UP_TILE
	j draw_tile_draw_cursor_trail

arrow_down_draw_cursor_trail:
	li a0, ARROW_DOWN_TILE
	j draw_tile_draw_cursor_trail

arrow_left_draw_cursor_trail:
	li a0, ARROW_LEFT_TILE
	j draw_tile_draw_cursor_trail

arrow_right_draw_cursor_trail:
	li a0, ARROW_RIGHT_TILE
	j draw_tile_draw_cursor_trail

ret_draw_cursor_trail:
	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 8
	ret

#####################################################
# Monta o caminho feito pelo cursor na tela
#####################################################
# a0 = keyCode
#####################################################
MAKE_TRAIL_LOGIC:
	addi sp, sp, -4
	sw ra, 0(sp)

	# movimenta cursor
	# a funcao retorna 0 se e somente se cursor nao mexeu
	la a1, WALKABLE_BLOCKS
	jal MOVE_CURSOR_LIMITED

	# if cursor moved then add position to trail else return
	beq a0, zero, ret_make_trail_logic

	# t0 = CURSOR_TRAIL
	la t0, CURSOR_TRAIL

	# t6 = trail.length
	li t6, 0

loop_make_trail_logic:
	lb t1, 0(t0)
	li t2, -1
	beq t1, t2, exit_loop_make_trail_logic

	addi t6, t6, 1
	addi t0, t0, 2
	j loop_make_trail_logic

exit_loop_make_trail_logic:
	li t1, 2
	blt t6, t1, add_pos_make_trail_logic

	# (t2, t3) = (mouseX, mouseY), (t4, t5) = trail[trail.length-2]
	la t1, CURSOR_POS
	lb t2, 0(t1)
	lb t3, 1(t1)
	lb t4, -4(t0)
	lb t5, -3(t0)
	xor t2, t2, t4
	xor t3, t3, t5
	add t2, t2, t3
	bne t2, zero, add_pos_make_trail_logic
	li t1, -1
	sb t1, -2(t0)
	j ret_make_trail_logic

add_pos_make_trail_logic:
	# add new mouse pos to trail
	la t1, CURSOR_POS
	lb t2, 0(t1)
	lb t3, 1(t1)
	li t4, -1
	sb t2, 0(t0)
	sb t3, 1(t0)
	sb t4, 2(t0)

ret_make_trail_logic:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

#####################################################
# Imprime o trail atual do cursor para debug.
#####################################################
PRINT_CURSOR_TRAIL:
	la t0, CURSOR_TRAIL

loop_print_cursor_trail:
	li t1, -1
	lb t2, 0(t0)

	beq t2, t1, exit_print_cursor_trail

	li a7, 1
	mv a0, t2
	ecall
	li a7, 11
	li a0, ' '
	ecall
	lb a0, 1(t0)
	li a7, 1
	ecall
	li a0, '\n'
	li a7, 11
	ecall

	addi t0, t0, 2
	j loop_print_cursor_trail

exit_print_cursor_trail:
	li a0, -1
	li a7, 1
	ecall
	li a0, '\n'
	li a7, 11
	ecall
	ret

#####################################################
# Retorna a primeira tile do trail.
#####################################################
GET_FIRST_TRAIL_TILE:
	la a0, CURSOR_TRAIL
	lb t0, 0(a0)
	lb t1, 2(a0)
	sub t0, t0, t1
	beq t0, zero, ver_get_first_trail_tile 
	li a0, TRAIL_HORIZONTAL_TILE
	ret

ver_get_first_trail_tile:
	li a0, TRAIL_VERTICAL_TILE
	ret


#####################################################
# Retorna a tile correta em a0 baseado no caminho 
# feito pelo trail.
#####################################################
# a0 = posicao atual no trail
#####################################################
GET_TRAIL_TILE:
	lb t0, -2(a0)
	lb t1, -1(a0)
	lb t2, 0(a0)
	lb t3, 1(a0)
	lb t4, 2(a0)
	lb t5, 3(a0)

	sub t6, t4, t0
	beq t6, zero, ver_get_trail_tile
	sub t6, t5, t1
	beq t6, zero, hor_get_trail_tile

	# t0 = deltaX, t1 = deltaX', t2 = deltaY, t3 = deltaY'
	sub t0, t2, t0
	sub t6, t4, t2
	sub t2, t3, t1
	sub t3, t5, t3
	mv t1, t6

	li t4, -1
	beq t0, t4, l_get_trail_tile

	li t4, 1
	beq t0, t4, r_get_trail_tile
	beq t2, t4, d_get_trail_tile

	beq t1, t4, ur_get_trail_tile
	li a0, TRAIL_UL_TILE
	ret

ur_get_trail_tile:
	li a0, TRAIL_UR_TILE
	ret

d_get_trail_tile:
	beq t1, t4, dr_get_trail_tile
	li a0, TRAIL_DL_TILE
	ret

dr_get_trail_tile:
	li a0, TRAIL_DR_TILE
	ret

r_get_trail_tile:
	beq t3, t4, rd_get_trail_tile
	li a0, TRAIL_DL_TILE
	ret

rd_get_trail_tile:
	li a0, TRAIL_UL_TILE
	ret

l_get_trail_tile:
	beq t3, t4, lu_get_trail_tile
	li a0, TRAIL_UR_TILE
	ret

lu_get_trail_tile:
	li a0, TRAIL_DR_TILE
	ret

hor_get_trail_tile:
	li a0, TRAIL_HORIZONTAL_TILE
	ret

ver_get_trail_tile:
	li a0, TRAIL_VERTICAL_TILE
	ret

#######################################################
# Para o processo de criaçao do trail e deleta o trail.
# Retorna a ultima posicao salva pelo trail
#######################################################
STOP_TRAIL:
	addi sp, sp, -4
	sw ra, 0(sp)

	jal GET_LAST_TRAIL_POS

	la t0, MAKING_TRAIL
	sb zero, 0(t0)

	la t0, CURSOR_TRAIL
	li t1, -1
	sb t1, 0(t0)

	lw ra, 0(sp)
	addi sp, sp, 4

#####################################################
# Retorna a ultima posicao salva no trail
#####################################################
GET_LAST_TRAIL_POS:
	la t0, CURSOR_TRAIL
	li t1, -1

loop_get_last_trail_pos:
	lb t2, 0(t0)
	beq t1, t2, ret_last_trail_pos

	addi t0, t0, 2
	j loop_get_last_trail_pos

ret_last_trail_pos:
	lb a0, -2(t0)
	lb a1, -1(t0)
	ret