####################################################
# Player (Colocar o tamanho do objeto em bytes aqui)
####################################################
# 0: word sprite idle
# 0: word sprite pose
# 4: word sprite magia
# 8: byte vida total
# 9: byte vida atual
# 10: half_word_x magia
# 12: half_word_y magia
# 14: byte size_x magia
# 15: byte size_y magia
# 15: tipo de player
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
    li t1, 2
    blt t0, t1, idle_logic_combat

    # Passos de atack 2
    addi t1, t1, NUMBER_OF_ATACK_STEPS
    blt t0, t1, first_atack_logic_combat

    addi t1, t1, 5
    blt t0, t1, first_reduce_life_logic_combat
    ret
    li t1, 5
    beq t0, t1, first_reduce_life_logic_combat
    li t1, 6
    beq t0, t1, second_atack_logic_combat
    li t1, 7
    beq t0, t1, second_atack_logic_combat
    li t1, 8
    beq t0, t1, second_reduce_life_logic_combat
    li t1, 9
    beq t0, t1, second_reduce_life_logic_combat
    j end_logic_combat
    
idle_logic_combat:
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
    li t0, 1
    la t1, IN_COMBAT
    lb t1, 0(t1)
    beq t1, t0, aliado_ataca_logic_combat

    la t0, IN_COMBAT
    li t1, 0
    sb t1, 0(t0)
    j end_logic_combat

first_reduce_life_logic_combat:
    la t0, IN_COMBAT
    li t1, 0
    sb t1, 0(t0)
    j end_logic_combat

second_atack_logic_combat:
    la t0, IN_COMBAT
    li t1, 0
    sb t1, 0(t0)
    j end_logic_combat

second_reduce_life_logic_combat:
    la t0, IN_COMBAT
    li t1, 0
    sb t1, 0(t0)
    j end_logic_combat


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
    addi t0, t0, NUMBER_OF_STEPS_UNTIL_SECOND_ATACK # N
    j atack_projetil_alied_logic_combat

first_atack_projetil_alied_logic_combat:
    addi t0, t0, NUMBER_OF_STEPS_UNTIL_FIRST_ATACK # N
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
    # DEBUG
    la a0, combat_mago_idle
    la a1, combat_mago_pose
    la a2, magia_idle
    la a3, projetil
    ret

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
    # la a0, combat_idle_aliado_azul
    # la a1, combat_pose_aliado_azul
    ret
type_2_get_combat_idle_sprite_by_type:
    # la a0, combat_idle_aliado_vermelho
    # la a1, combat_pose_aliado_vermelho
    ret
type_3_get_combat_idle_sprite_by_type:
    # la, a0 combat_idle_aliado_marron
    # la, a1 combat_pose_aliado_marron
    ret
type_4_get_combat_idle_sprite_by_type:
    # la, a0 combat_idle_inimigo_azul
    # la, a1 combat_pose_inimigo_azul
    ret
type_5_get_combat_idle_sprite_by_type:
    # la, a0 combat_idle_inimigo_vermelho
    # la, a1 combat_pose_inimigo_vermelho
    ret
type_6_get_combat_idle_sprite_by_type:
    # la, a0 combat_idle_inimigo_marron
    # la, a1 combat_pose_inimigo_marron
    ret
