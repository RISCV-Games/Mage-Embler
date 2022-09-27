.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
MAKING_TRAIL: .byte 0

.text
jal INIT_VIDEO
GAME:
	la a0, MAPS
	la a1, CORRESPONDENCE_ARR_MAP0
	jal DRAW_MAP

	la t0, MAKING_TRAIL
	lb t0, 0(t0)
	beq t0, zero, not_making_trail_game

	jal DRAW_WALKABLE_BLOCKS
	jal GET_KBD_INPUT
	jal MAKE_TRAIL
	jal DRAW_CURSOR

continue_loop_game:
	jal SWAP_FRAMES
	j GAME

not_making_trail_game:
	jal GET_KBD_INPUT
	mv s0, a0
	jal MOVE_CURSOR
	jal DRAW_CURSOR
	li t0, 'x'
	beq s0, t0, get_walkable
	j continue_loop_game

get_walkable:
	la t0, CURSOR_POS
	lb a0, 0(t0)
	lb a1, 1(t0)
	la a2, MAPS
	jal UPDATE_WALKABLE_BLOCKS

	la t0, MAKING_TRAIL
	li t1, 1
	sb t1, 0(t0)
	jal INIT_CURSOR_TRAIL
	j continue_loop_game


.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
.include "../src/map.s"