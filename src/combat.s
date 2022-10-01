
#########################################################
#   Desenha o modo de combate na master
#########################################################
# a0 = endereco para o objeto do player1                # 
# a1 = endereco para o objeto do player2                # 
# a2 = is_combat 0 - ninguem 1 player1 2 player2        # 
# a3 = is_print_dmg
#########################################################

DRAW_COMBAT:
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)      # Player1
    sw s1, 8(sp)      # Player2
    sw s2, 12(sp)      # counter
    sw s3, 16(sp)    # another counter
    sw s4, 20(sp)    # another counter
    sw s5, 24(sp)    # another counter
    sw s6, 28(sp)    # another counter
    sw s7, 32(sp)    # another counter
    sw s8, 36(sp)    # another counter

    mv s0, a0
    mv s1, a1
    mv s5, a2
    mv s6, a3

    # #########################
    # LIFE 
    # #########################
    # draw left retangule
    li a0, vermelho
    li a1, 0
    li a2, 210
    li a3, 160
    li a4, 30
    jal DRAW_FILL_RETANGULE

    # draw left retangule border
    li a0, branco
    li a1, 0
    li a2, 209
    li a3, 160
    li a4, 30
    jal DRAW_RETANGULE

    # Draw player life number
    lb s2, PLAYER_B_VIDA_ATUAL(s0)     # current life
    mv a0 ,s2
    li a1, PLAYER1_LIFE_NUMBER_POSITION_X
    li a2, PLAYER1_LIFE_POSITION_Y
    li a3, branco
    li t0, vermelho
    slli t0,t0, 8
    add a3, a3, t0
    jal PRINT_INT

    # Draw player life
    lb s3, PLAYER_B_VIDA_TOTAL(s0)     # total life
    li s4, 0         # counter

player1_current_life_draw_combat:
    bge s4, s2, player1_missing_life_draw_combat
    la a0, vida_cheia
    # X
    li a1, PLAYER1_LIFE_POSITION_X
    slli t0, s4, 2
    add a1, a1, t0
    # Y
    li a2, PLAYER1_LIFE_POSITION_Y
    # Size x
    li a3, LARGURA_VIDA
    # Size y
    li a4, ALTURA_VIDA
    li a5, 0
    jal RENDER
    
    # Adding counter
    addi s4, s4, 1
    j player1_current_life_draw_combat

player1_missing_life_draw_combat:
    bge s4, s3, start_player2_life_draw_combat
    la a0, vida_vazia
    # X
    li a1, PLAYER1_LIFE_POSITION_X
    slli t0, s4, 2
    add a1, a1, t0
    # Y
    li a2, PLAYER1_LIFE_POSITION_Y
    # Size x
    li a3, LARGURA_VIDA
    # Size y
    li a4, ALTURA_VIDA
    li a5, 0
    jal RENDER
    
    # Adding counter
    addi s4, s4, 1
    j player1_missing_life_draw_combat

start_player2_life_draw_combat:
    # draw left retangule
    li a0, azul     # red
    li a1, 159
    li a2, 210
    li a3, 160
    li a4, 30
    jal DRAW_FILL_RETANGULE

    # draw left retangule border
    li a0, branco
    li a1, 159
    li a2, 209
    li a3, 160
    li a4, 30
    jal DRAW_RETANGULE

    # Draw player life number
    lb s2, PLAYER_B_VIDA_ATUAL(s1)     # current life
    mv a0 ,s2
    li a1, PLAYER2_LIFE_NUMBER_POSITION_X
    li a2, PLAYER2_LIFE_POSITION_Y
    li a3, branco
    li t0, azul
    slli t0,t0, 8
    add a3, a3, t0
    jal PRINT_INT

    # Draw player life
    lb s3, PLAYER_B_VIDA_TOTAL(s1)     # total life
    li s4, 0         # counter

player2_current_life_draw_combat:
    bge s4, s2, player2_missing_life_draw_combat
    la a0, vida_cheia
    # X
    li a1, PLAYER2_LIFE_POSITION_X
    slli t0, s4, 2
    add a1, a1, t0
    # Y
    li a2, PLAYER2_LIFE_POSITION_Y
    # Size x
    li a3, LARGURA_VIDA
    # Size y
    li a4, ALTURA_VIDA
    li a5, 0
    jal RENDER
    
    # Adding counter
    addi s4, s4, 1
    j player2_current_life_draw_combat

player2_missing_life_draw_combat:
    bge s4, s3, finish_life_draw_combat
    la a0, vida_vazia
    # X
    li a1, PLAYER2_LIFE_POSITION_X
    slli t0, s4, 2
    add a1, a1, t0
    # Y
    li a2, PLAYER2_LIFE_POSITION_Y
    # Size x
    li a3, LARGURA_VIDA
    # Size y
    li a4, ALTURA_VIDA
    li a5, 0
    jal RENDER
    
    # Adding counter
    addi s4, s4, 1
    j player2_missing_life_draw_combat

finish_life_draw_combat:
    # #########################
    # NAMES
    # #########################
    # Name player 1
    lw a0, PLAYER_W_NOME(s0)
    li a1, vermelho
    # vermelho fundo branco
    li t0, branco
    slli a1, a1, 8
    add a1, a1, t0
    
    li a2, TAMANHO_X_NOME_PLAYER
    li a3, TAMANHO_Y_NOME_PLAYER
    li a4, vermelho
    li a5, POS_X_NOME_PLAYER_1
    li a6, POS_Y_NOME_PLAYER_1
    jal DRAW_DIALOG

    # Name player 2
    lw a0, PLAYER_W_NOME(s1)
    li a1, azul
    # vermelho fundo branco
    li t0, branco
    slli a1, a1, 8
    add a1, a1, t0
    
    li a2, TAMANHO_X_NOME_PLAYER
    li a3, TAMANHO_Y_NOME_PLAYER
    li a4, azul
    li a5, POS_X_NOME_PLAYER_2
    li a6, POS_Y_NOME_PLAYER_2
    jal DRAW_DIALOG

    # #########################
    # ELEMENTS
    # #########################
    # Player 1
    lb a0, PLAYER_B_TIPO(s0)
    jal GET_COMBAT_SPRITES_BY_TYPE
    mv a0, a4 # Nome do elemento
    li a1, branco
    li t0, bege
    slli t0, t0, 8
    add a1, a1, t0
    li a2, TAMANHO_X_ELEMENTO_PLAYER
    li a3, TAMANHO_Y_ELEMENTO_PLAYER
    li a4, bege
    li a5, POS_X_ELEMENTO_PLAYER_1
    li a6, POS_Y_ELEMENTO_PLAYER_1
    jal DRAW_DIALOG

    # Player 2
    lb a0, PLAYER_B_TIPO(s1)
    jal GET_COMBAT_SPRITES_BY_TYPE
    mv a0, a4 # Nome do elemento
    li a1, branco
    li t0, bege
    slli t0, t0, 8
    add a1, a1, t0
    li a2, TAMANHO_X_ELEMENTO_PLAYER
    li a3, TAMANHO_Y_ELEMENTO_PLAYER
    li a4, bege
    li a5, POS_X_ELEMENTO_PLAYER_2
    li a6, POS_Y_ELEMENTO_PLAYER_2
    jal DRAW_DIALOG


    # #########################
    # COMBAT INFORMATION
    # #########################
    # Player 1
    # Print retangule
    li a0, vermelho
    li a1, POS_X_INFO_BOX_PLAYER_1
    li a2, POS_Y_INFO_BOX_PLAYER
    li a3, TAMANHO_X_INFO_BOX
    li a4, TAMANHO_Y_INFO_BOX
    jal DRAW_FILL_RETANGULE

    li a0, branco
    jal DRAW_RETANGULE

    # Print atributes
    # DMG
    la a0, DMG_STRING
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 4
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 2
    li a3, branco
    li t0, vermelho
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_STRING

    lb a0, PLAYER_B_DAMAGE(s0)
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 2
    li a3, branco
    li t0, vermelho
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT

    # HIT
    la a0, HIT_STRING
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 4
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, branco
    li t0, vermelho
    slli t0, t0, 8
    add a3, t0, a3
    jal PRINT_STRING

    lb a0, PLAYER_B_TIPO(s0)
    lb a1, PLAYER_B_TIPO(s1)
    jal CONFRONT_TYPE
    beq a0, zero, print1_normal_hit_draw_combat
    bgt a0, zero, print1_green_hit_draw_combat

    # print amarelo
    lb t0, PLAYER_B_HIT(s0)
    add a0, t0, a0
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, amarelo
    li t0, vermelho
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT
    j print_crit_draw_combat

print1_green_hit_draw_combat:
    lb t0, PLAYER_B_HIT(s0)
    add a0, t0, a0
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, verde
    li t0, vermelho
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT
    j print_crit_draw_combat

print1_normal_hit_draw_combat:
    lb a0, PLAYER_B_HIT(s0)
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, branco
    li t0, vermelho
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT

print_crit_draw_combat:
    # CRIT
    la a0, CRIT_STRING
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 4
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 20
    li a3, branco
    li t0, vermelho
    slli t0, t0, 8
    add a3, t0, a3
    jal PRINT_STRING

    lb a0, PLAYER_B_CRIT(s0)
    li a1, POS_X_INFO_BOX_PLAYER_1
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 20
    li a3, branco
    li t0, vermelho
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT

    # Player 2
    # Print retangule
    li a0, azul
    li a1, POS_X_INFO_BOX_PLAYER_2
    li a2, POS_Y_INFO_BOX_PLAYER
    li a3, TAMANHO_X_INFO_BOX
    li a4, TAMANHO_Y_INFO_BOX
    jal DRAW_FILL_RETANGULE

    li a0, branco
    jal DRAW_RETANGULE

    # Print atributes
    # DMG
    la a0, DMG_STRING
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 4
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 2
    li a3, branco
    li t0, azul
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_STRING

    lb a0, PLAYER_B_DAMAGE(s1)
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 2
    li a3, branco
    li t0, azul
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT

    # HIT
    la a0, HIT_STRING
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 4
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, branco
    li t0, azul
    slli t0, t0, 8
    add a3, t0, a3
    jal PRINT_STRING

    lb a0, PLAYER_B_TIPO(s1)
    lb a1, PLAYER_B_TIPO(s0)
    jal CONFRONT_TYPE
    beq a0, zero, print2_normal_hit_draw_combat
    bgt a0, zero, print2_green_hit_draw_combat

    # print amarelo
    lb t0, PLAYER_B_HIT(s1)
    add a0, t0, a0
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, amarelo
    li t0, azul
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT
    j print_crit2_draw_combat

print2_green_hit_draw_combat:
    lb t0, PLAYER_B_HIT(s1)
    add a0, t0, a0
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, verde
    li t0, azul
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT
    j print_crit2_draw_combat

print2_normal_hit_draw_combat:
    lb a0, PLAYER_B_HIT(s1)
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 11
    li a3, branco
    li t0, azul
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT

print_crit2_draw_combat:
    # CRIT
    la a0, CRIT_STRING
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 4
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 20
    li a3, branco
    li t0, azul
    slli t0, t0, 8
    add a3, t0, a3
    jal PRINT_STRING

    lb a0, PLAYER_B_CRIT(s1)
    li a1, POS_X_INFO_BOX_PLAYER_2
    addi a1, a1, 40
    li a2, POS_Y_INFO_BOX_PLAYER
    addi a2, a2, 20
    li a3, branco
    li t0, azul
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_INT

    # #########################
    # DMG
    # #########################
    beq s6, zero, draw_players_draw_combat
    la t0, PRINT_DMG
    lb t3, 0(t0)
    # If 0 miss
    # If positive hit
    # If negative critical hit

    beq t3, zero, miss_draw_combat
    bgt t3, zero, hit_draw_combat

    # crit
    la a0, CRIT_STRING
    li a1, DMG_STRING_POSITION_X
    li a2, DMG_STRING_POSITION_Y

    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0

    jal PRINT_STRING

    la t0, PRINT_DMG
    lb t3, 0(t0)

    sub a0, zero, t3 # Inverter
    li a1, DMG_STRING_POSITION_X
    li t0, CRIT_STRING_OFFSET
    add a1, a1, t0
    li a2, DMG_STRING_POSITION_Y

    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0

    jal PRINT_INT

    la a0, DMG_STRING
    li a1, DMG_STRING_POSITION_X
    li t0, CRIT_STRING_OFFSET
    addi t0, t0, DMG_STRING_OFFSET
    add a1, a1, t0
    li a2, DMG_STRING_POSITION_Y
    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_STRING
    
    j draw_players_draw_combat

hit_draw_combat:
    la a0, HIT_STRING
    li a1, DMG_STRING_POSITION_X
    li a2, DMG_STRING_POSITION_Y

    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0

    jal PRINT_STRING

    la t0, PRINT_DMG
    lb t3, 0(t0)

    mv a0, t3
    li a1, DMG_STRING_POSITION_X
    li t0, HIT_STRING_OFFSET
    add a1, a1, t0
    li a2, DMG_STRING_POSITION_Y

    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0

    jal PRINT_INT

    la a0, DMG_STRING
    li a1, DMG_STRING_POSITION_X
    li t0, DMG_STRING_OFFSET
    addi t0, t0, HIT_STRING_OFFSET
    add a1, a1, t0
    li a2, DMG_STRING_POSITION_Y
    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0
    jal PRINT_STRING
    
    j draw_players_draw_combat

miss_draw_combat:
    la a0, MISS_STRING
    li a1, DMG_STRING_POSITION_X
    li a2, DMG_STRING_POSITION_Y

    li a3, branco
    li t0, transp
    slli t0, t0, 8
    add a3, a3, t0

    jal PRINT_STRING

    # #########################
    # PLAYERS
    # #########################
draw_players_draw_combat:
    # Draw players
    lw a0, PLAYER_W_SPRITE(s0)
    li a1, PLAYER1_POSITION_X
    li a2, PLAYER1_POSITION_Y
    li a3, PLAYER_COMBAT_SPRITE_WIDTH
    li a4, PLAYER_COMBAT_SPRITE_HEIGHT
    li a5, 0
    jal RENDER

    # Player 2
    lw a0, PLAYER_W_SPRITE(s1)
    li a1, PLAYER2_POSITION_X
    li a2, PLAYER2_POSITION_Y
    li a3, PLAYER_COMBAT_SPRITE_WIDTH
    li a4, PLAYER_COMBAT_SPRITE_HEIGHT
    li a5, 1
    jal RENDER

    # Drawing powers
    beq s5, zero, end_draw_combat
    li t0, 2
    beq s5, t0, player2_atack_draw_combat

player1_atack_draw_combat:
    # Atack
    mv t0, s0
    li t1, 0
    j draw_atack_draw_combat

player2_atack_draw_combat:
    # Atack
    mv t0, s1
    li t1, 1

draw_atack_draw_combat:
    lw a0, PLAYER_W_SPRITE_MAGIA(t0)
    lh a1, PLAYER_H_MAGIA_X(t0)
    lh a2, PLAYER_H_MAGIA_Y(t0)
    lb a3, PLAYER_B_MAGIA_SIZE_X(t0)
    lb a4, PLAYER_B_MAGIA_SIZE_Y(t0)
    mv a5, t1
    jal RENDER
    j end_draw_combat


end_draw_combat:
    lw ra, 0(sp)
    lw s0, 4(sp)      # Player1
    lw s1, 8(sp)      # Player2
    lw s2, 12(sp)      # counter
    lw s3, 16(sp)    # another counter
    lw s4, 20(sp)    # another counter
    lw s5, 24(sp)    # another counter
    lw s6, 28(sp)    # another counter
    lw s7, 32(sp)    # another counter
    lw s8, 36(sp)    # another counter
    addi sp, sp, 40
    ret

#########################################################
#  Controla a logica do modo de combate                 #
#                                                       #
#########################################################
#   label - PLAYERS_IN_COMBAT
#########################################################
# Modifica as labels na memoria IN_COMBAT quando termina#
#########################################################
LOGIC_COMBAT:
    # Desenha os 2 players em idle
    # Faz o primeiro atack
    # Retira a vida
    # Faz o segundo atack
    # Retira a vida

    addi sp, sp, -4
    sw ra 0(sp)

    la t0, COMBAT_STEP
    lb t0, 0(t0)

    # Passos de idle 2
    li t1, NUMBER_OF_IDLE_STEPS
    blt t0, t1, idle_logic_combat

    addi t1, t1, NUMBER_OF_ATACK_STEPS
    blt t0, t1, first_atack_logic_combat

    addi t1, t1, NUMBER_OF_MAX_LIFE
    blt t0, t1 first_reduce_life_logic_combat

    addi t1, t1, NUMBER_OF_ATACK_STEPS
    blt t0, t1, second_atack_logic_combat

    addi t1, t1, NUMBER_OF_MAX_LIFE
    blt t0, t1, second_reduce_life_logic_combat

    # Termina o combat
    j finish_logic_combat

idle_logic_combat:
    # Vaiaveis de estado
    la t0, IS_PRINT_DMG
    sb zero, 0(t0)

    # Coloca a label dos dois playres como idle
    la t0, PLAYER_ATACKING
    sb zero, 0(t0)

    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)

    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    # Verifica se pode avancar a cena
	csrr t0, time
    la t1, COMBAT_LAST_TIME
    lw t2, 0(t1)
    li t3, WAIT_IDLE_TIME
    sub t2, t0, t2
    bgtu t3, t2, end_logic_combat
    sw t0, 0(t1)
    # Send to combat step to next
    la t0, COMBAT_STEP
    lb t1, 0(t0)
    addi t1, t1, 1
    sb t1, 0(t0)

    j end_logic_combat


first_atack_logic_combat:
    # Vaiaveis de estado
    la t0, IS_PRINT_DMG
    sb zero, 0(t0)

    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)
    beq t1, t0, aliado_ataca_logic_combat

    # Significa que o inimigo_ataca_primeiro
    j inimigo_ataca_logica_combat


second_atack_logic_combat:
    # Vaiaveis de estado
    la t0, IS_PRINT_DMG
    sb zero, 0(t0)

    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)
    beq t1, t0, inimigo_ataca_logica_combat

    # Significa que o inimigo_ataca_primeiro
    j aliado_ataca_logic_combat



aliado_ataca_logic_combat:
    # Coloca a label do primeiro player como pose e do segundo como idle
    la t0, PLAYER_ATACKING
    li t1, 1
    sb t1, 0(t0)

    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)

    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a1, PLAYER_W_SPRITE(t2)

    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    # Desenhando o poder baseado no passo se primeiro passo de atack magia em idle resto projetil que se movimenta
    la t0, COMBAT_STEP
    lb t1, 0(t0)

    li t2, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK
    beq t1, t2, magic_aliado_idle_logic_combat

    li t2, NUMBER_OF_STEPS_UNTIL_SECOND_ATACK
    beq t1, t2, magic_aliado_idle_logic_combat

    # Significa que precisamos calcular o x do projetil
    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a3, PLAYER_W_SPRITE_MAGIA(t2) # Projetil

    # Tamanhos
    li t0, MOVING_MAGIC_WIDTH
    sb t0, PLAYER_B_MAGIA_SIZE_X(t2)
    li t0, MOVING_MAGIC_HEIGHT
    sb t0, PLAYER_B_MAGIA_SIZE_Y(t2)

    # Distancia
    # Adicionando Y
    li t0, MOVING_MAGIC_POSITION_1_Y
    sh t0, PLAYER_H_MAGIA_Y(t2)
    # Adicionando X
    la t0, COMBAT_STEP
    lb t0, 0(t0)

    li t3, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK
    addi t3, t3, NUMBER_OF_ATACK_STEPS

    blt t0, t3, first_atack_projetil_alied_logic_combat

    li t4, NUMBER_OF_STEPS_UNTIL_SECOND_ATACK 
    sub t0, t0, t4# N

    j atack_projetil_alied_logic_combat

first_atack_projetil_alied_logic_combat:
    li t4, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK 
    sub t0, t0, t4 # N

atack_projetil_alied_logic_combat:
    li t3, DELTA_X_MAGIC
    mul t0, t0, t3 # N * DELTA_X
    addi t0, t0, MOVING_MAGIC_POSITION_1_X # Positon + n
    sh t0, PLAYER_H_MAGIA_X(t2)

    j end_moving_atack_logic_combat

magic_aliado_idle_logic_combat:
    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a2, PLAYER_W_SPRITE_MAGIA(t2)

    # Setting positions and sizes
    li t0, IDLE_MAGIC_POSITION_1_X
    sh t0, PLAYER_H_MAGIA_X(t2)

    li t0, IDLE_MAGIC_POSITION_1_Y
    sh t0, PLAYER_H_MAGIA_Y(t2)

    li t0, IDLE_MAGIC_WIDTH
    sb t0, PLAYER_B_MAGIA_SIZE_X(t2)
    li t0, IDLE_MAGIC_HEIGHT
    sb t0, PLAYER_B_MAGIA_SIZE_Y(t2)

    j end_idle_atack_logic_combat


inimigo_ataca_logica_combat:
    # Coloca a label do segundo player como pose e do primeiro como idle
    la t0, PLAYER_ATACKING
    li t1, 2
    sb t1, 0(t0)

    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)

    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a1, PLAYER_W_SPRITE(t2)

    # Desenhando o poder baseado no passo se primeiro passo de atack magia em idle resto projetil que se movimenta
    la t0, COMBAT_STEP
    lb t1, 0(t0)

    li t2, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK
    beq t1, t2, magic_inimigo_idle_logic_combat

    li t2, NUMBER_OF_STEPS_UNTIL_SECOND_ATACK
    beq t1, t2, magic_inimigo_idle_logic_combat

    # Significa que precisamos calcular o x do projetil
    la t1, PLAYERS_IN_COMBAT
    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a3, PLAYER_W_SPRITE_MAGIA(t2) # Projetil

    # Tamanhos
    li t0, MOVING_MAGIC_WIDTH
    sb t0, PLAYER_B_MAGIA_SIZE_X(t2)
    li t0, MOVING_MAGIC_HEIGHT
    sb t0, PLAYER_B_MAGIA_SIZE_Y(t2)

    # Distancia
    # Adicionando Y
    li t0, MOVING_MAGIC_POSITION_2_Y
    sh t0, PLAYER_H_MAGIA_Y(t2)
    # Adicionando X
    la t0, COMBAT_STEP
    lb t0, 0(t0)

    li t3, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK
    addi t3, t3, NUMBER_OF_ATACK_STEPS

    blt t0, t3, first_atack_projetil_enemy_logic_combat
    li t4,NUMBER_OF_STEPS_UNTIL_SECOND_ATACK 
    sub t0, t0, t4# N
    j atack_projetil_enemy_logic_combat

first_atack_projetil_enemy_logic_combat:
    li t4, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK 
    sub t0, t0, t4# N

atack_projetil_enemy_logic_combat:
    li t3, DELTA_X_MAGIC
    mul t0, t0, t3 # N * DELTA_X
    li t4, MOVING_MAGIC_POSITION_2_X 
    sub t0, t4, t0 # Positon + n
    sh t0, PLAYER_H_MAGIA_X(t2)

    j end_moving_atack_logic_combat

magic_inimigo_idle_logic_combat:
    la t1, PLAYERS_IN_COMBAT
    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a2, PLAYER_W_SPRITE_MAGIA(t2)

    # Setting positions and sizes
    li t0, IDLE_MAGIC_POSITION_2_X
    sh t0, PLAYER_H_MAGIA_X(t2)

    li t0, IDLE_MAGIC_POSITION_2_Y
    sh t0, PLAYER_H_MAGIA_Y(t2)

    li t0, IDLE_MAGIC_WIDTH
    sb t0, PLAYER_B_MAGIA_SIZE_X(t2)
    li t0, IDLE_MAGIC_HEIGHT
    sb t0, PLAYER_B_MAGIA_SIZE_Y(t2)

    j end_idle_atack_logic_combat


second_reduce_life_logic_combat:
    # Vaiaveis de estado
    la t2, IS_PRINT_DMG
    li t1, 1
    sb t1, 0(t2)


    # First interaction
    li t1, NUMBER_OF_STEPS_UNTIL_SECOND_LIFE
    beq t1, t0, calculate_dmg_second_logic_combat

    # Coloca a label dos dois playres como idle
    la t0, PLAYER_ATACKING
    sb zero, 0(t0)

    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)

    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    # Verifica se pode avancar a cena
	csrr t0, time
    la t1, COMBAT_LAST_TIME
    lw t2, 0(t1)
    li t3, WAIT_LIFE_SUB_TIME
    sub t2, t0, t2
    bgtu t3, t2, end_logic_combat
    sw t0, 0(t1)
    # Send to combat step to next
    la t0, COMBAT_STEP
    lb t1, 0(t0)
    addi t1, t1, 1
    sb t1, 0(t0)

    # Subtract dmg and player life by 1
    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)

    beq t1, t0, sub_player_life_player_logic
    j sub_enemy_life_player_logic

first_reduce_life_logic_combat:
    # Vaiaveis de estado
    la t2, IS_PRINT_DMG
    li t1, 1
    sb t1, 0(t2)

    # First interaction
    li t1, NUMBER_OF_STEPS_UNTIL_FIRST_LIFE
    beq t1, t0, calculate_dmg_first_logic_combat

    # Coloca a label dos dois playres como idle
    la t0, PLAYER_ATACKING
    sb zero, 0(t0)

    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)

    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    lw t2, 4(t1)
    lb a0, PLAYER_B_TIPO(t2)
    jal GET_COMBAT_SPRITES_BY_TYPE
    sw a0, PLAYER_W_SPRITE(t2)

    # Verifica se pode avancar a cena
	csrr t0, time
    la t1, COMBAT_LAST_TIME
    lw t2, 0(t1)
    li t3, WAIT_LIFE_SUB_TIME
    sub t2, t0, t2
    bgtu t3, t2, end_logic_combat
    sw t0, 0(t1)
    # Send to combat step to next
    la t0, COMBAT_STEP
    lb t1, 0(t0)
    addi t1, t1, 1
    sb t1, 0(t0)

    # Subtract dmg and player life by 1
    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)

    beq t1, t0, sub_enemy_life_player_logic
    j sub_player_life_player_logic
    

sub_player_life_player_logic:
    la t1, PLAYERS_IN_COMBAT
    lw t2, 0(t1)
    lb t0, PLAYER_B_VIDA_ATUAL(t2)
    beq t0, zero, finish_logic_combat

    la t1, COMBAT_DAMAGE
    lb t3, 0(t1)
    beq t3, zero, end_logic_combat

    addi t0, t0, -1
    addi t3, t3, -1
    sb t0, PLAYER_B_VIDA_ATUAL(t2)
    sb t3, 0(t1)
    j end_logic_combat

sub_enemy_life_player_logic:
    la t1, PLAYERS_IN_COMBAT
    lw t2, 4(t1)
    lb t0, PLAYER_B_VIDA_ATUAL(t2)
    beq t0, zero, finish_logic_combat
    la t1, COMBAT_DAMAGE
    lb t3, 0(t1)
    beq t3, zero, end_logic_combat

    addi t0, t0, -1
    addi t3, t3, -1
    sb t0, PLAYER_B_VIDA_ATUAL(t2)
    sb t3, 0(t1)
    j end_logic_combat

calculate_dmg_first_logic_combat:
    # HIT, CRIT, PLAYER DMG
    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)

    beq t1, t0, player_calculate_dmg_logic_combat
    j enemy_calculate_dmg_logic_combat 

calculate_dmg_second_logic_combat:
    # HIT, CRIT, PLAYER DMG
    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)

    beq t1, t0, enemy_calculate_dmg_logic_combat
    j player_calculate_dmg_logic_combat


player_calculate_dmg_logic_combat:
    # Check if players hits
    la t0, PLAYERS_IN_COMBAT
    lw t1, 0(t0)
    lb t2, PLAYER_B_HIT(t1)

    lb a0, PLAYER_B_TIPO(t1)
    lw t1, 4(t0)
    lb a1, PLAYER_B_TIPO(t1)
    jal CONFRONT_TYPE
    add t2, t2, a0 # Hit + type

    li a0, 100
    jal RAND_INT

    bgt a0, t2, player_miss_calculate_dmg_logic_combat
    # acertou
    # Checking if crit
    li a0, 10
    jal RAND_INT # number 0 to 9 if 0 or 1 crit
    li t0, 10
    bgt a0, t0, no_crit_player_dmg_logic_combat
    # Has crit
    lb t2, PLAYER_B_CRIT(t1) # 
    addi t2, t2, 1

    lb t3, PLAYER_B_DAMAGE(t1)
    mul t3, t3, t2

    la t2, COMBAT_DAMAGE
    sb t3, 0(t2)

    la t0, PRINT_DMG
    sub t3, zero, t3
    sb t3, 0(t0) # negativo representa critico

    j end_dmg_logic_combat

no_crit_player_dmg_logic_combat:
    lb t3, PLAYER_B_DAMAGE(t1)
    la t2, COMBAT_DAMAGE
    sb t3, 0(t2)

    la t0, PRINT_DMG
    sb t3, 0(t0)

    j end_dmg_logic_combat

player_miss_calculate_dmg_logic_combat:
    la t2, COMBAT_DAMAGE
    sb zero, 0(t2)

    la t0, PRINT_DMG
    sb zero, 0(t0)

    j end_dmg_logic_combat

enemy_calculate_dmg_logic_combat:
    # Check if players hits
    la t0, PLAYERS_IN_COMBAT
    lw t1, 4(t0)
    lb t2, PLAYER_B_HIT(t1)
    
    lb a0, PLAYER_B_TIPO(t1)
    lw t1, 0(t0)
    lb a1, PLAYER_B_TIPO(t1)

    jal CONFRONT_TYPE

    add t2, t2, a0 # Hit + type

    li a0, 100
    jal RAND_INT

    bgt a0, t2, enemy_miss_calculate_dmg_logic_combat
    # acertou
    # Checking if crit
    li a0, 10
    jal RAND_INT # number 0 to 9 if 0 or 1 crit
    li t0, 1
    bgt a0, t0, no_crit_enemy_dmg_logic_combat
    # Has crit
    lb t2, PLAYER_B_CRIT(t1) # 
    addi t2, t2, 1

    lb t3, PLAYER_B_DAMAGE(t1)
    mul t3, t3, t2

    la t2, COMBAT_DAMAGE
    sb t3, 0(t2)

    la t0, PRINT_DMG
    sub t3, zero, t3
    sb t3, 0(t0) # negativo representa critico

    j end_dmg_logic_combat

no_crit_enemy_dmg_logic_combat:
    lb t3, PLAYER_B_DAMAGE(t1)
    la t2, COMBAT_DAMAGE
    sb t3, 0(t2)

    la t0, PRINT_DMG
    sb t3, 0(t0)

    j end_dmg_logic_combat

enemy_miss_calculate_dmg_logic_combat:
    la t2, COMBAT_DAMAGE
    sb zero, 0(t2)

    la t0, PRINT_DMG
    sb zero, 0(t0)

    j end_dmg_logic_combat

end_dmg_logic_combat:
    # Send to combat step to next
    la t0, COMBAT_STEP
    lb t1, 0(t0)
    addi t1, t1, 1
    sb t1, 0(t0)

    j end_logic_combat
    

end_idle_atack_logic_combat:
    # Verifica se pode avancar a cena
	csrr t0, time
    la t1, COMBAT_LAST_TIME
    lw t2, 0(t1)
    li t3, WAIT_IDLE_ATACK_TIME
    sub t2, t0, t2
    bgtu t3, t2, end_logic_combat
    sw t0, 0(t1)
    # Send to combat step to next
    la t0, COMBAT_STEP
    lb t1, 0(t0)
    addi t1, t1, 1
    sb t1, 0(t0)

    j end_logic_combat


end_moving_atack_logic_combat:
    # Verifica se pode avancar a cena
	csrr t0, time
    la t1, COMBAT_LAST_TIME
    lw t2, 0(t1)
    li t3, WAIT_MOVING_ATACK_TIME
    sub t2, t0, t2
    bgtu t3, t2, end_logic_combat
    sw t0, 0(t1)
    # Send to combat step to next
    la t0, COMBAT_STEP
    lb t1, 0(t0)
    addi t1, t1, 1
    sb t1, 0(t0)

    j end_logic_combat

end_logic_combat:

    lw ra 0(sp)
    addi sp, sp, 4
    ret

finish_logic_combat:
    la t0, IN_COMBAT
    sb zero, 0(t0)
	la t0, COMBAT_STEP
	sb zero, 0(t0)
    j end_logic_combat
    

##################################################
# Recebe os tipo e retorna vantagem ou desvantagem      
##################################################
# a0 = tipo atacante
# a1 = tipo defesa
##################################################
# a0 = desvantagam para acertar
##################################################
CONFRONT_TYPE:
    li t0, AL_AZUL
    beq a0, t0, blue_confront_type
    li t0, IN_AZUL
    beq a0, t0, blue_confront_type
    li t0, AL_VER
    beq a0, t0, red_confront_type
    li t0, IN_VER
    beq a0, t0, red_confront_type
    li t0, AL_MAR
    beq a0, t0, marron_confront_type
    li t0, IN_MAR
    beq a0, t0, marron_confront_type

blue_confront_type:
    li t0, AL_AZUL
    beq a1, t0, eq_confront_type
    li t0, IN_AZUL
    beq a1, t0, eq_confront_type
    li t0, AL_VER
    beq a1, t0, ad_confront_type
    li t0, IN_VER
    beq a1, t0, ad_confront_type
    li t0, AL_MAR
    beq a1, t0, des_confront_type
    li t0, IN_MAR
    beq a1, t0, des_confront_type

red_confront_type:
    li t0, AL_AZUL
    beq a1, t0, des_confront_type
    li t0, IN_AZUL
    beq a1, t0, des_confront_type
    li t0, AL_VER
    beq a1, t0, eq_confront_type
    li t0, IN_VER
    beq a1, t0, eq_confront_type
    li t0, AL_MAR
    beq a1, t0, ad_confront_type
    li t0, IN_MAR
    beq a1, t0, ad_confront_type

marron_confront_type:
    li t0, AL_AZUL
    beq a1, t0, ad_confront_type
    li t0, IN_AZUL
    beq a1, t0, ad_confront_type
    li t0, AL_VER
    beq a1, t0, des_confront_type
    li t0, IN_VER
    beq a1, t0, des_confront_type
    li t0, AL_MAR
    beq a1, t0, eq_confront_type
    li t0, IN_MAR
    beq a1, t0, eq_confront_type

eq_confront_type:
    li a0, 0
    ret

ad_confront_type:
    li a0, 20
    ret

des_confront_type:
    li a0, -20
    ret



##################################################
# Recebe o tipo e retorna a sprite de idle      
##################################################
# a0 = tipo
##################################################
# a0 = idle
# a1 = pose
# a2 = magic idle
# a3 = magic moving
##################################################
GET_COMBAT_SPRITES_BY_TYPE:
    li t0, AL_AZUL
    beq a0, t0, type_1_get_combat_idle_sprite_by_type
    li t0, AL_VER
    beq a0, t0, type_2_get_combat_idle_sprite_by_type
    li t0, AL_MAR
    beq a0, t0, type_3_get_combat_idle_sprite_by_type
    li t0, IN_AZUL
    beq a0, t0, type_4_get_combat_idle_sprite_by_type
    li t0, IN_VER
    beq a0, t0, type_5_get_combat_idle_sprite_by_type
    li t0, IN_MAR
    beq a0, t0, type_6_get_combat_idle_sprite_by_type
    j type_1_get_combat_idle_sprite_by_type

type_1_get_combat_idle_sprite_by_type:
    la a0, combat_idle_aliado_azul
    la a1, combat_pose_aliado_azul
    la a2, magia_idle
    la a3, projetil
    la a4, GELO
    ret
type_2_get_combat_idle_sprite_by_type:
    la a0, combat_idle_aliado_vermelho
    la a1, combat_pose_aliado_vermelho
    la a2, magia_idle
    la a3, projetil
    la a4, FOGO
    ret
type_3_get_combat_idle_sprite_by_type:
    la, a0 combat_idle_aliado_marron
    la, a1 combat_pose_aliado_marron
    la a2, magia_idle
    la a3, projetil
    la a4, TERRA
    ret
type_4_get_combat_idle_sprite_by_type:
    la, a0 combat_idle_inimigo_azul
    la, a1 combat_pose_inimigo_azul
    la a2, magia_idle
    la a3, projetil
    la a4, GELO
    ret
type_5_get_combat_idle_sprite_by_type:
    la, a0 combat_idle_inimigo_vermelho
    la, a1 combat_pose_inimigo_vermelho
    la a2, magia_idle
    la a3, projetil
    la a4, FOGO
    ret
type_6_get_combat_idle_sprite_by_type:
    la, a0 combat_idle_inimigo_marron
    la, a1 combat_pose_inimigo_marron
    la a2, magia_idle
    la a3, projetil
    la a4, TERRA
    ret
