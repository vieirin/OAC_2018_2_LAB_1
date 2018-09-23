.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro


.macro showImage (%image_pointer, %size)
	move $t0, %image_pointer
	sll $t3, %size, 2
	add %image_pointer, %image_pointer, $t3
loop:
  	lw $t4, (%image_pointer) # move from space to register
	sw $t4, ($gp)
	addi $gp, $gp, 4
	addi %image_pointer, %image_pointer, -4
	sub $t1, %image_pointer, $t0
	bnez $t1, loop
.end_macro
