####################################################
# Player (4 bytes)
####################################################
# Classe representando os jogadores, tanto aliados
# quanto inimigos.
###################################################
# 0: byte posX
# 1: byte posY
# 2: byte tileNum
# 3: byte isAlly
####################################################

####################################################
# Inicializa os players a partir do mapa.
####################################################
# a0 = map
# a1 = correspondence array
####################################################
INIT_PLAYERS:
	# t0 = i = 0
	li t0, 0

loop_init_players:
	li t1, TILES_PER_MAP
	bge t0, t1, ret_init_players

	add t1, t0, a0
	lb t1, 0(t1)
	andi t1, t1, 0x7
	li t2, BLOCK_ALLY
	beq t1, t2, ally_init_players
	li t2, BLOCK_ENEMY
	beq t1, t2, enemy_init_players

continue_loop_init_players:
	addi t0, t0, 1
	j loop_init_players

ally_init_players:
	li a2, 1
	j init_init_players
enemy_init_players:
	li a2, 0
	j init_init_players

init_init_players:
	# t3 = player position in memory
	la t1, N_PLAYERS
	lb t1, 0(t1)
	li t2, PLAYER_BYTE_SIZE
	mul t2, t2, t1
	la t4, PLAYERS
	add t3, t4, t2

	# N_PLAYERS++
	la t4, N_PLAYERS
	addi t1, t1, 1
	sb t1, 0(t4)

	# (t1, t2) = (posX, posY)
	li t2, MAP_WIDTH
	rem t1, t0, t2
	div t2, t0, t2

	# t4 = tileNum
	add t4, a0, t0
	lb t4, 0(t4)
	srli t4, t4, 3
	add t4, t4, a1
	lb t4, 0(t4)

	# initialize values
	sb t1, 0(t3)
	sb t2, 1(t3)
	sb t4, 2(t3)
	sb a2, 3(t3)
	
	j continue_loop_init_players

ret_init_players:
	ret