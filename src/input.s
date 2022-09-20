#####################################################
# Retorna uma direçao nos registradores a0 e a1 a partir
# da tecla que foi pressionada, da seguinte forma:
# keyCode | a0 | a1
#    'w'  | 0  | -1
#    'a'  | -1  | 0
#    's'  | 0  | 1
#    'd'  | 1  | 0
# Caso keyCode nao seja uma das letras acima retorna
# a0 = 0 e a1 = 0.
#####################################################
# a0 = keyCode
#####################################################
GET_DIR_FROM_KEY:
	li t0, 'w'
	bne, a0, t0, notW_get_dir_from_key
	li a0, 0
	li a1, -1
	ret
notW_get_dir_from_key:
	li t0, 'a'
	bne, a0, t0, notA_get_dir_from_key
	li a0, -1
	li a1, 0
	ret
notA_get_dir_from_key:
	li t0, 's'
	bne, a0, t0, notS_get_dir_from_key
	li a0, 0
	li a1, 1
	ret
notS_get_dir_from_key:
	li t0, 'd'
	bne, a0, t0, notD_get_dir_from_key
	li a0, 1
	li a1, 0
	ret
notD_get_dir_from_key:
	mv a0, zero
	mv a1, zero
	ret

#####################################################
# Retorna o código da tecla sendo pressionada ou 0
# caso nenhuma tecla estiver pressionada.
#####################################################
GET_KBD_INPUT:
	li t1, KBD_CONTROL		      		# carrega o endere�o de controle do KDMMIO
 	lw t0, 0(t1)			          		# Le bit de Controle Teclado
	andi t0, t0, 0x0001		      		# mascara o bit menos significativo
	beq t0, zero, ret_kbd_input	    # não tem tecla pressionada entao retorna
	lw a0, 4(t1)										# le o valor da tecla
	ret

ret_kbd_input:
	mv a0, zero
	ret
