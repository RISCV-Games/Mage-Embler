.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.text
  jal INIT_VIDEO

GAME:
  li a0, 0x09090909
  jal DRAW_BACKGROUND

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

  jal SWAP_FRAMES
  j GAME


.include "../src/video.s"
