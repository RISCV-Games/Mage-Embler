.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
opcao1: .string "opcao 1\n"
opcao2: .string "opcao 2\n"
opcao3: .string "opcao 3\n"

opcoes: .word opcao1, opcao2, opcao3

.text
	jal INIT_VIDEO

GAME:
  li a0, 3
  la a1, opcoes
  li a2, 0x000009ff
  li a3, 100
  li a4, 100
  li a5, 0x09090909
  jal DRAW_MENU

	jal SWAP_FRAMES
	j GAME


.include "../src/video.s"
.include "../src/menu.s"
