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
# a0 = map number
############################################################
INIT_PLAYERS:
	beq a0, zero, zero_init_players
	li t0, 1
	beq a0, t0, one_init_players
	li t0, 2
	beq a0, t0, two_init_players
	li t0, 3
	beq a0, t0, three_init_players
	li t0, 4
	beq a0, t0, four_init_players

	ret

zero_init_players:
	la t0, PLAYERS
	li t1, 4
	sb t1, PLAYER_BPOS_X(t0)
	li t1, 10
	sb t1, PLAYER_BPOS_Y(t0)
	li t1, 1
	sb t1, PLAYER_BIS_ALLY(t0)
	li t1, PLAYER_WATER
	sb t1, PLAYER_BELEMENT(t0)

	addi t0, t0, PLAYER_BYTE_SIZE
	li t1, 5
	sb t1, PLAYER_BPOS_X(t0)
	li t1, 4
	sb t1, PLAYER_BPOS_Y(t0)
	li t1, 1
	sb t1, PLAYER_BIS_ALLY(t0)
	li t1, PLAYER_FIRE
	sb t1, PLAYER_BELEMENT(t0)

	addi t0, t0, PLAYER_BYTE_SIZE
	li t1, 16
	sb t1, PLAYER_BPOS_X(t0)
	li t1, 4
	sb t1, PLAYER_BPOS_Y(t0)
	li t1, 0
	sb t1, PLAYER_BIS_ALLY(t0)
	li t1, PLAYER_EARTH
	sb t1, PLAYER_BELEMENT(t0)

	# set N_PLAYERS to correct amount
	la t0, N_PLAYERS
	li t1, 3
	sb t1, 0(t0)
	ret

one_init_players:
	ret

two_init_players:
	ret

three_init_players:
	ret

four_init_players:
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

	lb a2, PLAYER_BPOS_X(a0)
	lb a3, PLAYER_BPOS_Y(a0)
	li a4, PLAYER_STILL_ANIMATION_DELAY
	#jal GET_PLAYER_STILL_ANIMATION
	la a1, PLAYER_EARTH_STILL_ANIM
	la a0, tiles
	jal DRAW_ANIMATION_TILE

	lw ra, 0(sp)
	addi sp, sp, 4
	ret

EXECUTE_BLINK_ANIMATION:
	j ACTUALLY_MOVE_PLAYER
	ret

#########################################################
# Retorna a animação still do Player
#########################################################
# a0 = player
#########################################################
GET_PLAYER_STILL_ANIMATION:
	#lb t0, PLAYER_BELEMENT
	la a1, PLAYER_EARTH_STILL_ANIM
	ret


#########################################################
# Desenha todos os jogadores na tela.
#########################################################
DRAW_PLAYERS:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw s0, 4(sp)

	# s0 = i = 0
	li s0, 0

loop_draw_players:
	la t0, N_PLAYERS
	lb t0, 0(t0)
	bge s0, t0, ret_draw_players

	# a0 = players[i]
	la a0, PLAYERS
	li t0, PLAYER_BYTE_SIZE
	mul t0, t0, s0
	add a0, a0, t0

	# a1 = force draw player = false
	li a1, 0
	jal DRAW_PLAYER

	addi s0, s0, 1

	j loop_draw_players

ret_draw_players:
	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 8
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

