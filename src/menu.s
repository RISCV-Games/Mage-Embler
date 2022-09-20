; #########################################################
; #	Cria um menu a partir de opcoes dadas por strings     #
; retornando a posicao selecionada 0 index                # 
; #########################################################
; # a0 = quantidade de opcoes                             #
; # a1 = endereco das strings                             #
; # a2 = cor das strings                                  #
; # a3 = tamanho x do menu                                #
; # a4 = tamanho y do menu                                #
; # a5 = cor do menu                                      #
; #########################################################
DRAW_MENU:
  addi sp, sp, -28
  sw ra, 0(sp)
  sw s0, 4(sp) # a0
  sw s1, 8(sp) # a1
  sw s2, 12(sp) # a2 
  sw s3, 16(sp) # a3
  sw s4, 20(sp) # starting y 
  sw s5, 24(sp) # counter

  mv s0, a0
  mv s1, a1
  mv s2, a2
  mv s3, a3

  # Calculating starting y
  slli s4, a0, 3
  sub s4, a4, s4
  srai s4, s4, 1

  li s5, 0 # counter


drawstring_DRAW_MENU:
  bge t5, s0, end_DRAW_MENU
  
  # Getting string
  slli t1, s5, 2
  add t1, s1, t1 # t1 = s1 + 4 * t0
  lw a0, 0(t1)

  # Caluculating string position on menu
  jal GET_STRING_SIZE # a1 = string size

  sub a1, s3, a1
  srai a1, a1, 2 # a1 = (x - string_size) / 2

  mv a2, s4
  mv a3, s2
  jal PRINT_STRING

  addi s5, s5, 1
  addi s4, s4, 8

  j drawstring_DRAW_MENU
  
end_DRAW_MENU:
  lw ra, 0(sp)
  lw s0, 4(sp) # a0
  lw s1, 8(sp) # a1
  lw s2, 12(sp) # a2 
  lw s3, 16(sp) # a3
  lw s4, 20(sp) # starting y 
  lw s5, 24(sp) # counter

  addi sp, sp, 28

  ret


; ###########################################################
; #	Retorna o tamanho da string em a1, quebrando a convensao#
; retornando a posicao selecionada 0 index                  # 
; ########################################################  #
; # a0 = endereco da string                               #
; #########################################################
GET_STRING_SIZE:
  li t0, 0     # counter
  mv t1, a0

loop_GET_STRING_SIZE:
  lb t2, 0(t1) # char
  beq t2, zero, end_GET_STRING_SIZE
  addi t0, t0, 1
  addi t1, t1, 1
  j loop_GET_STRING_SIZE

end_GET_STRING_SIZE:
  mv a1, t0
  ret



  

