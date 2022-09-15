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
# Formato do a1 (WORD): tamanho, 0, 0, anim1..., animN                  
# cada animN representa um numero da tile a ser desenhada.
# O primeiro zero representa o indice da tile atual sendo desenhada.
# O segundo zero representa o tempo em que a ultima tile foi
# desenhada, em millisegundos.
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
	#andi t1, t1, 0x111111
	#andi t0, t0, 0x111111
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
