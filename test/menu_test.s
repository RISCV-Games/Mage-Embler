# Mova pelo menu e aperte enter para trocar de cor

.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
opcao1: .string "vermelho"
opcao2: .string "amarelo"
opcao3: .string "azul"

opcoes: .word opcao1, opcao2, opcao3

selected_option: .byte 0
is_selected: .byte 0
tile_to_draw: .byte 0

.text
	jal INIT_VIDEO

GAME:
  # Render
  li a0, 3           # Quantidade de strings
  la a1, opcoes      # endereco para a label com as strings
  li a2, 0x000009ff  # Cor das strings
  li a3, 70          # Tamanho x do menu
  li a4, 100          # Tamanho y do menu
  li a5, 0x09090909  # Cor de fundo do menu
  li a6, 100         # Posicao x do menu
  li a7, 20          # Posicao y do menu

  la t0, selected_option
  lb s8, 0(t0)        # String selecionada (0 index)
  jal DRAW_MENU

  # Input
  li a0, 3                      # Quantidade de opcoes
  la a1, selected_option        # label que segura opcao selecionada
  la a2, is_selected            # label que segura se foi selecionado ou nao
  jal INPUT_MENU

  # Some logic
  la t0, is_selected
  lb t1, 0(t0)
  beq t1, zero, DO_NOTHING
  # Do something here
  sb zero, 0(t0)       # Restart menu
  # Changing tile to draw
  la t0, selected_option
  lb t1, 0(t0)
  la t0, tile_to_draw
  sb t1, 0(t0)


DO_NOTHING:

  # Drawing some tiles
	la a0, tiles
	li a1, 8
	li a2, 8
  # getting color from selected option
  la t0, tile_to_draw
  lb a3, 0(t0)
	jal RENDER_TILE

	jal SWAP_FRAMES
	j GAME

.include "../src/video.s"
.include "../src/menu.s"
.include "../src/utils.s"
