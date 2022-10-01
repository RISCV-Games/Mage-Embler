########## Put the buffer to draw on register #########
.macro GET_BUFFER_TO_DRAW(%reg)
	addi sp, sp, -4
	sw s11, 0(sp)

	la %reg, FRAME_TO_DRAW
	lb %reg, 0(%reg)
	slli %reg, %reg, 20
	li s11, BUFFER_ADRESS
	add %reg, s11, %reg

	lw s11, 0(sp)
	addi sp, sp, 4
.end_macro

######### Verifica se eh a DE1-SoC ###############
.macro DE1(%reg,%salto)
	li %reg, 0x10008000	# carrega tp
	bne gp, %reg, %salto	# Na DE1 gp = 0 ! Não tem segmento .extern
.end_macro

.eqv PLAYER_W_SPRITE 0
.eqv PLAYER_W_SPRITE_MAGIA 4
.eqv PLAYER_W_NOME 8
.eqv PLAYER_H_MAGIA_X 12
.eqv PLAYER_H_MAGIA_Y 14
.eqv PLAYER_B_VIDA_TOTAL 16
.eqv PLAYER_B_VIDA_ATUAL 17
.eqv PLAYER_B_MAGIA_SIZE_X 18
.eqv PLAYER_B_MAGIA_SIZE_Y 19
.eqv PLAYER_B_TIPO 20
.eqv PLAYER_B_DAMAGE 21
.eqv PLAYER_B_HIT 22
.eqv PLAYER_B_CRIT 23
.eqv PLAYER_B_POS_X 24
.eqv PLAYER_B_POS_Y 25

######### Initialize a Player and increment N_PLAYERS (altera registradores t) ###############
.macro INIT_PLAYER(%pos_x, %pos_y, %tipo)
	# t0 = PLAYERS[N_PLAYERS]
	la t0, PLAYERS
	la t1, N_PLAYERS
	lb t1, 0(t1)
	li t2, PLAYER_BYTE_SIZE
	mul t1, t1, t2
	add t0, t0, t1

	# initialize
	li t1, %pos_x
	sb t1, PLAYER_B_POS_X(t0)
	li t1, %pos_y
	sb t1, PLAYER_B_POS_Y(t0)
	li t1, %tipo
	sb t1, PLAYER_B_TIPO(t0)

	# increment N_PLAYERS
	la t0, N_PLAYERS
	lb t1, 0(t0)
	addi t1, t1, 1
	sb t1, 0(t0)
.end_macro