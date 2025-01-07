.macro isHexa (%numeroVerificado) 
	
	Main:
		move $t0,%numeroVerificado
		lb $t0,1($t0)
		beq $t0,'x',Confirm
		beq $t0,'X',Confirm
		li $v0,0
		j Exit
	Confirm:
		li $v0,1
	Exit:
.end_macro

.macro verificaNegativo (%numeroVerificado) 
	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0) 
		li $t2,0
		beq $t1,'-',True
		addi $t0,$t0,2
	VerificaF:
		lb $t1,0($t0)
		beq $t1,'F',Loop
		beq $t1,'f',Loop
		j Verifica
	Loop:
		lb $t1,0($t0)
		beq $t1,$zero,Verifica
		addi $t2,$t2,1
		addi $t0,$t0,1
		j Loop
	True:
		li $v0,1
		j Exit
	Verifica:
		beq $t2,8,True
		li $v0,0
		j Exit
	Exit:
	
.end_macro

.data
	Num1: .asciiz "0xf4567"
.text
	la $t0,Num1
	verificaNegativo $t0
	move $a0,$v0
	
	li $v0,1
	syscall
	

		
