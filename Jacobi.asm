    .data
vector:
    .float  1.5,  2.5,  3.5,  4.5        # 4-element float vector

matrix:
    .float  1.1,  2.2,  3.3,  4.4,       # row 0
            5.5,  6.6,  7.7,  8.8,       # row 1
            9.9, 10.1, 11.2, 12.3,       # row 2
           13.4, 14.5, 15.6, 16.7        # row 3

zero_f:
    .float  0.0                        # for initializing sum

newline:
    .string "\n"

    .text
    .globl main
main:
    #
    # Example: multiply row 2 of `matrix` by `vector`,
    # skipping column 3 (so skip a[2][3]*vector[3]).
    #
    la    a0, matrix         # a0 = &matrix[0][0]
    la    a1, vector         # a1 = &vector[0]
    li    a2, 2              # a2 = row index = 2
    li    a3, 3              # a3 = skip column = 3
    li    a4, 4              # a4 = number of columns = 4
    jal   mul_row_vec_skip   # returns sum in f0

    # print result
    fmv.s fa0, f0            # move to float-arg register
    li    a7, 2              # print_float
    ecall

    # newline
    la    a0, newline
    li    a7, 4              # print_string
    ecall

    # exit
    li    a7, 10
    ecall

#————————————————————————————————————————————————————————
# mul_row_vec_skip:
#   Multiply a row of a matrix by a vector, skipping one column.
#   Inputs:
#     a0 = base addr of matrix
#     a1 = base addr of vector
#     a2 = row index
#     a3 = skip-column index
#     a4 = number of columns
#   Output:
#     f0 = ? ?_{k=0..n-1, k?skip} matrix[row][k] * vector[k]
#            (single-precision float sum)
#————————————————————————————————————————————————————————
    .global mul_row_vec_skip
mul_row_vec_skip:
    # --- prologue: save callee-saved registers ---
    addi  sp, sp, -40
    sw    ra,    36(sp)
    sw    s0,    32(sp)
    sw    s1,    28(sp)
    sw    s2,    24(sp)
    sw    s3,    20(sp)
    sw    s4,    16(sp)

    # --- move inputs into callee-saved regs ---
    mv    s0, a0       # s0 = matrix base
    mv    s1, a1       # s1 = vector base
    mv    s2, a2       # s2 = row index
    mv    s3, a3       # s3 = skip index
    mv    s4, a4       # s4 = number of columns

    # --- initialize sum = 0.0 in f2 ---
    la    t1, zero_f
    flw   f2, 0(t1)

    # --- loop index k in t0 from 0 to s4-1 ---
    li    t0, 0
loop:
    bge   t0, s4, finish   # if k >= n_cols, done
    beq   t0, s3, skip     # if k == skip, skip iteration

    # get matrix element: a0=s0, a1=s2, a2=t0, a3=s4
    mv    a0, s0
    mv    a1, s2
    mv    a2, t0
    mv    a3, s4
    jal   get_element      # returns in f0

    fmv.s f3, f0           # save matrix[row][k] in f3

    # get vector element: a0=s1, a1=t0
    mv    a0, s1
    mv    a1, t0
    jal   get_vec_elem     # returns in f0

    fmv.s f4, f0           # save vector[k] in f4

    # multiply and accumulate: f2 += f3 * f4
    fmul.s f5, f3, f4
    fadd.s f2, f2, f5

skip:
    addi  t0, t0, 1
    j     loop

finish:
    # move sum into f0 for return
    fmv.s f0, f2

    # --- epilogue: restore callee-saved registers ---
    lw    ra,    36(sp)
    lw    s0,    32(sp)
    lw    s1,    28(sp)
    lw    s2,    24(sp)
    lw    s3,    20(sp)
    lw    s4,    16(sp)
    addi  sp, sp, 40

    jr    ra

#————————————————————————————
# get_vec_elem:
#   in:  a0 = base addr, a1 = element index (0–3)
#  out:  f0 = vector[a1]
#————————————————————————————
    .global get_vec_elem
get_vec_elem:
    slli  t0, a1, 2       # t0 = index * 4
    add   t0, a0, t0      # t0 = address of element
    flw   f0, 0(t0)       # load float
    jr    ra

#————————————————————————————
# get_element:
#   in:  a0 = base addr, a1 = row, a2 = col, a3 = #cols
#  out:  f0 = matrix[a1][a2]
#————————————————————————————
    .global get_element
get_element:
    mul   t0, a1, a3      # t0 = row * #cols
    add   t0, t0, a2      # t0 = flat index
    slli  t0, t0, 2       # t0 = byte offset
    add   t0, a0, t0      # t0 = address of element
    flw   f0, 0(t0)       # load float
    jr    ra
