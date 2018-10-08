.globl exitMessage gaussian3
.include "macros.asm"
.include "fileops.asm"
.include "edgeExtractor.asm"

.data
	image:		.space 1048576 # (4 * words amount)
	gaussian3:	.space 200000
	imageRows:	.word 512
	imageCols:	.word 512
	inFilename:	.asciiz "img.bmp" #defines filename for opening
	exitMessage:	.asciiz "Something went wrong"
	backtomain:	.asciiz "back to main"
	mainmenu: .asciiz "selecione uma operacao:\n1)blur\n2)edge extractor\n3)binarizacao\n4)exit\n5)save\n" 
	errormain: .asciiz "opcao invalida, selecione uma opcao listada."
	kernelmenu: .asciiz "selecione o tamanho do kernel:\n1)3x3\n2)5x5\n3) 7x7\n"
	binamenu: .asciiz "escolha uma intensidade de 1 a 10:\n"
	filename: .asciiz "saida.bmp"
	buffer:		.space 786486
	bufferend: .space 2
.macro menu(%image_pointer,%size)
	move $t0, %image_pointer
	start:
	addi $v0, $zero, 4 #loads v0 for print syscall
	la $a0, mainmenu #printcontent adress
	syscall

	addi $v0, $zero, 5 #loads v0 for read int syscall
	syscall #saves value to v0

	#all read syscalls request int numbers.Any other input will trigger coproc0.

	beq $v0, 1, blurm #if 1 is chosen, go to blur menu
	beq $v0, 2, edgem #if 2 is chosen, go to edge extractor menu
	beq $v0, 3, binam #if 3 is chosen, go to binary threshold menu
	beq $v0, 4, exit #if 4 is chosen, exit program
	beq $v0, 5, save #if 5 is chose, save file
	#if the user types any other value, a error message is printed
	addi $v0, $zero, 4 #loads v0 for print syscall
	la $a0, errormain #error message adress
	syscall
	j start
	blurm: #blur menu
		addi $v0, $zero, 4 #loads v0 for print syscall
		la $a0, kernelmenu #print content adress
		syscall

	blurread: 
		addi $v0, $zero, 5 #loads v0 for read syscall
		syscall #saves value to v0

		#from bge to contblur, checks if the typed value is beetween 1 and 3. if it isn't, requests another value
		bge $v0,1,condblur1 
		j blurread
	condblur1:
		ble $v0,3,contblur
		j blurread
	contblur:
	move $a0, $t0
	beq $v0,1,blur3b
	beq $v0,2,blur5b
	beq $v0,3,blur7b
	blur3b:
	  	Blur3 ($a0, $v0)
	  	move $t0, $a0
	  	j start #returns to main menu
	blur5b:	
		Blur5 ($a0, $v0)
		move $t0, $a0
		j start #returns to main menu
	blur7b:	
		Blur7 ($a0, $v0)
		move $t0, $a0	
		j start #returns to main menu

	edgem: #edge extractor menu

		addi $v0, $zero, 4 #loads v0 for print syscall
		la $a0, kernelmenu #print content adress
		syscall

	edgeread: 
		addi $v0, $zero, 5 #loads v0 for read syscall
		syscall #saves value to v0

		##from bge to contedge, checks if the typed value is beetween 1 and 3. if it isn't, requests another value
		bge $v0,1,condedge1 
		j edgeread
	condedge1: 
		ble $v0,3,contedge
		j edgeread
	contedge: 
		la $a0, image
		gaussianBlur($a0, $s2)
		la $a0, image
		extractBorders($a0, $s2)
		la $a0, image
		move $t0, $a0
		j start #returns to main menu
	
	binam: #binary threshold menu
		addi $v0, $zero, 4 #loads v0 for print syscall
		la $a0, binamenu #print content adress
		syscall
	binaread: 
		addi $v0, $zero, 5 #loads v0 for read int syscall
		syscall #saves value to v0

		##from bge to contbina, checks if the typed value is beetween 1 and 10. if it isn't, requests another value
		bge $v0,1,condbina1 
		j binaread
	condbina1: 
		ble $v0,10,contbina
		j binaread
	contbina: 
		move $a0, $t0
		showBlackWhite ($a0, %size,$v0) #bitrfgoojapsodODS JOSJD 
		move $t0, $a0
		j start
	save:
		la $a0,image
		la $a1,buffer
		addi $a1,$a1, 786483
		org_buffer($a0,$a1)
		file_open:
   		 li $v0, 13
  		  la $a0, filename
   		 li $a1, 1
   		 li $a2, 0
  		  syscall  # File descriptor gets returned in $v0
  		
		file_write:
    		  # Syscall 15 requieres file descriptor in $a0
    		 move $a0, $v0
   		 li $v0, 15
   		 la $a1, buffer
  		  la $a2, bufferend
   		 la $a3, buffer
   		 subu $a2, $a2, $a3  # computes the length of the string, this is really a constant
   	 syscall
file_close:
    li $v0, 16  # $a0 already has the file descriptor
     
		j start
	exit:
.end_macro

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
	loadImage($s6, $a0, $s4)
	
	# prepares showImage args
		# a0: pointer to buffer start
		# a1: rowXcols value (once buffer is a memory array)
	# menu() 
	la $a0, image
	menu($a0,$s2)
	li $v0, 4
	la $a0, backtomain
	syscall
	li $v0, 10
	syscall

	

