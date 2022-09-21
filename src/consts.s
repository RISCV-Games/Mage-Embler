# Video
.eqv CURRENT_DISPLAY_FRAME_ADRESS 0xFF200604
.eqv BUFFER_ADRESS 0xFF000000
.eqv NUMBER_OF_PIXELS 0x12C00
.eqv TILE_SIZE 16
.eqv NUMBER_OF_TILES_IN_IMAGE 6
.eqv SCREEN_SIZE 320
.eqv KBD_CONTROL 0xFF200000
.eqv CURSOR_IMG tiles
.eqv CURSOR_NUM0 4 # tile number of first frame of cursor animation
.eqv CURSOR_NUM1 5 # tile number of second frame of cursor animation
.eqv CURSOR_ANIM_DELAY 200 # time between each frame of cursor animation
.eqv SCREEN_CENTER_X 9
.eqv SCREEN_CENTER_Y 7
.eqv TILES_PER_MAP 300
.eqv MAX_WORD 0xFFFFFFFF
.eqv MIN_WORD 0x10000000
.eqv N_CURSOR_TRAIL 40
.eqv TRAIL_BODY_TILE 0
.eqv TRAIL_HEAD_TILE 1
.eqv GET_DIR_EXCEPTION 1000
# Constantes para representacao do mapa
.eqv BLOCK_EMPTY 0
.eqv BLOCK_OBSTACLE 1
.eqv BLOCK_ALLY 2
.eqv BLOCK_ENEMY 3
# Tiles usadas para desenhar o mapa no modo debug
.eqv DEBUG_TILE_EMPTY 3
.eqv DEBUG_TILE_OBSTACLE 1
.eqv DEBUG_TILE_ALLY 2
.eqv DEBUG_TILE_ENEMY 0