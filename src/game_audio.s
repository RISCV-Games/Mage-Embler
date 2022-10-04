######################################################################
# Roda a lógica de audio do jogo baseado no
######################################################################
RUN_GAME_AUDIO:
	addi sp, sp, -4
	sw ra, 0(sp)

	la t0, AUDIO_STATE
	lb t0, 0(t0)

	li t1, AUDIO_STATE_NOTHING
	beq t0, t1, nothing_run_game_audio

	li t1, AUDIO_STATE_START_MENU
	beq t0, t1, start_menu_run_game_audio

	li t1, AUDIO_STATE_WIN_MENU
	beq t0, t1, win_menu_run_game_audio
	
	li t1, AUDIO_STATE_MAP
	beq t0, t1, map_run_game_audio

	li t1, AUDIO_STATE_COMBAT
	beq t0, t1, combat_run_game_audio

	li t1, AUDIO_STATE_MOVE_CURSOR
	beq t0, t1, move_cursor_run_game_audio

	li t1, AUDIO_STATE_NOTHING
	beq t0, t1, nothing_run_game_audio


ret_run_game_audio:
	lw ra, 0(sp)
	addi sp, sp, 4
	ret

nothing_run_game_audio:
	j ret_run_game_audio

start_menu_run_game_audio:
	la a0, START_MENU_SONG
	li a1, START_MENU_INSTRUMENT
	li a2, SONG_VOLUME
	jal playAudio

	j ret_run_game_audio

win_menu_run_game_audio:
	la a0, WIN_MENU_SONG
	li a1, WIN_MENU_INSTRUMENT
	li a2, SONG_VOLUME
	jal playAudio

	j ret_run_game_audio

map_run_game_audio:
	la a0, MAP_SONG
	li a1, WIN_MENU_INSTRUMENT
	li a2, SONG_VOLUME
	jal playAudio

	j ret_run_game_audio

combat_run_game_audio:
	la a0, COMBAT_SONG
	li a1, WIN_MENU_INSTRUMENT
	li a2, SONG_VOLUME
	jal playAudio

	j ret_run_game_audio

move_cursor_run_game_audio:
	li a0, 25
	li a1, 100
	li a2, 0
	li a3, SONG_VOLUME
	jal MIDI_OUT

	# *AUDIO_STATE = AUDIO_STATE_NOTHING
	la t0, AUDIO_STATE
	li t1, AUDIO_STATE_NOTHING
	sb t1, 0(t0)

	j ret_run_game_audio