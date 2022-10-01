.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"

.data:


PLAYER_1: .string "Player1"
PLAYER_2: .string "Player2"

.align 2
PLAYER1: .word,0, 0
.byte 20, 20
.half 0, 0 
.byte 0, 0
.word PLAYER_1
.byte AL_AZUL
.byte 5, 50, 1
PLAYER2: .word 0, 0
.byte 25, 15
.half 0, 0 
.byte 0, 0
.word PLAYER_2
.byte IN_MAR
.byte 5, 50, 1


.text
la s0, PLAYER_1
INIT_PLAYER(s0, 5, 5, AL_AZUL, 25, 25, 1, 1, 1)
INIT_PLAYER(s0, 5, 5, IN_VER, 25, 25, 1, 1, 1)
jal INIT_VIDEO

la t0, PLAYERS
addi t1, t0, PLAYER_BYTE_SIZE
la t2, PLAYERS_IN_COMBAT

sw t0, 0(t2)
sw t1, 4(t2)

la t0, IN_COMBAT
li t1, 1
sb t1, 0(t0)

GAME:
    jal LOGIC_COMBAT
    
	li a0, 0xCCCCCCCC
	jal DRAW_BACKGROUND

    la t0, IN_COMBAT
    lb t0, 0(t0)
    beq t0, zero, no_combat

    la t0, PLAYERS_IN_COMBAT
    lw a0, 0(t0)
    lw a1, 4(t0)

    la t0, PLAYER_ATACKING
    lb a2, 0(t0)
    
    la t0, IS_PRINT_DMG
    lb a3, 0(t0)

    jal DRAW_COMBAT


no_combat:
    jal SWAP_FRAMES
	
  j GAME


.include "../src/video.s"
.include "../src/cursor.s"
.include "../src/combat.s"
.include "../src/dialog.s"
.include "../src/menu.s"
.include "../src/utils.s"
.include "../src/input.s"
