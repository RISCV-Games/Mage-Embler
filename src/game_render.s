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

ret_run_game_render:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

init_run_game_render:
	jal INIT_VIDEO
	j ret_run_game_render

choose_ally_run_game_render:
	# a0 = MAPS[CURRENT_MAP]
	la t0, CURRENT_MAP
	lb t0, 0(t0)
	li t1, MAP_SIZE
	mul t0, t0, t1
	la t1, MAPS
	add a0, t0, t1

	# TODO: fix hardcoded value in a1
	la a1, CORRESPONDENCE_ARR_MAP0
	jal DRAW_MAP
	jal DRAW_CURSOR

	jal DRAW_PLAYERS
	jal SWAP_FRAMES
	j ret_run_game_render
