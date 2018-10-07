.macro gaussianBlur(%image_pointer, %image_size)
	add $t5, %image_pointer, %image_size
	li $a1, 3
	li $t0, 513
	sll $t0, $t0, 2
	add %image_pointer, %image_pointer, $t0 # starts at (1,1)
	add $t5, $t5, $t0 # end at (510, 510)
	createKernel($a1)
	move $t0, %image_pointer # %image_pointer
	move $t1, $zero # i counter
	j row
	convolute:
		bge $t0, $t5, return # if at last pixel goto return 
		move $t1, $zero # i resets to 0
		add $t0, $t0, 4 # next image pixel
		bne $t0, 510, row
		add $t0, $t0, 4 # if last pixel jump two pixels ahead
		row:
			li $t2, -1                   # j = -1
			addi $t1, $t1, 1             # i++
			bge $t1, 2, convolute
		col: 
			beq $t2, 2, row
			addi $t3, $t1, -1            # i - 1 
			mul $t3, $t3, 512            # 512 * (i - 1) 
			add $t3, $t3, $t2            # $t3 += j
			sll $t3, $t3, 2		     # $t3 *= 4
			add $t3, $t0, $t3	     # pxAddr (or $t3) = %image_pointer +/- 512*(i-1) + j
			lw $t4, ($t3) 		     # $t4 = pixel at pixel addr
			addi $t2, $t2, 1
			ble $t2, 2, col 
			j row
	return:
	
.end_macro

.macro createKernel(%kernel_size)
	# store kernel into float process
	li $t0, 0x3e8eda66 # 0.27901
	mtc1 $t0, $f0
	li $t0, 0x3ee24b34 # 0.44198
	mtc1 $t0, $f1
	li $t0, 0x3e8eda66 # 0.27901
	mtc1 $t0, $f2
.end_macro
