.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro


.macro showImage (%image_pointer, %size)
	move $t3, %size
	sll $t3,$t3,2
	move $t1, %image_pointer #começo
	add $t3,%image_pointer,$t3 #fim
	move $t2,%image_pointer
	
loop:	
	lw $t6,0($t1)
	lw $t7,0($t3)
	add $t4,$t6,$zero
	add $t6,$t7,$zero
	add $t7,$t4,$zero
	sw $t6, 0($t1)
	sw $t7 ,0($t3)
	addi $t1, $t1,4
	addi $t3,$t3,-4
	bne $t3,$t1,loop			

	move $t3,%size
	sll $t3,$t3,2
	add $t3,%image_pointer,$t3 
loop2:
  	lw $t4, ($t2) # move from space to register
	sw $t4, ($gp)
	addi $gp, $gp, 4
	addi $t2,$t2,4
	#bne $t2,%image_pointer,loop
	bne $t2, $t3, loop2

.end_macro

.macro showBlackWhite (%image_pointer, %size)
	move $t3, %size
	sll $t3,$t3,2
	move $t1, %image_pointer #começo
	add $t3,%image_pointer,$t3 #fim
	move $t2,%image_pointer
	
loop:	
	lw $t6,0($t1)
	lw $t7,0($t3)
	add $t4,$t6,$zero
	add $t6,$t7,$zero
	add $t7,$t4,$zero
	sw $t6, 0($t1)
	sw $t7 ,0($t3)
	addi $t1, $t1,4
	addi $t3,$t3,-4
	bne $t3,$t1,loop			

	move $t3,%size
	sll $t3,$t3,2
	add $t3,%image_pointer,$t3 
	addi $t7,$zero,0x007f7f7f #Filtro de cor
loop2:
  	lw $t4, ($t2) # move from space to register
  	slt $t5,$t4,$t7
  	beq $t5,1,preto
 
 branco: addi $t4,$zero,0xffffffff	
 	 j continua
 preto:
 	addi $t4,$zero,0
 continua:
	sw $t4, ($gp)
	addi $gp, $gp, 4
	addi $t2,$t2,4
	#bne $t2,%image_pointer,loop
	bne $t2, $t3, loop2
.end_macro