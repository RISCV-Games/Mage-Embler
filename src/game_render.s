######################################################################
# Roda a o render principal do jogo baseado no estado do jogo
# passado em a0.
######################################################################
# a0 = estado a executar
######################################################################
RUN_GAME_RENDER:
	addi sp, sp, -4
	sw ra, 0(sp)

	li t0, GAME_STATE_INIT
	beq a0, t0, init_run_game_render

	li t0, GAME_STATE_CHOOSE_ALLY
	beq a0, t0, choose_ally_run_game_render

	li t0, GAME_STATE_MAKING_TRAIL
	beq a0, t0, making_trail_run_game_render

	li t0, GAME_STATE_MOVING_PLAYER
	beq a0, t0, moving_player_run_game_render

	li t0, GAME_STATE_ACTION_MENU
	beq a0, t0, action_menu_run_game_render

	li t0, GAME_STATE_CHOOSE_ENEMY
	beq a0, t0, choose_enemy_run_game_render

	li t0, GAME_STATE_IN_COMBAT
	beq a0, t0, in_combat_run_game_render

	li t0, GAME_STATE_ENEMY_DELAY
	beq a0, t0, enemy_delay_run_game_render

	li t0, GAME_STATE_ALLY_PHASE_TRANSITION
	beq a0, t0, ally_phase_transition_run_game_render

	li t0, GAME_STATE_WIN_MAP
	beq a0, t0, win_map_run_game_render

	li t0, GAME_STATE_ENEMY_WINS
	beq a0, t0, enemy_wins_run_game_render

	li t0, GAME_STATE_ENEMY_PHASE_TRANSITION
	beq a0, t0, enemy_phase_transition_run_game_render

	li t0, GAME_STATE_DIALOGUE
	beq a0, t0, dialogue_run_game_render

ret_run_game_render:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

init_run_game_render:
	jal INIT_VIDEO
	j ret_run_game_render

choose_ally_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	# attackMode = false
	li a0, 0
	jal DRAW_CURSOR

	jal SWAP_FRAMES
	j ret_run_game_render

making_trail_run_game_render:
	jal DRAW_MAP
	jal DRAW_WALKABLE_BLOCKS
	jal DRAW_CURSOR_TRAIL
	jal DRAW_PLAYERS

	# attackMode = false
	li a0, 0
	jal DRAW_CURSOR

	jal SWAP_FRAMES
	j ret_run_game_render

moving_player_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	jal SWAP_FRAMES
	j ret_run_game_render

action_menu_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	# Render
	jal GET_ACTION_MENU_POS
	mv a6, a0         				     # Posicao x do menu
	mv a7, a1           			     # Posicao y do menu
	li a0, 2           				     # Quantidade de strings
	la a1, ACTION_MENU_STRINGS           # endereco para a label com as strings
	li a2, ACTIONS_MENU_STRING_COL       # Cor das strings
	li a3, ACTIONS_MENU_TAMANHO_X        # Tamanho x do menu
	li a4, ACTIONS_MENU_TAMANHO_Y        # Tamanho y do menu
	li a5, ACTIONS_MENU_BG_COL  	     # Cor de fundo do menu

	la t0, ACTION_MENU_SELECTED_OPTION
	lb s8, 0(t0)        			     # String selecionada (0 index)
	jal DRAW_MENU

	jal SWAP_FRAMES
	j ret_run_game_render

choose_enemy_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	# draw cursor in attack mode
	li a0, 1
	jal DRAW_CURSOR

	# TODO: implement this function
	#jal HIGHLIGHT_NEARBY_ENEMIES

	jal SWAP_FRAMES
	j ret_run_game_render

in_combat_run_game_render:
	#li a0, COMBAT_BACKGROUND
	#jal DRAW_BACKGROUND

	jal DRAW_MAP

	# calls DRAW_COMBAT and SWAP_FRAME

	la t0, PLAYERS_IN_COMBAT
	lw a0, 0(t0)
	lw a1, 4(t0)

	la t0, PLAYER_ATACKING
	lb a2, 0(t0)

	la t0, IS_PRINT_DMG
    lb a3, 0(t0)

	jal DRAW_COMBAT
	jal SWAP_FRAMES
	j ret_run_game_render

enemy_delay_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	# draw cursor in attack mode
	li a0, 1
	jal DRAW_CURSOR

	jal SWAP_FRAMES
	j ret_run_game_render

ally_phase_transition_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	la a0, ALLY_PHASE_STRING
	li a1, MENU_STRING_COLOR  # Cor das strings
    li a2, 100          # Tamanho x do menu
    li a3, 20          # Tamanho y do menu
    li a4, 0x09090909  # Cor de fundo do menu
    li a5, 110         # Posicao x do menu
    li a6, 100          # Posicao y do menu
    jal DRAW_DIALOG

	jal SWAP_FRAMES
	j ret_run_game_render

win_map_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	la a0, YOU_WIN_STRING
	li a1, MENU_STRING_COLOR  # Cor das strings
    li a2, 100          # Tamanho x do menu
    li a3, 20          # Tamanho y do menu
    li a4, MENU_BG_COLOR  # Cor de fundo do menu
    li a5, 110         # Posicao x do menu
    li a6, 100          # Posicao y do menu
    jal DRAW_DIALOG

	jal SWAP_FRAMES
	j ret_run_game_render

enemy_wins_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	la a0, YOU_LOOSE_STRING
	li a1, LOOSE_STRING_COLOR  # Cor das strings
    li a2, 100          # Tamanho x do menu
    li a3, 20          # Tamanho y do menu
    li a4, MENU_BG_COLOR  # Cor de fundo do menu
    li a5, 110         # Posicao x do menu
    li a6, 100          # Posicao y do menu
    jal DRAW_DIALOG

	jal SWAP_FRAMES
	j ret_run_game_render

enemy_phase_transition_run_game_render:
	jal DRAW_MAP
	jal DRAW_PLAYERS

	la a0, ENEMY_PHASE_STRING
	li a1, MENU_STRING_COLOR  # Cor das strings
    li a2, 100          # Tamanho x do menu
    li a3, 20          # Tamanho y do menu
    li a4, MENU_BG_COLOR  # Cor de fundo do menu
    li a5, 110         # Posicao x do menu
    li a6, 100          # Posicao y do menu
    jal DRAW_DIALOG

	jal SWAP_FRAMES
	j ret_run_game_render

dialogue_run_game_render:
	jal DRAW_MAP

	la t0, MAP_NUM
	lb t0, 0(t0)

	beq t0, zero, map0_dialogue_run_render_game

	li t1, 1
	beq t0, t1, map1_dialogue_run_render_game

	li t1, 2
	beq t0, t1, map2_dialogue_run_render_game

	li t1, 3
	beq t0, t1, map3_dialogue_run_render_game

	li t1, 4
	beq t0, t1, map4_dialogue_run_render_game

draw_dialogue_run_game_render:

	# t1 = string array offset
	la t1, DIALOGUE_STRING_NUM
	lb t1, 0(t1)
	slli t1, t1, 2
	add a0, a0, t1
	lw a0, 0(a0)

    li a1, 0x000009ff  # Cor das strings
    li a2, 300          # Tamanho x do menu
    li a3, 100          # Tamanho y do menu
    li a4, MENU_BG_COLOR  # Cor de fundo do menu
    li a5, 10         # Posicao x do menu
    li a6, 20          # Posicao y do menu
    jal DRAW_DIALOG

	jal SWAP_FRAMES
	j ret_run_game_render



map0_dialogue_run_render_game:
	la a0, map0_dialog
	j draw_dialogue_run_game_render

map1_dialogue_run_render_game:
	la a0, map1_dialog
	j draw_dialogue_run_game_render

map2_dialogue_run_render_game:
	la a0, map2_dialog
	j draw_dialogue_run_game_render

map3_dialogue_run_render_game:
	la a0, map3_dialog
	j draw_dialogue_run_game_render

map4_dialogue_run_render_game:
	la a0, map4_dialog
	j draw_dialogue_run_game_render