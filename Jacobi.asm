.data
vector_x:
    .float  1.5,  2.5,  3.5,  4.5
vector_b:
    .float  1.0,   1.0,   2.0,   3.0   
matrix:
    .float  1.1,  2.2,  3.3,  4.4,    # row 0
            5.5,  6.6,  7.7,  8.8,    # row 1
            9.9, 10.1, 11.2, 12.3,    # row 2
           13.4, 14.5, 15.6, 16.7     # row 3
zero_f:
    .float  0.0
str_row:
    .string "Row "
str_col:
    .string ", skip "
str_result:
    .string ": "
newline:
    .string "\n"

.text
.globl main
main:
    # load bases & constants
    la    s0, matrix       # s0 = &matrix
    la    s1, vector_x     # s1 = &vector_x
    la    s5, vector_b     # s5 = &vector_b
    li    s3, 4            # s3 = number of columns/rows
    li    s6, 0            # s6 = row index i

row_loop:
    bge   s6, s3, done     # if i>=4, exit (all rows done)
    li    s4, 0            # s4 = column index j (reset for each row)

col_loop:
    bge   s4, s3, next_row # if j>=4, go to next row
    
    # print "Row i, skip j: "
    la    a0, str_row
    li    a7, 4            # print_string
    ecall
    mv    a0, s6           # print row index i
    li    a7, 1            # print_int
    ecall
    la    a0, str_col
    li    a7, 4
    ecall
    mv    a0, s4           # print column index j
    li    a7, 1            # print_int
    ecall
    la    a0, str_result
    li    a7, 4
    ecall

    # --- compute skipped dot product into f0 ---
    mv    a0, s0           # matrix base
    mv    a1, s1           # vector_x base
    mv    a2, s6           # row index i
    mv    a3, s4           # skip index j
    mv    a4, s3           # #cols
    jal   mul_row_vec_skip
    fmv.s f6, f0           # save dot in f6

    # --- load b[i] into f7 ---
    mv    a0, s5           # vector_b base
    mv    a1, s6           # index i (not j!)
    jal   get_vec_elem
    fmv.s f7, f0

    # --- get matrix[i][j] (the diagonal/skipped element) ---
    mv    a0, s0           # matrix base
    mv    a1, s6           # row index i
    mv    a2, s4           # column index j
    mv    a3, s3           # #cols
    jal   get_element
    fmv.s f8, f0           # f8 = matrix[i][j] = a_ij

    # --- compute (b[i] - skipped_dot) / a_ij ---
    fsub.s f0, f7, f6      # f0 = b[i] - skipped_dot
    fdiv.s f0, f0, f8      # f0 = (b[i] - skipped_dot) / a_ij

    # print result
    fmv.s fa0, f0
    li    a7, 2            # print_float
    ecall

    # newline
    la    a0, newline
    li    a7, 4
    ecall

    # next column j
    addi  s4, s4, 1
    j     col_loop

next_row:
    # next row i
    addi  s6, s6, 1
    j     row_loop

done:
    li    a7, 10           # exit
    ecall

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