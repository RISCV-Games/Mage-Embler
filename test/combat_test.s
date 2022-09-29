.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.eqv magia_x 60
.eqv magia_y 110
.data:
.align 2
PLAYER1: .word 0 ,0
.byte 20, 5
.half 0, 0 
.byte 0, 0
.byte AL_AZUL
PLAYER2: .word 0, 0
.byte 20, 15 
.half 0, 0 
.byte 0, 0
.byte AL_AZUL

.text
jal INIT_VIDEO

la t0, PLAYER1
la t1, PLAYER2
la t2, PLAYERS_IN_COMBAT

sw t0, 0(t2)
sw t1, 4(t2)

la t0, IN_COMBAT
li t1, 1
sb t1, 0(t0)

GAME:
    
	li a0, 0x09090909
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
