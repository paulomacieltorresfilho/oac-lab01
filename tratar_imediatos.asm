.macro printChar %char
	move $a0,%char
	li $v0,11
	syscall
.end_macro

.macro concatDuasStrings($str1, $str2, $destino)
    # Inicializar registradores
    move $t0, $str1              # $t0 aponta para a primeira string
    move $t1, $str2              # $t1 aponta para a segunda string
    move $t2, $destino           # $t2 aponta para o destino

    # Copiar a primeira string para o destino
ConcatenarPrimeira:
    lb $t3, 0($t0)               # Lê caractere da primeira string
    sb $t3, 0($t2)               # Escreve no destino
    beqz $t3, AdicionarSeparador # Se encontrar nulo, adicionar separador
    addi $t0, $t0, 1             # Avança na primeira string
    addi $t2, $t2, 1             # Avança no destino
    j ConcatenarPrimeira          # Continua copiando

    # Adicionar separador ": "
AdicionarSeparador:
    li $t3, ':'                  # Caractere ':'
    sb $t3, 0($t2)               # Adiciona ':' ao destino
    addi $t2, $t2, 1             # Avança no destino
    li $t3, ' '                  # Caractere espaço
    sb $t3, 0($t2)               # Adiciona espaço ao destino
    addi $t2, $t2, 1             # Avança no destino

    # Copiar a segunda string para o destino
ConcatenarSegunda:
    lb $t3, 0($t1)               # Lê caractere da segunda string
    sb $t3, 0($t2)               # Escreve no destino
    beqz $t3, FimConcatenar      # Se encontrar nulo, encerra
    addi $t1, $t1, 1             # Avança na segunda string
    addi $t2, $t2, 1             # Avança no destino
    j ConcatenarSegunda          # Continua copiando

    # Fim da macro
FimConcatenar:
.end_macro


.macro pegarInstrucao (%string,%offset,%enderecoSalvo)

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


.macro concatBuffer(%buffer, %string)
    # Encontra o final do buffer (localiza o último '\n' ou caractere nulo)
    move $t0, %buffer       # $t0 aponta para o início do buffer
find_end:
    lb $t1, 0($t0)          # Carrega o próximo byte
    beqz $t1, append        # Se for nulo, inicia a escrita
    addi $t0, $t0, 1        # Avança no buffer
    b find_end

append:
    # Escreve a string no final do buffer
    move $t2, %string       # $t2 aponta para o início da string
write_string:
    lb $t3, 0($t2)          # Carrega o próximo caractere da string
    beqz $t3, write_newline # Se for nulo, vai escrever o '\n'
    sb $t3, 0($t0)          # Salva o caractere no buffer
    addi $t2, $t2, 1        # Avança na string
    addi $t0, $t0, 1        # Avança no buffer
    b write_string

write_newline:
    li $t3, 10              # ASCII para '\n'
    sb $t3, 0($t0)          # Adiciona '\n' ao final
    addi $t0, $t0, 1        # Avança no buffer

    # Finaliza com nulo
    sb $zero, 0($t0)        # Adiciona caractere nulo ao final
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

.macro formatarInstrucao (%endSemFormatacao, %endComFormatacao)
	Main:
		move $t0,%endSemFormatacao
		move $t1,%endComFormatacao
		li $t4,0 # flag para encontrar letra
		li $t5,0 # Contador de espaços colocados
		li $t6,32# ASCII ESPAÇO
		li $t7,44# ASCII Virgula
	Loop:
		lb $t2,0($t0)
		beqz $t2,Confere2
		beq $t2,$t6,Pula
		beq $t2,$t7,Pula
		li $t4,1
		sb $t2,0($t1)
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
		li $v0,1
		j Exit
	Confere:
		addi $t0,$t0,1
		lb $t2,0($t0)
		beqz $t2,True
		bne $t2,$t6,Erro
	True:
		sb $zero,0($t1)
		li $v0,1
		j Exit
	Erro:
		li $v0,0
	Exit:
.end_macro


.macro dividirInstrucao (%instrucaoAlvo, %instrucaoParte1, %instrucaoParte2, %instrucaoParte3, %instrucaoParte4) # Dividi a instrucao em quatro partes

	MAIN:	
		move $t0,%instrucaoAlvo
		move $t1,%instrucaoParte1
	PrimeiraParte:
		lb $t2,0($t0)
		beqz $t2,Exit
		beq $t2,' ',Transicionar12
		sb $t2,0($t1)
		addi $t1,$t1,1
		addi $t0,$t0,1
		j PrimeiraParte
	Transicionar12:
		sb $zero,0($t1)
		addi $t0,$t0,1
		move $t1,%instrucaoParte2
	SegundaParte:
		lb $t2,0($t0)
		beqz $t2,Exit
		beq $t2,' ',Transicionar23
		sb $t2,0($t1)
		addi $t1,$t1,1
		addi $t0,$t0,1
		j SegundaParte
	Transicionar23:
		sb $zero,0($t1)
		addi $t0,$t0,3
		move $t1,%instrucaoParte3
	TerceiraParte:
		lb $t2,0($t0)
		beqz $t2,Exit
		beq $t2,' ',Transicionar34
		sb $t2,0($t1)
		addi $t1,$t1,1
		addi $t0,$t0,1
		j TerceiraParte
	Transicionar34:
		sb $zero,0($t1)
		addi $t0,$t0,3
		move $t1,%instrucaoParte4
	QuartaParte:
		lb $t2,0($t0)
		beqz $t2,Exit
		sb $t2,0($t1)
		addi $t1,$t1,1
		addi $t0,$t0,1
		j QuartaParte
	Exit:
		sb $zero,0($t1)
		
.end_macro

.macro cmp_string (%string1,%string2) #Verifica se duas string são iguais, se sim retorna 1 se não retorna 0
	
	MAIN:
		move $t0 , %string1 #coloca o endereço da string1 em t0
		move $t1 , %string2 #coloca o endereço da string2 em t1
		lb $t2 , 0($t0) #carrega o primeiro byte da string1 em a0
		lb $t3 , 0($t1) #carrega o primeirto byte da string2 em a1
	LOOP:
		bne $t2,$t3,DIFERENTE #verifica se as duas string sao diferentes
		beqz $t2,IGUAL
		addi $t0,$t0,1 #passa para o proximo caracter da string
		addi $t1,$t1,1 #passa para o proxima caracter da string
		lb $t2,0($t0) #carrega o proximo caracter em a0
		lb $t3,0($t1) #carrega o proxima caracter em a1
		j LOOP
	IGUAL:
		li $v0,1 #retorna 1
		j EXIT
	DIFERENTE:
		li $v0, 0#retorn 0
		j EXIT
	EXIT:

.end_macro

.macro isHexa (%numeroVerificado) #Verifica se o numero é um Hexadecimal
	
	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0)
		beq $t1,'-',Atualiza
		lb $t1,1($t0)
	Confere:
		beq $t1,'x',Confirm
		beq $t1,'X',Confirm
		li $v0,0
		j Exit
	Atualiza:
		lb $t1,2($t0)
		j Confere
	Confirm:
		li $v0,1
	Exit:
.end_macro

.macro isBinary(%numeroVerificado) #Verifica se o numero é um binário

	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0)
		beq $t1,'-',PulaCaract
		lb $t1,1($t0)
	Confere:
		beq $t1,'B',True
		beq $t1,'b',True
		li $v0,0
		j False
	PulaCaract:
		lb $t1,2($t0)
		j Confere
	False:
		li $v0,0
		j Exit
	True:
		li $v0,1
	Exit:
.end_macro

.macro validHexa (%numeroVerificado) #Verifica se o numero é um Hexadecimal Valido

	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0)
		beq $t1,'-',PulaCaract
		addi $t0,$t0,2
		li $t2,0
	Loop:
		lb $t1,0($t0)
		beqz $t1,True
		slti $t2,$t1,48
		beq $t2,1,Erro
		sgt $t2,$t1,57
		beq $t2,1,VerificaMaiusculo
		addi $t0,$t0,1
		j Loop
	VerificaMaiusculo:
		lb $t1,0($t0)
		slti $t2,$t1,65
		beq $t2,1,Erro
		sgt $t2,$t1,70
		beq $t2,1,VerificaMinusculo
		addi $t0,$t0,1
		j Loop
	VerificaMinusculo:
		lb $t1,0($t0)
		slti $t2,$t1,97
		beq $t2,1,Erro
		sgt $t2,$t1,102
		beq $t2,1,Erro
		addi $t0,$t0,1
		j Loop	
	PulaCaract:
		addi $t0,$t0,3
		j Loop
	Erro:
		li $v0,0
		j Exit
	True:
		li $v0,1
	Exit:
.end_macro

.macro validBinary (%numeroVerificado) #Verifica se o numero é um binario valido

	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0)
		beq $t1,'-',PulaCaract
		addi $t0,$t0,2
	Loop:
		lb $t1,0($t0)
		beqz $t1,True
		slti $t2,$t1,48
		beq $t2,1,Erro
		sgt $t2,$t1,49
		beq $t2,1,Erro
		addi $t0,$t0,1
		j Loop
	PulaCaract:
		addi $t0,$t0,3
		j Loop
	Erro:
		li $v0,0
		j Exit
	True:
		li $v0,1
	Exit:
	
.end_macro

.macro validDecimal (%numeroVerificado) #Verifica se o numero é um decimal valido
	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0)
		beq $t1,'-',PulaCaract
	Loop:
		lb $t1,0($t0)
		beqz $t1,True
		slti $t2,$t1,48
		beq $t2,1,Erro
		sgt $t2,$t1,57
		beq $t2,1,Erro
		addi $t0,$t0,1
		j Loop
	PulaCaract:
		addi $t0,$t0,1
		j Loop
	Erro:
		li $v0,0
		j Exit
	True:
		li $v0,1
	Exit:
.end_macro

.macro converteHexaBinario(%numeroVerificado, %numeroEscrito) # Converte uma string Hexadecimal "0x01" em Binário
    Main:
        move $t0, %numeroVerificado   # Endereço da string com "0x"
        move $t4, %numeroEscrito      # Endereço onde o binário será armazenado
        lb $t5, 0($t0)                # Lê o primeiro caractere
        beq $t5, '-', PulaCaract      # Verifica se há sinal negativo
        li $t5, 0                     # Inicializa sinal positivo
        addi $t0, $t0, 2              # Pula os dois primeiros caracteres "0x"

    AjustarParametro:
        li $t1, 0                     # Inicializa o acumulador para o valor binário

    HexaLoop:
        lb $t2, 0($t0)                # Lê um caractere da string
        beqz $t2, Verifica            # Se for nulo, finaliza o loop

        # Verifica se é um número (0-9)
        li $t3, '0'
        blt $t2, 'A', ConvertDigit    # Se for menor que 'A', é um dígito

        # Verifica se é uma letra maiúscula (A-F)
        li $t3, 'A'
        li $t6, 'F'
        ble $t2, $t6, ConvertUppercase

        # Verifica se é uma letra minúscula (a-f)
        li $t3, 'a'
        li $t6, 'f'
        ble $t2, $t6, ConvertLowercase

    ConvertDigit:
        subi $t2, $t2, '0'            # Converte de ASCII para número
        j CombineValue

    ConvertUppercase:
        sub $t2, $t2, 'A'             # Converte de ASCII para número (A-F)
        addi $t2, $t2, 10             # Ajusta para valores 10-15
        j CombineValue

    ConvertLowercase:
        sub $t2, $t2, 'a'             # Converte de ASCII para número (a-f)
        addi $t2, $t2, 10             # Ajusta para valores 10-15

    CombineValue:
        sll $t1, $t1, 4               # Desloca acumulador 4 bits à esquerda
        or $t1, $t1, $t2              # Combina o valor do dígito atual
        addi $t0, $t0, 1              # Avança para o próximo caractere
        j HexaLoop                    # Repete o loop

    PulaCaract:
        addi $t0, $t0, 3              # Pula "-0x"
        li $t5, 1                     # Marca sinal negativo
        j AjustarParametro

    Verifica:
        beq $t5, 1, Comp2             # Se for negativo, calcula complemento de 2
        sw $t1, 0($t4)                # Armazena o valor binário no endereço de saída
        j Exit

    Comp2:
        not $t1, $t1                  # Calcula complemento de 2
        addi $t1, $t1, 1
        sw $t1, 0($t4)                # Armazena o valor binário no endereço de saída
        
       Exit:

       
.end_macro


.macro converteBinarioBinario(%numeroVerificado, %enderecoEscrita) ) #Converte um string Binario "0b01" em Binario"
    Main:
        move $t0, %numeroVerificado   # Endereço da string com "0b"
        lb $t3,0($t0)
        beq $t3,'-',PulaCaract
        li $t3,0
        addi $t0, $t0, 2  # Pula os dois primeiros caracteres "0b"
    AjustaParametros: 
        move $t4, %enderecoEscrita    # Endereço de escrita
        li $t1, 0                     # Acumulador para o valor binário
    Loop:
        lb $t2, 0($t0)                # Lê um caractere da string
        beqz $t2, Verifica               # Se for nulo (final da string), sai do loop
        subi $t2, $t2, 48             # Converte de ASCII para número (0 ou 1)
        sll $t1, $t1, 1               # Desloca acumulador à esquerda (multiplica por 2)
        or $t1, $t1, $t2              # Adiciona o bit ao acumulador
        addi $t0, $t0, 1              # Avança para o próximo caractere
        j Loop                        # Recomeça o loop
    PulaCaract: 
    	li $t3,1
    	addi $t0,$t0,3
    	j AjustaParametros
    Verifica:
    	beq $t3,1,Comp2
        sw $t1, 0($t4)                # Escreve o número binário no endereço de saída
       	j Exit
     Comp2:
      	not $t1,$t1
      	addi $t1,$t1,1
      	sw $t1,0($t4)
      Exit:
.end_macro

.macro converteDecimalBinario (%numeroVerificado, %enderecoEscrita) #Converte um strin Decimal "10" em Binario"

    Main:
        move $t0, %numeroVerificado   # Endereço da string decimal
        li $t1, 0                     # Acumulador para o número decimal
        lb $t3,0($t0)
        beq $t3,'-',PulaDigito
	li $t3,0
    # Converter string decimal para inteiro
    ConvertToDecimal:
        lb $t2, 0($t0)                # Lê um caractere da string
        beqz $t2, Verifica        # Se for nulo (final da string), ir para armazenamento
        subi $t2, $t2, 48             # Converte caractere ASCII para número
        mul $t1, $t1, 10              # Multiplica acumulador por 10
        add $t1, $t1, $t2             # Adiciona o dígito ao acumulador
        addi $t0, $t0, 1              # Avança para o próximo caractere
        j ConvertToDecimal            # Continua processando a string
    # Armazenar o número decimal convertido
    PulaDigito:
    	addi $t0,$t0,1
    	li $t3,1
    	j ConvertToDecimal
    Verifica:
    	beq $t3,1,Comp2
    	j Exit
    Comp2:
    	not $t1,$t1
    	addi $t1,$t1,1
    Exit:
        sw $t1, 0(%enderecoEscrita)   # Salva o número decimal diretamente como uma word
.end_macro

.macro converteBinChar (%numeroBin, %escreveMemoria) #Converte um numero Binario em seu correspondente Hexadecimal"
	parte1:
		move $t0, %numeroBin
		move $t1, %escreveMemoria

		# Adiciona prefixo "0x" na memória
		li $t2, 48           # '0'
		li $t3, 120          # 'x'
		sb $t2, 0($t1)       # Armazena '0'
		sb $t3, 1($t1)       # Armazena 'x'
		addi $t1, $t1, 2     # Avança o ponteiro para a memória

		li $t2, 28           # Começa no bit mais significativo (28)

	parte2: # Loop principal
		srlv $t3, $t0, $t2    # Desloca o dígito mais significativo para os 4 bits menos significativos
		andi $t3, 0xF        # Isola os 4 bits menos significativos

		blt $t3, 10, parte3      # Se $t3 < 10, vai para números
		addi $t3, $t3, 87    # Converte para letras minúsculas ('a' a 'f')
		j parte4

	parte3: # Transformar para número
		addi $t3, $t3, 48    # Converte para caracteres ('0' a '9')

	parte4: # Salvar o caractere
		sb $t3, 0($t1)       # Armazena o caractere na memória
		addi $t1, $t1, 1     # Avança para o próximo caractere

		subi $t2, $t2, 4     # Avança para o próximo dígito
		bgez $t2, parte2         # Repete enquanto $t2 >= 0

		# Finaliza a string com nulo
		li $t3, 0
		sb $t3, 0($t1)
.end_macro

.macro montadorTipoI (%opCode,%rs,%rt,%imediato,%enderecoEscrita) # Constroi o binario do montador tipo I

	Main:
		move $t0,%enderecoEscrita
		move $t1,%opCode
		move $t2,%rs
		move $t3,%rt
		move $t4,%imediato
		
		lw $t2,0($t2)
		lw $t3,0($t3)
		lw $t4,0($t4)
		li $t5,0
		add $t5,$t5,$t4
	AcresencetarImediato:
		andi $t5,$t5,0x0000ffff
	AcrescentarRt:
		sll $t3,$t3,16
		or $t5,$t3,$t5
	AcrescentarRs:
		sll $t2,$t2,21
		or $t5,$t2,$t5
	Acrescetar0p:
		sll $t1,$t1,26
		or $t5,$t1,$t5
	Salvar:
		sw $t5,0($t0)
	
.end_macro

.macro montarImediatoBinario (%imediato,%binarioInstrucao)
	Main:
		move $a0,%imediato
		move $a2,%binarioInstrucao
		isBinary $a0
		beq $v0,1,TratarBinario
		isHexa $a0
		beq $v0,1,TratarHexa
	
	TratarInteiro:
		validDecimal $a0
		beq $v0,0,Erro
		converteDecimalBinario $a0,$a2
		li $v0,1
		j Exit
	TratarBinario:
		validBinary $a0
		beq $v0,0,Erro
		converteBinarioBinario $a0,$a2
		li $v0,1
		j Exit
	TratarHexa:
		validHexa $a0
		beq $v0,0,Erro
		converteHexaBinario $a0,$a2
		li $v0,1
		j Exit
	Erro:
		li $v0,0
	Exit:
.end_macro

.macro formarInstrucao (%montadorBinario,%instrucaoFormatada,%enderecoSalvar) # Constroi a instrucao para salvar no arquivo .MIF e grava em um local
	Main:
		move $t0,%montadorBinario
		move $t1,%instrucaoFormatada
		move $t2,%enderecoSalvar
	ColocarMontador:
		lb $t3,0($t0)
		beqz $t3,ColocarEspaco
		sb $t3,0($t2)
		addi $t0,$t0,1
		addu $t2,$t2,1
		j ColocarMontador
	ColocarEspaco:
		addi $t2,$t2,1
		li $t3,' ' 
		sb $t2,0($t2)
		addi $t2,$t2,1
	ColocarInstrucao:
		lb $t3,0($t1)
		move $a0,$t3
		li $v0,1
		syscall
		beqz $t1,Exit
		sb $t3,0($t2)
		addi $t1,$t1,1
		addi $t2,$t2,1
		j ColocarInstrucao
	Exit:
		li $t3,10
		sb $t3,0($t0)
.end_macro

.macro copyString(%string,%enderecoSalvo)

	Main:
		move $t0,%string
		move $t1,%enderecoSalvo
	Loop:
		lb $t2,0($t0)
		beqz $t2,Exit
		sb $t2,0($t1)
		addi $t1,$t1,1
		addi $t0,$t0,1
		j Loop
	Exit:
		sb $zero,0($t1)
.end_macro

.macro limparRegistradores
	Main:
   	 # Limpar $s0-$s7
    		 li $t0, 16             # Número base para $s0 (16 = número do registrador $s0)
  		 li $t1, 24             # Limite para $s7 (24 = número do registrador $s7 + 1)
	LimparS:
    		move $t2, $zero
    		addu $t3, $t0, $zero   # Copia o índice atual
    		mtc0 $t2, $t3          # Move zero para registrador $sX
    		addi $t0, $t0, 1       # Incrementa o índice
    		blt $t0, $t1, LimparS  # Continua até $s7

    		# Limpar $a0-$a3
    		li $t0, 4              # Número base para $a0 (4 = número do registrador $a0)
    		li $t1, 8              # Limite para $a3 (8 = número do registrador $a3 + 1)
	LimparA:
    		move $t2, $zero
    		addu $t3, $t0, $zero   # Copia o índice atual
    		mtc0 $t2, $t3          # Move zero para registrador $aX
    		addi $t0, $t0, 1       # Incrementa o índice
    		blt $t0, $t1, LimparA  # Continua até $a3
.end_macro

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

.macro checkSpace (%string)
    move $t0, %string       # Mover o endereço do string para $t0
    li $t2, 32              # Carregar o valor ASCII do espaço (' ') em $t2
    li $t3, 0               # Inicializar $t3 com 0 (flag de ocorrência)
checkLoop:
    lb $t1, 0($t0)          # Carregar o byte atual na string para $t1
    beqz $t1, checkEnd      # Se for zero (fim da string), sair do loop
    beq $t1, $t2, foundSpace # Se o caractere for espaço, saltar para foundSpace
    addi $t0, $t0, 1        # Incrementar o ponteiro do string
    j checkLoop             # Repetir o loop
foundSpace:
    li $t3, 1               # Se encontrar um espaço, definir flag para 1
checkEnd:
    move $a0,$t3
    li $v0,1
    syscall 
    
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

.macro separarImediatos (%imediato1,%imediato2)

	move $t0,%imediato1
	move $t1,%imediato2
	lw $t2,0($t0)
	move $t3,$t0
	
	srl $t0,$t0,16
	lw $t2,0($t0)
	andi $t3,0x0000ffff
	lw $t3,0($t1)

.end_macro

.macro printInt (%numero)

	move $a0,%numero
	li $v0,1
	syscall

.end_macro

.macro montadorTipoR (%opCode , %rs ,%rt ,%rd ,%shamt,%funct,%endereco)

	move $t1,%opCode
	move $t2,%rs
	move $t3,%rt
	move $t4,%rd
	move $t5,%shamt
	move $t6,%funct
	move $t7,%endereco
	
	lw $t2,0($t2)
	lw $t3,0($t3)
	lw $t4,0($t4)
	lw $t5,0($t5)
	
	GravarOpCode:
		andi $t1,0x0000003f
		sll $t1,$t1,26
	GravarRs:
		sll $t2,$t2,21
		or $t1,$t1,$t2
	GravarRT:
		sll $t3,$t3,16
		or $t1,$t1,$t3
	GravarRd:
		sll $t4,$t4,11
		or $t1,$t1,$t4
	GravarShamt:
		sll $t5,$t5,6
		or $t1,$t1,$t5
	GravarFunct:
		or $t1,$t1,$t6
	sw $t1,0($t7)
.end_macro

.macro validNumber(%number)
	move $t0,%number
	lbu $t0,0($t0)
	beq $t0,0x24,False
	j True
	False:
	li $v0,0
	j Exit
	True:
	li $v0,1
	Exit:
.end_macro


.data
############### Instruções gerais ############################################################################	
   	input: .asciiz  "..data\n   valor1: .word 10\n    valor2: .word 20\n    mensagem: .asciiz \"Olá, Mundo!\"\n\n.text   addi  $t0,   $t1,  0x1\n  andi $t2, $t3,   0xFF00\n ori  $t4,   $t5,   0x0F\n   label1: xori  $t6,   $t7,  0x0FFF\n lui  $t8,  0x1234\n  addi   $t9,  $t0,   0x10\n  label2:  andi   $s0,  $s1,  0xF0F0\n ori $s2,  $s3,  0x00FF\n  xori  $s4, $s5,   0xFF00\n  label3: lui  $s6,  0x5678\n  addi   $t1,   $t2,  0x5\n   andi   $t3, $t4,  0xA0A0\n ori $t5,   $t6,  0xFF\nxori  $t7,   $t8,   0x0B0B\n lui   $t9,  0x9876\n label4:  addi   $s0,  $s1,  0x3C\n  andi   $s2,   $s3,   0x1234\n ori $s4, $s5,   0xF00F\nxori   $s6,  $s7, 0x0C0C\n   lui  $t0,   0x4321\n   label5:  addi  $t1,  $t2,  0x44\n  andi $t3, $t4,  0xABCD\n ori   $t5,  $t6,   0x123\nxori  $t7,   $t8,  0x9876\n label6: lui   $t9,  0x0010\n  addi  $s0, $s1,   0x2F\n  andi   $s2,   $s3,  0x0D0D\n ori $s4,  $s5,   0xAA55\n  xori  $s6,  $s7,  0x55AA\n.text"

	inputData: .space 20000
	inputText: .space 20000
	outputText: .space 20000
################## Instruções Imediatas ##########################################################################
	inst_addi: .asciiz "addi"
	inst_andi: .asciiz "andi"
	inst_ori: .asciiz "ori"
	inst_xori: .asciiz "xori"
	inst_slti: .asciiz "slti"
	inst_lui: .asciiz "lui"
################# Instruções Tipo R ################################################################################
	inst_add: .asciiz "add"
	inst_sub: .asciiz "sub"
	inst_and: .asciiz "and"
	inst_or:  .asciiz "or"
	inst_nor: .asciiz "nor"
	inst_xor: .asciiz "xor"
	inst_mult: .asciiz "mult"
	inst_div: .asciiz "div"
	inst_mfhi: .asciiz "mfhi"
	inst_mflo: .asciiz "mflo"
	inst_clo: .asciiz "clo"
	inst_clz: .asciiz "clz"
	inst_divu: .asciiz "divu"
	inst_deret: .asciiz "deret"
################## Partes da Instrução ############################################################################	
	instrucaoComFormatacao: .space 20000
	instrucaoParte0:  .space 100
	instrucaoParte1:  .space 100 #Sempre vai ser a instruçao
	instrucaoParte2: .space 100 #Sepre vai ser um registrador
	instrucaoParte3: .space 100 #Pode ser um registrador ou imediato
	instrucaoParte4: .space 100 #Pode ser um registrador ou imediato
	instrucaoMontada: .space 100
	montadorHexadecimal: .space 100
	numeroInstrucao: .space 100
#################### Parametros Montador ########################################################################
	.align 2
	rs: .space 4 # Parametro RS do montador
	.align 2
	rt: .space 4 # Parametro RT do montador
	.align 2
	rd: .space 4 # Parametro RD do montador
	.align 2
	shamt: .space 4
	.align 2
	funct: .space 4
	.align 2
	imediato: .space 4 #Parametro Imediato do montador
	.align 2
	imediato2: .space 4
	.align 2
	montadorBinario:.space 4 # Montador da instruçao em binario
############################ Buffer de Controles ###############################################################

	.align 2
	bufferPosicaoInstrucao: .word 0
	.align 2
	bufferNumeroInstrucao: .word 0
	.align 2
	bufferEnderecoConjunto: .space 4
	
####################### Erros ###################################################################################	
	Erro_imediato: .asciiz "Imediato Invalido \n" # aparece casa o montador seja invalido
	Erro_instrucao: .asciiz "Instrucão Invalida \n"
########################  Registradosres ###########################################################################	
# formato: quantidade registradores, primeiro valor
	registradores_v: .byte '2', 0x2 # 2 registradores, primeiro é o 0x2
	registradores_a: .byte '4', 0x4 # 4 registradores, primeiro é o 0x4
	registradores_t: .byte '8', 0x8
	registradores_s: .byte '8', 0x10
	registradores_k: .byte '2', 0x1a
	registrador_at : .asciiz "$at"
#####################################################################################################################
.text
	
	FormatarInstrucao:
		la $a0,input   ### Entrada de texto do arquivi .asm
		la $a1,inputData ### Local onde vai armazenar as strings referentes ao .data
		la $a2,inputText ### Local onde vai armazenar as strings referentes ao .text
		separarSecoes $a0,$a1,$a2 ### Separa as seções .data e .text
		la $a0,instrucaoComFormatacao ### Local onde vai ser salvo as intrucoes seguindo um padrão de formatação
		formatarInstrucaoArquivoText $a2,$a0 ### Formata a seção de instrucao e salva no local de memoria Instrucao com Formatacao
		la $t0,outputText
		la $t1,bufferEnderecoConjunto
		sw $t0,0($t1)
	
		
	PegarInstrucao:
		la $a0,bufferPosicaoInstrucao
		lw $a1, 0($a0)
		la $a2, instrucaoParte0
		la $a3, instrucaoComFormatacao
		pegarInstrucao $a3,$a1,$a2
		beq $a1,$v0,Exit
		la $a0,bufferPosicaoInstrucao
		addi $v0,$v0,1
		lw $v0,0($a0)
	
	DividiInstrucao:
		la $a0,instrucaoParte1
		la $a1,instrucaoParte2
		la $a2,instrucaoParte3
		la $a3,instrucaoParte4
		la $t0,instrucaoParte0
		dividirInstrucao $t0,$a0,$a1,$a2,$a3
		
	CompararInstrucoes:
		
		la $a0,instrucaoParte1
		
		la $a1,inst_addi #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_addi # Vai formar o montador da instrucao
		
		la $a1,inst_andi #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_andi # Vai formar o montador da instrucao
		
		la $a1,inst_ori #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_ori # Vai formar o montador da instrucao
		
		la $a1,inst_xori #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_xori # Vai formar o montador da instrucao

		la $a1,inst_slti #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_slti # Vai formar o montador da instrucao
		
		la $a1,inst_lui #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_lui # Vai formar o montador da instrucao
		
		la $a1,inst_add #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Add # Vai formar o montador da instrucao
		
		la $a1,inst_sub #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Sub # Vai formar o montador da instrucao

		la $a1,inst_and #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_And # Vai formar o montador da instrucao
		
		la $a1,inst_or #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Or # Vai formar o montador da instrucao		

		la $a1,inst_nor #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Nor # Vai formar o montador da instrucao

		la $a1,inst_xor #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Xor # Vai formar o montador da instrucao	
		
		la $a1,inst_mult #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Mult # Vai formar o montador da instrucao	
		
		la $a1,inst_div #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Div # Vai formar o montador da instrucao	

		la $a1,inst_mfhi #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Mfhi # Vai formar o montador da instrucao
		
		la $a1,inst_mflo #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Mflo # Vai formar o montador da instrucao
		
		la $a1,inst_clo #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Clo# Vai formar o montador da instrucao	
		
		la $a1,inst_clz #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Clz# Vai formar o montador da instrucao	

		la $a1,inst_divu #carrega a instrucao para comparar com a0
		cmp_string $a0,$a1 #compara as duas instrucoes
		beq $v0,1,Case_Divu# Vai formar o montador da instrucao				

	Case_addi:
		li $s0, 0x08 #Carrega o op code
		la $a0, instrucaoParte3
		jal CONVERTE_REGISTRADOR 
		la $t1 , rs
		sw $v0,0($t1)
		la $a0, instrucaoParte2
		jal CONVERTE_REGISTRADOR
		la $t1 , rt
		sw $v0,0($t1) 
		j MontarInstrucaoI
	Case_andi:
		li $s0, 0x0C #Carrega o op code
		la $a0, instrucaoParte3
		jal CONVERTE_REGISTRADOR 
		la $t1 , rs
		sw $v0,0($t1)
		la $a0, instrucaoParte2
		jal CONVERTE_REGISTRADOR
		la $t1 , rt
		sw $v0,0($t1) 
		j MontarInstrucaoI
	Case_ori:
		li $s0, 0x0D #Carrega o op code
		la $a0, instrucaoParte3
		jal CONVERTE_REGISTRADOR 
		la $t1 , rs
		sw $v0,0($t1)
		la $a0, instrucaoParte2
		jal CONVERTE_REGISTRADOR
		la $t1 , rt
		sw $v0,0($t1) 
		j MontarInstrucaoI
	Case_xori:
		li $s0, 0x0E #Carrega o op code
		la $a0, instrucaoParte3
		jal CONVERTE_REGISTRADOR 
		la $t1 , rs
		sw $v0,0($t1)
		la $a0, instrucaoParte2
		jal CONVERTE_REGISTRADOR
		la $t1 , rt
		sw $v0,0($t1) 
		j MontarInstrucaoI
	Case_slti:
		li $s0, 0x0A #Carrega o op code
		la $a0, instrucaoParte3
		jal CONVERTE_REGISTRADOR 
		la $t1 , rs
		sw $v0,0($t1)
		la $a0, instrucaoParte2
		jal CONVERTE_REGISTRADOR
		la $t1 , rt
		sw $v0,0($t1) 
		j MontarInstrucaoI
	Case_lui:
		li $s0, 0x0F
		la $a0,instrucaoParte3
		la $a1,instrucaoParte4
		limpaMemoria $a1
		copyString $a0,$a1
		la $a0, instrucaoParte2
		la $t1 , rt
		jal CONVERTE_REGISTRADOR
		sw $v0,0($t1)
		j MontarInstrucaoI
		
	Case_Add:
		la $a1,instrucaoParte4
		validNumber $a1
		beq $v0,1,Case_addi
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x20 # Funct
		j MontarInstrucaoR

	Case_Sub:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x22 # Funct
		j MontarInstrucaoR

	Case_And:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x24 # Funct
		j MontarInstrucaoR

	Case_Or:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x25 # Funct
		j MontarInstrucaoR

	Case_Nor:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x27 # Funct
		j MontarInstrucaoR
		
	Case_Xor:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x26 # Funct
		j MontarInstrucaoR
		
	Case_Mult:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x18 # Funct
		j MontarInstrucaoR
		
	Case_Div:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x1A # Funct
		j MontarInstrucaoR

	Case_Mfhi:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rs na memoria
		li $s0,0x0 # OpCode
		li $s5,0x10 # Funct
		j MontarInstrucaoR
		
	Case_Mflo:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rs na memoria
		li $s0,0x0 # OpCode
		li $s5,0x12 # Funct
		j MontarInstrucaoR
		
	Case_Clo:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x01C # OpCode
		li $s5,0x21 # Funct
		j MontarInstrucaoR
	
	Case_Clz:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x01c # OpCode
		li $s5,0x20 # Funct
		j MontarInstrucaoR

	Case_Divu:
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x1B # Funct
		j MontarInstrucaoR
		
	Case_Addu:
		la $a1,instrucaoParte4
		validNumber $a1
		beq $v0,1,QuebraInstrucao
		la $a0,instrucaoParte2 
		jal CONVERTE_REGISTRADOR
		la $t1,rd
		sw $v0,0($t1) #### Salva o rd na memoria
		la $a0,instrucaoParte3
		jal CONVERTE_REGISTRADOR
		la $t1,rs
		sw $v0,0($t1) #### Salva o rs na memoria
		la $a0,instrucaoParte4
		jal CONVERTE_REGISTRADOR
		la $t1,rt
		sw $v0,0($t1) #### Salva o rt na memoria
		li $s0,0x0 # OpCode
		li $s5,0x20 # Funct
		j MontarInstrucaoR
	
	QuebraInstrucao:
		li $s7,1
		la $a0,instrucaoParte4
		la $a1,imediato
		la $a2,imediato2
		montarImediatoBinario $a0,$a1
		separarImediatos $a1,$a2
		la $t0, rt
		li $t1, 1
		lw $t1,0($t0)
		la $t0,rs
		lw $zero,0($t0)
		li $s0, 0x0F
		jal MontadorI
		li $t1,1
		la $t0,rs
		lw $t1,0($t0)
		li $s0, 0x0D
		la $t0,imediato2
		la $t1,imediato
		lw $t0,0($t1)
		jal MontadorI
		li $s7 , 0
		la $a0 , instrucaoParte4
		limpaMemoria $a0
		la $t0,registrador_at
		copyString $t0,$at
		j CompararInstrucoes
		
	MontarInstrucaoI:
		# Montar Imediado
		la $a0,instrucaoParte4 # Aonde o imediato fica salvo
		la $a1,imediato # Aonde o imediato vai ser salvo
		montarImediatoBinario $a0,$a1
		lw $t0,0($a1)
		sgt $t1,$t0,0x00007fff
		beq $t1,1,QuebraInstrucao
		beq $v0,0,Erro_Imediato #Verifica se teve erro de imediato invalido
	MontadorI:
		#Carregar Paramentros
		la $s1, rs
		la $s2, rt
		la $s3, imediato
		la $a1,montadorBinario #Aonde a instrucao vai ser salva em Binario_
		montadorTipoI $s0,$s1,$s2,$s3,$a1
		beq $s7,1,Voltar
		j MontarBinarioChar
	Voltar:
		jr $ra

	MontarInstrucaoR:
		la $s1,rs
		la $s2,rt
		la $s3,rd
		la $s4,shamt
		la $s5,montadorBinario
		montadorTipoR $s0,$s1,$s2,$s3,$s4,$s5,$s5
		lw $t0,0($s5)
	j MontarBinarioChar
		
	Erro_Instrucao:
		la $a0,Erro_instrucao #carregar o erro
		la $a1,instrucaoMontada #carregar aonde seria colocada a instrucao
		printString $a0
		j Exit
		copyString $a0,$a1 #Salvar o erro onde seria coloca a instrucao
		printString $a0
		j Exit
	Erro_Imediato:
		la $a0,Erro_imediato #carregar o erro
		la $a1,instrucaoMontada #carregar aonde seria colocada a instrucao
		copyString $a0,$a1 #Salvar o erro onde seria coloca a instrucao
	
	MontarBinarioChar:
		la $a0,montadorBinario
		lw $a0,0($a0)
		la $a1,montadorHexadecimal
		converteBinChar $a0,$a1
		la $a1,montadorHexadecimal
		la $a2,bufferNumeroInstrucao
		lw $a0,0($a2)
		addi $a0,$a0,1
		sw $a0,0($a2)
		la $a1,numeroInstrucao
		converteBinChar $a0,$a1
		
	FormarInstrucao:
		la $a0,numeroInstrucao
		la $a1 montadorHexadecimal
		la $a3,instrucaoMontada
		concatDuasStrings $a0,$a1,$a3,
	IncluirInstrucao:
		la $a1,outputText
		la $a2,instrucaoMontada
		concatBuffer $a1,$a2
	Verifica:
		jal LIMPA_GERAL
		j PegarInstrucao
		
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
	
	# Verifica se o registrador é apenas numérico (ex: $8, $1, $0)
	li $t2, '0'
	sge $t3, $t1, $t2 # t3 -> 1 se t1 for maior ou igual a '0'
	
	li $t2, '9'
	sle $t4, $t1, $t2 # t4 -> 1 se t1 for menor ou igual a '9'
	
	and $t5, $t3, $t4 # t5 -> 1 se o caracter estiver entre '0' e '9'
	bnez $t5, CASE_REG_NUM
	
	# Verifica se é 0
	li $t9, 'z'
	beq $t1, $t9, CASE_ZERO
	
	# Verifica se é v
	li $t9, 'v'
	beq $t1, $t9, CASE_REG_V
	
	# Verifica se é t
	li $t9, 't'
	beq $t1, $t9, CASE_REG_T
	
	# Verifica se é a
	li $t9, 'a'
	beq $t1, $t9, CASE_REG_A
	
	# Verifica se é s
	li $t9, 's'
	beq $t1, $t9, CASE_REG_S
	
	# Verifica se é k
	li $t9, 'k'
	beq $t1, $t9, CASE_REG_K
	
	# Verifica se é r
	li $t9, 'r'
	beq $t1, $t9, CASE_REG_R
	
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
	
	CASE_ZERO:
		li $v0, 0
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_NUM:
		subi $t2, $t1, 0x30 # t2 recebe valor inteiro do ascii do segundo byte do nome do registrador
		
		lb $t1, 2($t0) # terceiro byte do registrador
		beqz $t1, CASE_REG_NUM_UM_DIG # Se terceiro caracter for \0 (não existir)
		
		beqz $t2, ERROR # Se o valor do segundo byte for 0, 3° caracter nao de existir
		
		li $t4, 4
		bge $t2, $t4, ERROR # Se 3° caracter nao deve existir, ir para erro
		
		li $t4, 3
		beq $t2, $t4, CASE_REG_NUM_2_DIG_30
		
		j CASE_REG_NUM_2_DIG
	
	CASE_REG_NUM_UM_DIG:
		move $v0, $t2
		j EXIT_CONVERTE_REGISTRADOR
	
	CASE_REG_NUM_2_DIG:
		#$t2 -> valor primeiro byte
		#$t1 -> ascii segundo byte
		li $t3, '0'
		sge $t4, $t1, $t3 # t4 1 -> se t1 for maior ou igual a 0
		
		li $t3, '9'
		sle $t5, $t1, $t3 # t5 1 -> se t1 for menor ou igual a 9
		
		and $t6, $t5, $t4 # 1 se estiver no range
		beqz $t6, ERROR # se não estiver no range, lançar error
		
		subi $t1, $t1, 0x30 # valor númerico segundo byte
		
		li $t3, 10
		mult $t2, $t3
		
		mflo $t2 # salva em t2 a multiplicacao de t2*10
		add $v0, $t2, $t1
		
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_NUM_2_DIG_30:
		li $t3, '0'
		blt $t1, $t3, ERROR
		
		li $t3, '1'
		bgt $t1, $t3, ERROR
		
		subi $t1, $t1, 0x30 # valor númerico segundo byte
		
		li $t3, 10
		mult $t2, $t3
		
		mflo $t2 # salva em t2 a multiplicacao de t2*10
		add $v0, $t2, $t1
		j EXIT_CONVERTE_REGISTRADOR
		
		
	CASE_REG_T:
		# Tratamento diferente por conta dos t8 e t9
		
		lb $t1, 2($t0) # terceiro byte
		
		li, $t2, '8'
		beq $t1, $t2, CASE_REG_T8
		
		li, $t2, '9'
		beq $t1, $t2, CASE_REG_T9
		
		la $a0, registradores_t
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_T8:
		li $v0, 24
		j EXIT_CONVERTE_REGISTRADOR
	
	CASE_REG_T9:
		li $v0, 25
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_V:
		la $a0, registradores_v
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_A:
		lb $t1, 2($t0)
		li $t2, 't'
		beq $t1, $t2, CASE_REG_AT # Verifica se registrador é at
	
		la $a0, registradores_a
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
	
	CASE_REG_AT:
		li $v0, 1
		j EXIT_CONVERTE_REGISTRADOR
	
	CASE_REG_K:
		la $a0, registradores_k
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
	
	CASE_REG_R:
		lb $t1, 2($t0)
		li $t2, 'a'
		beq $t1, $t2, CASE_REG_RA # Verifica se registrador é ra
		
		j ERROR
	
	CASE_REG_RA:
		li $v0, 31
		j EXIT_CONVERTE_REGISTRADOR
		
	CASE_REG_S:
	
		lb $t1, 2($t0)
		li $t2, 'p'
		beq $t1, $t2, CASE_REG_SP  # verifica se registrador é o $sp
	
		la $a0, registradores_s
		jal LE_TERCEIRO_CARACTER
		j EXIT_CONVERTE_REGISTRADOR
	
	CASE_REG_SP:
		li $v0, 29
		j EXIT_CONVERTE_REGISTRADOR
		
	ERROR:
		li $v0, -1
		j EXIT_CONVERTE_REGISTRADOR
		
	EXIT_CONVERTE_REGISTRADOR:
		lw $ra, 0($sp)
		lw $a0, 4($sp)
		addi $sp, $sp, 8
		jr $ra
	
	LIMPA_GERAL:
		
		la $a0,outputText
		li $v0,4
		
		la $a0,instrucaoParte0
		la $a1,instrucaoParte1
		la $a2,instrucaoParte2
		la $a3,instrucaoParte4
		la $s0,imediato
		la $s1,imediato2
		la $s2,montadorBinario
		la $s3,instrucaoMontada
		la $s5,montadorHexadecimal
		
		limpaMemoria $a0
		limpaMemoria $a1
		limpaMemoria $a2
		limpaMemoria $a3
		limpaMemoria $s0
		limpaMemoria $s1
		limpaMemoria $s2
		limpaMemoria $s3
		limpaMemoria $s5
		
		la $a0,rs
		la $a1,rt
		la $a2,rd
		la $a3,shamt
		
		lw $zero,0($a0)
		lw $zero,0($a1)
		lw $zero,0($a2)
		lw $zero,0($a3)
		limparRegistradores
		jr $ra

	Exit:
		la $a0,outputText
		li $v0,4
		syscall
		la $v0,10
		syscall