.macro formatarInstrucao (%endSemFormatacao , %endComFormatacao)

	MAIN:
		move $t0,%endSemFormatacao
		move $t1,%endComFormatacao
		li $t2,0
		
		LOOP:
			lb $a0,0($t0)
			beqz $a0,EXIT
			beq $a0,' ',COLOCA_ESPACO
			sb $a0,0($t1)
			li $t2,1
			addi $t0,$t0,1
			addi $t1,$t1,1
			j LOOP
		COLOCA_ESPACO:
			beq $t2,0,CONTINUE
			sb $a0,0($t1)
			li $t2,0
			addi $t1,$t1,1
		CONTINUE:
			addi $t0,$t0,1
			j LOOP			
	EXIT:
		sb $zero , 0($t1)
		
.end_macro 



.data
	instrucaoSemFormatacao: .asciiz "    addi $ra ,      $rb  ,   0x1 "
	instrucaoComFormatacao: .space 32
	
.text
	la $s1, instrucaoSemFormatacao
	la $s2, instrucaoComFormatacao
	
	formatarInstrucao $s1,$s2
	la $a0,instrucaoComFormatacao
	li $v0,4 
	syscall
	
	li $v0,10
	syscall