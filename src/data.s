.include "../src/consts.s"

.data
FRAME_TO_DRAW: .byte 0
CURSOR_POS: .byte SCREEN_CENTER_X, SCREEN_CENTER_Y
.align 2
CURSOR_ANIM: .word 2, 0, MIN_WORD, CURSOR_NUM0, CURSOR_NUM1
.align 0
CURSOR_TRAIL: .space N_CURSOR_TRAIL


WALKABLE_BLOCKS: .align 0
.space TILES_PER_MAP

.align 0
MAPS:
.byte
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0x0a,0,0,0,0,0,0,0x11,0x11,0,0,0,0,0,0,
0,0,0, 0x0a,0,0,0,0,0,0,0,0,0x11,0x11,0,0,0,0,0,0,
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

CORRESPONDENCE_ARR_MAP0:
.byte 3, 2, 0

# Images
.include "../sprites/tiles.data"
