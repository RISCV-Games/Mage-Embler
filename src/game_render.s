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

	#jal HIGHLIGHT_NEARBY_ENEMIES

	jal SWAP_FRAMES
	j ret_run_game_render
