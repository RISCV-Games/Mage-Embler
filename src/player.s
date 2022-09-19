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
	
loop_draw_cursor_trail:
	# if trail[i] == -1 then return
	lb t1, 0(s0)
	li t2, -1
	beq t1, t2, ret_draw_cursor_trail

	# if trail[i+1] == -1 then t1 = tile = TRAIL_HEAD_TILE
	lb t1, 2(s0)
	beq t1, t2, is_head_draw_cursor_trail

	li t1, TRAIL_BODY_TILE
	j is_body_draw_cursor_trail
is_head_draw_cursor_trail:
	li t1, TRAIL_HEAD_TILE
is_body_draw_cursor_trail:

	# Draw the tile
	la a0, tiles
	lb a1, 0(s0)
	lb a2, 1(s0)
	mv a3, t1
	jal RENDER_TILE

	addi s0, s0, 2
	j loop_draw_cursor_trail

ret_draw_cursor_trail:
	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 8


#####################################################
# Monta e desenha o caminho feito pelo cursor na tela
#####################################################
# a0 = keyCode
#####################################################
MAKE_PATH:
	