.data
vector_x:
    .float  0,  0,  0,  0
vector_b:
    .float  6,   25,   -11,   15
matrix:
    .float  10,  -1,  2,  0,
            -1,  11,  -1,  3,
            2, -1, 10, -1,
           0, 3, -1, 8
omega:
    .float  0.8
one_minus_omega:
    .float  0.0
zero_f:
    .float  0.0
str_row:
    .string "Row "
str_col:
    .string ", solving for x"
str_result:
    .string ": "
str_iteration:
    .string "=== Iteration "
str_iteration_end:
    .string " ==="
str_current_x:
    .string "Current x values: "
str_space:
    .string " "
str_final:
    .string "\n=== FINAL RESULT after 10 iterations ==="
newline:
    .string "\n"

.text
.globl main
main:
    la    s0, matrix
    la    s1, vector_x
    la    s5, vector_b
    li    s3, 4
    li    s7, 0
    li    s8, 10

    la    t0, omega
    flw   f1, 0(t0)
    li    t1, 1
    fcvt.s.w f2, t1
    fsub.s f3, f2, f1
    la    t0, one_minus_omega
    fsw   f3, 0(t0)

iteration_loop:
    bge   s7, s8, final_result
    
    la    a0, str_iteration
    li    a7, 4
    ecall
    addi  t0, s7, 1
    mv    a0, t0
    li    a7, 1
    ecall
    la    a0, str_iteration_end
    li    a7, 4
    ecall
    la    a0, newline
    li    a7, 4
    ecall
    
    la    a0, str_current_x
    li    a7, 4
    ecall
    li    t0, 0
print_current_loop:
    bge   t0, s3, print_current_done
    mv    a0, s1
    mv    a1, t0
    jal   get_vec_elem
    fmv.s fa0, f0
    li    a7, 2
    ecall
    la    a0, str_space
    li    a7, 4
    ecall
    addi  t0, t0, 1
    j     print_current_loop
print_current_done:
    la    a0, newline
    li    a7, 4
    ecall
    
    li    s6, 0

row_loop:
    bge   s6, s3, iteration_complete
    
    la    a0, str_row
    li    a7, 4
    ecall
    mv    a0, s6
    li    a7, 1
    ecall
    la    a0, str_col
    li    a7, 4
    ecall
    mv    a0, s6
    li    a7, 1
    ecall
    la    a0, str_result
    li    a7, 4
    ecall

    mv    a0, s1
    mv    a1, s6
    jal   get_vec_elem
    fmv.s f9, f0

    mv    a0, s0
    mv    a1, s1
    mv    a2, s6
    mv    a3, s6
    mv    a4, s3
    jal   mul_row_vec_skip
    fmv.s f6, f0

    mv    a0, s5
    mv    a1, s6
    jal   get_vec_elem
    fmv.s f7, f0

    mv    a0, s0
    mv    a1, s6
    mv    a2, s6
    mv    a3, s3
    jal   get_element
    fmv.s f8, f0

    fsub.s f0, f7, f6
    fdiv.s f0, f0, f8

    la    t0, omega
    flw   f10, 0(t0)
    la    t0, one_minus_omega
    flw   f11, 0(t0)

    fmul.s f12, f11, f9
    fmul.s f13, f10, f0
    fadd.s f0, f12, f13

    mv    a0, s1
    mv    a1, s6
    fmv.s fa0, f0
    jal   set_vec_elem

    fmv.s fa0, f0
    li    a7, 2
    ecall

    la    a0, newline
    li    a7, 4
    ecall

    addi  s6, s6, 1
    j     row_loop

iteration_complete:
    la    a0, newline
    li    a7, 4
    ecall

    addi  s7, s7, 1
    j     iteration_loop

final_result:
    la    a0, str_final
    li    a7, 4
    ecall
    la    a0, newline
    li    a7, 4
    ecall
    
    li    t0, 0
print_final_loop:
    bge   t0, s3, print_final_done
    mv    a0, s1
    mv    a1, t0
    jal   get_vec_elem
    fmv.s fa0, f0
    li    a7, 2
    ecall
    la    a0, str_space
    li    a7, 4
    ecall
    addi  t0, t0, 1
    j     print_final_loop
print_final_done:
    la    a0, newline
    li    a7, 4
    ecall

done:
    li    a7, 10
    ecall

set_vec_elem:
    addi  sp, sp, -4
    sw    t0, 0(sp)
    
    slli  t0, a1, 2
    add   t0, a0, t0
    fsw   fa0, 0(t0)
    
    lw    t0, 0(sp)
    addi  sp, sp, 4
    jr    ra

mul_row_vec_skip:
    addi  sp, sp, -48
    sw    ra,    44(sp)
    sw    s0,    40(sp)
    sw    s1,    36(sp)
    sw    s2,    32(sp)
    sw    s3,    28(sp)
    sw    s4,    24(sp)
    sw    t0,    20(sp)
    sw    t1,    16(sp)
    
    mv    s0, a0
    mv    s1, a1
    mv    s2, a2
    mv    s3, a3
    mv    s4, a4
    
    la    t1, zero_f
    flw   f2, 0(t1)
    li    t0, 0

loop:
    bge   t0, s4, finish
    beq   t0, s3, skip_increment
    
    addi  sp, sp, -4
    sw    t0, 0(sp)
    mv    a0, s0
    mv    a1, s2
    mv    a2, t0
    mv    a3, s4
    jal   get_element
    fmv.s f3, f0
    lw    t0, 0(sp)
    addi  sp, sp, 4
    
    addi  sp, sp, -4
    sw    t0, 0(sp)
    mv    a0, s1
    mv    a1, t0
    jal   get_vec_elem
    fmv.s f4, f0
    lw    t0, 0(sp)
    addi  sp, sp, 4
    
    fmul.s f5, f3, f4
    fadd.s f2, f2, f5

skip_increment:
    addi  t0, t0, 1
    j     loop
    
finish:
    fmv.s f0, f2
    lw    ra,    44(sp)
    lw    s0,    40(sp)
    lw    s1,    36(sp)
    lw    s2,    32(sp)
    lw    s3,    28(sp)
    lw    s4,    24(sp)
    lw    t0,    20(sp)
    lw    t1,    16(sp)
    addi  sp, sp, 48
    jr    ra

get_vec_elem:
    addi  sp, sp, -4
    sw    t0, 0(sp)
    
    slli  t0, a1, 2
    add   t0, a0, t0
    flw   f0, 0(t0)
    
    lw    t0, 0(sp)
    addi  sp, sp, 4
    jr    ra

get_element:
    addi  sp, sp, -4
    sw    t0, 0(sp)
    
    mul   t0, a1, a3
    add   t0, t0, a2
    slli  t0, t0, 2
    add   t0, a0, t0
    flw   f0, 0(t0)
    
    lw    t0, 0(sp)
    addi  sp, sp, 4
    jr    ra
