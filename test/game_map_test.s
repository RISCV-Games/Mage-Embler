.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
jal INIT_VIDEO
GAME:
	la a0, MAPS
	jal DRAW_MAP_DEBUG


	jal SWAP_FRAMES
	j GAME


.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
.include "../src/map.s"