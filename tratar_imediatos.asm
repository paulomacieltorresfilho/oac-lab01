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

.macro cortaImediatoHexa (%numeroVerificado,%ImediatoCortado)
	
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

.macro transformarImediatoHexa (%imediatoCortado,%imediatoTransformado)

	Main:
		move $t0,%imediatoCortado
		move $t1,%imediatoTransformado
		lb $t4, 0($t0)
		li $t3, 0
		addi $t0,$t0,1
	Confere:
		lb $t2,0($t0)
		beqz $t2,ConferirNegativo
		ble $t2,57,TransformaDecimal
		ble $t2,70,TransformaMaiusculo
		j TransformaMinusculo
	TransformaDecimal:
		li $t5,0
		subi $t5,$t2,48
		or $t3,$t5,$t3
		j Intermediario
	TransformaMaiusculo:
		li $t5,0
		subi $t5,$t2,55
		or $t3,$t5,$t3
		j Intermediario
	TransformaMinusculo:
		li $t5,0
		subi $t5,$t2,87
		or $t3,$t5,$t3
		j Intermediario
	Intermediario:
		sll $t3,$t3,4
		addi $t0,$t0,1
		j Confere
	ConferirNegativo:
		beq $t4,49,ExtensaoSinal
		ori $t3,0x0000
		sw $t3,0($t1)
		j Exit
	ExtensaoSinal:
		sll $t3, $t3, 16              # Expande os 16 bits
        	sra $t3, $t3, 16              # Mantém o sinal
		sw $t3,0($t1)
	Exit:
		move $v0,$t3
		
	
.end_macro

.data
	Num1: .asciiz "10012"
	.align 2
	Num2: .space 50
.text
	la $a0,Num1
	la $a1,Num2
	transformarImediatoHexa $a0,$a1
	la $a0,Num2
	lw $a0,0($a0)
	
	li $v0,1
	syscall
	

		
