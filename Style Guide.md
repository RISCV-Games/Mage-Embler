# Style guide

- Nome de procedimentos em maiusculo
- Nome de labels dentro de procedimento em minusculo e no formato: loop_<procedimento>
- Colocar label de data dentro do arquivo data.s
- Colocar contantes `.eqv` dentro do arquivo constantes.s
- Colocar um cabeçário em cima do procedimento
- Manter o jogo rodando no RARS

EX:  
```asm
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
```

# Nome de branch
Criar branch separada para cada tópico, manter a branch main sempre rodando no RARS  
Ex:  
feat/<nome-da-feature>
fix/<nome-do-fix>

# Paleta de cores
NomeCor    - Valor Normal  - Valor no RISC-V
Vermelho   - FF0000        - 
Branco     - FFF7CE        - 183
Azul       - 
Marron     - 5C4033
BEGE       - b5ad7b        - 100
AttackRed  - 641e23        - 75
