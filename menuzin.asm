
menu: 
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
#if the user types any other value, a error message is printed
addi $v0, $zero, 4 #loads v0 for print syscall
la $a0, errormain #error message adress
syscall
j menu #returns to main menu




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
condblur1 : 	ble $v0,3,contblur
		j blurread
contblur: 

j menu #returns to main menu





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
condedge1 : 	ble $v0,3,contedge
		j edgeread
contedge: 


j menu #returns to main menu





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
condbina1 : 	ble $v0,10,contbina
		j binaread
contbina: 



j menu
exit:



.data
mainmenu: .asciiz "selecione uma operacao:\n1)blur\n2)edge extractor\n3)binarizacao\n4)exit\n" 
errormain: .asciiz "opcao invalida, selecione uma opcao listada."
kernelmenu: .asciiz "selecione o tamanho do kernel:\n1)3x3\n2)5x5\n3) 7x7\n"
binamenu: .asciiz "escolha uma intensidade de 1 a 10:\n"


