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

	
