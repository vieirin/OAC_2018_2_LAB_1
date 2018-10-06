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

.macro Blur3 (%image_pointer, %size)
	move $t0, %image_pointer
	addi $t0,$t0,2052  # Inicío do blur
	li $t2,3   #Tamanho do Kernel
	li $t4, 0  # R 
	li $t5, 0  # G
	li $t6, 0  # B
	li $t1,0
	
	li $t8, 516        #Número de linhas. Tive que modificar essa variável para se adequar ao loop (acho que o valor será 512 +4 +8 +12 para 3x3 5x5 
	li $t9,510	#Número de colunas. Valor é 512 - 8 para 3x3 512 - 16 para 5x5 e - 24 para 7x7
	j loop
loopBlur:	
	li $t9,510 #Número de colunas. Valor é 512 - 8 para 3x3 512 - 16 para 5x5 e - 24 para 7x7
	
	addi $t0,$t0,8
	addi $t8,$t8,-1
	beqz $t8,exit
	
	j loopKernel1
loop:
	li $t3,3 #Númeor do kernel
	
	divu $t4,$t4,$t3
	divu $t4,$t4,$t3
	
	divu $t5,$t5,$t3
	divu $t5,$t5,$t3
	
	divu $t6,$t6,$t3
	divu $t6,$t6,$t3
	
	sll $t5,$t5,8
	sll $t6,$t6,16
	
	or $t4,$t4,$t5
	or $t4,$t4,$t6
	
	sw $t4,0($t0)
        
        li $t4, 0  # R 
	li $t5, 0  # G
	li $t6, 0  # B
	
	
	addi $t0,$t0,4
	addi $t7,$t0,-2052 #Pixel 0x0 na matrix 3x3
	addi $t9,$t9,-1
	bne $t9,0 loopKernel1
	
	j loopBlur
	
loopKernel1:	
	li $t2,3 #número do kernel
	
loopKernel2:
	lbu $t1,0($t7)
	addu $t4,$t4,$t1
	
	addi $t7,$t7,1
	lbu $t1,0($t7)
	addu $t5,$t5,$t1
	
	addi $t7,$t7,1
	lbu $t1,0($t7)
	addu $t6,$t6,$t1
	
	addi $t7,$t7,2 #usado para pular o zero e ir direto pro próximo R
	addi $t2,$t2,-1
	bgtz $t2 loopKernel2
	
	addi $t3,$t3,-1
	beqz $t3, loop
	addi $t7,$t7,2040 #pula para a linha de baixo para a primeira posição
	j loopKernel1


exit:	


.end_macro 

.macro Blur5 (%image_pointer, %size)
	move $t0, %image_pointer
	addi $t0,$t0,4104  # Inicío do blur
	li $t2,5   #Tamanho do Kernel
	li $t4, 0  # R 
	li $t5, 0  # G
	li $t6, 0  # B
	li $t1,0
	
	li $t8, 520        #Número de linhas. Tive que modificar essa variável para se adequar ao loop (acho que o valor será 512 +4 +8 +12 para 3x3 5x5 
	li $t9,496	#Número de colunas. Valor é 512 - 8 para 3x3 512 - 16 para 5x5 e - 24 para 7x7
	j loop
loopBlur:	
	li $t9,496 #Número de colunas. Valor é 512 - 8 para 3x3 512 - 16 para 5x5 e - 24 para 7x7
	
	addi $t0,$t0,8
	addi $t8,$t8,-1
	beqz $t8,exit
	
	j loopKernel1
loop:
	li $t3,5 #Númeor do kernel
	
	divu $t4,$t4,$t3
	divu $t4,$t4,$t3
	
	divu $t5,$t5,$t3
	divu $t5,$t5,$t3
	
	divu $t6,$t6,$t3
	divu $t6,$t6,$t3
	
	sll $t5,$t5,8
	sll $t6,$t6,16
	
	or $t4,$t4,$t5
	or $t4,$t4,$t6
	
	sw $t4,0($t0)
        
        li $t4, 0  # R 
	li $t5, 0  # G
	li $t6, 0  # B
	
	
	addi $t0,$t0,4
	addi $t7,$t0,-4104 #Pixel 0x0 na matrix 3x3
	addi $t9,$t9,-1
	bne $t9,0 loopKernel1
	
	j loopBlur
	
loopKernel1:	
	li $t2,5 #número do kernel
	
loopKernel2:
	lbu $t1,0($t7)
	addu $t4,$t4,$t1
	
	addi $t7,$t7,1
	lbu $t1,0($t7)
	addu $t5,$t5,$t1
	
	addi $t7,$t7,1
	lbu $t1,0($t7)
	addu $t6,$t6,$t1
	
	addi $t7,$t7,2 #usado para pular o zero e ir direto pro próximo R
	addi $t2,$t2,-1
	bgtz $t2 loopKernel2
	
	addi $t3,$t3,-1
	beqz $t3, loop
	addi $t7,$t7,2032 #pula para a linha de baixo para a primeira posição
	j loopKernel1


exit:	


.end_macro 

.macro Blur7 (%image_pointer, %size)
	move $t0, %image_pointer
	addi $t0,$t0,6156  # Inicío do blur
	li $t2,7   #Tamanho do Kernel
	li $t4, 0  # R 
	li $t5, 0  # G
	li $t6, 0  # B
	li $t1,0
	
	li $t8, 530       #Número de linhas. Tive que modificar essa variável para se adequar ao loop (acho que o valor será 512 +4 +8 +12 para 3x3 5x5 
	li $t9,488	#Número de colunas. Valor é 512 - 8 para 3x3 512 - 16 para 5x5 e - 24 para 7x7
	j loop
loopBlur:	
	li $t9,488 #Número de colunas. Valor é 512 - 8 para 3x3 512 - 16 para 5x5 e - 24 para 7x7
	
	addi $t0,$t0,8
	addi $t8,$t8,-1
	beqz $t8,exit
	
	j loopKernel1
loop:
	li $t3,7 #Númeor do kernel
	
	divu $t4,$t4,$t3
	divu $t4,$t4,$t3
	
	divu $t5,$t5,$t3
	divu $t5,$t5,$t3
	
	divu $t6,$t6,$t3
	divu $t6,$t6,$t3
	
	sll $t5,$t5,8
	sll $t6,$t6,16
	
	or $t4,$t4,$t5
	or $t4,$t4,$t6
	
	sw $t4,0($t0)
        
        li $t4, 0  # R 
	li $t5, 0  # G
	li $t6, 0  # B
	
	
	addi $t0,$t0,4
	addi $t7,$t0,-6156 #Pixel 0x0 na matrix 3x3
	addi $t9,$t9,-1
	bne $t9,0 loopKernel1
	
	j loopBlur
	
loopKernel1:	
	li $t2,7 #número do kernel
	
loopKernel2:
	lbu $t1,0($t7)
	addu $t4,$t4,$t1
	
	addi $t7,$t7,1
	lbu $t1,0($t7)
	addu $t5,$t5,$t1
	
	addi $t7,$t7,1
	lbu $t1,0($t7)
	addu $t6,$t6,$t1
	
	addi $t7,$t7,2 #usado para pular o zero e ir direto pro próximo R
	addi $t2,$t2,-1
	bgtz $t2 loopKernel2
	
	addi $t3,$t3,-1
	beqz $t3, loop
	addi $t7,$t7,2024 #pula para a linha de baixo para a primeira posição
	j loopKernel1


exit:	


.end_macro 
