.include "../src/consts.s"

.data
FRAME_TO_DRAW: .byte 0
CURSOR_POS: .byte SCREEN_CENTER_X, SCREEN_CENTER_Y
.align 2
CURSOR_ANIM: .word 2, 0, MIN_WORD, CURSOR_NUM0, CURSOR_NUM1
PLAYER_BLINK_ANIM0: .word 2, 0, MIN_WORD, 1, 2
PLAYER_BLINK_ANIM1: .word 2, 0, MIN_WORD, 2, 1
.align 0
CURSOR_TRAIL: .space N_CURSOR_TRAIL
MAKING_TRAIL: .byte 0
# Indicates if player blink animation is in progress
BLINK_ANIMATION: .byte 0

ACTUALLY_MOVE_PLAYER_DATA: 
.align 2
.word 0 # player
.byte 0 # oldPosX
.byte 0 # oldPosY
.byte 0 # status

.align 2
# Player animations data:
PLAYER_EARTH_STILL_ANIM: .word 2, 0, MIN_WORD, ALLY_EARTH_STILL_FRAME0, ALLY_EARTH_STILL_FRAME1

WALKABLE_BLOCKS: .align 2
.space TILES_PER_MAP

.align 0
MAPS:
.byte
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0x11,0x11,0,0,0,0,0,0,
0,0,0, 0,0,0,0,0,0,0,0,0,0x11,0x11,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0x11,0x11,0x11,0x11,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0x11,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0x11,0x11,0x11,0x11,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

.align 0
N_PLAYERS:
.byte 0

# Allocating PLAYER_BYTE_SIZE * 10 bytes
.align 0
PLAYERS:
.space 40

CORRESPONDENCE_ARR_MAP0:
.byte 3, 2, 1, 0

.align 2
# Images
.include "../sprites/tiles.data"
