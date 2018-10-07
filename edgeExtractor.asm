.macro gaussianBlur(%image_pointer, %image_size)
	add $t5, %image_pointer, %image_size
	li $a1, 3
	li $t0, 513
	sll $t0, $t0, 2
	add %image_pointer, %image_pointer, $t0 # starts at (1,1)
	add $t5, $t5, $t0 # end at (510, 510)
	createKernel($a1)
	move $t0, %image_pointer # %image_pointer
	li $t1, -1 # i counter

	move $t6, $zero # reset rgb regs
	move $t7, $zero
	move $t8, $zero
	j row
	convolute:
		srl $t8, $t8, 4
		srl $t7, $t7, 4
		srl $t6, $t6, 4
		sll $t7, $t7, 8
		sll $t8, $t8, 16
		or $t6, $t6, $t7
		or $t6, $t6, $t8
		sw $t6, 0($t0)
		bge $t0, $t5, return # if at last pixel goto return 
		move $t1, $zero # i resets to 0
		add $t0, $t0, 4 # next image pixel
		move $t6, $zero # reset rgb regs
		move $t7, $zero
		move $t8, $zero
		bne $t0, 510, row
		add $t0, $t0, 12 # if last pixel jump two pixels ahead
		row:
			li $t2, -1                   # j = -1
			addi $t1, $t1, 1             # i++
			bgt $t1, 2, convolute
		col: 
			beq $t2, 2, row
			addi $t3, $t1, -1            # i - 1 
			mul $t3, $t3, 512            # 512 * (i - 1) 
			add $t3, $t3, $t2            # $t3 += j
			sll $t3, $t3, 2		     # $t3 *= 4
			add $t3, $t0, $t3	     # pxAddr (or $t3) = %image_pointer +/- 512*(i-1) + j
			getKernelValue($t1, $t2)
			# loads bytes to $t6, $t7, $t8
			lbu $t4, ($t3)
			mtc1 $t4, $f3
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f5
			cvt.w.s $f3, $f3
			mfc1 $t4, $f3
			addu $t6, $t6, $t4
			addi $t3, $t3, 1
			
			lbu $t4, ($t3)
			mtc1 $t4, $f3
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f5
			cvt.w.s $f3, $f3
			mfc1 $t4, $f3
			addu $t7, $t7, $t4
			addi $t3, $t3, 1
			
			lbu $t4, ($t3)
			mtc1 $t4, $f3
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f5
			cvt.w.s $f3, $f3
			mfc1 $t4, $f3
			addu $t8, $t8, $t4
			addi $t3, $t3, 2
			
			addi $t2, $t2, 1
			ble $t2, 2, col 
			j row
	return:
	
.end_macro

.macro createKernel(%kernel_size)
	# store kernel into float process
	li $t0, 0x3f800000 # 0.
	mtc1 $t0, $f0
	li $t0, 0x40000000 # 0.44198
	mtc1 $t0, $f1
	li $t0, 0x3f800000 # 0.27901
	mtc1 $t0, $f2
	li $t0, 0x40800000
	mtc1 $t0, $f4
.end_macro

.macro multJ(%componentValue, %col)
	bne %col, 0, notFirst
		mtc1 %componentValue, $f3
		cvt.s.w $f3, $f3
		mul.s $f3, $f3, $f0
		cvt.w.s $f3, $f3
		mfc1 $v0, $f3
		j return
	notFirst:
		bne %col, 1, notSecond
			mtc1 %componentValue, $f3
			bne $t2, 1, notCentral
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f4
				cvt.w.s $f3, $f3
				mfc1 $v0, $f3
			notCentral:
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f1
				cvt.w.s $f3, $f3
				mfc1 $v0, $f3
			j return
	notSecond:
		bne %col, 2, return
			mtc1 %componentValue, $f3
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f2
			cvt.w.s $f3, $f3
			mfc1 $v0, $f3
	return:
.end_macro

.macro extractBorders(%image_pointer, %size)
	convertGray(%image_pointer, %size)
	add $t5, %image_pointer, %size
	li $a1, 3
	li $t0, 513
	sll $t0, $t0, 2
	add %image_pointer, %image_pointer, $t0 # starts at (1,1)
	add $t5, $t5, $t0 # end at (510, 510)
	move $t0, %image_pointer # %image_pointer
	li $t1, -1 # i counter

	move $t6, $zero # reset rgb regs
	move $t7, $zero
	move $t8, $zero
	j row
	convolute:
		move $a2, $t8
		convertScaleAbs($a2)
		move $t8, $v0
		move $t7, $v0
		move $t6, $v0
		sll $t7, $t7, 8
	        sll $t8, $t8, 16
		or $t6, $t6, $t7
		or $t6, $t6, $t8
		sw $t6, 0($t0)
		bge $t0, $t5, return # if at last pixel goto return 
		move $t1, $zero # i resets to 0
		add $t0, $t0, 4 # next image pixel
		move $t6, $zero # reset rgb regs
		move $t7, $zero
		move $t8, $zero
		bne $t0, 510, row
		add $t0, $t0, 12 # if last pixel jump two pixels ahead
		row:
			li $t2, -1                   # j = -1
			addi $t1, $t1, 1             # i++
			bgt $t1, 2, convolute
		col: 
			beq $t2, 2, row
			addi $t3, $t1, -1            # i - 1 
			mul $t3, $t3, 512            # 512 * (i - 1) 
			add $t3, $t3, $t2            # $t3 += j
			sll $t3, $t3, 2		     # $t3 *= 4
			add $t3, $t0, $t3	     # pxAddr (or $t3) = %image_pointer +/- 512*(i-1) + j
			getLaplacianValue($t1, $t2)
			# loads bytes to $t6, $t7, $t8
			lbu $t4, ($t3)
			mul $t4, $t4, $v0
			addu $t6, $t6, $t4
			addu $t7, $t7, $t4
			addu $t8, $t8, $t4
			
			addi $t3, $t3, 4
			
			addi $t2, $t2, 1
			ble $t2, 2, col 
			j row
	return: 

.end_macro

.macro convertGray(%image_pointer, %size)
	move $t0, %image_pointer
	add $t1, %image_pointer, %size
	li $t2, 10
	#weights
	li $t5, 3
	loop:
		lbu $t2, 0($t0)		#
		lbu $t3, 1($t0)		#
		lbu $t4, 2($t0)	 	#
		add $t2, $t2, $t3		# GRAYSCALE
		add $t2, $t2, $t4		#
		divu $t2, $t2, $t5	#
		sb $t2, 0($t0)     	#
		sb $t2, 1($t0)    	#
		sb $t2, 2($t0)    	#
		addi $t0, $t0, 4
		bne $t0, $t1, loop 
.end_macro

.macro convertScaleAbs(%component)
	sll %component, %component, 1
	slt $t9, $zero, %component
	bnez $t9, return
		li $a3, -1
		mul $v0, %component, $a3
		j exit
	return:
		move $v0, %component
	exit:

.end_macro

.macro getKernelValue(%x, %y)
  addi $t9, %y, 1 #due to logic at above function we need to sum j up to 1
  bnez %x, xNotZero
    beqz $t9, returnF0
    beq $t9, 1, returnF1
    beq $t9, 2, returnF2
  xNotZero:
    bne %x, 1, xNotOne
      beqz $t9, returnF1
      beq $t9, 1, returnF4
      beq $t9, 2, returnF1
  xNotOne:
    beqz $t9, returnF0
    beq $t9, 1, returnF1
    beq $t9, 2, returnF2
  
  
  returnF0: mov.s $f5, $f0
      j return
  returnF1: mov.s $f5, $f1
      j return
  returnF2: mov.s $f5, $f2
      j return
  returnF4: mov.s $f5, $f4
  return:
.end_macro

.macro getLaplacianValue(%x, %y)
  addi $t9, %y, 1 #due to logic at above function we need to sum j up to 1
  bnez %x, xNotZero
    beqz $t9, return0
    beq $t9, 1, return1
    beq $t9, 2, return0
  xNotZero:
    bne %x, 1, xNotOne
      beqz $t9, return1
      beq $t9, 1, return4
      beq $t9, 2, return1
  xNotOne:
    beqz $t9, return0
    beq $t9, 1, return1
    beq $t9, 2, return0
      
  return0: move $v0, $zero
      j return
  return1: li $v0, 1
      j return
  return4: li $v0, -4
      j return
  return:
.end_macro
