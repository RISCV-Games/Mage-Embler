.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.eqv magia_x 60
.eqv magia_y 110
.data:
.align 2
PLAYER1: .word combat_mago_pose, magia_idle
.byte 20, 5
.half magia_x, magia_y 
.byte IDLE_POWER_WIDTH, IDLE_POWER_HEIGHT
PLAYER2: .word combat_mago_idle, magia_idle
.byte 20, 15 
.half magia_x, magia_y 
.byte IDLE_POWER_WIDTH, IDLE_POWER_HEIGHT

.text
jal INIT_VIDEO

GAME:
    
	li a0, 0x09090909
	jal DRAW_BACKGROUND

    la a0, PLAYER1
    la a1, PLAYER2
    li a2, 1
    jal DRAW_COMBAT
    jal SWAP_FRAMES
	
  j GAME


.include "../src/video.s"
.include "../src/cursor.s"
.include "../src/combat.s"
