.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
	jal INIT_VIDEO

GAME:
	#li a0, 0x09090909
	#jal DRAW_BACKGROUND

	la a0, tiles
	li a1, 0
	li a2, 0
	li a3, 0
	jal RENDER_TILE

	la a0, tiles
	li a1, 0
	li a2, 1
	li a3, 1
	jal RENDER_TILE

	la a0, tiles
	li a1, 50
	li a2, 70
	li a3, 96
	li a4, 16
	li a5, 0
	jal RENDER

	la a0, tiles
	li a1, 0
	li a2, 86
	li a3, 96
	li a4, 16
	li a5, 1
	jal RENDER


	li a0, 0x09090909
	li a1, 100
	li a2, 100
	li a3, 120
	li a4, 120
	jal DRAW_FILL_RETANGULE

	li a0, 0x0FF
	li a1, 100
	li a2, 100
	li a3, 120
	li a4, 120
	jal DRAW_RETANGULE

	li a0, 50
	li a1, 50
	li a2, 100
	li a3, 100
	li a4, 0x000000FF
	jal DRAW_LINE

	jal SWAP_FRAMES
	j GAME


.include "../src/video.s"
