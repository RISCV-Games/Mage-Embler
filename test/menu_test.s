.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
opcao1: .string "opcao 1\n"
opcao2: .string "opcao 2\n"

opcoes: .word opcao1, opcao2

.text
	jal INIT_VIDEO

GAME:
  la a0, 2
  la a1, opcoes
  li a2, 0x000009ff
  li a3, 240
  li a4, 320
  jal DRAW_MENU

	jal SWAP_FRAMES
	j GAME


.include "../src/video.s"
.include "../src/menu.s"
