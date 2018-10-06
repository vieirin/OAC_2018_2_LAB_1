.globl exitMessage
.include "macros.asm"
.include "fileops.asm"

.data
	image:		.space 1048576 # (4 * words amount)
	buffer:		.space 786486
	imageRows:	.word 512
	imageCols:	.word 512
	inFilename:	.asciiz "img.bmp" #defines filename for opening
	exitMessage:	.asciiz "Something went wrong"
	backtomain:	.asciiz "back to main"

.include "menuzin.asm"

.text
main: 
	la $a0, inFilename
	openFile($a0)
	move $s0, $v0
	la $a1, buffer
	readFile($s0, $a1)
	move $s4, $v0
	la $s6, buffer
	closeFile($s0)
	# At this point the register values are:
		# $s0: file descriptor
		# $s4: nchars read by readFile
		# $s6: buffer pointer
	# prepare loadImage args
		# a0: pointer to buffer start
		# a1: image pointer
		# a2: iterator (starts at 0)
	# adds 0 to word, once bit map saves in 3-3bytes groups (RGB)
	la $a0, image
	move $s2, $s4
	addi $s2,$s2,-54
	li $t0,3
	divu $s2,$s2,$t0
	sll $s2,$s2,2
	li $s3, 5
	loadImage($s6, $a0, $s4)
	Blur($a0,$s2,$s3)
	#showBlackWhite($a0,$s2,$s3)
	# prepares showImage args
		# a0: pointer to buffer start
		# a1: rowXcols value (once buffer is a memory array)
	#menu()
	li $v0, 4
	la $a0, backtomain
	syscall
	li $v0, 10
	syscall

	
