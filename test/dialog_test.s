.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
string_test: .string "Voces esta em um dialogo bla bla\noutra linha de dialogo aqui\nmais uma linha de dialogo aqui\noutra aqui linha aqui"

.text
	jal INIT_VIDEO

GAME:

    la a0, string_test # endereco para a label com as strings
    li a1, 0x000009ff  # Cor das strings
    li a2, 300          # Tamanho x do menu
    li a3, 100          # Tamanho y do menu
    li a4, 0x09090909  # Cor de fundo do menu
    li a5, 10         # Posicao x do menu
    li a6, 20          # Posicao y do menu
    jal DRAW_DIALOG


	jal SWAP_FRAMES
	j GAME


.include "../src/video.s"
.include "../src/dialog.s"
.include "../src/menu.s"
.include "../src/utils.s"
