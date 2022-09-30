.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data
string_test: .string "ruan\npetrus"

.text
	jal INIT_VIDEO

GAME:
	li a0, 0x09090909
	jal DRAW_BACKGROUND

  la a0 string_test
  li a1, 16
  li a2, 16
  li a3, 0x000009ff
  jal PRINT_STRING

  li a0, 10
  li a1, 100
  li a2, 100
  li a3, 0x000009ff
  jal PRINT_INT

	jal SWAP_FRAMES
	j GAME


.include "../src/video.s"
