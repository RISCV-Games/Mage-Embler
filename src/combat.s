####################################################
# Player (Colocar o tamanho do objeto em bytes aqui)
####################################################
# 0: word sprite
# 4: word sprite magia
# 8: byte vida total
# 9: byte vida atual
# 10: half_word_x magia
# 12: half_word_y magia
# 14: size_x magia
# 15: size_y magia
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
# a2 = is_combat 0 - ninguem 1 player1 2 player2        # 
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
    li a3, PLAYER1_LIFE_COLOR
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
    li a3, PLAYER2_LIFE_COLOR
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
    # Drawing players
    lw a0, PLAYER_W_SPRITE(s0)
    li a1, PLAYER1_POSITION_X
    li a2, PLAYER1_POSITION_Y
    li a3, PLAYER_COMBAT_SPRITE_WIDTH
    li a4, PLAYER_COMBAT_SPRITE_HEIGHT
    li a5, 0
    jal RENDER

    # Drawing players
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
    # Carregando player 1
    mv t0, s0
    li t1, 0
    j draw_atack_draw_combat
player2_atack_draw_combat:
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
