.include "../src/data.s"
.include "../src/macros.s"

.text
la t0, GAME_STATE
sb zero, 0(t0)

GAME:

jal RUN_GAME_LOGIC
jal RUN_GAME_RENDER

j GAME

.include "../src/player.s"
.include "../src/video.s"
.include "../src/input.s"
.include "../src/cursor.s"
.include "../src/map.s"
.include "../src/utils.s"
.include "../src/menu.s"
.include "../src/combat.s"
.include "../src/dialog.s"
.include "../src/game_render.s"
.include "../src/game_logic.s"