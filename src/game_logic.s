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


ret_run_game_logic:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

init_run_game_logic:
	# initialize players with the first map
	li a0, 0
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

	# if 'x' is pressed on top of a player go to player
	la t0, KBD_INPUT
	lb t0, 0(t0)
	li t1, 'x'
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
	beq a0, zero, ret_run_game_logic
	# if player is not an ally then return
	lb t0, PLAYER_B_TIPO(a0)
	li t1, IN_AZUL
	bge t0, t1, ret_run_game_logic


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

making_trail_run_game_logic:
	jal GET_KBD_INPUT
	jal MAKE_TRAIL_LOGIC

	# if 'x' is pressed and no player is at the cursor pos then move player
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	jal GET_PLAYER_BY_POS
	bne a0, zero, next_making_trail_run_game_logic

	la t0, KBD_INPUT
	lb t0, 0(t0)
	li t1, 'x'
	beq t0, t1, x_making_trail_run_game_logic

next_making_trail_run_game_logic:
	li a0, GAME_STATE_MAKING_TRAIL
	j ret_run_game_logic

x_making_trail_run_game_logic:
	# Get selected player and start blink animation
	la a0, SELECTED_PLAYER
	lw a0, 0(a0)
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
	# *GAME_STATE = GAME_STATE_CHOOSE_ALLY
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ALLY
	sb t1, 0(t0)

	# if player lands next to an enemy then GAME_STATE = GAME_STATE_ACTION_MENU
	jal CHECK_ENEMY_NEIGHBORS
	bne a0, zero, set_action_menu_run_game_logic

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

	# *GAME_STATE = GAME_STATE_ACTION_MENU
	la t0, GAME_STATE
	li t1, GAME_STATE_CHOOSE_ALLY
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

	li a0, GAME_STATE_CHOOSE_ENEMY
	j ret_run_game_logic

choose_enemy_run_game_logic: