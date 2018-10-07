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
		sll $t6,$t6,8
		sll $t7,$t7,16
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
		add $t0, $t0, 4 # if last pixel jump two pixels ahead
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
			bne $t2, -1, notFirst
			# loads bytes to $t6, $t7, $t8
			lbu $t4, ($t3)
			move $t9, $t4
			mtc1 $t4, $f3
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f0
			cvt.w.s $f3, $f3
			mfc1 $t4, $f3
			multJ($t9, $t1)
			add $t4, $t4, $v0
			addu $t6, $t6, $t4
			
			addi $t3, $t3,1
			
			lbu $t4, 0($t3)
			move $t9, $t4
			mtc1 $t4, $f3 
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f0
			cvt.w.s $f3, $f3
			mfc1 $t4, $f3
		 	multJ($t9, $t1)
			add $t4, $t4, $v0
			addu $t7, $t7, $t4
	
			addi $t3, $t3, 1

			lbu $t4, ($t3)
			move $t9, $t4
			mtc1 $t4, $f3 
			cvt.s.w $f3, $f3
			mul.s $f3, $f3, $f0
			cvt.w.s $f3, $f3
			mfc1 $t4, $f3
		 	multJ($t9, $t1)
			add $t4, $t4, $v0
			addu $t8, $t8, $t4
			
			add $t3, $t3, 2	
			j continue
			notFirst:
				bne $t1, 1, notCentral
					lbu $t4, ($t3)
					move $t9, $t4
					mtc1 $t4, $f3 
					cvt.s.w $f3, $f3
					mul.s $f3, $f3, $f4
					cvt.w.s $f3, $f3
					mfc1 $t4, $f3
			 		multJ($t9, $t1)
					add $t4, $t4, $v0
					addu $t6, $t6, $t4
			
					addi $t3, $t3,1
			
					lbu $t4, 0($t3)
					move $t9, $t4
					mtc1 $t4, $f3 
					cvt.s.w $f3, $f3
					mul.s $f3, $f3, $f4
					cvt.w.s $f3, $f3
					mfc1 $t4, $f3
			 		multJ($t9, $t1)
					add $t4, $t4, $v0
					addu $t7, $t7, $t4
	
					addi $t3, $t3, 1
	
					lbu $t4, ($t3)
					move $t9, $t4
					mtc1 $t4, $f3 
					cvt.s.w $f3, $f3
					mul.s $f3, $f3, $f4
					cvt.w.s $f3, $f3
					mfc1 $t4, $f3
		 			multJ($t9, $t1)
					add $t4, $t4, $v0
					addu $t8, $t8, $t4
					add $t3, $t3, 2	
					j continue
				# loads bytes to $t6, $t7, $t8
				notCentral:
				lbu $t4, ($t3)
				move $t9, $t4
				mtc1 $t4, $f3 
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f1
				cvt.w.s $f3, $f3
				mfc1 $t4, $f3
		 		multJ($t9, $t1)
				add $t4, $t4, $v0
				addu $t6, $t6, $t4
			
				addi $t3, $t3,1
			
				lbu $t4, 0($t3)
				move $t9, $t4
				mtc1 $t4, $f3 
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f1
				cvt.w.s $f3, $f3
				mfc1 $t4, $f3
		 		multJ($t9, $t1)
				add $t4, $t4, $v0
				addu $t7, $t7, $t4
	
				addi $t3, $t3, 1

				lbu $t4, ($t3)
				move $t9, $t4
				mtc1 $t4, $f3 
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f1
				cvt.w.s $f3, $f3
				mfc1 $t4, $f3
		 		multJ($t9, $t1)
				add $t4, $t4, $v0
				addu $t8, $t8, $t4
				add $t3, $t3, 2	
				j continue
			notSecond:
				lbu $t4, ($t3)
				move $t9, $t4
				mtc1 $t4, $f3 
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f2
				cvt.w.s $f3, $f3
				mfc1 $t4, $f3
				multJ($t9, $t1)
				add $t4, $t4, $v0
				addu $t6, $t6, $t4
			
				addi $t3, $t3,1
			
				lbu $t4, 0($t3)
				move $t9, $t4
				mtc1 $t4, $f3 
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f2
				cvt.w.s $f3, $f3
				mfc1 $t4, $f3
				multJ($t9, $t1)
				add $t4, $t4, $v0
				addu $t7, $t7, $t4
	
				addi $t3, $t3, 1

				lbu $t4, ($t3)
				move $t9, $t4
				mtc1 $t4, $f3 
				cvt.s.w $f3, $f3
				mul.s $f3, $f3, $f2
				cvt.w.s $f3, $f3
				mfc1 $t4, $f3
				multJ($t9, $t1)
				add $t4, $t4, $v0
				addu $t8, $t8, $t4
				add $t3, $t3, 2	
				j continue
			continue:
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
