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
