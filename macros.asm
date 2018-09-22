.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro


.macro showImage (%image_pointer, %size)
	li $t1, 0
	move $t3, %size
loop:
  	lw $t4, (%image_pointer) # move from space to register
	sw $t4, ($gp)
	addi $gp, $gp, 4
	addi $t1, $t1, 1
	addi %image_pointer, %image_pointer, 4
	bne $t1, $t3, loop 
.end_macro
