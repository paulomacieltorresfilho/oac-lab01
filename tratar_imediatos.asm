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
		slti $t5,$t1,56
		beq $t5,0,Loop
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

.macro cortaImediato (%numeroVerificado,%ImediatoCortado)
	
	Main:
		move $t0,%numeroVerificado
		verificaNegativo $t0
		move $t0,%numeroVerificado
		move $t1,%ImediatoCortado
		move $t2,$v0
		add $t2,$t2,48
		sb $t2,0($t1)
		addi $t0,$t0,2
		addi $t1,$t1,1
		move $t3,$t0
		li $t4,0
	Conta_Char:
		lb $t2,0($t0)
		beqz $t2,Confere
		addi $t4,$t4,1
		addi $t0,$t0,1
		j Conta_Char
	Confere:
		ble $t4,3,DividiMenor
		subi $t4,$t4,4
		add $t3,$t3,$t4
	DividiMaior:
		lb $t4,0($t3)
		beqz $t4,Exit
		sb $t4,0($t1)
		addi $t3,$t3,1
		addi $t1,$t1,1
		j DividiMaior
	DividiMenor:
		lb $t4,0($t3)
		beqz $t4,Exit
		sb $t4,0($t1)
		addi $t3,$t3,1
		addi $t1,$t1,1
		j DividiMenor
	Exit:
		sb $zero,0($t1)
		
.end_macro		

.data
	Num1: .asciiz "0xA321AAAA"
	Num2: .space 3000
.text
	la $a0,Num1
	la $a1,Num2
	cortaImediato $a0,$a1
	la $a0,Num2
	
	li $v0,4
	syscall
	

		
