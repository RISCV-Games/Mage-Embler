#################################################
#	Organiza os frames do buffer de video         #
#################################################
INIT_VIDEO:
  # Setting current view frame
  li t0, 0xFF200604 # current frame address
  # Force start on frame 0
  sw zero,0(s3)

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
  li t0, 0xFF200604 # current frame number (0 or 1)
  lw t1, 0(t0)
	xori t2,t1,1
	sw t2,0(t0)

  # Swap current draw frame
  la t0, FRAME_TO_DRAW
  sb t1, 0(t0)
	
	ret

#########################################################
#	Retorna o buffer para se desenhar                     #
#########################################################
GET_BUFFER_TO_DRAW:
  la a0, FRAME_TO_DRAW
  lb a0, 0(t0)
  slli a0, a0, 20
  li t0, BUFFER_ADRESS
  add a0, t0, a0

  ret

#########################################################
#	Desenha a tela inteira com a cor desejada             #
#########################################################
# a0 = cor                                              #
#########################################################
DRAW_BACKGROUND:
  addi sp, sp, -8
  sw ra, 0(sp) 
  sw a0, 4(sp)

  jal GET_BUFFER_TO_DRAW
  mv t0, a0

  li t1, NUMBER_OF_PIXELS
  add t1, t0, t1

  lw a0, 4(sp)
loop_draw_back_ground:
	bge t0, t1, end_draw_back_ground
	sw a0, 0(t0)
	addi t0, t0, 4
	j loop_draw_back_ground

end_draw_back_ground:
  lw ra, 0(sp)
  addi sp, sp, 8
	ret
