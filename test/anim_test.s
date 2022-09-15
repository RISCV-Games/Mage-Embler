.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

# Como eh um .data de teste achei melhor deixar no proprio arquivo
.data
# Desenha 4 tiles de numeros 0, 1, 2, 3
animTest: .word 4, 0, 0, 1, 2, 3

.text
  jal INIT_VIDEO

GAME:
	la a0, tiles
	la a1, animTest
	li a2, 3
	li a3, 5
	jal DRAW_ANIMATION_TILE

	li a0, 500
	li a7, 32
	ecall


  jal SWAP_FRAMES
  j GAME


.include "../src/video.s"
