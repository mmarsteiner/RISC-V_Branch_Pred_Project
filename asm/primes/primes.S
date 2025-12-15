    .global _start

_start: 
    # Initialize the data memory to zero
    addi x1, x0, 0
    addi x9, x0, 2000
    addi x9, x9, 2000
    addi x9, x9, 2000
    addi x9, x9, 1920 # 1000th prime is 7919
init_loop_start:
    sw x0, 0(x1)
    addi x1, x1, 1
    blt x1, x9, init_loop_start 
    # At each memory address, the value is 0 if the address is a prime number
    # Or 1 if it is a composite number
    # This could be more memory-efficient if bit manipulation was employed
    # to only use 1 bit per number, but that is much more complicated
    
    # Make x1 always store the value "1"
    # Mark 0 and 1 as composite
    addi x1, x0, 1
    sw x1, 0(x0)
    sw x1, 1(x0)
    
    # Marking process: x2 stores index of lowest prime
    # x3 stores index of the number being marked composite
    addi x2, x0, 0
    j outer_loop_condition
outer_loop_start:
    # Check to see if the prime candidate was already marked as composite
    lw x4, 0(x2)
    beq x4, x1, outer_loop_increment # continue with next iteration
    # Inner loop to mark multiples of this prime as composite
    add x3, x2, x2
    j inner_loop_condition
inner_loop_start:
    sw x1, 0(x3)
    add x3, x3, x2
inner_loop_condition: 
    blt x3, x9, inner_loop_start
outer_loop_increment: 
    addi x2, x2, 1
outer_loop_condition: 
    blt x2, x9, outer_loop_start
done:
    # Makes it easier to set a hardware breakpoint after the end of the program
    nop
    nop
    nop

