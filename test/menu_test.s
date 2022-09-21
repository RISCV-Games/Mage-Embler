.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
opcao1: .string "opcao 1"
opcao2: .string "opcao 2"
opcao3: .string "opcao 3"

opcoes: .word opcao1, opcao2, opcao3

.text
	jal INIT_VIDEO

GAME:
  li a0, 3           # Quantiadade de strings
  la a1, opcoes      # endereco para a label com as strings
  li a2, 0x000009ff  # Cor das strings
  li a3, 60          # Tamanho x do menu
  li a4, 100          # Tamanho y do menu
  li a5, 0x09090909  # Cor de fundo do menu
  li a6, 100         # Posicao x do menu
  li a7, 20          # Posicao y do menu
  li s8, 1           # String selecionada (0 index)
  jal DRAW_MENU

	jal SWAP_FRAMES
	j GAME


.include "../src/video.s"
.include "../src/menu.s"
