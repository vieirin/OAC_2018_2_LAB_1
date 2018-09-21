.text
main: 
	j openFile
	


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
	move $s0, $v0
	jal openFileError
	#needs to queue value from $ra to go back to main
	j exit

openFileError:
	# Print out if syscall for opening file was unsuccessful
	move $t0, $v0
	slt $t1, $t0, $zero
	bne $t1, $zero, exit
	jr $ra

exit:
	# exit lable is called everytime something goes wrong
	# syscall 10 exits
	la $a0, exitMessage
	li $v0, 4
	syscall # print exit message
	li $v0, 10
	syscall
	
	
.data
	inFilename:	.asciiz "img.bmp" #defines filename for opening
	exitMessage:	.asciiz "Something went wrong"