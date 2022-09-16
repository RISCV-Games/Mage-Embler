.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"
.data
deathSound: .word 13, 0, MIN_WORD
69,500,76,500,74,500,76,500,79,600, 76,1000,0,1200,69,500,76,500,74,500,76,500,81,600,76,1000

.text

LOOP:
	la a0, deathSound
	li a1, 0
	li a2, 1
	jal playAudio
	j LOOP

.include "../src/audio.s"