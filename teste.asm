.macro cmp_string (%string1,%string2) #Verifica se duas string são iguais, se sim retorna 1 se não retorna 0
	
	MAIN:
		move $t0 , %string1 #coloca o endereço da string1 em t0
		move $t1 , %string2 #coloca o endereço da string2 em t1
		lb $a0 , 0($t0) #carrega o primeiro byte da string1 em a0
		lb $a1 , 0($t1) #carrega o primeirto byte da string2 em a1
	LOOP:
		bne $a0,$a1,DIFERENTE #verifica se as duas string sao diferentes
		beqz $a0,IGUAL
		addi $t0,$t0,1 #passa para o proximo caracter da string
		addi $t1,$t1,1 #passa para o proxima caracter da string
		lb $a0,0($t0) #carrega o proximo caracter em a0
		lb $a1,0($t1) #carrega o proxima caracter em a1
		j LOOP
	IGUAL:
		li $v0,1 #retorna 1
		j EXIT
	DIFERENTE:
		li $v0, 0#retorn 0
		j EXIT
	EXIT:

.end_macro

.data
	inst: .asciiz "addi"
.text
	la $s0,inst
	cmp_string ($t0,"addi")
	move $a0,$v0
	
	li $v0,1
	syscall
	
	
	
