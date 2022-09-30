###########################################################
#	Retorna o tamanho da string em a1, quebrando a convensao#
# retornando a posicao selecionada 0 index                  # 
########################################################  #
# a0 = endereco da string                               #
#########################################################
GET_STRING_SIZE:
	li t0, 0     # counter
	li t4, 0	 # last bigger
	mv t1, a0

loop_GET_STRING_SIZE:
	lb t2, 0(t1) # char
	beq t2, zero, end_GET_STRING_SIZE
	li t3, '\n'
	bne t2, t3, not_pula_GET_STRING_SIZE

	# If finds \n
	ble t0, t4, not_bigger_GET_STRING_SIZE     # t0 new bigger
	mv t4, t0

not_bigger_GET_STRING_SIZE:
	li t0, -1

not_pula_GET_STRING_SIZE:
	addi t0, t0, 1
	addi t1, t1, 1
	j loop_GET_STRING_SIZE

end_GET_STRING_SIZE:
	mv a1, t0
	bgt t0, t4, counter_bigger_GET_STRING_SIZE
	mv a1, t4
counter_bigger_GET_STRING_SIZE:
	ret

##############################################################
# RandINT                                                    #
# retorna um numero pseudo aleatorio de 0 ate o input        # 
##############################################################
# a0 = n                                                     #
##############################################################
RAND_INT:
   csrr t0, time 
   remu a0, t0, a0
   ret
