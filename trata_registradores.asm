.data
	# formato: quantidade registradores, primeiro valor
	registradores_v: .byte '2', 0x2 # 2 registradores, primeiro é o 0x2
	registradores_a: .byte '4', 0x4 # 4 registradores, primeiro é o 0x4
	registradores_t: .byte '8', 0x8
	registradores_s: .byte '8', 0x10
	registradores_t_pt2: .byte '2', 0x18
	registrador_exemplo: .ascii "$a0"
	
.text

MAIN:
	la $a0, registrador_exemplo
	jal CONVERTE_REGISTRADOR
	move $s0, $v0
	
	li $v0, 10
	syscall

# a0: byte a ser convertido
# v0: valor númerico do byte
# CONVERTE_ASCII_NUM:
	# subi $v0, $a0, 0x30 # subtrai 00110000 para ter somente os 4 bits do número
	# jr $ra

# a0: endereco da string do registrador
# v0: valor em bytes do registrador
CONVERTE_REGISTRADOR:
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)

	move $t0, $a0 # endereco string
	lb $t1, 0($t0) # t1: registrador auxiliar para ler o caractere
	li $t9, '$' # t9: registrador para comparacoes
	bne $t1, $t9, ERROR # se não for $, lança erro
	
	# Trata primeiro caractere após $
	lb $t1, 1($t0)
	
	# Verifica se é 0
	li $t9, '0'
	beq $t1, $t9, ZERO
	li $t9, 'z'
	beq $t1, $t9, ZERO
	
	# Verifica se é V
	li $t9, 'v'
	beq $t1, $t9, CASE_REG_V
	
	# Verifica se é T
	li $t9, 't'
	beq $t1, $t9, CASE_REG_T
	
	# Verifica se é A
	li $t9, 'a'
	beq $t1, $t9, CASE_REG_A
	
	# Verifica se é S
	li $t9, 's'
	beq $t1, $t9, CASE_REG_S
	
	j ERROR
	

	# a0: endereco dos dados dos registadores
	LE_TERCEIRO_CARACTER:
		lb $t1, 2($t0)
		
		# verifica se o caractere é 0 ou maior
		li $t4, 0x30 # 0x30 é 0 em ascii
		sge $t5, $t1, $t4
		beqz $t5, ERROR
		
		# verifica se o caracter está dentro do range dos registradores do tipo (ex: s - 0 a 8)
		lb $t2, 0($a0)
		slt $t3, $t1, $t2 # se o o numero do terceiro caracter for menor que a quantidade de registradores do mesmo tipo, seta t3 para 1
		beqz $t3, ERROR

		# t3 e t4 = 1 -> seguir para transformar o caractere
		
		subi $t1, $t1, 0x30 # extrai valor do numero ascii
		lb $t2, 1($a0) # pega primeira posicao dos registradores do tipo
		
		add $v0, $t1, $t2 # coloca em v0 a soma da primeira posicao do registrador do tipo + o número auxiliar -> numero do registrador em bytes
		
		jr $ra
	
	ZERO:
		li $v0, 0
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_T:
		# Tratamento diferente por conta dos t8 e t9
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_V:
		la $a0, registradores_v
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_A:
		la $a0, registradores_a
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_S:
		la $a0, registradores_s
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
		
	ERROR:
		li $v0, -1
		j EXIT_CONVERTE_REGISTRADOR
		
	EXIT_CONVERTE_REGISTRADOR:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		addi $sp, $sp, 8
		jr $ra
	
	
