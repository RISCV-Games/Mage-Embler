.macro GET_BUFFER_TO_DRAW(%reg)
  addi sp, sp, -4
  sw s11, 0(sp)

  la %reg, FRAME_TO_DRAW
  lb %reg, 0(t0)
  slli %reg, %reg, 20
  li s11, BUFFER_ADRESS
  add %reg, s11, %reg

  lw s11, 0(sp)
  addi sp, sp, 4
.end_macro
