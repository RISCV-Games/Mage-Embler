####################################################
# Player (Colocar o tamanho do objeto em bytes aqui)
####################################################
# 0: byte dmg
# 1: byte vida total
# 2: byte vida atual
# 3: byte critico
# .
# .
# offset: (byte, half word, word) nomeDaVariavel
####################################################

#########################################################
#	Desenha o modo de combate                           #
#   #
#########################################################
# a0 = endereco para o objeto do player1                # 
# a1 = endereco para o objeto do player2                # 
# a2 = endereco para imagem da animacao                 #
#########################################################

DRAW_COMBAT:
    addi sp, sp, -20
    sw ra, 0(sp)
    sw s0, 4(sp)      # Player1
    sw s1, 8(sp)      # Player2
    sw s2, 12(sp)      # counter
    sw s3, 16(sp)    # another counter

    mv s0, a0
    mv s1, a1

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
    lb s2, 2(s0)     # current life
    mv a0 ,s2
    li a1, PLAYER1_LIFE_NUMBER_POSITION_X
    li a2, PLAYER1_LIFE_POSITION_Y
    li a3, PLAYER1_LIFE_COLOR
    jal PRINT_INT

    # Draw player life
    lb s3, 1(s0)     # total life
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
    lb s2, 2(s1)     # current life
    mv a0 ,s2
    li a1, PLAYER2_LIFE_NUMBER_POSITION_X
    li a2, PLAYER2_LIFE_POSITION_Y
    li a3, PLAYER2_LIFE_COLOR
    jal PRINT_INT

    # Draw player life
    lb s3, 1(s1)     # total life
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
    lw ra, 0(sp)
    lw s0, 4(sp)      # Player1
    lw s1, 8(sp)      # Player2
    lw s2, 12(sp)      # counter
    lw s3, 16(sp)    # another counter
    addi sp, sp, 20
    ret
