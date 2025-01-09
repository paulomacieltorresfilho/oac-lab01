.macro formatarInstrucao (%endSemFormatacao , %endComFormatacao)

	MAIN:
		move $t0,%endSemFormatacao #coloca o endereço da string sem formatação em t0
		move $t1,%endComFormatacao #coloca o ender~ço da string com formatação em t1
		li $t2,0 #identifica a ocorrencio de caracter nao nulo
		
		LOOP:
			lb $a0,0($t0) #carrega o caractere em t0
			beqz $a0,EXIT #verifica se o caractere NULL
			beq $a0,' ',COLOCA_ESPACO #Confere se o caratctere e vazip
			sb $a0,0($t1) #Salva o caractere no %endComFormatação
			li $t2,1 #flag para identificar caractere sem ser espaço
			addi $t0,$t0,1 #passa para o proximo caractere de t0
			addi $t1,$t1,1 #passa para a proxima posição vazia de t1
			j LOOP
		COLOCA_ESPACO:
			beq $t2,0,CONTINUE #se so houver espaçoes em brancos ele vai para CONTINUE
			sb $a0,0($t1) #salva um caracter vazio em t1 (PARA DAS OS ESPAÇOS DA STRING FORMATADA")
			li $t2,0 #volta a flag para 0
			addi $t1,$t1,1 #passa para a proxima posição de t1
		CONTINUE:
			addi $t0,$t0,1 #atualizxa t0 para pegar o proximo caractere
			j LOOP	 #volta pro LOOP principal
	EXIT:
		sb $zero , 0($t1)
		
.end_macro 

.macro dividirInstrucao (%instrucaoAlvo, %instrucaoParte1, %instrucaoParte2, %instrucaoParte3, %instrucaoParte4) #Usar depois de formatar a instrução

	MAIN:
		move $t0,%instrucaoAlvo
		move $t1,%instrucaoParte1
		move $t2,%instrucaoParte2
		move $t3,%instrucaoParte3
		move $t4,%instrucaoParte4
	PRIMEIRA_PARTE:
		lb $a0,0($t0)
		beqz $a0,EXIT
		beq $a0,' ',SEGUNDA_PARTE_TRANSICAO
		sb $a0,0($t1)
		addi $t0,$t0,1
		addi $t1,$t1,1
		j PRIMEIRA_PARTE
	SEGUNDA_PARTE_TRANSICAO:
		sb $zero,0($t1)
		addi $t1,$t1,1
		addi $t0,$t0,1
	SEGUNDA_PARTE:
		lb $a0,0($t0)
		beqz $a0,EXIT
		beq $a0,' ',TERCEIRA_PARTE_TRANSICAO
		sb $a0,0($t2)
		addi $t0,$t0,1
		addi $t2,$t2,1
		j SEGUNDA_PARTE
	TERCEIRA_PARTE_TRANSICAO:
		sb $zero,0($t2)
		addi $t2,$t2,1
		addi $t0,$t0,3
	TERCEIRA_PARTE:
		lb $a0,0($t0)
		beqz $a0,EXIT
		beq $a0,' ',QUARTA_PARTE_TRANSICAO
		sb $a0,0($t3)
		addi $t0,$t0,1
		addi $t3,$t3,1
		j TERCEIRA_PARTE
	QUARTA_PARTE_TRANSICAO:
		sb $zero,0($t3)
		addi $t3,$t3,1
		addi $t0,$t0,3
	QUARTA_PARTE:
		lb $a0,0($t0)
		beqz $a0,EXIT
		sb $a0,0($t4)
		addi $t0,$t0,1
		addi $t4,$t4,1
		j QUARTA_PARTE
	EXIT:
		sb $zero,0($t4)
		add $t1,$t1,$zero
		add $t2,$t2,$zero
		add $t3,$t3,$zero
		add $t4,$t4,$zero
.end_macro


.data
	instrucaoSemFormatacao: .asciiz "    addi          $ra    ,      $rb "
	instrucaoComFormatacao: .space 32
	instrucaoParte1: .space 32
	instrucaoParte2: .space 32
	instrucaoParte3: .space 32
	instrucaoParte4: .space 32
	newline: .asciiz "\n"
	
.text
	la $s1, instrucaoSemFormatacao
	la $s2, instrucaoComFormatacao
	
	formatarInstrucao $s1,$s2
	la $s2,instrucaoComFormatacao
	la $s3, instrucaoParte1
	la $s4, instrucaoParte2
	la $s5, instrucaoParte3
	la $s6, instrucaoParte4
	
	dividirInstrucao $s2,$s3,$s4,$s5,$s6
	
	Loop1:
	
		lb $t1,0($s4)
		beqz $t1,loop2
		addi $s4,$s4,1
		j Loop1
		
	loop2:
	la $a0,instrucaoComFormatacao
	li $v0,4
	syscall
	
	la $a0, newline     # Endereço da quebra de linha em $a0
    	li $v0, 4           # Código do syscall para imprimir string
    	syscall
	
	la $a0,instrucaoParte1
	li $v0,4
	syscall
	
	la $a0, newline     # Endereço da quebra de linha em $a0
    	li $v0, 4           # Código do syscall para imprimir string
    	syscall
    	
	la $a0,instrucaoParte2
	li $v0,4
	syscall
	
	la $a0, newline     # Endereço da quebra de linha em $a0
    	li $v0, 4           # Código do syscall para imprimir string
    	syscall	
    		
	la $a0,instrucaoParte3
	li $v0,4
	syscall
	
	la $a0, newline     # Endereço da quebra de linha em $a0
    	li $v0, 4           # Código do syscall para imprimir string
    	syscall	
    	
	la $a0,instrucaoParte4
	li $v0,4
	syscall
	
	li $v0,10
	syscall
	
	
	
