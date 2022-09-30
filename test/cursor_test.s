.include "../src/data.s"
.include "../src/consts.s"
.include "../src/macros.s"
.text
jal INIT_VIDEO

GAME:
	li a0, 0x09090909
	JAL DRAW_BACKGROUND
	jal DRAW_CURSOR
	jal INPUT
  jal SWAP_FRAMES
	
  j GAME

INPUT:
	li t1, KBD_CONTROL		      # carrega o endere�o de controle do KDMMIO
 	lw t0, 0(t1)			          # Le bit de Controle Teclado
	andi t0, t0, 0x0001		      # mascara o bit menos significativo
	beq t0, zero, fim_input	    # não tem tecla pressionada ent�o volta ao loop
	lw t2, 4(t1)								# le o valor da tecla

	li t0, 'w'
	bne t2, t0, not_w_input
	li t3, 0
	li t4, -1
	j op_input

not_w_input:
	li t0, 'a'
	bne t2, t0, not_a_input
	li t3, -1
	li t4, 0
	j op_input

not_a_input:
	li t0, 's'
	bne t2, t0, not_s_input
	li t3, 0
	li t4, 1
	j op_input

not_s_input:
	li t0, 'd'
	bne t2, t0, fim_input
	li t3, 1
	li t4, 0
	j op_input

op_input:
	la t0, CURSOR_POS
	lbu t1, 0(t0)
	lbu t2, 1(t0)
	add t1, t1, t3
	add t2, t2, t4
	sb t1, 0(t0)
	sb t2, 1(t0)

fim_input:
	ret


.include "../src/video.s"
.include "../src/cursor.s"
.include "../src/input.s"