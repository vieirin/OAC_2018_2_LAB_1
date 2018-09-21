.text
main: 
	jal openFile
	li $v0, 4
	la $a0, backtomain
	syscall
	jal readFile
	jal closeFile
	# prepares showImage args
		# a0: pointer to buffer start
		# a1: iterator (starts at 0)
		# a2: rowXcols value (once buffer is a memory array)
	move $a0, $s0
	move $a1, $zero
	lw $t0, imageRows
	lw $t1, imageCols
	mulu $a2, $t0, $t1
	jal showImage
	comeBackMain:
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
		# $a2: buffer lenght (512x512 = 262144)
	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	li $a2, 786432
	syscall
	jr $ra

showImage:
	# iterates over buffer and save its values to gp in order to show image
		# a0: pointer to buffer start
		# a1: iterator (starts at 0)
		# a2: rowXcols value (once buffer is a memory array)
	slt $t0, $a2, $a0
	bnez $t0, comeBackMain # if a1 > a2 go back to main where you belong
	move $t2, $a0 
	sll $t2, $t2, 8
	sw $t2, ($gp)
	addi $a0, $a0, 4 # pointer for buffer skips a word
	addi $a1, $a1, 1 # iterator++
	addi $gp, $gp, 4 # gp skips a word
	j showImage 

.data
	inFilename:	.asciiz "img.bmp" #defines filename for opening
	exitMessage:	.asciiz "Something went wrong"
	backtomain:	.asciiz "back to main"
	buffer:		.space 524288
	imageRows:	.word 512
	imageCols:	.word 512
