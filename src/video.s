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
#	Desenha um retangulo com a cor desejada             #
#########################################################
# a0 = cor                                              #
# a1 = x                                                #
# a2 = y                                                #
# a3 = size_x                                           #
# a4 = size_y                                           #
#########################################################
DRAW_RETANGULE:
	GET_BUFFER_TO_DRAW(t0)

	# calculating starting position
	li t1, 320
	mul t1, a2, t1
	add t0, t0, t1
	add t0, t0, a1

	li t1, 0
	li t2, 0

draw_line_draw_rentangule:
	sb a0, 0(t0)
	addi t0, t0, 1
	addi t1, t1, 1
	blt t1, a3, draw_line_draw_rentangule 

	li t1, 0
	addi t2, t2, 1

	addi t0, t0, 320
	sub t0, t0, a3

	bgt a4, t2, draw_line_draw_rentangule
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
		
	ret				# retorna


######################################################################
#	Anima uma imagem com informações estão guardadas                   
# na memória começando no endereço em a1.                            
# Formato do a1 (WORD): tamanho, i, MIN_WORD, anim1..., animN                  
# cada animN representa um numero da tile a ser desenhada.
# "tamanho" indica quantos frames a animaçao possui.
# "i" eh um numero que satisfas 0 <= i < tamanho e indica a partir
# de qual frame a animacao comecara (geralmente i eh 0).
# Exemplos de como usar a funcao: anim_test.s, cursor_test.s
######################################################################
# a0 = endereço da imagem com tiles
# a1 = informações da animação
# a2 = X
# a3 = Y
# a4 = tempo entre frames (ms)
######################################################################
DRAW_ANIMATION_TILE:
	# save ra
	addi sp, sp, -4
	sw ra, 0(sp)

	# if time passed is less than a4, dont animate
	csrr t0, time
	lw t1, 8(a1)
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
	sw t0, 8(a1)

skip_draw_animation:
	# t0 = tamanho, t1 = i
	lw t0, 0(a1)
	lw t1, 4(a1)

	# t2 = (i + 1) % tamanho
	addi t2, t1, 1
	rem t2, t2, t0
	sw t2, 4(a1)

	# t1 = number of current tile
	slli t1, t1, 2
	add t1, a1, t1
	lw t1, 12(t1)

	# draw the tile
	mv a1, a2
	mv a2, a3
	mv a3, t1
	jal RENDER_TILE

ret_draw_animation:
	# restore stack and return
	lw ra, 0(sp)
	addi sp, sp, 4
	ret


#########################################################
#	Desenha uma string na tela                            #
#########################################################
#  a0    =  endereco da string                          #
#  a1    =  x                                           #
#  a2    =  y                                           #
#  a3    =  cor		    	                                #
#########################################################

PRINT_STRING:	
  addi	sp, sp, -8                        # aloca espaco
  sw	ra, 0(sp)                           # salva ra
  sw	s0, 4(sp)                           # salva s0
  mv	s0, a0                              # s0 = endereco do caractere na string

loop_PRINT_STRING:
  lb	a0, 0(s0)                           # le em a0 o caracter a ser impresso
  beq     a0, zero, fimloop_PRINT_STRING  # string ASCIIZ termina com NULL
  jal     PRINT_CHAR                      # imprime char
	addi    a1, a1, 8                       # incrementa a coluna
	li 	t6, 313		
	blt	a1, t6, naopulalinha_PRINT_STRING   # se ainda tiver lugar na linha
  addi    a2, a2, 8                       # incrementa a linha
  mv    	a1, zero                        # volta a coluna zero

naopulalinha_PRINT_STRING:	
  addi    s0, s0, 1                       # proximo caractere
  j       loop_PRINT_STRING               # volta ao loop

fimloop_PRINT_STRING:	
  lw      ra, 0(sp)  	                    # recupera ra
	lw 	    s0, 4(sp)		                    # recupera s0 original
  addi    sp, sp, 8		                    # libera espaco
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
