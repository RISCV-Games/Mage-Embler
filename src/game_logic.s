######################################################################
# Roda a lógica principal do jogo baseado no GAME_STATE.
# Retorna em a0 o estado para o RUN_GAME_RENDER.
######################################################################
RUN_GAME_LOGIC:
	addi sp, sp, -4
	sw ra, 0(sp)

	la t0, GAME_STATE
	lb t0, 0(t0)

	li t1, GAME_STATE_INIT
	beq t0, t1, init_run_game_logic

	li t1, GAME_STATE_CHOOSE_ALLY
	beq t0, t1, choose_ally_run_game_logic

	li t1, GAME_STATE_MAKING_TRAIL
	beq t0, t1, making_trail_run_game_logic

	li t1, GAME_STATE_MOVING_PLAYER
	beq t0, t1, moving_player_run_game_logic

	li t1, GAME_STATE_ACTION_MENU
	beq t0, t1, action_menu_run_game_logic

	li t1, GAME_STATE_CHOOSE_ENEMY
	beq t0, t1, choose_enemy_run_game_logic

	li t1, GAME_STATE_IN_COMBAT
	beq t0, t1, in_combat_run_game_logic

	li t1, GAME_STATE_CHECK_TURN
	beq t0, t1, check_turn_run_game_logic

	li t1, GAME_STATE_NEXT_TURN
	beq t0, t1, next_turn_run_game_logic

	li t1, GAME_STATE_MOVE_ENEMY
	beq t0, t1, move_enemy_run_game_logic

	li t1, GAME_STATE_AFTER_MOVE
	beq t0, t1, after_move_run_game_logic

	li t1, GAME_STATE_ENTER_COMBAT
	beq t0, t1, enter_combat_run_game_logic

	li t1, GAME_STATE_ENEMY_DELAY
	beq t0, t1, enemy_delay_run_game_logic

	li t1, GAME_STATE_ENEMY_ENTER_COMBAT
	beq t0, t1, enemy_enter_combat_run_game_logic

	li t1, GAME_STATE_CHECK_NEXT_MAP
	beq t0, t1, check_next_map_run_game_logic

	li t1, GAME_STATE_MAP_TRANSITION
	beq t0, t1, map_transition_run_game_logic

ret_run_game_logic:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

init_run_game_logic:
	# initialize players
	jal INIT_PLAYERS

	# change state to GAME_STATE_CHOOSE_ALLY
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ALLY
	sb t1, 0(t0)

	# CURRENT_MAP = MAPS[0]
	la t0, MAPS
	la t1, CURRENT_MAP
	sw t0, 0(t1)
	
	li a0, GAME_STATE_INIT
	j ret_run_game_logic

choose_ally_run_game_logic:
	jal GET_KBD_INPUT
	jal MOVE_CURSOR

	# if '\n' is pressed on top of a player go to player
	la t0, KBD_INPUT
	lb t0, 0(t0)
	li t1, '\n'
	beq t0, t1, x_choose_ally_run_game_logic

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

x_choose_ally_run_game_logic:
	# get player at CURSOR_POS
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	jal GET_PLAYER_BY_POS

	# if there is no player at cursor pos then return
	beq a0, zero, ret_x_choose_ally_run_game_logic

	# if player is not an ally then return
	lb t0, PLAYER_B_TIPO(a0)
	li t1, IN_AZUL
	bge t0, t1, ret_x_choose_ally_run_game_logic

	# if player is dead then return
	lb t0, PLAYER_B_VIDA_ATUAL(a0)
	beq t0, zero, ret_x_choose_ally_run_game_logic

	# if player has already moved then return
	lb t0, PLAYER_B_MOVED(a0)
	bne t0, zero, ret_x_choose_ally_run_game_logic


	# else SELECTED_PLAYER = a0
	la t0, SELECTED_PLAYER
	sw a0, 0(t0)

	# update walkable blocks
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	la a2, CURRENT_MAP
	lw a2, 0(a2)
	jal UPDATE_WALKABLE_BLOCKS

	# change state to GAME_STATE_MAKING_TRAIL
	jal INIT_CURSOR_TRAIL
	la t0, GAME_STATE
	li t1, GAME_STATE_MAKING_TRAIL
	sb t1, 0(t0)

	# return GAME_STATE_MAKING_TRAIL
	mv a0, t1
	j ret_run_game_logic

ret_x_choose_ally_run_game_logic:
	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

making_trail_run_game_logic:
	jal GET_KBD_INPUT
	jal MAKE_TRAIL_LOGIC

	# if '\n' is pressed and no alive player is at the cursor pos then move player
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	jal GET_PLAYER_BY_POS
	bne a0, zero, check_dead_making_trail_run_game_logic

check_x_making_trail_run_game_logic:
	la t0, KBD_INPUT
	lb t0, 0(t0)
	li t1, '\n'
	beq t0, t1, x_making_trail_run_game_logic

next_making_trail_run_game_logic:
	li a0, GAME_STATE_MAKING_TRAIL
	j ret_run_game_logic

check_dead_making_trail_run_game_logic:
	# if player at cursor pos is dead then allow player to move to cursor pos
	lb t0, PLAYER_B_VIDA_ATUAL(a0)
	beq t0, zero, check_x_making_trail_run_game_logic

	# else return
	j next_making_trail_run_game_logic

x_making_trail_run_game_logic:
	# Get selected player and start blink animation
	la a0, SELECTED_PLAYER
	lw a0, 0(a0)
	la a2, CURSOR_POS
	lb a1, 0(a2)
	lb a2, 1(a2)
	jal INIT_ACTUALLY_MOVE_PLAYER

	# *GAME_STATE = GAME_STATE_MOVING_PLAYER
	la t0, GAME_STATE
	li t1, GAME_STATE_MOVING_PLAYER
	sb t1, 0(t0)

	li a0, GAME_STATE_MOVING_PLAYER
	j ret_run_game_logic

moving_player_run_game_logic:
	# if blink animation is over goto next state
	la t0, BLINK_ANIMATION
	lb t0, 0(t0)
	beq t0, zero, stop_moving_player_run_game_logic

	# else keep at drawing blink animation
	li a0, GAME_STATE_MOVING_PLAYER
	j ret_run_game_logic

stop_moving_player_run_game_logic:
	# update PLAYER_B_SPECIAL_TERRAIN

	# t3 = player = *SELECTED_PLAYER
	la t3, SELECTED_PLAYER
	lw t3, 0(t3)

	# (t0, t1) = player.pos
	lb t0, PLAYER_B_POS_X(t3)
	lb t1, PLAYER_B_POS_Y(t3)

	# t2 = MAP[player position in map]
	li t2, MAP_WIDTH
	mul t1, t1, t2
	add t1, t0, t1
	la t2, CURRENT_MAP
	lw t2, 0(t2)
	add t2, t2, t1
	lb t2, 0(t2)

	# set player.specialTerrain to logical bits of t2
	andi t2, t2, 0x7
	sb t2, PLAYER_B_SPECIAL_TERRAIN(t3)

	# player.moved = true
	li t0, 1
	sb t0, PLAYER_B_MOVED(t3)

	# *GAME_STATE = GAME_STATE_AFTER_MOVE
	la t0, GAME_STATE
	li t1, GAME_STATE_AFTER_MOVE
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

set_action_menu_run_game_logic:
	# *GAME_STATE = GAME_STATE_ACTION_MENU
	la t0, GAME_STATE
	li t1, GAME_STATE_ACTION_MENU
	sb t1, 0(t0)

	li a0, GAME_STATE_ACTION_MENU
	j ret_run_game_logic

action_menu_run_game_logic:
	# Input
	li a0, 2                     			  # Quantidade de opcoes
	la a1, ACTION_MENU_SELECTED_OPTION        # label que segura opcao selecionada
	la a2, ACTION_MENU_IS_SELECTED            # label que segura se foi selecionado ou nao
	jal INPUT_MENU

	# if an option was selected then handle it
	la t0, ACTION_MENU_IS_SELECTED
	lb t0, 0(t0)
	bne t0, zero, selected_action_menu_run_game_logic

	li a0, GAME_STATE_ACTION_MENU
	j ret_run_game_logic

selected_action_menu_run_game_logic:
	# t0 = *ACTION_MENU_SELECTED_OPTION
	la t0, ACTION_MENU_SELECTED_OPTION
	lb t0, 0(t0)

	# checks if attack was selected
	beq t0, zero, attack_action_menu_run_game_logic

	# if attack was not selected, then wait was selected
	# restart menu
	la t0, ACTION_MENU_IS_SELECTED
	sb zero, 0(t0)
	la t0, ACTION_MENU_SELECTED_OPTION
	sb zero, 0(t0)

	# *GAME_STATE = GAME_STATE_CHECK_TURN
	la t0, GAME_STATE
	li t1, GAME_STATE_CHECK_TURN
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

attack_action_menu_run_game_logic:
	# restart menu
	la t0, ACTION_MENU_IS_SELECTED
	sb zero, 0(t0)
	la t0, ACTION_MENU_SELECTED_OPTION
	sb zero, 0(t0)

	# *GAME_STATE = GAME_STATE_CHOOSE_ENEMY
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ENEMY
	sb t1, 0(t0)

	jal UPDATE_NEARBY_ENEMIES

	li a0, GAME_STATE_CHOOSE_ENEMY
	j ret_run_game_logic

choose_enemy_run_game_logic:
	jal GET_KBD_INPUT
	jal MOVE_CURSOR_ATTACK_MODE

	# if '\n' is pressed go to combat mode
	la t0, KBD_INPUT
	lb t0, 0(t0)
	li t1, '\n'
	beq t0, t1, x_choose_enemy_run_game_logic

	li a0, GAME_STATE_CHOOSE_ENEMY
	j ret_run_game_logic

x_choose_enemy_run_game_logic:
	# *GAME_STATE = GAME_STATE_ENTER_COMBAT
	la t0, GAME_STATE
	li t1, GAME_STATE_ENTER_COMBAT
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

in_combat_run_game_logic:
	# if combat ended go back to choose ally
	la t0, IN_COMBAT
    lb t0, 0(t0)
    beq t0, zero, end_combat_run_game_logic

	# else run combat logic
	jal LOGIC_COMBAT

	li a0, GAME_STATE_IN_COMBAT
	j ret_run_game_logic

end_combat_run_game_logic:
	# *GAME_STATE = GAME_STATE_CHECK_TURN
	la t0, GAME_STATE
	li t1, GAME_STATE_CHECK_TURN
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

check_turn_run_game_logic:
	# if every ally is dead set state to GAME_STATE_ALL_ALLIES_DEAD
	jal CHECK_ALIVE_ALLIES
	beq a0, zero, allies_dead_check_turn_run_game_logic

	# if every enemy is dead set state to GAME_STATE_CHECK_NEXT_MAP
	jal CHECK_ALIVE_ENEMIES
	beq a0, zero, next_map_check_turn_run_game_logic

	# if there is an unmoved ally then set state to GAME_STATE_CHOOSE_ALLY
	jal CHECK_UNMOVED_ALLIES
	bne a0, zero, choose_ally_check_turn_run_game_logic

	# if there is an unmoved enemy then set state to GAME_STATE_CHOOSE_ENEMY
	jal CHECK_UNMOVED_ENEMIES
	bne a0, zero, move_enemy_check_turn_run_game_logic

	# otherwise set state to GAME_STATE_NEXT_TURN
	# *GAME_STATE = GAME_STATE_NEXT_TURN
	la t0, GAME_STATE
	li t1, GAME_STATE_NEXT_TURN
	sb t1, 0(t0)

	li a0, GAME_STATE_NEXT_TURN
	j ret_run_game_logic

choose_ally_check_turn_run_game_logic:
	# *GAME_STATE = GAME_STATE_CHOOSE_ALLY
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ALLY
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

move_enemy_check_turn_run_game_logic:
	# *GAME_STATE = GAME_STATE_MOVE_ENEMY
	la t0, GAME_STATE
	li t1, GAME_STATE_MOVE_ENEMY
	sb t1, 0(t0)

	li a0, GAME_STATE_MOVE_ENEMY
	j ret_run_game_logic

next_map_check_turn_run_game_logic:
	# *GAME_STATE = GAME_STATE_CHECK_NEXT_MAP
	la t0, GAME_STATE
	li t1, GAME_STATE_CHECK_NEXT_MAP
	sb t1, 0(t0)

	li a0, GAME_STATE_CHECK_NEXT_MAP
	j ret_run_game_logic

allies_dead_check_turn_run_game_logic:
	# *GAME_STATE = GAME_STATE_ALL_ALLIES_DEAD
	la t0, GAME_STATE
	li t1, GAME_STATE_ALL_ALLIES_DEAD
	sb t1, 0(t0)

	li a0, GAME_STATE_ALL_ALLIES_DEAD
	j ret_run_game_logic

move_enemy_run_game_logic:
	addi sp, sp, -4
	sw s0, 0(sp)

	# Gets an unmoved enemy and saves it
	jal CHECK_UNMOVED_ENEMIES

	# s0 = enemy
	mv s0, a0

	# *SELECTED_PLAYER = enemy
	la t0, SELECTED_PLAYER
	sw s0, 0(t0)


	# finds the closest ally to this enemy
	jal GET_CLOSEST_ALLY

	# finds the walkable square that is closest to the closest ally
	mv a1, s0
	jal GET_CLOSEST_WALKABLE

	# a0 = enemy, (a1, a2) = closestSquare
	mv a2, a1
	mv a1, a0
	mv a0, s0
	jal INIT_ACTUALLY_MOVE_PLAYER

	lw s0, 0(sp)
	addi sp, sp, 4

	# *GAME_STATE = GAME_STATE_MOVING_PLAYER
	la t0, GAME_STATE
	li t1, GAME_STATE_MOVING_PLAYER
	sb t1, 0(t0)

	li a0, GAME_STATE_MOVING_PLAYER
	j ret_run_game_logic

after_move_run_game_logic:
	la t0, SELECTED_PLAYER
	lw t0, 0(t0)

	# check if player is ally
	lb t1, PLAYER_B_TIPO(t0)
	li t2, IN_AZUL
	blt t1, t2, ally_after_move_run_game_logic

	# if there are ally neighbors nearby pick one of them and fight
	jal CHECK_ALLY_NEIGHBORS
	beq a0, zero, next_after_move_run_game_logic

	# *GAME_STATE = GAME_STATE_ENTER_COMBAT
	la t0, GAME_STATE
	li t1, GAME_STATE_ENTER_COMBAT
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

ally_after_move_run_game_logic:
	# if ally is next to an enemy prompt it with an action menu
	jal CHECK_ENEMY_NEIGHBORS
	bne a0, zero, action_menu_after_move_run_game_logic

next_after_move_run_game_logic:
	# *GAME_STATE = GAME_STATE_CHECK_TURN
	la t0, GAME_STATE
	li t1, GAME_STATE_CHECK_TURN
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

action_menu_after_move_run_game_logic:
	# *GAME_STATE = GAME_STATE_ACTION_MENU
	la t0, GAME_STATE
	li t1, GAME_STATE_ACTION_MENU
	sb t1, 0(t0)

	li a0, GAME_STATE_ACTION_MENU
	j ret_run_game_logic

next_turn_run_game_logic:
	jal UNMOVE_PLAYERS

	# *GAME_STATE = GAME_STATE_CHOOSE_ALLY
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ALLY
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

enter_combat_run_game_logic:
	# t1 = *SELECTED_PLAYER
	la t1, SELECTED_PLAYER
	lw t1, 0(t1)

	# check if selected player is enemy
	lb t1, PLAYER_B_TIPO(t1)
	li t0, IN_AZUL
	bge t1, t0, enemy_setup_combat_run_game_logic

	# get selected enemy
	la a1, CURSOR_POS
	lb a0, 0(a1)
	lb a1, 1(a1)
	jal GET_PLAYER_BY_POS

finish_enter_combat_run_game_logic:
	# t1 = *SELECTED_PLAYER
	la t1, SELECTED_PLAYER
	lw t1, 0(t1)

	# Set players in combat to SELECTED_PLAYER, SELECTED_ENEMY
	la t0, PLAYERS_IN_COMBAT
	sw t1, 0(t0)
	sw a0, 4(t0)

	# IN_COMBAT = 1
	la t0, IN_COMBAT
	li t1, 1
	sb t1, 0(t0)

	# *GAME_STATE = GAME_STATE_IN_COMBAT
	la t0, GAME_STATE
	li t1, GAME_STATE_IN_COMBAT
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

enemy_setup_combat_run_game_logic:
	# *ENEMY_DELAY = time
	la t0, ENEMY_DELAY
	csrr t1, time
	sw t1, 0(t0)

	# *GAME_STATE = GAME_STATE_ENEMY_DELAY
	la t0, GAME_STATE
	li t1, GAME_STATE_ENEMY_DELAY
	sb t1, 0(t0)

	li a0, GAME_STATE_ENEMY_DELAY
	j ret_run_game_logic

enemy_delay_run_game_logic:
	# t0 = time passed
	csrr t0, time
	la t1, ENEMY_DELAY
	lw t1, 0(t1)
	sub t0, t0, t1

	# if t0 < WAIT_ENEMY_DELAY continue
	li t1, WAIT_ENEMY_DELAY
	blt t0, t1, continue_enemy_delay_run_game_logic

	# *GAME_STATE = GAME_STATE_ENEMY_ENTER_COMBAT
	la t0, GAME_STATE
	li t1, GAME_STATE_ENEMY_ENTER_COMBAT
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

continue_enemy_delay_run_game_logic:
	li a0, GAME_STATE_ENEMY_DELAY
	j ret_run_game_logic

enemy_enter_combat_run_game_logic:
	jal CHECK_ALLY_NEIGHBORS

	la t0, CURSOR_POS
	lb t1, PLAYER_B_POS_X(a0)
	lb t2, PLAYER_B_POS_Y(a0)
	sb t1, 0(t0)
	sb t2, 1(t0)

	# t1 = *SELECTED_PLAYER
	la t1, SELECTED_PLAYER
	lw t1, 0(t1)

	# Set players in combat to SELECTED_PLAYER, SELECTED_ENEMY
	la t0, PLAYERS_IN_COMBAT
	sw a0, 0(t0)
	sw t1, 4(t0)

	# IN_COMBAT = 2
	la t0, IN_COMBAT
	li t1, 2
	sb t1, 0(t0)

	# *GAME_STATE = GAME_STATE_IN_COMBAT
	la t0, GAME_STATE
	li t1, GAME_STATE_IN_COMBAT
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

check_next_map_run_game_logic:
	# check if we are in the last map
	la t0, MAP_NUM
	lb t0, 0(t0)
	li t1, N_MAPS
	addi t1, t1, -1
	beq t0, t1, last_map_check_next_map_run_game_logic

	# if not in last map increment map num
	addi t0, t0, 1
	la t1, MAP_NUM
	sb t0, 0(t1)

	# *CURRENT_MAP = MAPS[MAP_NUM]
	li t1, MAP_SIZE
	mul t0, t0, t1
	la t1, MAPS
	add t0, t0, t1
	la t1, CURRENT_MAP
	sw t0, 0(t1)

	jal INIT_PLAYERS

	# *GAME_STATE = GAME_STATE_CHOOSE_ALLY
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ALLY
	sb t1, 0(t0)

	li a0, GAME_STATE_CHOOSE_ALLY
	j ret_run_game_logic

last_map_check_next_map_run_game_logic:

map_transition_run_game_logic: