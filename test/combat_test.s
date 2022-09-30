.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data:

.align 2
PLAYER1: .word 0 ,0
.byte 20, 10
.half 0, 0 
.byte 0, 0
.byte AL_VER
.byte 5
PLAYER2: .word 0, 0
.byte 25, 15 
.half 0, 0 
.byte 0, 0
.byte IN_AZUL
.byte 5

.text
jal INIT_VIDEO

la t0, PLAYER1
la t1, PLAYER2
la t2, PLAYERS_IN_COMBAT

sw t0, 0(t2)
sw t1, 4(t2)

la t0, IN_COMBAT
li t1, 2
sb t1, 0(t0)

GAME:
    
	li a0, 0xFFFFFFFF
	jal DRAW_BACKGROUND

    la t0, IN_COMBAT
    lb t0, 0(t0)
    beq t0, zero, no_combat

    la t0, PLAYERS_IN_COMBAT
    lw a0, 0(t0)
    lw a1, 4(t0)

    la t0, PLAYER_ATACKING
    lb a2, 0(t0)
    jal DRAW_COMBAT

    jal LOGIC_COMBAT

no_combat:
    jal SWAP_FRAMES
	
  j GAME


.include "../src/video.s"
.include "../src/cursor.s"
.include "../src/combat.s"
