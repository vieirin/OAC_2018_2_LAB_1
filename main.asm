.include "macros.asm"

.text
main: 
	jal openFile
	jal readFile
	jal closeFile
	# At this point the register values are:
		# $s0: file descriptor
		# $s4: nchars read by readFile
		# $s6: buffer pointer
	# prepare loadImage args
		# a0: pointer to buffer start
		# a1: image pointer
		# a2: iterator (starts at 0)
	# adds 0 to word, once bit map saves in 3-3bytes groups (RGB)
	jal loadImage
	# prepares showImage args
		# a0: pointer to buffer start
		# a1: rowXcols value (once buffer is a memory array)
	la $a0, image
	lw $t0, imageRows
	lw $t1, imageCols
	mulu $a1, $t0, $t1 # 512 * 512
	#li $a1, 1048576
	showImage($a0, $a1)
	#showBlackWhite ($a0, $a1)
	li $v0, 4
	la $a0, backtomain
	syscall
	li $v0, 10
	syscall
	

openFile:
	# syscall 13 
		# a0 filename 
		# a1 open flag (0: read)
		# a2 mode (?)
	li $v0, 13 # syscall 13: open file
	la $a0, inFilename # a0 for syscall 13: filename
	li $a1, 0 # open for reading
	li $a2, 0 # mode 0
	syscall
	# syscall returns to v0, so stores it to s0
	move $s0, $v0
	# needs to queue value from $ra to go back to main
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal openFileError
	# dequeue to jump back to main
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	jr $t1

openFileError:
	# Print out if syscall for opening file was unsuccessful
	move $t0, $v0
	slt $t1, $t0, $zero
	bne $t1, $zero, exitError
	jr $ra

closeFile:
	li $v0, 16 # syscall for close file
	move $a0, $s0 # file descriptor
	syscall
	jr $ra

exitError:
	# exit lable is called everytime something goes wrong
	# syscall 10 exits
	li $v0, 4
	la $a0, exitMessage
	syscall # print exit message
	li $v0, 10
	syscall
	
readFile:
	# Reads file to memory from reg address
	# syscall 14
		# $a0: file descriptor ($s0)
		# $a1: address buffer
		# $a2: buffer lenght (512x512*3 = 786432)
	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	li $a2, 786486
	syscall # readsfile to buffer
	
	bgt $v0, 0, fpnull
		break
	fpnull:
	move $s4, $v0 # saves nread char to $s4
	move $s6, $a1 # saves buffer pointer to $s6
	jr $ra

loadImage:
	# a0: pointer to buffer start
	# a1: image pointer
	# a2: iterator (starts at 0)
	# At this point the register values are:
		# $s0: file descriptor
		# $s4: nchars read by readFile
		# $s6: buffer pointer
	subi $s4, $s4, 54 	# arqbytes-header
	div $s4, $s4, 3		# $s4: words ammount
	
	la $s6, buffer
	addi $s6, $s6, 54	# header offset

	la $s1, image		# s1 = &imagem

	li $t0, 0		# i = 0	
	loop:
		beq $t0, $s4, return
		
		lbu $t1, ($s6) # load R byte from buffer
		addi $s6, $s6, 1
		sb $t1, ($s1)
		addi $s1, $s1, 1
		
		lbu $t1, ($s6) # load G byte from buffer
		addi $s6, $s6, 1
		sb $t1, ($s1)
		addi $s1, $s1, 1
				
		lbu $t1, ($s6) # load B byte from buffer
		addi $s6, $s6, 1
		sb $t1, ($s1)
		addi $s1, $s1, 1
		
		sb $zero, ($s1) # writes 00
		addi $s1, $s1, 1
		
		addi $t0, $t0, 1
		
		
		b loop
	return:
		jr $ra

.data
	imageRows:	.word 512
	imageCols:	.word 512
	inFilename:	.asciiz "img.bmp" #defines filename for opening
	exitMessage:	.asciiz "Something went wrong"
	backtomain:	.asciiz "back to main"
	buffer:		.space 786486
	image:		.space 1048576 # (4 * words amount)
	
