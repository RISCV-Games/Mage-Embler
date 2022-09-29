# Video
.eqv CURRENT_DISPLAY_FRAME_ADRESS 0xFF200604
.eqv BUFFER_ADRESS 0xFF000000
.eqv NUMBER_OF_PIXELS 0x12C00
.eqv TILE_SIZE 16
.eqv NUMBER_OF_TILES_IN_IMAGE 1
.eqv SCREEN_SIZE 320
.eqv KBD_CONTROL 0xFF200000
.eqv CURSOR_IMG tiles
.eqv CURSOR_NUM0 4 # tile number of first frame of cursor animation
.eqv CURSOR_NUM1 5 # tile number of second frame of cursor animation
.eqv CURSOR_ANIM_DELAY 200 # time between each frame of cursor animation
.eqv SCREEN_CENTER_X 9
.eqv SCREEN_CENTER_Y 7
.eqv REAL_CENTER_X 160
.eqv REAL_CENTER_Y 120
.eqv TILES_PER_MAP 300
.eqv MAX_WORD 0xFFFFFFFF
.eqv MIN_WORD 0x10000000
.eqv N_CURSOR_TRAIL 300
.eqv TRAIL_VERTICAL_TILE 6
.eqv TRAIL_HORIZONTAL_TILE 7
.eqv ARROW_RIGHT_TILE 12
.eqv ARROW_LEFT_TILE 13
.eqv ARROW_UP_TILE 14
.eqv ARROW_DOWN_TILE 15
.eqv TRAIL_UR_TILE 8
.eqv TRAIL_UL_TILE 9
.eqv TRAIL_DR_TILE 10
.eqv TRAIL_DL_TILE 11
.eqv GET_DIR_EXCEPTION 1000
# Constantes para representacao do mapa
.eqv BLOCK_EMPTY 0
.eqv BLOCK_OBSTACLE 1
.eqv BLOCK_ALLY 2
.eqv BLOCK_ENEMY 3
.eqv BLOCK_WALKABLE 0
# Tiles usadas para desenhar o mapa no modo debug
.eqv DEBUG_TILE_EMPTY 3
.eqv DEBUG_TILE_OBSTACLE 1
.eqv DEBUG_TILE_ALLY 2
.eqv DEBUG_TILE_ENEMY 0

# Constantes para mecanica do jogo
.eqv MOVE_RADIUS 5
.eqv CURSOR_MAX_X 19
.eqv CURSOR_MAX_Y 14
.eqv MAP_WIDTH 20
.eqv MAP_HEIGHT 15

# Player related constants
.eqv PLAYER_BYTE_SIZE 8
.eqv PLAYER_BPOS_X 0
.eqv PLAYER_BPOS_Y 1
.eqv PLAYER_BIS_ALLY 2
.eqv PLAYER_BTILE_NUM 3
.eqv PLAYER_WMOVE_ANIMATION_DATA 4