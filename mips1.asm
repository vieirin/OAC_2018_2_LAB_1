    .macro Terminate
        li $v0, 10
        syscall
    .end_macro

    .text    
main:
    li $t1, 0
    li $t2, 4
    li $t3, 4096
loop:
    li $t4, 0xFF0000 
    sw $t4, ($gp)
    addi $gp, $gp, 4
    addi $t1, $t1, 1
    bne $t1, $t3, loop  

    Terminate
