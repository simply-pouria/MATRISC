.data
vector_x:
    .float  0,  0,  0,  0
vector_x_new:
    .float  0.0,  0.0,  0.0,  0.0     # storage for new x values
vector_b:
    .float  6,   25,   -11,   15
matrix:
    .float  10,  -1,  2,  0,    # row 0
            -1,  11,  -1,  3,    # row 1
            2, -1, 10, -1,    # row 2
           0, 3, -1, 8     # row 3
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
str_old_x:
    .string "Current x values: "
str_new_x:
    .string "New x values: "
str_space:
    .string " "
str_final:
    .string "\n=== FINAL RESULT after 10 iterations ==="
newline:
    .string "\n"

.text
.globl main
main:
    # load bases & constants
    la    s0, matrix       # s0 = &matrix
    la    s1, vector_x     # s1 = &vector_x (current values)
    la    s2, vector_x_new # s2 = &vector_x_new (new values)
    la    s5, vector_b     # s5 = &vector_b
    li    s3, 4            # s3 = number of columns/rows
    li    s7, 0            # s7 = iteration counter
    li    s8, 10           # s8 = max iterations

iteration_loop:
    bge   s7, s8, final_result  # if iteration >= 10, done
    
    # Print iteration header
    la    a0, str_iteration
    li    a7, 4
    ecall
    addi  t0, s7, 1        # print iteration number (1-based)
    mv    a0, t0
    li    a7, 1
    ecall
    la    a0, str_iteration_end
    li    a7, 4
    ecall
    la    a0, newline
    li    a7, 4
    ecall
    
    # Print current x values
    la    a0, str_old_x
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
    
    li    s6, 0            # s6 = row index i

row_loop:
    bge   s6, s3, iteration_complete # if i>=4, all equations processed
    
    # For equation i, solve for x_i (diagonal element)
    
    # print "Row i, solving for x_i: "
    la    a0, str_row
    li    a7, 4            # print_string
    ecall
    mv    a0, s6           # print row index i
    li    a7, 1            # print_int
    ecall
    la    a0, str_col
    li    a7, 4
    ecall
    mv    a0, s6           # print variable index (same as row for diagonal)
    li    a7, 1            # print_int
    ecall
    la    a0, str_result
    li    a7, 4
    ecall

    # --- compute skipped dot product (skip diagonal element i) ---
    mv    a0, s0           # matrix base
    mv    a1, s1           # vector_x base (current values)
    mv    a2, s6           # row index i
    mv    a3, s6           # skip index i (diagonal)
    mv    a4, s3           # #cols
    jal   mul_row_vec_skip
    fmv.s f6, f0           # save dot in f6

    # --- load b[i] into f7 ---
    mv    a0, s5           # vector_b base
    mv    a1, s6           # index i
    jal   get_vec_elem
    fmv.s f7, f0

    # --- get matrix[i][i] (the diagonal element) ---
    mv    a0, s0           # matrix base
    mv    a1, s6           # row index i
    mv    a2, s6           # column index i (diagonal)
    mv    a3, s3           # #cols
    jal   get_element
    fmv.s f8, f0           # f8 = matrix[i][i] = a_ii

    # --- compute x_i_new = (b[i] - skipped_dot) / a_ii ---
    fsub.s f0, f7, f6      # f0 = b[i] - skipped_dot
    fdiv.s f0, f0, f8      # f0 = (b[i] - skipped_dot) / a_ii

    # --- store new x_i value ---
    mv    a0, s2           # vector_x_new base
    mv    a1, s6           # index i
    fmv.s fa0, f0          # value to store
    jal   set_vec_elem

    # print result
    fmv.s fa0, f0
    li    a7, 2            # print_float
    ecall

    # newline
    la    a0, newline
    li    a7, 4
    ecall

    # next row i
    addi  s6, s6, 1
    j     row_loop

iteration_complete:
    # Print new x values for this iteration
    la    a0, str_new_x
    li    a7, 4
    ecall
    li    t0, 0
print_new_loop:
    bge   t0, s3, print_new_done
    mv    a0, s2
    mv    a1, t0
    jal   get_vec_elem
    fmv.s fa0, f0
    li    a7, 2
    ecall
    la    a0, str_space
    li    a7, 4
    ecall
    addi  t0, t0, 1
    j     print_new_loop
print_new_done:
    la    a0, newline
    li    a7, 4
    ecall
    la    a0, newline
    li    a7, 4
    ecall

    # --- COPY NEW VALUES TO CURRENT VALUES ---
    # This is the key step: x_old := x_new for next iteration
    li    t0, 0
copy_loop:
    bge   t0, s3, copy_done
    
    # get new value
    mv    a0, s2           # vector_x_new base
    mv    a1, t0           # index
    jal   get_vec_elem
    fmv.s f9, f0           # f9 = new value
    
    # store in current vector
    mv    a0, s1           # vector_x base (current)
    mv    a1, t0           # index
    fmv.s fa0, f9          # value to store
    jal   set_vec_elem
    
    addi  t0, t0, 1
    j     copy_loop
copy_done:

    # next iteration
    addi  s7, s7, 1
    j     iteration_loop

final_result:
    # Print final result
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
    li    a7, 10           # exit
    ecall

#————————————————————————————
# set_vec_elem:
#   in:  a0=base, a1=index, fa0=value
#  out:  stores value at vector[a1]
#————————————————————————————
set_vec_elem:
    # Save t0 since we use it
    addi  sp, sp, -4
    sw    t0, 0(sp)
    
    slli  t0, a1, 2        # t0 = index * 4
    add   t0, a0, t0       # t0 = base + (index * 4)
    fsw   fa0, 0(t0)       # store float value
    
    # Restore t0
    lw    t0, 0(sp)
    addi  sp, sp, 4
    jr    ra

#————————————————————————————————————————————————————————
# mul_row_vec_skip:
#   Inputs: a0=matrix, a1=vector, a2=row, a3=skip, a4=#cols
#   Output: f0 = ?_{k?skip} matrix[row][k] * vector[k]
#————————————————————————————————————————————————————————
mul_row_vec_skip:
    # Save registers
    addi  sp, sp, -48
    sw    ra,    44(sp)
    sw    s0,    40(sp)
    sw    s1,    36(sp)
    sw    s2,    32(sp)
    sw    s3,    28(sp)
    sw    s4,    24(sp)
    sw    t0,    20(sp)
    sw    t1,    16(sp)
    
    mv    s0, a0       # matrix base
    mv    s1, a1       # vector base
    mv    s2, a2       # row index
    mv    s3, a3       # skip index
    mv    s4, a4       # #columns
    
    # sum = 0.0
    la    t1, zero_f
    flw   f2, 0(t1)
    li    t0, 0        # k = 0

loop:
    bge   t0, s4, finish
    beq   t0, s3, skip_increment  # if k == skip, just increment and continue
    
    # -- matrix[row][k] --
    # save k
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
    
    # -- vector[k] --
    addi  sp, sp, -4
    sw    t0, 0(sp)
    mv    a0, s1
    mv    a1, t0
    jal   get_vec_elem
    fmv.s f4, f0
    lw    t0, 0(sp)
    addi  sp, sp, 4
    
    # accumulate
    fmul.s f5, f3, f4
    fadd.s f2, f2, f5

skip_increment:
    addi  t0, t0, 1
    j     loop
    
finish:
    fmv.s f0, f2
    # Restore registers
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

#————————————————————————————
# get_vec_elem:
#   in:  a0=base, a1=index
#  out:  f0=vector[a1]
#————————————————————————————
get_vec_elem:
    # Save t0 since we use it
    addi  sp, sp, -4
    sw    t0, 0(sp)
    
    slli  t0, a1, 2
    add   t0, a0, t0
    flw   f0, 0(t0)
    
    # Restore t0
    lw    t0, 0(sp)
    addi  sp, sp, 4
    jr    ra

#————————————————————————————
# get_element:
#   in:  a0=base, a1=row, a2=col, a3=#cols
#  out:  f0=matrix[a1][a2]
#————————————————————————————
get_element:
    # Save t0 since we use it
    addi  sp, sp, -4
    sw    t0, 0(sp)
    
    mul   t0, a1, a3
    add   t0, t0, a2
    slli  t0, t0, 2
    add   t0, a0, t0
    flw   f0, 0(t0)
    
    # Restore t0
    lw    t0, 0(sp)
    addi  sp, sp, 4
    jr    ra