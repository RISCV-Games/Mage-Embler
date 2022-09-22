#########################################################
#	Cria uma caixa de dialogo a com as informacoes      #
#   Desejadas                                           #
#########################################################
# a0 = endereco da string                               # 
# a1 = cor da string                                    #
# a2 = tamanho x do dialogo                             #
# a3 = tamanho y do dialogo                             #
# a4 = cor do dialogo                                   #
# a5 = x do dialogo                                     #
# a6 = y do dialogo                                     #  
#########################################################
DRAW_DIALOG:
    addi sp, sp, -28
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)

    mv s0, a0
    mv s1, a1
    mv s2, a2
    mv s3, a3
    mv s5, a5
    mv s6, a6

    # Drawing box
    mv a0, a4
    mv a1, a5
    mv a2, a6
    mv a3, s2
    mv a4, s3
    jal DRAW_FILL_RETANGULE

    li a0, 0x0FF
    jal DRAW_RETANGULE

    mv a0, s0
    jal GET_STRING_SIZE  # a1 = string size

    # Getting centralize string position
    slli a1, a1, 3
    sub t0, s2, a1       # size x - string_size
    srai t0, t0, 1       # t0 / 2
    add a1, t0, s5        

    addi a2, s6, SPACE_BETWEEN_STRING_DIALOG       # Y do dialogo + 4
    mv a3, s1                                      # string color
    mv a0, s0                                      # String position
    jal PRINT_STRING

    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)

    addi sp, sp, 28
    ret


#################################################################
# Systema de input do menu                                      #
# O sistema é nao blocking e apos o player apertar              #
# enter adiciona um na label recebida                           #
#################################################################
# a0 = label para acrecentar toda vez que o player aperta enter #
#################################################################
INPUT_DIALOG:
	li t1,0xFF200000        	            # carrega o endereco de controle do KDMMIO
	lw t0,0(t1)        		                # Le bit de Controle Teclado
	andi t0,t0,0x0001        	            # mascara o bit menos significativo
	beq t0,zero, fim_input_dialog          	# Se nenhuma tecla pressionada, vá para FIM


	lw t2, 4(t1)                            # t2 = valor da tecla teclada

	li t0, '\n'          
	beq t2, t0, inc_input_dialog
	j fim_input_dialog

inc_input_dialog:
	lb t0, 0(a0)
	addi t0, t0, 1
    sb t0, 0(a0)

fim_input_dialog:
	ret

