#################################################
#	Toca um som sem interromper o jogo.
# É necessário passar como argumento uma lista de
# words com as seguintes informacoes:
# tamanho, i, MIN_WORD, notas/duracoes
##################################################
# a0 = endereco da lista com informacoes do audio
# no formato explicado acima (ver audio_test.s para um exemplo)
# a1 = instrumento
# a2 = volume
##################################################
playAudio:

	# check if enough time passed between notes
	lw t0, 8(a0)
	csrr t1, time
	# t1 = time passed since last note
	sub t1, t1, t0

	# t0 = (i-1) % tamanho
	lw t0, 4(a0)
	lw t2, 0(a0)
	add t0, t0, t2
	addi t0, t0, -1
	rem t0, t0, t2

	# t0 = last note duration
	slli t0, t0, 3
	add t0, t0, a0
	lw t0, 16(t0)

	# return if not enought time passed
	blt t1, t0, ret_playAudio

	# save ra
	addi sp, sp, -4
	sw ra, 0(sp)

	# save time when the note was played
	csrr t0, time
	sw t0, 8(a0)

	# t0 = nota, t1 = duracao, t2 = (i + 1) % tamanho
	lw t2, 4(a0)
	slli t1, t2, 3
	add t1, t1, a0
	lw t0, 12(t1)
	lw t1, 16(t1)
	addi t2, t2, 1
	lw t3, 0(a0)
	rem t2, t2, t3

	# save incremented value of i
	sw t2, 4(a0)

	# play sound
	# TODO: remove ecall 33
	mv a0, t0
	mv a3, a2
	mv a2, a1
	mv a1, t1
	li a7, 33
	ecall

	lw ra, 0(sp)
	addi sp, sp, 4

ret_playAudio:
	ret

AUDIO_TEST:
	addi sp, sp, -4
	sw ra, 0(sp)

	li a7, 1
	ecall

	li a0, '\n'
	li a7, 11
	ecall

	mv a0, a1
	li a7, 1
	ecall

	li a0, '\n'
	li a7, 11
	ecall

	lw ra, 0(sp)
	addi sp, sp, 4
	ret
