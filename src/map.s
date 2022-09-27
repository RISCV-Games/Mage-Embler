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
	li t0, MAP_WIDTH
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

######################################################################
# Desenha os blocos atingíveis de acordo com WALKABLE_BLOCKS.
######################################################################
DRAW_WALKABLE_BLOCKS:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw s0, 4(sp)

	# s0 = i = 0
	li s0, 0

loop_draw_walkable_blocks:
	li t0, TILES_PER_MAP
	beq s0, t0, ret_draw_walkable_blocks

	la t0, WALKABLE_BLOCKS
	add t0, t0, s0
	lb t0, 0(t0)
	beq t0, zero, continue_loop_draw_walkable_blocks

	# a0 = tiles, a1 = x, a2 = y
	la a0, tiles
	li t0, MAP_WIDTH
	rem a1, s0, t0
	div a2, s0, t0
	li a3, BLOCK_WALKABLE
	jal RENDER_TILE

continue_loop_draw_walkable_blocks:
	addi s0, s0, 1
	j loop_draw_walkable_blocks

ret_draw_walkable_blocks:
	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 8
	ret


######################################################################
# Atualiza a lista que contêm os blocos alcançáveis.
######################################################################
# a0 = startTile.x
# a1 = startTile.y
# a2 = map
######################################################################
UPDATE_WALKABLE_BLOCKS:
	addi sp, sp, -4
	sw ra, 0(sp)

	# clear walkable blocks array
	la t0, WALKABLE_BLOCKS
	li t1, 0

loop_update_walkable_blocks:
	li t2, TILES_PER_MAP
	beq t1, t2, break_loop_update_walkable_blocks

	add t2, t0, t1
	sw zero, 0(t2)

	addi t1, t1, 4
	j loop_update_walkable_blocks

break_loop_update_walkable_blocks:

	mv a3, a2
	li a2, MOVE_RADIUS
	jal FIND_WALKABLE_BLOCKS

	lw ra, 0(sp)
	addi sp, sp, 4
	ret

######################################################################
# Preenche a lista de blocos andáveis com 1s de forma recursiva.
######################################################################
# a0 = startTile.x
# a1 = startTile.y
# a2 = totalDist
# a3 = map
######################################################################
FIND_WALKABLE_BLOCKS:
	# t0 = map[pos]
	li t0, MAP_WIDTH
	mul t0, a1, t0
	add t0, t0, a0
	add t0, a3, t0
	lb t2, 0(t0)
	li t1, BLOCK_OBSTACLE
	beq t2, t1, ret_find_walkable_blocks
	beq a2, zero, base_case_0_find_walkable_blocks

	# constrain a0 and a1
	blt a0, zero, ret_find_walkable_blocks
	blt a1, zero, ret_find_walkable_blocks
	li t1, MAP_WIDTH
	bge a0, t1, ret_find_walkable_blocks
	li t1, MAP_HEIGHT
	bge a1, t1, ret_find_walkable_blocks

	sub t0, t0, a3
	la t1, WALKABLE_BLOCKS
	add t0, t0, t1
	li t1, 1
	sb t1, 0(t0)

	addi a2, a2, -1

	addi sp, sp, -4
	sw ra, 0(sp)

	addi a0, a0, 1
	jal FIND_WALKABLE_BLOCKS

	addi a0, a0, -2
	jal FIND_WALKABLE_BLOCKS
	addi a0, a0, 1
	
	addi a1, a1, 1
	jal FIND_WALKABLE_BLOCKS

	addi a1, a1, -2
	jal FIND_WALKABLE_BLOCKS
	addi a1, a1, 1

	addi a2, a2, 1
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

ret_find_walkable_blocks:
	ret

base_case_0_find_walkable_blocks:
	blt a0, zero, ret_find_walkable_blocks
	blt a1, zero, ret_find_walkable_blocks
	li t0, MAP_WIDTH
	bge a0, t0, ret_find_walkable_blocks
	li t0, MAP_HEIGHT
	bge a1, t0, ret_find_walkable_blocks

	li t0, MAP_WIDTH
	mul t0, a1, t0
	add t0, t0, a0
	la t1, WALKABLE_BLOCKS
	add t0, t0, t1
	li t1, 1
	sb t1, 0(t0)
	ret

######################################################################
# Desenha uma bloco no mapa.
######################################################################
# a0 = lista com correspondencia entre os tipo do bloco e a tile
# a1 = tipo do bloco. Os 5 bits mais significativos escolhem a tile a
# ser renderizada e os outros 3 bits selecionam o comportamento logico
# dela, entao sao irrelevantes para essa funcao.
# a2 = x
# a3 = y
######################################################################
DRAW_BLOCK:
	addi sp, sp, -4
	sw ra, 0(sp)

	# t0 = tile number
	srli a1, a1, 3
	add t0, a0, a1
	lb t0, 0(t0)

	la a0, tiles
	mv a1, a2
	mv a2, a3
	mv a3, t0
	jal RENDER_TILE


	lw ra, 0(sp)
	addi sp, sp, 4
	ret

######################################################################
# Desenha o mapa.
######################################################################
# a0 = endereco do mapa
# a1 = lista de correspondencia de tiles.
######################################################################
DRAW_MAP:
	addi sp, sp, -16
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)

	# s0 = map, s1 = i = 0, s2 = correspondence list
	mv s0, a0
	li s1, 0
	mv s2, a1

loop_draw_map:
	li t0, TILES_PER_MAP
	bge s1, t0, ret_draw_map

	# a1 = map[s1]
	add a1, s0, s1
	lb a1, 0(a1)
	
	# a2 = x, a3 = y
	li t0, MAP_WIDTH
	rem a2, s1, t0
	div a3, s1, t0
	
	# a0 = map
	mv a0, s2
	jal DRAW_BLOCK

	addi s1, s1, 1
	j loop_draw_map


ret_draw_map:
	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	addi sp, sp, 12
	ret