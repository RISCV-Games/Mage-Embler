############################################################
# Player (8 bytes)
# Alterar PLAYERS e PLAYER_BYTE_SIZE ao mudar o tamanho.
############################################################
# Classe representando os jogadores, tanto aliados
# quanto inimigos.
############################################################
# 0: byte posX
# 1: byte posY
# 2: byte isAlly
# 3: byte element (PLAYER_WATER, PLAYER_FIRE, PLAYER_EARTH)
#############################################################

############################################################
# Inicializa os players a partir do mapa.
############################################################
# a0 = map
# a1 = correspondence array
############################################################
INIT_PLAYERS:
	# t0 = i = 0
	li t0, 0

loop_init_players:
	li t1, TILES_PER_MAP
	bge t0, t1, ret_init_players

	add t1, t0, a0
	lb t1, 0(t1)
	andi t1, t1, 0x7
	li t2, BLOCK_ALLY
	beq t1, t2, ally_init_players
	li t2, BLOCK_ENEMY
	beq t1, t2, enemy_init_players

continue_loop_init_players:
	addi t0, t0, 1
	j loop_init_players

ally_init_players:
	li a2, 1
	j init_init_players
enemy_init_players:
	li a2, 0
	j init_init_players

init_init_players:
	# t3 = player position in memory
	la t1, N_PLAYERS
	lb t1, 0(t1)
	li t2, PLAYER_BYTE_SIZE
	mul t2, t2, t1
	la t4, PLAYERS
	add t3, t4, t2

	# N_PLAYERS++
	la t4, N_PLAYERS
	addi t1, t1, 1
	sb t1, 0(t4)

	# (t1, t2) = (posX, posY)
	li t2, MAP_WIDTH
	rem t1, t0, t2
	div t2, t0, t2

	# t4 = tileNum
	add t4, a0, t0
	lb t4, 0(t4)
	srli t4, t4, 3
	add t4, t4, a1
	lb t4, 0(t4)

	# initialize values
	sb t1, PLAYER_BPOS_X(t3)
	sb t2, PLAYER_BPOS_Y(t3)
	sb a2, PLAYER_BIS_ALLY(t3)
	
	j continue_loop_init_players

ret_init_players:
	ret
###################################################################################
# Retorna um Player a partir de sua posição (x, y).
###################################################################################
# a0 = x
# a1 = y
###################################################################################
GET_PLAYER_BY_POS:
	la t0, PLAYERS
	# t1 = i = 0
	li t1, 0
	# t2 = nPlayers * PLAYER_BYTE_SIZE
	la t2, N_PLAYERS
	lb t2, 0(t2)
	li t3, PLAYER_BYTE_SIZE
	mul t2, t2, t3

loop_get_player_by_pos:
	bge t1, t2, ret_get_player_by_pos

	add t3, t0, t1
	lb t4, PLAYER_BPOS_X(t3)
	lb t5, PLAYER_BPOS_Y(t3)
	bne t4, a0, continue_loop_get_player_by_pos
	bne t5, a1, continue_loop_get_player_by_pos
	j ret_get_player_by_pos

continue_loop_get_player_by_pos:
	addi t1, t1, PLAYER_BYTE_SIZE
	j loop_get_player_by_pos

ret_get_player_by_pos:
	mv a0, t3
	ret

###################################################################################
# Move o player localizado na posição do cursor de  acordo com o mapa.
###################################################################################
# a0 = map
# a1 = keyCode
###################################################################################
MOVE_PLAYER:
	addi sp, sp, -12
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)

	# if blink animation is in progress go to actually move_player
	la t0, BLINK_ANIMATION
	lb t0, 0(t0)
	beq t0, zero, goto_actually_move_player

	# initialize trail if function is being called for the first time
	la t0, MAKING_TRAIL
	lb t0, 0(t0)
	beq t0, zero, init_move_player

finish_init_move_player:

	jal DRAW_WALKABLE_BLOCKS
	lw a0, 8(sp)
	jal MAKE_TRAIL
	jal DRAW_CURSOR

	# if 'x' is pressed stop trail and actually move the player
	li t0, 'x'
	lw t1, 8(sp)
	beq t0, t1, finish_move_player

ret_move_player:
	lw ra, 0(sp)
	addi sp, sp, 12

finish_move_player:
	jal GET_PLAYER_BY_POS
	la t0, ACTUALLY_MOVE_PLAYER_DATA

	# store player in sp + 8
	# jal GET_PLAYER_BY_POS
	# sw a0, 8(sp)
	
	# # stop trail and save its last pos at (a2, a3).
	# jal STOP_TRAIL
	# mv a2, a0
	# mv a3, a1

	# # (a0, a1) = (mouseX, mouseY)
	# la t0, CURSOR_POS
	# lb a0, 0(t0)
	# lb a1, 1(t0)

	# # a3 = player
	# lw a3, 8(sp)

init_move_player:
	mv a2, a0
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	jal UPDATE_WALKABLE_BLOCKS

	jal INIT_CURSOR_TRAIL

	j finish_init_move_player

#########################################################
# Desenha o jogador na tela.
#########################################################
# a0 = player
# a1 = force draw even if BLINK_ANIMATION is in progress
#########################################################
DRAW_PLAYER:
	# if a1 != 0 draw player regardess of BLINK_ANIMATION
	bne a1, zero, start_draw_player

	# if blink animation is not ongoing, run the "standing still" animation
	la t0, BLINK_ANIMATION
	lb t0, 0(t0)
	bne t0, zero, EXECUTE_BLINK_ANIMATION

start_draw_player:
	addi sp, sp, -4
	sw ra, 0(sp)

	la a1, PLAYER_EARTH_STILL_ANIM
	lb a2, PLAYER_BPOS_X(a0)
	lb a3, PLAYER_BPOS_Y(a0)
	li a4, PLAYER_STILL_ANIMATION_DELAY
	la a0, tiles
	jal DRAW_ANIMATION_TILE

	lw ra, 0(sp)
	addi sp, sp, 4
	ret

EXECUTE_BLINK_ANIMATION:
	j ACTUALLY_MOVE_PLAYER
	ret

###################################################################################
# Inicializa os argumentos estáticos necessários para ACTUALLY_MOVE_PLAYER e
# movimenta o jogador logicamente.
###################################################################################
# a0 = player
###################################################################################
INIT_ACTUALLY_MOVE_PLAYER:
	# indicate that blink animation started
	la t0, BLINK_ANIMATION
	li t1, 1
	sb t1, 0(t0)

	# save player pos
	lb t0, PLAYER_BPOS_X(a0)
	lb t1, PLAYER_BPOS_Y(a0)
	la t3, ACTUALLY_MOVE_PLAYER_DATA
	sb t0, ACTUALLY_MOVE_PLAYER_DATA_BPOSX(t3)
	sb t1, ACTUALLY_MOVE_PLAYER_DATA_BPOSY(t3)

	# set status to ACTUALLY_MOVE_PLAYER_DISAPPEAR
	li t0, ACTUALLY_MOVE_PLAYER_DISAPPEAR
	sb t0, ACTUALLY_MOVE_PLAYER_DATA_BSTATUS(t3)

	# save player
	sw a0, ACTUALLY_MOVE_PLAYER_DATA_WPLAYER(t3)

	# move player to cursor position
	la t1, CURSOR_POS
	lb t0, 0(t1)
	lb t1, 1(t1)
	sb t0, PLAYER_BPOS_X(a0)
	sb t1, PLAYER_BPOS_Y(a0)
	ret
	

###################################################################################
# Executa a animação de movimentação do jogador e movimenta ele.
# Utiliza informações guardadas em ACTUALLY_MOVE_PLAYER_DATA.
###################################################################################
ACTUALLY_MOVE_PLAYER:
	addi sp, sp, -4
	sw ra, 0(sp)

	# goto correct part of function based on status
	la t0, ACTUALLY_MOVE_PLAYER_DATA 
	li t1, ACTUALLY_MOVE_PLAYER_DISAPPEAR
	lb t2, ACTUALLY_MOVE_PLAYER_DATA_BSTATUS(t0)
	beq t1, t2, disappear_actually_move_player

	# if status is not disappear draw smoke and player at new position

	# draw player
	lw a0, ACTUALLY_MOVE_PLAYER_DATA_WPLAYER(t0)
	li a1, 1 # force draw player

	# calculate smoke position
	la t0, ACTUALLY_MOVE_PLAYER_DATA
	lw t2, ACTUALLY_MOVE_PLAYER_DATA_WPLAYER(t0)
	lb t1, PLAYER_BPOS_X(t2)
	lb t2, PLAYER_BPOS_Y(t2)
	slli t1, t1, 4
	slli t2, t2, 4
	addi t1, t1, -16
	addi t2, t2, -16

	# draw smoke
	li a0, SMOKE_TILE_SIZE
	la a1, SMOKE_ANIM_APPEAR
	mv a2, t1
	mv a3, t2
	li a4, SMOKE_ANIMATION_DELAY
	li a5, SMOKE_TILE_SIZE
	jal DRAW_ANIMATION

	# if animation finished then conclude BLINK_ANIMATION
	bne a0, zero, stop_blink_animation_actually_move_player

ret_actually_move_player:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

stop_blink_animation_actually_move_player:
	la t0, BLINK_ANIMATION
	sb zero, 0(t0)
	j ret_actually_move_player

disappear_actually_move_player:
	# calculate smoke position
	la t0, ACTUALLY_MOVE_PLAYER_DATA
	lb t1, ACTUALLY_MOVE_PLAYER_DATA_BPOSX(t0)
	lb t2, ACTUALLY_MOVE_PLAYER_DATA_BPOSY(t0)
	slli t1, t1, 4
	slli t2, t2, 4
	addi t1, t1, -16
	addi t2, t2, -16

	# draw smoke
	li a0, SMOKE_TILE_SIZE
	la a1, SMOKE_ANIM_DISAPPEAR
	mv a2, t1
	mv a3, t2
	li a4, SMOKE_ANIMATION_DELAY
	li a5, SMOKE_TILE_SIZE
	jal DRAW_ANIMATION

	# if a0 != 0 then the animation ended, so set status to ACTUALLY_MOVE_PLAYER_APPEAR
	bne a0, zero, set_appear_actually_move_player
	j ret_actually_move_player

set_appear_actually_move_player:
	# set status to appear
	la t0, ACTUALLY_MOVE_PLAYER_DATA
	li t1, ACTUALLY_MOVE_PLAYER_APPEAR
	sb t1, ACTUALLY_MOVE_PLAYER_DATA_BSTATUS(t0)
	j ret_actually_move_player

goto_actually_move_player: