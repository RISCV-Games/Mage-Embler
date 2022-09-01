.include "data.s"
.include "consts.s"

.text
  jal INIT_VIDEO

GAME:
  li a0, 0x09090909
  jal DRAW_BACKGROUND
  jal SWAP_FRAMES
  j GAME


.include "video.s"
