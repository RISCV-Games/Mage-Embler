.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"
.include "../images/mago.data"
.include "../images/mago2.data"
.include "../images/smoke.data"
.include "../images/fumaca1.data"
.include "../images/fumaca2.data"
.include "../images/fumaca3.data"

.data
# Desenha 4 tiles de numeros 0, 1, 2, 3
fumaca_anim: .word 2, 0, MIN_WORD, fumaca1, fumaca3
mago_anim: .word 2, 0, MIN_WORD, mago, mago2

.text
jal INIT_VIDEO

GAME:
	li a0, 0x09090909
	jal DRAW_BACKGROUND

	li a0, 48
	la a1, fumaca_anim
	li a2, REAL_CENTER_X
	li a3, REAL_CENTER_Y
	li a4, 200
	li a5, 48
	jal DRAW_ANIMATION

	li a0, 16
	la a1, mago_anim
	li a2, REAL_CENTER_X
	li a3, REAL_CENTER_Y
	li a4, 200
	li a5, 16
	jal DRAW_ANIMATION

	jal SWAP_FRAMES
  j GAME



.include "../src/video.s"
