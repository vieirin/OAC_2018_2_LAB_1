.macro openFile(%filename)
	# syscall 13 
		# a0 filename 
		# a1 open flag (0: read)
		# a2 mode (?)
	li $v0, 13 # syscall 13: open file
	li $a1, 0 # open for reading
	li $a2, 0 # mode 0
	syscall
	openFileError($v0)
.end_macro

.macro openFileError(%fileDesc)
	# Print out if syscall for opening file was unsuccessful
	move $t0, %fileDesc
	slt $t1, $t0, $zero
	beqz $t1, pass
	exitError:
		# exit lable is called everytime something goes wrong
		# syscall 10 exits
		li $v0, 4
		la $a0, exitMessage
		syscall # print exit message
		li $v0, 10
		syscall
	pass:
.end_macro

.macro closeFile(%fileDesc)
	li $v0, 16 # syscall for close file
	move $a0, %fileDesc # file descriptor
	syscall
.end_macro

.macro readFile(%fileDesc, %buffer)
	# Reads file to memory from reg address
	# syscall 14
		# $a0: file descriptor ($s0)
		# $a1: address buffer
		# $a2: buffer lenght (512x512*3 = 786432)
	li $v0, 14
	move $a0, %fileDesc
	move $a1, %buffer
	li $a2, 786486
	syscall # readsfile to buffer
	
	bgt $v0, 0, fpnull
		break
	fpnull:
.end_macro

.macro org_buffer(%image_pointer,%bp)
	showImage(%image_pointer)

	move $t1,%image_pointer
	li $t1, 0	
	loop:
	lbu $t0, 0(%image_pointer)
	sb $t0, 0(%bp)
	addi %bp, %bp, 1
	addi %image_pointer, %image_pointer, 1
	
	lbu $t0, 0(%image_pointer)
	sb $t0, 0(%bp)
	addi %bp, %bp, 1
	addi %image_pointer, %image_pointer, 1
	
	lbu $t0, 0(%image_pointer)
	sb $t0, 0(%bp)
	addi %bp, %bp, 1
	addi %image_pointer, %image_pointer, 2
	
	addi $t1,$t1,3
	beq $t1,786432,exit
	j loop
exit:	
.end_macro

.macro showImage (%image_pointer)
	li $t3, 1048576
	move $t1, %image_pointer #começo
	add $t3,%image_pointer,$t3 #fim
	move $t2,%image_pointer

loop: #vira de cabeça pra cima
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
	
	move $t1,%image_pointer
	addi $t8,$zero,512 #número de linhas que o loop deverá passar 
	
loopespelho:#loop das linas
	add $t3,$t1,2048
	addi $t9,$zero,256 #número de repetições da troca de colunas 
loopinterno:#loop das colunas
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
	bne $t9,0,loopinterno
	
	add $t1,$t1,1024
	addi $t8,$t8,-1
	bne $t8,0,loopespelho

	li $t3, 1048576
	add $t3,%image_pointer,$t3 
loop2:#loop de impressão
  	lw $t4, ($t2) # move from space to register
	sw $t4, ($gp)
	addi $gp, $gp, 4
	addi $t2,$t2,4
	#bne $t2,%image_pointer,loop
	bne $t2, $t3, loop2

.end_macro