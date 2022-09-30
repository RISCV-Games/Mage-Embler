.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
jal INIT_VIDEO
GAME:
	la a0, MAPS
	jal DRAW_MAP_DEBUG
	jal DRAW_WALKABLE_BLOCKS
	jal GET_KBD_INPUT
	mv s0, a0
	jal MOVE_CURSOR
	jal DRAW_CURSOR
	li t0, 'x'
	beq s0, t0, get_walkable

continue_loop_game:
	jal SWAP_FRAMES
	j GAME

get_walkable:
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	la a2, MAPS
	jal UPDATE_WALKABLE_BLOCKS
	j continue_loop_game

.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
.include "../src/map.s"