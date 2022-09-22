#########################################################
#	Cria um menu a partir de opcoes dadas por strings     #
# retornando a posicao selecionada 0 index                # 
#########################################################
# a0 = quantidade de opcoes                             #
# a1 = endereco das strings                             #
# a2 = cor das strings                                  #
# a3 = tamanho x do menu                                #
# a4 = tamanho y do menu                                #
# a5 = cor do menu                                      #
# a6 = x do menu                                        #
# a7 = y do menu                                        #  
# s8 = opcao selecionada do menu                        #  
#########################################################
DRAW_MENU:
	addi sp, sp, -36
	sw ra, 0(sp)
	sw s0, 4(sp) # a0
	sw s1, 8(sp) # a1
	sw s2, 12(sp) # a2 
	sw s3, 16(sp) # a3
	sw s4, 20(sp) # starting y 
	sw s5, 24(sp) # counter
	sw s6, 28(sp) # starting x
	sw s8, 32(sp) # selected option

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3

	# Calculating starting y
	slli s4, a0, 3
	sub s4, a4, s4
	srai s4, s4, 1

	# Drawing retangule
	mv a1, a6
	mv a2, a7

	mv s6, a1
	add s4, s4, a2

	mv a0, a5

	jal DRAW_FILL_RETANGULE
	# Drawing board lines
	mv a1, a6
	mv a2, a7

	li a0, 0x0FF
	jal DRAW_RETANGULE

	li s5, 0 # counter

drawstring_DRAW_MENU:
	bge s5, s0, end_DRAW_MENU
	
	# Getting string
	slli t1, s5, 2
	add t1, s1, t1 # t1 = s1 + 4 * t0
	lw a0, 0(t1)

	# Caluculating string position on menu
	jal GET_STRING_SIZE # a1 = string size

	slli a1, a1, 3
	sub a1, s3, a1
	srai a1, a1, 1 # a1 = (size_x - string_size) / 2
	add a1, a1, s6

	mv a2, s4
	mv a3, s2

	bne s5, s8, not_selected_DRAW_MENU

	# Code to do with a selected option inverting colors right now
	andi t0, a3, 0x000000FF # last byte
	andi t2, a3, 0x0000FF00 # second last  byte
	
	slli t0, t0, 8  # um byte para a esquerda
	srli t2, t2, 8  # um byte para a direita

	add a3, t0, t2  # Adding together

not_selected_DRAW_MENU:
	jal PRINT_STRING

	addi s5, s5, 1
	addi s4, s4, 8

	j drawstring_DRAW_MENU
	
end_DRAW_MENU:
	lw ra, 0(sp)
	lw s0, 4(sp) # a0
	lw s1, 8(sp) # a1
	lw s2, 12(sp) # a2 
	lw s3, 16(sp) # a3
	lw s4, 20(sp) # starting y 
	lw s5, 24(sp) # counter
	lw s6, 28(sp) # starting x
	sw s8, 32(sp) # selected option

	addi sp, sp, 36

	ret


###########################################################
#	Retorna o tamanho da string em a1, quebrando a convensao#
# retornando a posicao selecionada 0 index                  # 
########################################################  #
# a0 = endereco da string                               #
#########################################################
GET_STRING_SIZE:
	li t0, 0     # counter
	mv t1, a0

loop_GET_STRING_SIZE:
	lb t2, 0(t1) # char
	beq t2, zero, end_GET_STRING_SIZE
	addi t0, t0, 1
	addi t1, t1, 1
	j loop_GET_STRING_SIZE

end_GET_STRING_SIZE:
	mv a1, t0
	ret


#########################################################
# Systema de input do menu                              #
# O sistema é nao blocking e altera a opcao             #
# atualmente selecionada na memoria                     #
# Possui um estado de menu ou nao coloca o estado em 0  #
# Apos o player selecionar uma opcao                    #
#########################################################
# a0 = quantidade de opcoes                             #  
# a1 = label de que segura opcao do menu                #
# a2 = label de que segura quando o player fez uma acao #
#########################################################
INPUT_MENU:
	li t1,0xFF200000        	            # carrega o endereco de controle do KDMMIO
	lw t0,0(t1)        		                # Le bit de Controle Teclado
	andi t0,t0,0x0001        	            # mascara o bit menos significativo
	beq t0,zero, fim_input_menu          	# Se nenhuma tecla pressionada, vá para FIM


	lw t2, 4(t1)                            # t2 = valor da tecla teclada

	li t0, 's'          
	beq t2, t0, inc_input_menu
	li t0, 'w'          
	beq t2, t0, dec_input_menu
	li t0, '\n'          
	beq t2, t0, selected_input_menu
	j fim_input_menu


inc_input_menu:
	lb t0, 0(a1)
	addi t0, t0, 1

	blt t0, a0, safe_inc_input_menu
	li t0, 0

safe_inc_input_menu:
	sb t0, 0(a1)
	j fim_input_menu

dec_input_menu:
	lb t0, 0(a1)
	addi t0, t0, -1

	bge t0, zero, safe_dec_input_menu
	addi t0, a0, -1

safe_dec_input_menu:
	sb t0, 0(a1)
	j fim_input_menu

selected_input_menu:
	li t0, 1
	sb t0, 0(a2)
	j fim_input_menu

fim_input_menu:
	ret


	

