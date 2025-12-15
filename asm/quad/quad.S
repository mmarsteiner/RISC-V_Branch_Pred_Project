    .global _start

_start: 
    addi s9, zero, 2047
    addi s0, zero, 0
    j init_loop_condition
init_loop:
    sw zero, 0(s0)
    addi s0, s0, 1
init_loop_condition:
    blt s0, s9, init_loop

    addi s0, zero, 0
    addi s3, zero, 1
    j main_loop_condition
main_loop_start:
    andi s1, s0, 0b11 # if s1 is zero, then s0 is divisible by 4
    addi s2, zero, 0
    bnez s1, main_loop_increment
    sw s3, 0(s0) # write a 1 to the memory locations that are divisible by 4
main_loop_increment:
    addi s0, s0, 1
main_loop_condition:
    blt s0, s9, main_loop_start

    # Makes it easier to set a hardware breakpoint after the end of the program
    nop
    nop
    nop

