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

.macro loadImage(%buffer, %image_pointer, %size)
    	move $t6, %buffer
    	addi $t6, $t6, 54	# header offset
	
	addi $t0, %size, -54
	add $t0, $t0, $t6	# t0 = fim buffer
	
	loop:
		sub $t4, $t0, $t6
		beqz %image_pointer, return
		
		lbu $t1, ($t0) # load B byte from buffer
		addi $t0, $t0, -1
		lbu $t2, ($t0) # load G byte from buffer
		addi $t0, $t0, -1
		lbu $t3, ($t0) # load R byte from buffer
		addi $t0, $t0, -1
		sll $t3,$t3,8
		sll $t2,$t2,16
		or $t5,$t2,$t3
		or $t5,$t5,$t1
		sw $t5, (%image_pointer)
		addi %image_pointer, %image_pointer,4
	
		b loop
	return:
.end_macro 