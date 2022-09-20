.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
jal INIT_VIDEO
jal INIT_CURSOR_PATH
GAME:
	li a0, 0x09090909
	jal DRAW_BACKGROUND
	jal GET_KBD_INPUT
	jal MAKE_PATH
	jal DRAW_CURSOR

	jal SWAP_FRAMES

	j GAME


.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
