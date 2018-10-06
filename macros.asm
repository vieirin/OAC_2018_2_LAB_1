.macro print_int (%x)
	li $v0, 1
	add $a0, $zero, %x
	syscall
.end_macro

.macro loadImage(%buffer, %image_pointer, %buffersize)
    	move $t6, %buffer
    	addi $t6, $t6, 54	# header offset
	move $t8,%image_pointer
	addi $t0, %buffersize, -54
	add $t0, $t0, $t6	# t0 = buffer's end 
	
	loop:
		sub $t4, $t0, $t6
		beqz $t4, return
		
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
		sw $t5, ($t8)
		addi $t8, $t8,4
	
		b loop #teste
		
	return:
				
		move $t1,%image_pointer
		addi $t8,$zero,512
Mirror:
		add $t3,$t1,2048
		addi $t9,$zero,256 
internalLoop:
		lw $t6,0($t1)
		lw $t7,0($t3)
		add $t4,$t6,$zero
		add $t6,$t7,$zero
		add $t7,$t4,$zero
		sw $t6, 0($t1)
		sw $t7 ,0($t3)
		addi $t1, $t1,4
		addi $t3,$t3,-4
		addi $t9,$t9,-1
		bne $t9,0,internalLoop
		
		add $t1,$t1,1024
		addi $t8,$t8,-1
		bne $t8,0,Mirror		

.end_macro 



.macro showBlackWhite (%image_pointer, %size,%intensity) 
	li $t0,10
	addi $t4,%intensity,2
	move $t3, %size

	add $t3,%image_pointer,$t3 #End
	move $t2,%image_pointer    #Beginning
	addi $t7,$zero,0x007f7f7f  #Threshold
	mulu $t7,$t7,$t4
	divu $t7,$t7,$t0 	   #Intensity
	addi $t9,$zero,3
	
loop2:
  	
	lbu $t0 0($t2)		#
	lbu $t5,1($t2)		#
	lbu $t6,2($t2)		#
	add $t0,$t0,$t5		# GRAYSCALE
	add $t0,$t0,$t6		#
	divu $t0,$t0,$t9	#
	sb $t0, 0($t2)     	#
	sb $t0, 1($t2)    	#
	sb $t0, 2($t2)    	#
	
	#### Binary Threshold ####
	
	lw $t4, ($t2)
	slt $t5,$t4,$t7 #Compare to Threshold
	beq $t5,1,Black 
White: addi $t4,$zero,0xffffffff	
	 j continue
Black:
 	addi $t4,$zero,0
continue:	
	
	sw $t4, ($t2)
	addi $t2,$t2,4
	ble $t2, $t3, loop2
	
.end_macro






