.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
jal INIT_VIDEO
GAME:
	la a0, CORRESPONDENCE_ARR_MAP0
	li a1, 0x0
	li a2, SCREEN_CENTER_X,
	li a3, SCREEN_CENTER_Y
	jal DRAW_BLOCK

	jal SWAP_FRAMES
	j GAME


.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
.include "../src/map.s"