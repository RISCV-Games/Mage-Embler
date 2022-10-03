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
	bltu t1, t0, ret_playAudio

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

    jal MIDI_OUT

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





###########################################
#        MidiOut 31 (2015/1)              #
#  a0 = pitch (0-127)                     #
#  a1 = duration in milliseconds          #
#  a2 = instrument (0-15)                 #
#  a3 = volume (0-127)                    #
###########################################


#################################################################################################
#
# Note Data           = 32 bits     |   1'b - Melody   |   4'b - Instrument   |   7'b - Volume   |   7'b - Pitch   |   1'b - End   |   1'b - Repeat   |   11'b - Duration   |
#
# Note Data (ecall) = 32 bits     |   1'b - Melody   |   4'b - Instrument   |   7'b - Volume   |   7'b - Pitch   |   13'b - Duration   |
#
#################################################################################################
MIDI_OUT:
    DE1(s8,de2_midi_out)
	
    li a7,31		# Chama o ecall normal
	ecall
	j fim_midi_out

de2_midi_out:	
    li      t0, NOTE_DATA
    add     t1, zero, zero

    # Melody = 0

    # Definicao do Instrumento
	andi    t2, a2, 0x0000000F
    slli    t2, t2, 27
    or      t1, t1, t2

    # Definicao do Volume
    andi    t2, a3, 0x0000007F
    slli    t2, t2, 20
    or      t1, t1, t2

    # Definicao do Pitch
    andi    t2, a0, 0x0000007F
    slli    t2, t2, 13
    or      t1, t1, t2

    # Definicao da Duracao
    li 	t4, 0x1FF
    slli 	t4, t4, 4
    addi 	t4, t4, 0x00F			# t4 = 0x00001FFF
    and    	t2, a1, t4
    or      t1, t1, t2

    # Guarda a definicao da duracao da nota na Word 1
    j       sint_midi_out

sint_midi_out:	
    sw	t1, 0(t0)

	# Verifica a subida do clock AUD_DACLRCK para o sintetizador receber as definicoes
	li      t2, NOTE_CLOCK
check_aud_daclrck_midi_out:     	
    lw      t3, 0(t2)
    beq     t3, zero, check_aud_daclrck_midi_out

fim_midi_out:    		
    ret

