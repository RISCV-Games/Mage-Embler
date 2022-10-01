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
	
	li a0, GAME_STATE_INIT
	j ret_run_game_logic

choose_ally_run_game_logic:
	# save keyboard input
	jal GET_KBD_INPUT
	la t0, KBD_INPUT
	sb a0, 0(t0)
	jal MOVE_CURSOR

	# t0 = *KBD_INPUT
	la t0, KBD_INPUT
	lb t0, 0(t0)

	# if 'x' is pressed on top of a player go to player
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
