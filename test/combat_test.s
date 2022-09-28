.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"
.data:
PLAYER1: .byte 0, 20, 5, 0
PLAYER2: .byte 0, 20, 15, 0

.text
jal INIT_VIDEO

GAME:
    la a0, PLAYER1
    la a1, PLAYER2
    jal DRAW_COMBAT
    jal SWAP_FRAMES
	
  j GAME


.include "../src/video.s"
.include "../src/cursor.s"
.include "../src/combat.s"
