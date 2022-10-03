############################################################
# Player
# Alterar PLAYERS e PLAYER_BYTE_SIZE ao mudar o tamanho.
############################################################
# Classe representando os jogadores, tanto aliados
# quanto inimigos.
############################################################


############################################################
# Inicializa os players a partir do mapa.
############################################################
INIT_PLAYERS:
	la a0, MAP_NUM
	lb a0, 0(a0)

	# sets N_PLAYERS to 0
	la t0, N_PLAYERS
	sb zero, 0(t0)

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
    addi sp, sp, -4
    sw s0, 0(sp)

    la s0, PLAYER_1

    INIT_PLAYER( s0, 4 , 10, AL_AZUL, 15, 15, 5 , 80 , 1 )

    INIT_PLAYER( s0, 9,  10, IN_VER, 15, 1, 3 , 80 , 1 )

    lw s0, 0(sp)
    addi sp, sp, 4
    ret

one_init_players:
    addi sp, sp, -4
    sw s0, 0(sp)

    la s0, PLAYER_1

    INIT_PLAYER( s0, 0 ,  4, AL_VER , 25, 25, 5 , 80 , 1 )
    INIT_PLAYER( s0, 0 ,  5, AL_AZUL, 25, 25, 5 , 80 , 1 )

    INIT_PLAYER( s0, 19 ,  3, IN_VER , 25,  3, 5 , 80 , 1 )
    INIT_PLAYER( s0, 19 ,  4, IN_MAR , 25,  3, 5 , 80 , 1 )

    lw s0, 0(sp)
    addi sp, sp, 4
    ret

two_init_players:
	ret

three_init_players:
	ret

four_init_players:
	ret


###################################################################################
# Retorna um Player a partir de sua posição (x, y). Se não há um player vivo nessa
# posição retorna 0, caso contrário retorna o player.
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
	bge t1, t2, failed_get_player_by_pos

	# t3 = PLAYERS[I]
	add t3, t0, t1
	# skip dead players
	lb t6, PLAYER_B_VIDA_ATUAL(t3)
	beq t6, zero, continue_loop_get_player_by_pos

	lb t4, PLAYER_B_POS_X(t3)
	lb t5, PLAYER_B_POS_Y(t3)
	bne t4, a0, continue_loop_get_player_by_pos
	bne t5, a1, continue_loop_get_player_by_pos
	j found_player_get_player_by_pos

continue_loop_get_player_by_pos:
	addi t1, t1, PLAYER_BYTE_SIZE
	j loop_get_player_by_pos

failed_get_player_by_pos:
	li a0, 0
	ret

found_player_get_player_by_pos:
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

	# if the player = *SELECTED_PLAYER and BLINK_ANIMATION = true then execute blink animation
	la t0, BLINK_ANIMATION
	lb t0, 0(t0)
	beq t0, zero, start_draw_player
	la t0, SELECTED_PLAYER
	lw t0, 0(t0)
	beq a0, t0, EXECUTE_BLINK_ANIMATION

start_draw_player:
	addi sp, sp, -4
	sw ra, 0(sp)

	lb a2, PLAYER_B_POS_X(a0)
	lb a3, PLAYER_B_POS_Y(a0)
	li a4, PLAYER_STILL_ANIMATION_DELAY
	jal GET_PLAYER_STILL_ANIM
	mv a1, a0
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
GET_PLAYER_STILL_ANIM:
	# t0 = player.tipo
	lb t0, PLAYER_B_TIPO(a0)
	li t1, AL_AZUL
	beq t0, t1, al_azul_get_player_still_anim
	li t1, AL_VER
	beq t0, t1, al_ver_get_player_still_anim
	li t1, AL_MAR
	beq t0, t1, al_mar_get_player_still_anim
	li t1, IN_AZUL
	beq t0, t1, in_azul_get_player_still_anim
	li t1, IN_VER
	beq t0, t1, in_ver_get_player_still_anim

	la a0, ENEMY_EARTH_STILL_ANIM
	ret

al_azul_get_player_still_anim:
	la a0, ALLY_WATER_STILL_ANIM
	ret

al_ver_get_player_still_anim:
	la a0, ALLY_FIRE_STILL_ANIM
	ret

al_mar_get_player_still_anim:
	la a0, ALLY_EARTH_STILL_ANIM
	ret

in_azul_get_player_still_anim:
	la a0, ENEMY_WATER_STILL_ANIM
	ret

in_ver_get_player_still_anim:
	la a0, ENEMY_FIRE_STILL_ANIM
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

	# skip dead players
	lb t0, PLAYER_B_VIDA_ATUAL(a0)
	beq t0, zero, continue_loop_draw_players

	# a1 = force draw player = false
	li a1, 0
	jal DRAW_PLAYER

continue_loop_draw_players:
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
# a1 = newPosX
# a2 = newPosY
###################################################################################
INIT_ACTUALLY_MOVE_PLAYER:
	# indicate that blink animation started
	la t0, BLINK_ANIMATION
	li t1, 1
	sb t1, 0(t0)

	# save player pos
	lb t0, PLAYER_B_POS_X(a0)
	lb t1, PLAYER_B_POS_Y(a0)
	la t3, ACTUALLY_MOVE_PLAYER_DATA
	sb t0, ACTUALLY_MOVE_PLAYER_DATA_BPOSX(t3)
	sb t1, ACTUALLY_MOVE_PLAYER_DATA_BPOSY(t3)

	# set status to ACTUALLY_MOVE_PLAYER_DISAPPEAR
	li t0, ACTUALLY_MOVE_PLAYER_DISAPPEAR
	sb t0, ACTUALLY_MOVE_PLAYER_DATA_BSTATUS(t3)

	# save player
	sw a0, ACTUALLY_MOVE_PLAYER_DATA_WPLAYER(t3)

	# move player to new pos
	sb a1, PLAYER_B_POS_X(a0)
	sb a2, PLAYER_B_POS_Y(a0)
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
	lb t1, PLAYER_B_POS_X(t2)
	lb t2, PLAYER_B_POS_Y(t2)
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

###################################################################################
# Boolean valued function which indicates wheter a neighbor of the selected player
# is an enemy. Also moves the cursor to the first enemy neighbor found.
###################################################################################
CHECK_ENEMY_NEIGHBORS:
	# t0 = player = *SELECTED_PLAYER
	la t0, SELECTED_PLAYER
	lw t0, 0(t0)

	# (t4, t5) = player.pos
	lb t4, PLAYER_B_POS_X(t0)
	lb t5, PLAYER_B_POS_Y(t0)

	# a0 = false
	li a0, 0

	# t1 = 0 = i
	li t1, 0

loop_check_enemy_neighbors:
	la t2, N_PLAYERS
	lb t2, 0(t2)
	bge t1, t2, ret_check_enemy_neighbors

	# t2, t6 = players[i]
	li t2, PLAYER_BYTE_SIZE
	mul t2, t2, t1
	la t3, PLAYERS
	add t2, t2, t3
	# save t2 in a1 and t6
	mv t6, t2
	mv a1, t2
	# skip dead players
	lb a2, PLAYER_B_VIDA_ATUAL(a1)
	beq a2, zero, continue_loop_check_enemy_neighbors

	# (t2, t3) = players[i].pos
	lb t3, PLAYER_B_POS_Y(t2)
	lb t2, PLAYER_B_POS_X(t2)

	# t2 = distSq = players[i].pos.distSq(player)
	sub t2, t2, t4
	sub t3, t3, t5
	mul t3, t3, t3
	mul t2, t2, t2
	add t2, t2, t3

	# if distSq != 1 continue
	li t3, 1
	bne t2, t3, continue_loop_check_enemy_neighbors

	# else if players[i] is an enemy, return true
	lb t6, PLAYER_B_TIPO(t6)
	li a3, IN_AZUL
	blt t6, a3, continue_loop_check_enemy_neighbors

	# move cursor and return true
	lb t0, PLAYER_B_POS_X(a1)
	lb t1, PLAYER_B_POS_Y(a1)
	la t2, CURSOR_POS
	sb t0, 0(t2)
	sb t1, 1(t2)
	li a0, 1
	j ret_check_enemy_neighbors

continue_loop_check_enemy_neighbors:
	addi t1, t1, 1
	j loop_check_enemy_neighbors

ret_check_enemy_neighbors:
	ret

###################################################################################
# Returns zero if no neighbor of the selected player is an ally, otherwise
# returns one neighbor which is an ally. Also moves the cursor to this ally,
# in case one is found.
###################################################################################
CHECK_ALLY_NEIGHBORS:
	# t0 = player = *SELECTED_PLAYER
	la t0, SELECTED_PLAYER
	lw t0, 0(t0)

	# (t4, t5) = player.pos
	lb t4, PLAYER_B_POS_X(t0)
	lb t5, PLAYER_B_POS_Y(t0)

	# a0 = false
	li a0, 0

	# t1 = i = 0
	li t1, 0

loop_check_ally_neighbors:
	la t2, N_PLAYERS
	lb t2, 0(t2)
	bge t1, t2, ret_check_ally_neighbors

	# t2, t6 = players[i]
	li t2, PLAYER_BYTE_SIZE
	mul t2, t2, t1
	la t3, PLAYERS
	add t2, t2, t3
	# save t2 in a1 and t6
	mv t6, t2
	mv a1, t2
	# skip dead players
	lb a2, PLAYER_B_VIDA_ATUAL(a1)
	beq a2, zero, continue_loop_check_ally_neighbors

	# (t2, t3) = players[i].pos
	lb t3, PLAYER_B_POS_Y(t2)
	lb t2, PLAYER_B_POS_X(t2)

	# t2 = distSq = players[i].pos.distSq(player)
	sub t2, t2, t4
	sub t3, t3, t5
	mul t3, t3, t3
	mul t2, t2, t2
	add t2, t2, t3

	# if distSq != 1 continue
	li t3, 1
	bne t2, t3, continue_loop_check_ally_neighbors

	# else if players[i] is an ally, return this ally
	lb t6, PLAYER_B_TIPO(t6)
	li a3, IN_AZUL
	bge t6, a3, continue_loop_check_ally_neighbors

	# move cursor and return ally
	lb t0, PLAYER_B_POS_X(a1)
	lb t1, PLAYER_B_POS_Y(a1)
	la t2, CURSOR_POS
	sb t0, 0(t2)
	sb t1, 1(t2)
	mv a0, a1
	j ret_check_ally_neighbors

continue_loop_check_ally_neighbors:
	addi t1, t1, 1
	j loop_check_ally_neighbors

ret_check_ally_neighbors:
	ret

###################################################################################
# Update the NEARBY_ENEMIES array according to the selected player's position
# and the enemies positions.
###################################################################################
UPDATE_NEARBY_ENEMIES:
	la t0, NEARBY_ENEMIES
	sw zero, 0(t0) 

	# t0 = player = *SELECTED_PLAYER
	la t0, SELECTED_PLAYER
	lw t0, 0(t0)

	# (t4, t5) = player.pos
	lb t4, PLAYER_B_POS_X(t0)
	lb t5, PLAYER_B_POS_Y(t0)

	# t1 = 0 = i
	li t1, 0

loop_update_nearby_enemies:
	la t2, N_PLAYERS
	lb t2, 0(t2)
	bge t1, t2, ret_update_nearby_enemies

	# t2, t6 = players[i]
	li t2, PLAYER_BYTE_SIZE
	mul t2, t2, t1
	la t3, PLAYERS
	add t2, t2, t3
	mv t6, t2

	# skip dead players
	lb a2, PLAYER_B_VIDA_ATUAL(t6)
	beq a2, zero, continue_loop_update_nearby_enemies

	# (t2, t3) = players[i].pos
	lb t3, PLAYER_B_POS_Y(t2)
	lb t2, PLAYER_B_POS_X(t2)

	# a4 = distSq = players[i].pos.distSq(player), (t2, t3) = (deltaX, deltaY)
	sub t2, t2, t4
	sub t3, t3, t5
	mul a4, t3, t3
	mul a5, t2, t2
	add a4, a4, a5

	# if distSq != 1 continue
	li a5, 1
	bne a4, a5, continue_loop_update_nearby_enemies

	# else if players[i] is not an enemy then continue
	lb t6, PLAYER_B_TIPO(t6)
	li a5, IN_AZUL
	blt t6, a5, continue_loop_update_nearby_enemies

	li t6, 1
	beq t2, t6, right_update_nearby_enemies

	li t6, -1
	beq t2, t6, left_update_nearby_enemies

	li t6, -1
	beq t3, t6, up_update_nearby_enemies

	li t6, 1
	la a5, NEARBY_ENEMIES
	sb t6, CURSOR_ATTACK_DOWN(a5)

continue_loop_update_nearby_enemies:
	addi t1, t1, 1
	j loop_update_nearby_enemies

right_update_nearby_enemies:
	la a5, NEARBY_ENEMIES
	sb t6, CURSOR_ATTACK_RIGHT(a5)
	j continue_loop_update_nearby_enemies

left_update_nearby_enemies:
	li t6, 1
	la a5, NEARBY_ENEMIES
	sb t6, CURSOR_ATTACK_LEFT(a5)
	j continue_loop_update_nearby_enemies

up_update_nearby_enemies:
	li t6, 1
	la a5, NEARBY_ENEMIES
	sb t6, CURSOR_ATTACK_UP(a5)
	j continue_loop_update_nearby_enemies

ret_update_nearby_enemies:
ret

###################################################################################
# Boolean valued function which indicates if there are alive allies that
# have not moved in the current turn. Returns 0 if every ally has moved,
# returns an ally that has not moved otherwise.
###################################################################################
CHECK_UNMOVED_ALLIES:
	# t0 = players
	la t0, PLAYERS

	# t1 = i = 0
	li t1, 0

	# t2 = *N_PLAYERS * PLAYER_BYTE_SIZE
	la t2, N_PLAYERS
	lb t2, 0(t2)
	li t3, PLAYER_BYTE_SIZE
	mul t2, t2, t3

	# a0 = false
	li a0, 0

loop_check_unmoved_allies:
	bge t1, t2, ret_check_unmoved_allies

	# t3 = players[i]
	add t3, t0, t1

	# skip dead players
	lb t4, PLAYER_B_VIDA_ATUAL(t3)
	beq t4, zero, continue_loop_check_unmoved_allies

	# skip enemies
	lb t4, PLAYER_B_TIPO(t3)
	li t5, IN_AZUL
	bge t4, t5, continue_loop_check_unmoved_allies

	# skip moved allies
	lb t4, PLAYER_B_MOVED(t3)
	bne t4, zero, continue_loop_check_unmoved_allies

	# only remaining players are the alive, unmoved allies so return players[i]
	mv a0, t3
	j ret_check_unmoved_allies


continue_loop_check_unmoved_allies:
	addi t1, t1, PLAYER_BYTE_SIZE
	j loop_check_unmoved_allies

ret_check_unmoved_allies:
	ret

###################################################################################
# Boolean valued function which indicates if there are alive enemies that
# have not moved in the current turn. Returns 0 if every enemy has moved,
# returns an enemy that has not moved otherwise.
###################################################################################
CHECK_UNMOVED_ENEMIES:
	# t0 = players
	la t0, PLAYERS

	# t1 = i = 0
	li t1, 0

	# t2 = *N_PLAYERS * PLAYER_BYTE_SIZE
	la t2, N_PLAYERS
	lb t2, 0(t2)
	li t3, PLAYER_BYTE_SIZE
	mul t2, t2, t3

	# a0 = false
	li a0, 0

loop_check_unmoved_enemies:
	bge t1, t2, ret_check_unmoved_enemies

	# t3 = players[i]
	add t3, t0, t1

	# skip dead players
	lb t4, PLAYER_B_VIDA_ATUAL(t3)
	beq t4, zero, continue_loop_check_unmoved_enemies

	# skip allies
	lb t4, PLAYER_B_TIPO(t3)
	li t5, IN_AZUL
	blt t4, t5, continue_loop_check_unmoved_enemies

	# skip moved enemies
	lb t4, PLAYER_B_MOVED(t3)
	bne t4, zero, continue_loop_check_unmoved_enemies

	# only remaining players are the alive, unmoved enemies so return players[i]
	mv a0, t3
	j ret_check_unmoved_enemies


continue_loop_check_unmoved_enemies:
	addi t1, t1, PLAYER_BYTE_SIZE
	j loop_check_unmoved_enemies

ret_check_unmoved_enemies:
	ret

###################################################################################
# Boolean valued function which indicates if there are any alive enemies.
###################################################################################
CHECK_ALIVE_ENEMIES:
	# t0 = players
	la t0, PLAYERS

	# t1 = i = 0
	li t1, 0

	# t2 = *N_PLAYERS * PLAYER_BYTE_SIZE
	la t2, N_PLAYERS
	lb t2, 0(t2)
	li t3, PLAYER_BYTE_SIZE
	mul t2, t2, t3

	# a0 = false
	li a0, 0

loop_check_alive_enemies:
	bge t1, t2, ret_check_alive_enemies

	# t3 = players[i]
	add t3, t0, t1

	# skip dead players
	lb t4, PLAYER_B_VIDA_ATUAL(t3)
	beq t4, zero, continue_loop_check_alive_enemies

	# skip allies
	lb t4, PLAYER_B_TIPO(t3)
	li t5, IN_AZUL
	blt t4, t5, continue_loop_check_alive_enemies

	# if player is an alive enemy return true
	li a0, 1
	j ret_check_alive_enemies


continue_loop_check_alive_enemies:
	addi t1, t1, PLAYER_BYTE_SIZE
	j loop_check_alive_enemies

ret_check_alive_enemies:
	ret

###################################################################################
# Boolean valued function which indicates if there are alive allies.
###################################################################################
CHECK_ALIVE_ALLIES:
	# t0 = players
	la t0, PLAYERS

	# t1 = i = 0
	li t1, 0

	# t2 = *N_PLAYERS * PLAYER_BYTE_SIZE
	la t2, N_PLAYERS
	lb t2, 0(t2)
	li t3, PLAYER_BYTE_SIZE
	mul t2, t2, t3

	# a0 = false
	li a0, 0

loop_check_alive_allies:
	bge t1, t2, ret_check_alive_allies

	# t3 = players[i]
	add t3, t0, t1

	# skip dead players
	lb t4, PLAYER_B_VIDA_ATUAL(t3)
	beq t4, zero, continue_loop_check_alive_allies

	# skip enemies
	lb t4, PLAYER_B_TIPO(t3)
	li t5, IN_AZUL
	bge t4, t5, continue_loop_check_alive_allies

	# if player is an alive ally then return true
	li a0, 1
	j ret_check_alive_allies


continue_loop_check_alive_allies:
	addi t1, t1, PLAYER_BYTE_SIZE
	j loop_check_alive_allies

ret_check_alive_allies:
	ret

###################################################################################
# Função de debug que loga alguns atributos dos players.
###################################################################################
LOG_PLAYERS_DEBUG:
	addi sp, sp, -8
	sw ra, 0(sp)
	sw s0, 4(sp)

	li a0, '\n'
	li a7, 11
	ecall

	# s0 = i = 0
	li s0, 0

loop_log_players_debug:
	# if i >= *N_PLAYERS then return
	la t0, N_PLAYERS
	lb t0, 0(t0)
	bge s0, t0, ret_log_players_debug

	# t0 = players[i]
	li t0, PLAYER_BYTE_SIZE
	mul t0, s0, t0
	la t1, PLAYERS
	add t0, t0, t1

	# print tipo
	lb a0, PLAYER_B_TIPO(t0)
	li a7, 1
	ecall

	li a0, ' '
	li a7, 11
	ecall

	# t0 = players[i]
	li t0, PLAYER_BYTE_SIZE
	mul t0, s0, t0
	la t1, PLAYERS
	add t0, t0, t1

	# print moved
	lb a0, PLAYER_B_MOVED(t0)
	li a7, 1
	ecall

	li a0, '\n'
	li a7, 11
	ecall
	addi s0, s0, 1
	j loop_log_players_debug

ret_log_players_debug:
	lw ra, 0(sp)
	lw s0, 4(sp)
	addi sp, sp, 8
	ret

###################################################################################
# Returns the closest ally to a given enemy.
###################################################################################
# a0 = enemy
###################################################################################
GET_CLOSEST_ALLY:
	addi sp, sp, -20
	sw s0, 0(sp)
	sw s1, 4(sp)
	sw ra, 8(sp)
	sw a0, 12(sp)
	sw s2, 16(sp)

	# s0 = i = 0
	li s0, 0

	# s2 = closestPlayer
	li s2, 0

	# s1 = minDist = biggest possible 12 bit immediate
	li s1, 0x7ff

loop_get_closest_ally:
	la t0, N_PLAYERS
	lb t0, 0(t0)
	bge s0, t0, ret_get_closest_ally

	# a1 = players[i]
	li a1, PLAYER_BYTE_SIZE
	mul a1, a1, s0
	la t0, PLAYERS
	add a1, a1, t0

	# skip dead players
	lb t0, PLAYER_B_VIDA_ATUAL(a1)
	beq t0, zero, continue_loop_get_closest_ally

	# skip enemies
	lb t0, PLAYER_B_TIPO(a1)
	li t1, IN_AZUL
	bge t0, t1, continue_loop_get_closest_ally

	# a0 = enemy
	lw a0, 12(sp)
	jal GET_PLAYER_DIST
	# if distance between ally and enemy >= minDist then continue
	bge a0, s1, continue_loop_get_closest_ally

	# else set minDist = a0 and closestPlayer = players[i] = a1
	mv s1, a0
	mv s2, a1

continue_loop_get_closest_ally:
	addi s0, s0, 1
	j loop_get_closest_ally

ret_get_closest_ally:
	# return closest player
	mv a0, s2

	lw s0, 0(sp)
	lw s1, 4(sp)
	lw ra, 8(sp)
	lw s2, 16(sp)
	addi sp, sp, 20
	ret

###################################################################################
# Returns the square of the euclidean distance between two players.
###################################################################################
# a0 = player0
# a1 = player1
###################################################################################
GET_PLAYER_DIST:
	lb t0, PLAYER_B_POS_X(a0)
	lb t1, PLAYER_B_POS_Y(a0)
	lb t2, PLAYER_B_POS_X(a1)
	lb t3, PLAYER_B_POS_Y(a1)

	sub t0, t0, t2
	sub t1, t1, t3
	mul t0, t0, t0
	mul t1, t1, t1
	add a0, t0, t1
	ret

###################################################################################
# Returns the square of the euclidean distance between two positions.
###################################################################################
# a0 = pos1.x
# a1 = pos1.y
# a2 = pos2.x
# a3 = pos2.y
###################################################################################
GET_POS_DIST:
	sub a0, a0, a2
	sub a1, a1, a3
	mul a0, a0, a0
	mul a1, a1, a1
	add a0, a0, a1

	ret

###################################################################################
# Finds the empty walkable square that is closest to the closest ally.
###################################################################################
# a0 = ally
# a1 = enemy
###################################################################################
GET_CLOSEST_WALKABLE:
	addi sp, sp, -24
	sw ra, 0(sp)
	sw a0, 4(sp)
	sw a1, 8(sp)
	sw s0, 12(sp)
	sw s1, 16(sp)
	sw s2, 20(sp)

	# (a0, a1) = enemy.pos
	lb a0, PLAYER_B_POS_X(a1)
	lb a1, PLAYER_B_POS_Y(a1)

	# a2 = map
	la a2, CURRENT_MAP
	lw a2, 0(a2)

	# update walkable blocks with respect to the enemy
	jal UPDATE_WALKABLE_BLOCKS

	# s0 = i = 0
	li s0, 0

	# s1 = closestSquare
	li s1, -1

	# s2 = minDist = biggest 12 bit immediate
	li s2, 0x7ff

loop_get_closest_walkable:
	li t0, MAP_SIZE
	bge s0, t0, ret_get_closest_walkable

	# skip non-walkable squares
	la t0, WALKABLE_BLOCKS
	add t0, t0, s0
	lb t0, 0(t0)
	beq t0, zero, continue_loop_get_closest_walkable

	# skip squares with alive players
	li t0, MAP_WIDTH
	rem a0, s0, t0
	div a1, s0, t0
	jal GET_PLAYER_BY_POS
	beq a0, zero, empty_get_closest_walkable
	lb t0, PLAYER_B_VIDA_ATUAL(a0)
	bne t0, zero, continue_loop_get_closest_walkable

empty_get_closest_walkable:
	# (a0, a1) = squarePos
	li t0, MAP_WIDTH
	rem a0, s0, t0
	div a1, s0, t0

	# (a2, a3) = ally.pos
	lw t0, 4(sp)
	lb a2, PLAYER_B_POS_X(t0)
	lb a3, PLAYER_B_POS_Y(t0)

	# a0 = currDist = distSq(ally, square)
	jal GET_POS_DIST

	# if currDist >= minDist then continue
	bge a0, s2, continue_loop_get_closest_walkable

	# else minDist = currDist and closestSquare = square
	mv s2, a0
	mv s1, s0

continue_loop_get_closest_walkable:
	addi s0, s0, 1
	j loop_get_closest_walkable

ret_get_closest_walkable:
	# (a0, a1) = (closestSquare.x, closestSquare.y)
	li t0, MAP_WIDTH
	rem a0, s1, t0
	div a1, s1, t0

	# restore stack
	lw ra, 0(sp)
	lw s0, 12(sp)
	lw s1, 16(sp)
	lw s2, 20(sp)
	addi sp, sp, 24
	ret

###################################################################################
# Marks every player as unmoved.
###################################################################################
UNMOVE_PLAYERS:
	# t0 = i = 0
	li t0, 0
loop_unmove_players:
	la t1, N_PLAYERS
	lb t1, 0(t1)
	bge t0, t1, ret_unmove_players

	# t1 = players[i]
	li t1, PLAYER_BYTE_SIZE
	mul t1, t0, t1
	la t2, PLAYERS
	add t1, t1, t2

	# players[i].moved = false
	sb zero, PLAYER_B_MOVED(t1)

	addi t0, t0, 1
	j loop_unmove_players

ret_unmove_players:
	ret