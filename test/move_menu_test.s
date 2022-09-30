.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
jal INIT_VIDEO
la a0, MAPS
la a1, CORRESPONDENCE_ARR_MAP0

li a0, 0
jal INIT_PLAYERS

GAME:
	la a0, MAPS
	la a1, CORRESPONDENCE_ARR_MAP0
	jal DRAW_MAP
	jal DRAW_CURSOR

	jal DRAW_PLAYERS

	jal GET_KBD_INPUT
	mv s0, a0
	jal MOVE_CURSOR
	jal DRAW_CURSOR

	li t0, 'x'
	beq s0, t0, move_player_game

continue_loop_game:
	jal SWAP_FRAMES
	j GAME

move_player_game:
	j continue_loop_game




.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
.include "../src/map.s"
