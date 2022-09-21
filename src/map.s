######################################################################
# Desenha o mapa no modo debug.
######################################################################
# a0 = endereco do mapa
######################################################################
DRAW_MAP_DEBUG:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)

	# s0 = map, s1 = i = 0
	mv s0, a0
	li s1, 0

loop_draw_map_debug:
	li t0, TILES_PER_MAP
	bge s1, t0, ret_draw_map_debug

	# a0 = map[s1]
	add a0, s0, s1
	lb a0, 0(a0)
	
	# a1 = x, a2 = y
	li t0, 20
	rem a1, s1, t0
	div a2, s1, t0

	jal DRAW_BLOCK_DEBUG

	addi s1, s1, 1
	j loop_draw_map_debug


ret_draw_map_debug:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	addi sp, sp, 12
	ret

######################################################################
# Desenha uma bloco no mapa no modo debug.
######################################################################
# a0 = tipo do bloco (BLOCK_EMPTY, BLOCK_OBSTACLE, BLOCK_ALLY ou BLOCK_ENEMY)
# a1 = x
# a2 = y
######################################################################
DRAW_BLOCK_DEBUG:
	addi sp, sp, -4
	sw ra, 0(sp)

	li t0, BLOCK_EMPTY
	bne a0, t0, not_empty_draw_block_debug
	la a0, tiles
	li a3, DEBUG_TILE_EMPTY
	jal RENDER_TILE
	j ret_draw_block_debug
not_empty_draw_block_debug:
	li t0, BLOCK_OBSTACLE
	bne a0, t0, not_obstacle_draw_block_debug
	la a0, tiles
	li a3, DEBUG_TILE_OBSTACLE
	jal RENDER_TILE
	j ret_draw_block_debug
not_obstacle_draw_block_debug:
	li t0, BLOCK_ALLY
	bne a0, t0, not_ally_draw_block_debug
	la a0, tiles
	li a3, DEBUG_TILE_ALLY
	jal RENDER_TILE
	j ret_draw_block_debug
not_ally_draw_block_debug:
	li t0, BLOCK_ENEMY
	bne a0, t0, not_enemy_draw_block_debug
	la a0, tiles
	li a3, DEBUG_TILE_ENEMY
	jal RENDER_TILE
	j ret_draw_block_debug
not_enemy_draw_block_debug:

ret_draw_block_debug:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret