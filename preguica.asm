.macro printInt (%numero)

	move $a0,%numero
	li $v0,1
	syscall

.end_macro

.macro printChar %char
	move $a0,%char
	li $v0,11
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


.macro separarSecoes (%textoOriginal , %secaoData , %secaoText)

	move $t0,%textoOriginal
	move $t1,%secaoData
	
	EncontrarData:
	lb $t2,0($t0)
	beq $t2,'.',PularData
	addi $t0,$t0,1
	j EncontrarData
	
	PularData:
	addi $t0,$t0,5
	
	SalvarData:
	lb $t2,0($t0)
	beq $t2,'.',VerificaT
	sb $t2,0($t1)
	addi $t0,$t0,1
	addi $t1,$t1,1
	j SalvarData
	
	VerificaT:
	lb $t2,1($t0)
	beq $t2,'t',PularText
	addi $t0,$t0,1
	j SalvarData
	
	PularText:
	move $t1,%secaoText
	addi $t0,$t0,5
	
	SalvarText:
	lb $t2,0($t0)
	beqz $t2, Exit
	sb $t2,0($t1)
	addi $t0,$t0,1
	addi $t1,$t1,1
	j SalvarText
	
	Exit:
	
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
	li $t5,1
	li $t3,0
	li $t4,0
	li $t2,10
	sb $t2,0($t1)
	j Atualiza
	
	Exit:
		sb $zero,0($t1)
.end_macro

.macro pegarParte (%string,%offset,%enderecoSalvo)

	move $t0,%string
	lb $t1,0($t0)
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
    # Texto a ser separado
input: .asciiz "           .data\n    valor1: .word 10\n    valor2: .word 20\n    mensagem: .asciiz \"Olá, Mundo!\"\n\n.text\n    j label\n"

   
    dataLabel: .asciiz ".data"
    textLabel: .asciiz ".text"
    dataSection: .space 10000  # Espaço para armazenar a seção .data separada
    textSection: .space 10000  # Espaço para armazenar a seção .text separada
    textFormatado: .space 1000000
    inst: .space 1000000
.text

    main:
        la $a0, input          # Endereço da string de entrada
        la $a1, dataSection    # Endereço para armazenar a seção .data
        la $a2, textSection    # Endereço para armazenar a seção .text
        separarSecoes($a0, $a1, $a2)  # Chama a macro para separar as seções
        la $a0,textFormatado
        formatarInstrucaoArquivoText $a2,$a0
      	printString $a0

        la $a0,textFormatado
        la $a1,inst
        li $a2,0

   
        Loop:
        	pegarParte $a0,$a2,$a1
        Exit:
        		
     
	
	

	

		