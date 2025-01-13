.macro printString (%string)
    move $t0, %string       # Mover o endereço do string para $t0
printLoop:
    lb $t1, 0($t0)          # Carregar o byte atual no $t1
    beqz $t1, printEnd      # Se o byte for zero, sair do loop
    move $a0, $t1           # Mover o caractere para $a0
    li $v0, 11             # Preparar para a chamada do syscall print_char
    syscall                 # Fazer a chamada do syscall
    addi $t0, $t0, 1        # Incrementar o ponteiro do string
    j printLoop             # Repetir o loop
printEnd:
.end_macro

.macro formatarInstrucaoArquivo (%endSemFormatacao, %endComFormatacao)
	.data
	quebraLinha:.asciiz"\n"
	.text
	
	Main:
		move $t0,%endSemFormatacao
		move $t1,%endComFormatacao
		li $t4,0 # flag para encontrar letra
		li $t5,0 # Contador de espaços colocados
		li $t6,32# ASCII ESPAÇO
		li $t7,44# ASCII Virgula
		li $t3,10 #ASCII Quebra de Linha
	Loop:
		lb $t2,0($t0)
		beq $t2,':',PularLabel
		beqz $t2,Confere2
		beq $t2,$t6,Pula
		beq $t2,$t7,Pula
		li $t4,1
		sb $t2,0($t1)
		addi $t0,$t0,1
		addi $t1,$t1,1
		j Loop
	PularLabel:
		sb $t3,0($t1)
		li $t5,0
		li $t4,0
		addi $t0,$t0,1
		addi $t1,$t1,1
		j Loop		
	Pula:
		beq $t4,1,ColocarCaract
		addi $t0,$t0,1
		j Loop
	ColocarCaract:
		beq $t5,7,Confere #Confere se existi mais caracteres depois do espaço, se tiver vai dar erro
		beq $t5,0,ColocarEspaco
		sb $t6,0($t1)
		sb $t7,1($t1)
		sb $t6,2($t1)
		addi $t0,$t0,1
		addi $t1,$t1,3
		addi $t5,$t5,3
		li $t4,0
		j Loop
	ColocarEspaco:
		sb $t6,0($t1)
		addi $t0,$t0,1
		addi $t1,$t1,1
		addi $t5,$t5,1
		li $t4,0
		j Loop
	Confere2:
		sb $zero,0($t1)
		j Exit
	Confere:
		addi $t0,$t0,1
		lb $t2,0($t0)
		beqz $t2,True
		bne $t2,$t6,RecomecarContagem
		j Confere
	True:
		sb $zero,0($t1)
		li $v0,1
		j Exit
	RecomecarContagem:
		li $t5,0
		li $t4,0
		j Loop
	Exit:
	
.end_macro
.data
text: .asciiz "addi  $t0,   $t1,  0x1\nlabel1:   andi  $t2,  $t3,   0xFF00\n ori  $t4,   $t5,  0x0F\nlabel2: ori  $t4,   $t5,  0x0F\nlabel3:    xori   $t6,   $t7,  0x0FFF\nlabel4:  lui $t8,   0x1234\nlabel5:   addi $t9,   $t0, 0x10\nlabel6: andi $s0,  $s1, 0xF0F0\nlabel7: ori  $s2, $s3, 0x00FF\nlabel8:  xori $s4,   $s5, 0xFF00\nlabel9:   lui   $s6,  0x5678\n"
textoComFormatacao: .space 100000
bufferContaInstrucao: .space 4


.text 

	la $a0,text
	la $a1,textoComFormatacao
	formatarInstrucaoArquivo $a0,$a1
	printString $a1
	

