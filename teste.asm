.macro printInt (%numero)

	move $a0,%numero
	li $v0,1
	syscall

.end_macro

.macro printString (%string)
    move $t0, %string       # Mover o endereço do string para $t0
printLoop:
    lb $t1, 0($t0)          # Carregar o byte atual no $t1
    beqz $t1,printEnd
    # Se o byte for zero, sair do loop
    move $a0, $t1           # Mover o caractere para $a0
    li $v0, 11             # Preparar para a chamada do syscall print_char
    syscall                 # Fazer a chamada do syscall
    addi $t0, $t0, 1        # Incrementar o ponteiro do string
    j printLoop             # Repetir o loop
printEnd:
.end_macro

.macro printChar %char
	move $a0,%char
	li $v0,11
	syscall
.end_macro


.macro formatarInstrucaoArquivoText (%instrucaoSemFormatacao , %instrucaoComFormatacao)

	move $t0,%instrucaoSemFormatacao
	move $t1,%instrucaoComFormatacao
	li $t3,0 #conta quantos simbolos ja coloquei
	li $t4,0
	li $t5,1
	
	Loop:
	lb $t2 , 0($t0)
	beqz $t2,Exit
	beq $t2,':',ColocaDoisPontos
	beq $t2,44,VerificaCaract
	beq $t2,32,VerificaCaract
	beq $t2,10,VerificaQuebraDeLinha
	sb $t2,0($t1)
	li $t4,1
	li $t5,0
	Atualiza:
	addi $t0,$t0,1
	addi $t1,$t1,1
	j Loop
	
	ColocaDoisPontos:
	sb $t2,0($t1)
	li $t2,10
	sb $t2,1($t1)
	addi $t0,$t0,1
	addi $t1,$t1,2
	li $t5,1
	li $t3,0
	li $t4,0
	j Loop
	
	VerificaCaract: #Verifica se tinha caracter antes de colocas os caracteres especiais
	beq $t4,1,ColocarCaract
	addi $t0,$t0,1
	j Loop
	
	ColocarCaract:
	beq $t3,0,InserirEspaco
	li $t2,32
	
	sb $t2,0($t1)
	li $t2,44
	
	sb $t2,1($t1)
	li $t2,32
	
	sb $t2,2($t1)
	addi $t3,$t3,3
	addi $t1,$t1,3
	addi $t0,$t0,1
	li $t4,0
	j Loop
	
	InserirEspaco:
	li $t2,32
	sb $t2,0($t1)
	addi $t3,$t3,1
	li $t4,0
	j Atualiza
	
	VerificaQuebraDeLinha:
	beq $t5,0,VerificaPosterior
	bne $t2,10,Loop
	addi $t0,$t0,1
	lb $t2,0($t0)
	li $t3,0
	li $t4,0
	j VerificaQuebraDeLinha
	
	VerificaPosterior:
	lb $t2,1($t0)
	bne $t2,10,ColocaQuebraDeLinha
	beqz $t2,Exit
	addi $t0,$t0,1
	j Loop
	
	ColocaQuebraDeLinha:
	li $t3,0
	li $t4,0
	li $t2,10
	sb $t2,0($t1)
	j Atualiza
	
	Exit:
		sb $zero,0($t1)
.end_macro


.macro concatTresStrings (%str1, %str2, %str3, %dest)
    # Copia a primeira string
    move $a0, %str1           # Endereço da primeira string
concat_copy1:
    lb $t0, 0($a0)            # Carrega o próximo caractere da string
    beqz $t0, insert_space1   # Se for nulo, vai para a próxima string
    sb $t0, 0(%dest)          # Salva no buffer de destino
    addi $a0, $a0, 1          # Avança na string
    addi %dest, %dest, 1      # Avança no buffer de destino
    j concat_copy1

insert_space1:
    li $t0, 32                # ASCII para espaço (' ')
    sb $t0, 0(%dest)          # Salva o espaço no buffer de destino
    addi %dest, %dest, 1

    # Copia a segunda string
    move $a0, %str2           # Endereço da segunda string
concat_copy2:
    lb $t0, 0($a0)
    beqz $t0, insert_space2
    sb $t0, 0(%dest)
    addi $a0, $a0, 1
    addi %dest, %dest, 1
    j concat_copy2

insert_space2:
    li $t0, 32
    sb $t0, 0(%dest)
    addi %dest, %dest, 1

    # Copia a terceira string
    move $a0, %str3           # Endereço da terceira string
concat_copy3:
    lb $t0, 0($a0)
    beqz $t0, end_concat_three
    sb $t0, 0(%dest)
    addi $a0, $a0, 1
    addi %dest, %dest, 1
    j concat_copy3

end_concat_three:
	li $t3,10
	sb $t3,0(%dest)
.end_macro

.macro concatDuasStrings %str1, %str2, %dest, %start_pos
    # Ajusta o ponteiro de destino para a posição inicial fornecida
    add %dest, %dest, %start_pos

    # Copia a primeira string
    move $a0, %str1           # Endereço da primeira string
concat_copy1:
    lb $t0, 0($a0)            # Carrega o próximo caractere da string
    beqz $t0, start_second_string # Se caractere for nulo, vai para a segunda string
    sb $t0, 0(%dest)          # Salva o caractere no buffer de destino
    addi $a0, $a0, 1          # Avança na string
    addi %dest, %dest, 1      # Avança no buffer de destino
    j concat_copy1

    # Copia a segunda string
start_second_string:
    move $a0, %str2           # Endereço da segunda string
concat_copy2:
    lb $t0, 0($a0)            # Carrega o próximo caractere da segunda string
    beqz $t0, add_newline     # Se caractere for nulo, vai adicionar '\n'
    sb $t0, 0(%dest)          # Salva o caractere no buffer de destino
    addi $a0, $a0, 1          # Avança na string
    addi %dest, %dest, 1      # Avança no buffer de destino
    j concat_copy2

    # Adiciona o caractere de quebra de linha
add_newline:
    # Retorna o endereço final no $v0
    move $v0, %dest
.end_macro

.macro pegarParte (%string,%offset,%enderecoSalvo)

	move $t0,%string
	move $t1,%offset
	move $t2,%enderecoSalvo
	li $t3,0
	li $t6,10
	add $t0,$t0,$t1
	move $t4,$t0
	li $t7,1
	VerificaLabel:
		lb $t5,0($t0)
		beqz $t5,Exit
		beq $t5,':',Pulalabel
		beq $t5,$t6,Verifica
		addi $t3,$t3,1
		addi $t0,$t0,1
		j VerificaLabel
	Pulalabel:
		addi $t3,$t3,1
		addi $t0,$t0,2
		move $t4,$t0
		li $t7,0
	Verifica:
		beq $t7,1,ZerarContador
		addi $t3,$t3,1
	PegarComando:
		lb $t5,0($t4)
		beqz $t5,Exit
		beq $t5,$t6,Exit
		sb $t5,0($t2)
		addi $t4,$t4,1
		addi $t2,$t2,1
		addi $t3,$t3,1
		j PegarComando
	ZerarContador:
		li $t3,0
		j PegarComando
	Exit:
		add $t3,$t3,$t1
		move $v0,$t3
.end_macro

.macro limpaMemoria (%endereco)
	
	Main:
		move $t0,%endereco
		li $t1,0
	Loop:
		lb $t2,0($t0)
		beqz $t2,Exit
		sb $t1,0($t0)
		addi $t0,$t0,1
		j Loop
	Exit:
.end_macro


.data
texto:   .asciiz "\n\n\n\n\n\n\n\deret\n\n\n\n\n\n\n\n\n\n\n\n \n \n \n addi  $t0,   $t1,  0x1\n  andi $t2, $t3,   0xFF00\n ori  $t4,   $t5,   0x0F\n   label1: xori  $t6,   $t7,  0x0FFF\n lui  $t8,  0x1234\n  addi   $t9,  $t0,   0x10\n  label2:  andi   $s0,  $s1,  0xF0F0\n\n\n\n\n\n\n\n\n\n\       \n\n\    \n\n  ori $s2,  $s3,  0x00FF\n  xori  $s4, $s5,   0xFF00\n  label3: lui  $s6,  0x5678\n  addi   $t1,   $t2,  0x5\n   andi   $t3, $t4,  0xA0A0\n ori $t5,   $t6,  0xFF\nxori  $t7,   $t8,   0x0B0B\n lui   $t9,  0x9876\n label4:  addi   $s0,  $s1,  0x3C\n  andi   $s2,   $s3,   0x1234\n ori $s4, $s5,   0xF00F\nxori   $s6,  $s7, 0x0C0C\n   lui  $t0,   0x4321\n   label5:  addi  $t1,  $t2,  0x44\n  andi $t3, $t4,  0xABCD\n ori   $t5,  $t6,   0x123\nxori  $t7,   $t8,  0x9876\n label6: lui   $t9,  0x0010\n  addi  $s0, $s1,   0x2F\n  andi   $s2,   $s3,  0x0D0D\n ori $s4,  $s5,   0xAA55\n  xori  $s6,  $s7,  0x55AA\n"
textoPrincipal: .space 1000
instrucao: .space 100000

.text
	la $a0,texto
	la $a1,textoPrincipal
	formatarInstrucaoArquivoText $a0,$a1
	printString $a1
 
