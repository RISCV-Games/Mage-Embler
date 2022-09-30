#################################################
#	Organiza os frames do buffer de video         #
#################################################
INIT_VIDEO:
	# Setting current view frame
	li t0, CURRENT_DISPLAY_FRAME_ADRESS
	# Force start on frame 0
	sw zero,0(t0)

	# Setting current draw frame
	la t0, FRAME_TO_DRAW
	li t1, 1
	sb t1, 0(t0)

	ret

#########################################################
#	Troca o frame desenhado e o frame que esta sendo visto#
#########################################################
SWAP_FRAMES:
	# Swap current view frame
	li t0, CURRENT_DISPLAY_FRAME_ADRESS 
	lw t1, 0(t0)
	xori t2,t1,1
	sw t2,0(t0)

	# Swap current draw frame
	la t0, FRAME_TO_DRAW
	sb t1, 0(t0)
	
	ret

#########################################################
#	Desenha a tela inteira com a cor desejada             #
#########################################################
# a0 = cor                                              #
#########################################################
DRAW_BACKGROUND:
	GET_BUFFER_TO_DRAW(t0)
	li t1, NUMBER_OF_PIXELS
	add t1, t0, t1

loop_draw_back_ground:
	bge t0, t1, end_draw_back_ground
	sw a0, 0(t0)
	addi t0, t0, 4
	j loop_draw_back_ground

end_draw_back_ground:
	ret

#########################################################
#	Desenha um retangulo e preenche com a cor desejada  #
#########################################################
# a0 = cor                                              #
# a1 = x                                                #
# a2 = y                                                #
# a3 = size_x                                           #
# a4 = size_y                                           #
#########################################################
DRAW_FILL_RETANGULE:
	GET_BUFFER_TO_DRAW(t0)

	# calculating starting position
	li t1, 320
	mul t1, a2, t1
	add t0, t0, t1
	add t0, t0, a1

	li t1, 0
	li t2, 0

draw_line_draw_fill_retangule:
	sb a0, 0(t0)
	addi t0, t0, 1
	addi t1, t1, 1
	blt t1, a3, draw_line_draw_fill_retangule

	li t1, 0
	addi t2, t2, 1

	addi t0, t0, 320
	sub t0, t0, a3

	bgt a4, t2, draw_line_draw_fill_retangule
	ret

#########################################################
#	Desenha um retangulo                                #
#########################################################
# a0 = cor                                              #
# a1 = x                                                #
# a2 = y                                                #
# a3 = size_x                                           #
# a4 = size_y                                           #
#########################################################
DRAW_RETANGULE:
	addi sp, sp -20
	sw ra, 0(sp)
	sw s0, 4(sp)
	sw s1, 8(sp)
	sw s2, 12(sp)
	sw s4, 16(sp)

	mv s0, a0
	mv s1, a1
	mv s2, a2
	mv s3, a3
	mv s4, a4

	# Linha horizontal um
	mv a0, s1
	mv a1, s2
	add a2, s1, s3
	mv a3, s2
	mv a4, s0
	jal DRAW_LINE

	# Linha horizontal 2
	mv a0, s1
	add a1, s2, s4
	add a1, s2, s4
	add a2, s1, s3
	add a3, s2, s4
	mv a4, s0
	jal DRAW_LINE

	# Linha vertical 1
	mv a0, s1
	mv a1, s2
	mv a2, s1
	add a3, s2, s4
	mv a4, s0
	jal DRAW_LINE

	# Linha vertical 2
	add a0, s1, s3
	mv a1, s2
	add a2, s1, s3
	add a3, s2, s4
	addi a3, a3, 1
	mv a4, s0
	jal DRAW_LINE

	lw ra, 0(sp)
	lw s0, 4(sp)
	lw s1, 8(sp)
	lw s2, 12(sp)
	lw s4, 16(sp)
	addi sp, sp 20


	ret

#########################################################
#	Desenha um tile na tela                               #
#########################################################
# a0 = endereço para a imagem                           #
# a1 = X                                                #
# a2 = Y                                                #
# a3 = numero da tile na imagem                         #
#########################################################
RENDER_TILE:
# Render baseado em tiles 16x16
	slli a1, a1, 4 # Multiplicando a1 x 16
	slli a2, a2, 4 # Multiplicando a2 x 16
	slli a3, a3, 4 # Multiplicando a3 x 16

	# Calculando posicao na tela para print
	GET_BUFFER_TO_DRAW(t0)
	add t0, t0, a1 # Adciona X

	li t1, SCREEN_SIZE
	mul t1, t1, a2 # y x 320
	add t0, t0, t1 # Adiciona y

	# Calculando a posicao na imagem
	add a0, a0, a3

	# Setting counter to zero
	li t2, 0 # Contador de coluna
	li t3, 0 # Contador de linha

	# Setting boundries
	li t4, TILE_SIZE
	li t5, NUMBER_OF_TILES_IN_IMAGE
	slli t5, t5, 4
	
draw_line_render_tile:
	lw t6,0(a0)			        # carrega em t6 uma word (4 pixeis) da imagem
	sw t6,0(t0)		        	# imprime no bitmap a word (4 pixeis) da imagem
		
	addi t0,t0,4			      # incrementa endereco do bitmap
	addi a0,a0,4			      # incrementa endereco da imagem
		
	addi t2,t2,4			      # incrementa contador de coluna
	blt t2,t4, draw_line_render_tile	# se contador da coluna < largura, continue imprimindo

	# isso serve pra "pular" de linha no bitmap display e na imagem
	addi t0,t0, SCREEN_SIZE # t0 += 320
	sub t0,t0,t4			      # t0 -= largura da tile
	add a0,a0, t5			      # a0 += image size 
	sub a0,a0,t4			      # t0 -= largura da tile
		
	li t2, 0			          # zera (contador de coluna)
	addi t3,t3,1			      # incrementa contador de linha
	bgt t4, t3, draw_line_render_tile		# se altura > contador de linha, continue imprimindo
		
	ret				              # retorna

#########################################################
#	Desenha uma imagem na tela desenha                    #
# sempre uma imagem toda                                #
#########################################################
# a0 = endereço para a imagem                           #
# a1 = X  real of screen                                #
# a2 = Y  real of screen                                #
# a3 = width of image                                   #
# a4 = height of image                                  #
# a5 = reverse (if 1 reverse image)                     # 
#########################################################
RENDER:
	# if X < 0 return
	blt a1, zero, ret_render

	# if Y < 0 return
	blt a2, zero, ret_render

	# if x + width >= 320 return
	add t0, a1, a3
	addi t0, t0, -320
	bge t0, zero, ret_render
	# if y + height >= 240 return
	add t0, a2, a4
	addi t0, t0, -240
	bge t0, zero, ret_render

	# Render baseado em tiles 16x16
	# Calculando posicao na tela para print
	GET_BUFFER_TO_DRAW(t0)
	add t0, t0, a1 # Adciona X

	li t1, SCREEN_SIZE
	mul t1, t1, a2 # y x 320
	add t0, t0, t1 # Adiciona y

	# Setting counter to zero
	li t2, 0 # Contador de coluna
	li t3, 0 # Contador de linha

	bne a5, zero, rev_render

draw_line_render:
	lb t6,0(a0)			                    # carrega em t6 um byte da imagem
	sb t6,0(t0)		        	            # imprime no bitmap byte da imagem
		
	addi t0,t0,1			                  # incrementa endereco do bitmap
	addi a0,a0,1			                  # incrementa endereco da imagem
		
	addi t2,t2,1			                  # incrementa contador de coluna
	blt t2,a3,draw_line_render          # se contador da coluna < largura, continue imprimindo

	# isso serve pra "pular" de linha no bitmap display e na imagem
	addi t0,t0, SCREEN_SIZE # t0 += 320
	sub t0,t0,a3			                  # t0 -= largura da tile
		
	li t2, 0			                      # zera (contador de coluna)
	addi t3,t3,1			                  # incrementa contador de linha
	bgt a4, t3, draw_line_render        # se altura > contador de linha, continue imprimindo
		
	ret				              # retorna

rev_render:
	addi t4, a3, -1                  # Width - 1
	add t0, t0, t4                   # Image inicio +  width - 1

rev_draw_line_render:
	lb t6,0(a0)			                 # carrega em t6 um byte da imagem
	sb t6,0(t0)			                 # imprime no bitmap o byte da imagem
		
	addi t0,t0, -1			             # incrementa endereco do bitmap
	addi a0,a0, 1			               # incrementa endereco da imagem
		
	addi t2,t2,1			               # incrementa contador de coluna
	blt t2,a3, rev_draw_line_render	 # se contador da coluna < largura, continue imprimindo

	addi t0,t0,320			             # t0 += 320
	add t0,t0,a3			               # t0 -= largura da imagem
	# ^ isso serve pra "pular" de linha no bitmap display
		
	li t2, 0
	addi t3,t3,1			                # incrementa contador de linha
	bgt a4,t3, rev_draw_line_render		# se altura > contador de linha, continue imprimindo
ret_render:
	ret				# retorna


##############################################################################################
#	Anima uma imagem com informações estão guardadas
# na memória começando no endereço em a1. Retorna 1 se a animação já foi desenhada por inteiro
# uma vez e 0 caso contrário
# Formato do a1 (WORD): tamanho, i, MIN_WORD, anim1..., animN
# cada animN representa um numero da tile a ser desenhada.
# "tamanho" indica quantos frames a animaçao possui.
# "i" eh um numero que satisfas 0 <= i < tamanho e indica a partir
# de qual frame a animacao comecara (geralmente i eh 0).
# Exemplos de como usar a funcao: anim_test.s, cursor_test.s
##############################################################################################
# a0 = endereço da imagem com tiles
# a1 = informações da animação
# a2 = X
# a3 = Y
# a4 = tempo entre frames (ms)
##############################################################################################
DRAW_ANIMATION_TILE:
	# save ra
	addi sp, sp, -8
	sw ra, 0(sp)

	# if time passed is less than a4, dont animate
	csrr t0, time
	lw t1, 8(a1)
	sub t0, t0, t1
	bgeu t0, a4, continue_draw_animation_tile

	# t1 = (t1 + tamanho - 1) % tamanho
	lw t0, 0(a1)
	lw t1, 4(a1)
	add t1, t0, t1
	addi t1, t1, -1
	rem t1, t1, t0 
	sw t1, 4(a1)
	j skip_draw_animation_tile

continue_draw_animation_tile:	
	csrr t0, time
	sw t0, 8(a1)

skip_draw_animation_tile:
	# t0 = tamanho, t1 = i
	lw t0, 0(a1)
	lw t1, 4(a1)

	# t2 = (i + 1) % tamanho
	addi t2, t1, 1
	rem t2, t2, t0
	sw t2, 4(a1)
	# save t2 on stack to calculate the return value later
	sw t2, 4(sp)

	# t1 = number of current tile
	slli t1, t1, 2
	add t1, a1, t1
	lw t1, 12(t1)

	# draw the tile
	mv a1, a2
	mv a2, a3
	mv a3, t1
	jal RENDER_TILE

	# if the animation endend return 1 else return 0
	lw t2, 4(sp)
	beq t2, zero, end_draw_animation_tile
	mv a0, zero

ret_draw_animation_tile:
	# restore stack and return
	lw ra, 0(sp)
	addi sp, sp, 8
	ret

end_draw_animation_tile:
	li a0, 1
	j ret_draw_animation_tile

##############################################################################################
#	Anima uma imagem com informações estão guardadas
# na memória começando no endereço em a1. Retorna 1 se a animação já foi desenhada por inteiro
# uma vez e 0 caso contrário
# Formato do a1 (WORD): tamanho, i, j, MIN_WORD, anim1..., animN
# cada animN representa um numero da tile a ser desenhada.
# "tamanho" indica quantos frames a animaçao possui.
# "i" eh um numero que satisfas 0 <= i < tamanho e indica a partir
# de qual frame a animacao comecara (geralmente i eh 0).
# j é um número que deve ser inicializado como -1 e conta quantas vezes a animação já
# rodou por completo.
# Exemplos de como usar a funcao: anim_test.s, cursor_test.s
##############################################################################################
# a0 = tamanho da imagem x
# a1 = informações da animação
# a2 = X
# a3 = Y
# a4 = tempo entre frames (ms)
# a5 = tamanho da imagem y
##############################################################################################
DRAW_ANIMATION:
	# save ra
	addi sp, sp, -8
	sw ra, 0(sp) 
	sw a1, 4(sp)

	# if time passed is less than a4, dont animate
	csrr t0, time
	lw t1, 12(a1)
	sub t0, t0, t1
	bgeu t0, a4, continue_draw_animation

	# t1 = (t1 + tamanho - 1) % tamanho
	lw t0, 0(a1)
	lw t1, 4(a1)
	add t1, t0, t1
	addi t1, t1, -1
	rem t1, t1, t0 
	sw t1, 4(a1)
	j skip_draw_animation

continue_draw_animation:	
	csrr t0, time
	sw t0, 12(a1)
	lw t0, 4(a1)
	beq t0, zero, increment_anim_counter_draw_animation

skip_draw_animation:
	# t0 = tamanho, t1 = i
	lw t0, 0(a1)
	lw t1, 4(a1)

	# t2 = (i + 1) % tamanho
	addi t2, t1, 1
	rem t2, t2, t0
	sw t2, 4(a1)

	# t1 = address of current image
	slli t1, t1, 2
	add t1, a1, t1
	lw t1, 16(t1)

	# draw the tile
	mv a1, a2
	mv a2, a3
	mv a4, a5
	li a5, 0
	mv a3, a0
	mv a0, t1
	jal RENDER

	# if animation was rendered at least one time then return 0
	lw a1, 4(sp)
	lw t0, 8(a1)
	bgt t0, zero, ret1_draw_animation
	li a0, 0

ret_draw_animation:
	# restore stack and return
	lw ra, 0(sp)
	addi sp, sp, 8
	ret

ret1_draw_animation:
	# return 1 and restore j to 0
	li a0, 1
	li t0, -1
	sw t0, 8(a1)
	j ret_draw_animation

increment_anim_counter_draw_animation:
	lw t0, 8(a1)
	addi t0, t0, 1
	sw t0, 8(a1)
	j skip_draw_animation


#########################################################
#	Desenha um inteiro na tela                            #
#############################################
#  PrintInt                                 #
#  a0    =    valor inteiro                 #
#  a1    =    x                             #
#  a2    =    y  			                #
#  a3    =    cor                           #
#############################################

PRINT_INT:	
	addi 	sp, sp, -4			# Aloca espaco
	sw 	ra, 0(sp)			    # salva ra
	la 	t0, TEMP_BUFFER			# carrega o Endereco do Buffer da String
		
	bge 	a0, zero, ehpos_print_int		# Se eh positvo
	li 	t1, '-'				# carrega o sinal -
	sb 	t1, 0(t0)			# coloca no buffer
	addi 	t0, t0, 1		# incrementa endereco do buffer
	sub 	a0, zero, a0	# torna o numero positivo
		
ehpos_print_int:  
	li 	t2, 10				# carrega numero 10
	li 	t1, 0				# carrega numero de digitos com 0
		
loop1_print_int:	
	div 	t4, a0, t2			# divide por 10 (quociente)
	rem 	t3, a0, t2			# resto
	addi  sp, sp, -4			        # aloca espaco na pilha
	sw 	t3, 0(sp)			# coloca resto na pilha
	mv 	a0, t4				# atualiza o numero com o quociente
	addi 	t1, t1, 1			# incrementa o contador de digitos
	bne 	a0, zero, loop1_print_int		# verifica se o numero eh zero
				
loop2_print_int:	
	lw 	t2, 0(sp)			    # le digito da pilha
	addi 	sp, sp, 4			# libera espaco
	addi 	t2, t2, 48			# converte o digito para ascii
	sb 	t2, 0(t0)			    # coloca caractere no buffer
	addi 	t0, t0, 1			# incrementa endereco do buffer
	addi 	t1, t1, -1			# decrementa contador de digitos
	bne 	t1, zero, loop2_print_int		# eh o ultimo?
	sb 	zero, 0(t0)			    # insere \NULL na string
	
	la 	a0, TEMP_BUFFER			# Endereco do buffer da srting
	jal 	PRINT_STRING		# chama o print string
			
	lw 	ra, 0(sp)			# recupera a
	addi 	sp, sp, 4			# libera espaco
fim_print_int:	
	ret					# retorna


#########################################################
#	Desenha uma string na tela                            #
#########################################################
#  a0    =  endereco da string                          #
#  a1    =  x                                           #
#  a2    =  y                                           #
#  a3    =  cor		    	                                #
#########################################################

PRINT_STRING:	
	addi	sp, sp, -12                        # aloca espaco
	sw	ra, 0(sp)                           # salva ra
  	sw	s0, 4(sp)                           # salva s0
	sw  s1, 8(sp)
	mv	s0, a0                              # s0 = endereco do caractere na string
	mv s1, a1                               # s1 = x para voltar caso \n

loop_PRINT_STRING:
	lb	a0, 0(s0)                           # le em a0 o caracter a ser impresso
	beq     a0, zero, fimloop_PRINT_STRING  # string ASCIIZ termina com NULL

	li t6, '\n'
	beq a0, t6, pula_linha_PRINT_STRING     # Checking if char is \n

	jal     PRINT_CHAR                      # imprime char
	addi    a1, a1, 8                       # incrementa a linha
	li 	t6, 313		
	blt	a1, t6, naopulalinha_PRINT_STRING   # se ainda tiver lugar na linha

pula_linha_PRINT_STRING:
	addi    a2, a2, 9                       # incrementa a coluna
	mv    	a1, s1                        # volta a linha para inicial

naopulalinha_PRINT_STRING:	
	addi    s0, s0, 1                       # proximo caractere
	j       loop_PRINT_STRING               # volta ao loop

fimloop_PRINT_STRING:	
	lw      ra, 0(sp)  	                    # recupera ra
	lw 	    s0, 4(sp)		                    # recupera s0 original
	lw 	    s1, 8(sp)		                    # recupera s0 original
	addi    sp, sp, 12		                    # libera espaco
fimprintString:	

  ret      	    			                    # retorna

#########################################################
#  PrintChar                                            #
#  a0 = char(ASCII)                                     #
#  a1 = x                                               #
#  a2 = y                                               #
#  a3 = cores (0x0000bbff) 	b = fundo, f = frente	      #
#########################################################
#	 s9 e s8 foram utilizados que nao ha registradores t suficiente


PRINT_CHAR:	
	addi sp, sp, -8
	sw s9, 0(sp)
	sw s8, 4(sp)

	li t4, 0xFF                                      # t4 temporario
	slli t4, t4, 8                                   # t4 = 0x0000FF00 (no RARS, nao podemos fazer diretamente "andi rd, rs1, 0xFF00")
	and	t5, a3, t4                                   # t5 obtem cor de fundo
	srli t5, t5, 8                                   # numero da cor de fundo
	andi t6, a3, 0xFF                                # t6 obtem cor de frente
	
	li 	s8, ' '
	blt a0, s8, naoimprimivel_PRINT_CHAR	           # ascii menor que 32 nao eh imprimivel
	li 	s8, '~'
	bgt	a0, s8, naoimprimivel_PRINT_CHAR	           # ascii Maior que 126  nao eh imprimivel
	j imprimivel_PRINT_CHAR
    
naoimprimivel_PRINT_CHAR: 
  	li      a0, 32		                               # Imprime espaco

imprimivel_PRINT_CHAR:	
	li	s8, SCREEN_SIZE		                            # Num colunas 320
	mul     t4, s8, a2			                          # multiplica a2x320  t4 = coordenada y

	add     t4, t4, a1                                # t4 = 320*y + x
	addi    t4, t4, 7                                 # t4 = 320*y + (x+7)
	
	GET_BUFFER_TO_DRAW(s8)
	
	add     t4, t4, s8                                # t4 = endereco de impressao do ultimo pixel da primeira linha do char
	addi    t2, a0, -32                               # indice do char na memoria
	slli    t2, t2, 3                                 # offset em bytes em relacao ao endereco inicial
	la      t3, LabelTabChar                          # endereco dos caracteres na memoria
	add     t2, t2, t3                                # endereco do caractere na memoria
	lw      t3, 0(t2)                                 # carrega a primeira word do char
	li 	    t0, 4				                              # i=4

forchar1I_PRINT_CHAR:	
  	beq     t0, zero, endforchar1I_PRINT_CHAR         # if(i == 0) end for i
  	addi    t1, zero, 8               	              # j = 8

forchar1J_PRINT_CHAR:	
	beq     t1, zero, endforchar1J_PRINT_CHAR         # if(j == 0) end for j
	andi    s9, t3, 0x001			                        # primeiro bit do caracter
	srli    t3, t3, 1             		                # retira o primeiro bit
	beq     s9, zero, printcharpixelbg1_PRINT_CHAR	  # pixel eh fundo?
	sb      t6, 0(t4)             		                # imprime pixel com cor de frente
	j       endcharpixel1_PRINT_CHAR

printcharpixelbg1_PRINT_CHAR:	
  	sb      t5, 0(t4)                                 # imprime pixel com cor de fundo

endcharpixel1_PRINT_CHAR: 
  	addi    t1, t1, -1                	              # j--
  	addi    t4, t4, -1                	              # t4 aponta um pixel para a esquerda
  	j       forchar1J_PRINT_CHAR		                  # vollta novo pixel

endforchar1J_PRINT_CHAR: 
  	addi    t0, t0, -1 		                            # i--
  	addi    t4, t4, 328           	                  # 2**12 + 8
  	j       forchar1I_PRINT_CHAR	                    # volta ao loop

endforchar1I_PRINT_CHAR:	
  	lw      t3, 4(t2)           	                    # carrega a segunda word do char
	li 	t0, 4			# i = 4

forchar2I_PRINT_CHAR:    
  	beq     t0, zero, endforchar2I_PRINT_CHAR         # if(i == 0) end for i
  	addi    t1, zero, 8                               # j = 8

forchar2J_PRINT_CHAR:	
  	beq	t1, zero, endforchar2J_PRINT_CHAR             # if(j == 0) end for j
  	andi    s9, t3, 0x001	    		                    # pixel a ser impresso
  	srli    t3, t3, 1                 	              # desloca para o proximo
  	beq     s9, zero, printcharpixelbg2_PRINT_CHAR    # pixel eh fundo?
  	sb      t6, 0(t4)			                            # imprime cor frente
  	j       endcharpixel2_PRINT_CHAR		              # volta ao loop

printcharpixelbg2_PRINT_CHAR:
  	sb      t5, 0(t4)		                              # imprime cor de fundo

endcharpixel2_PRINT_CHAR:
  	addi    t1, t1, -1		                            # j--
  	addi    t4, t4, -1                                # t4 aponta um pixel para a esquerda
  	j       forchar2J_PRINT_CHAR

endforchar2J_PRINT_CHAR:	
  	addi	t0, t0, -1 		                              # i--
  	addi    t4, t4, 328		                            #
  	j       forchar2I_PRINT_CHAR	                    # volta ao loop

endforchar2I_PRINT_CHAR:
  	lw s9, 0(sp)
  	lw s8, 4(sp)
  	addi sp, sp, 8                                  # reduzindo pilha
  	ret				                                        # retorna


#########################################################
#  Draw Line                  													#
#  Desenha uma linha do ponto (a0,a1) ao ponto (a2,a3)  #
# com a cor a4                                          #
#########################################################
# a0 = x inicial                                        #
# a1 = y inicial                                        #
# a2 = x final                                          #
# a3 = y final                                          #
# a4 = cor                                              #
#########################################################

DRAW_LINE: 	
	GET_BUFFER_TO_DRAW(a6)
	   	
	li 	  a7, 320
	sub 	t0, a3, a1
	bge 	t0, zero, pula_signedY_draw_line
	sub 	t0, zero, t0
pula_signedY_draw_line:	
	sub 	t1, a2, a0
	bge  	t1, zero, pula_signedX_draw_line
	sub  	t1, zero, t1	
pula_signedX_draw_line: 	
	bge t0, t1, pulacbres_draw_line
	ble a0, a2, pulac1bres_draw_line
 	mv 	a5, a0
 	mv 	a0, a2
 	mv 	a2, a5
 	mv	a5, a1
 	mv 	a1, a3
 	mv 	a3, a5
pulac1bres_draw_line:	
	j plotlowbres_draw_line

pulacbres_draw_line: 	
	ble  	a1, a3, pulac2bres_draw_line
	mv 	a5, a0
	mv 	a0, a2
	mv 	a2, a5
	mv 	a5, a1
	mv 	a1, a3
	mv 	a3, a5
pulac2bres_draw_line:	
	j plothighbres_draw_line

plotlowbres_draw_line:	
	sub 	t0, a2, a0		# dx=x1-x0
	sub 	t1, a3, a1		# dy y1-y0
	li  	t2, 1			# yi=1
	bge 	t1, zero, pula1bres_draw_line	# dy>=0 PULA
	li  	t2, -1			# yi=-1
	sub 	t1, zero, t1		# dy=-dy
pula1bres_draw_line:	
	slli 	t3, t1, 1		# 2*dy
	sub 	t3, t3, t0		# D=2*dy-dx
	mv 	t4, a1			# y=y0
	mv 	t5, a0			# x=x0
	
loopx1bres_draw_line:	
	mul 	t6, t4, a7		# y*320
	add 	t6, t6, t5		# y*320+x
	add 	t6, t6, a6		# 0xFF000000+y*320+x
	sb 	a4, 0(t6)		# plot com cor a4
	
	ble 	t3, zero, pula2bres_draw_line	# D<=0
	add 	t4, t4, t2		# y=y+yi
	slli 	t6, t0, 1		# 2*dx
	sub 	t3, t3, t6		# D=D-2dx
pula2bres_draw_line:
	slli 	t6, t1, 1		# 2*dy
	add 	t3, t3, t6		# D=D+2dx
	addi	t5, t5, 1
	bne 	t5, a2, loopx1bres_draw_line
	ret
		
plothighbres_draw_line: 	
	sub 	t0, a2, a0		# dx=x1-x0
	sub 	t1, a3, a1		# dy y1-y0
	li 	t2, 1			# xi=1
	bge 	t0, zero, pula3bres_draw_line	# dy>=0 PULA
	li 	t2, -1			# xi=-1
	sub 	t0, zero, t0		# dx=-dx
pula3bres_draw_line:	
	slli 	t3, t0, 1		# 2*dx
	sub 	t3, t3, t1		# D=2*dx-d1
	mv 	t4, a0			# x=x0
	mv 	t5, a1			# y=y0
	
loopx2bres_draw_line:	
	mul 	t6, t5, a7		# y*320
	add 	t6, t6, t4		# y*320+x
	add 	t6, t6, a6		# 0xFF000000+y*320+x
	sb 	a4, 0(t6)		# plot com cor a4
	
	ble 	t3, zero, pula4bres_draw_line	# D<=0
	add 	t4, t4, t2		# x=x+xi
	slli 	t6, t1, 1		# 2*dy
	sub 	t3, t3, t6		# D=D-2dy
pula4bres_draw_line: 	slli 	t6, t0, 1		# 2*dy
	add 	t3, t3, t6		# D=D+2dx
	addi 	t5, t5, 1
	bne 	t5, a3, loopx2bres_draw_line
	ret		
