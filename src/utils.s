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

##############################################################
# Retorna a posição onde o ACTION_MENU deve ser desenhado
# de acordo com a posição do SELECTED_PLAYER
##############################################################
GET_ACTION_MENU_POS:
	# (t0, t1) = *SELECTED_PLAYER.pos
	la t0, SELECTED_PLAYER
	lw t0, 0(t0)
	lb t1, PLAYER_B_POS_Y(t0)
	lb t0, PLAYER_B_POS_X(t0)

	# if the player is to the right of the screen the menu should be at the left
	li t2, SCREEN_CENTER_X
	bge t0, t2, left_get_action_menu_pos

	# else the menu should be at the right
	li a0, ACTIONS_MENU_POS_X_RIGHT
	li a1, ACTIONS_MENU_POS_Y_RIGHT
	ret

left_get_action_menu_pos:
	li a0, ACTIONS_MENU_POS_X_LEFT
	li a1, ACTIONS_MENU_POS_Y_LEFT
	ret