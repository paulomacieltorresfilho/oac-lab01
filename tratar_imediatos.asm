.macro converterHexaChar (%numeroHexa,%escreveMemoria)
	
	Main:
		move $t0,%numeroHexa
		move $t1,%escreveMemoria
		li $t2,48
		li $t3,120
		sb $t2,0($t1)
		sb $t3,1($t1)
		addi $t1,$t1,2
		li $t2,28
	Loop:
		srl 
	
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

.macro verificaNegativoSinal (%numeroVerificado) 
	Main:
		move $t0,%numeroVerificado
		lb $t1,0($t0) 
		li $t2,0
		bne $t1,'-',False
		addi $t0,$t0,3
		move $t4,$t0
	ContaChar:
		lb $t3,0($t0)
		beqz $t3,Decide
		addi $t2,$t2,1
		addi $t0,$t0,1
		j ContaChar
	Decide:
		ble $t2,4,True
		subi $t2,$t2,4
		move $t6,$t2
		li $t5,0
	Confere:
		beqz $t2,Decide2
	ContaZero:
		lb $t3,0($t4)
		bne $t3,48,Decide2
		addi $t5,$t5,1
		addi $t0,$t0,1
		subi $t2,$t2,1
		j Confere
	Decide2:
		beq $t5,$t6,True
		j False
	True:
		li $v0,1
		li $v1,1
		j Exit
	False:
		li $v0,0
		li $v1,0
	Exit:	
.end_macro

.macro verificaNegativoSemSinal (%numeroVerificado)
	Main:
		move $t0,%numeroVerificado
		addi $t0,$t0,2
		lb $t1,0($t0)
		beq $t1,'f',IniciarParametros
		beq $t1,'F',IniciarParametros
		j False
	IniciarParametros:
		li $t2,0
		addi $sp,$sp,-4
		sw $t0,0($sp)
	ContaChar:
		lb $t1,0($t0)
		beqz $t1,Confere
		addi $t2,$t2,1
		addi $t0,$t0,1
		j ContaChar
	Confere:
		beq $t2,8,IniciarSegundoParametros
		j False
	IniciarSegundoParametros:
		lw $t0,0($sp)
		addi $sp,$sp,4
		li $t2,0
		li $t3,0
	IniciarContagemF:
		bne $t2,4,VerificaF
		j Decide
	VerificaF:
		lb $t1,0($t0)
		beq $t1,'f',IncrementaF
		beq $t1,'F',IncrementaF
		j Decide
	IncrementaF:
		addi $t2,$t2,1
		addi $t3,$t3,1
		addi $t0,$t0,1
		j IniciarContagemF
	Decide:
		beq $t3,4,VerificaChar
		j False
	VerificaChar:
		lb $t1,0($t0)
		bge $t1,56,True
		j False
	True:
		li $v0,1
		li $v1,0
		j Exit
	False:
		li $v0,0
		li $v0,0
	Exit:
.end_macro   


.macro cortaImediatoHexa (%numeroVerificado,%ImediatoCortado) #"0xFFFF8000
	
	Main:
		move $t0,%numeroVerificado
		verificaNegativoSinal $t0
		beq $v0,0,ConfereComSinal
	Continua:
		move $t0,%numeroVerificado
		move $t1,%ImediatoCortado
		move $t2,$v0
		add $t2,$t2,48
		sb $t2,0($t1)
		move $t2,$v1
		add $t2,$t2,48
		sb $t2,1($t1)
		addi $t0,$t0,2
		addi $t1,$t1,2
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
	ConfereComSinal:
		move $t0,%numeroVerificado
		verificaNegativoSemSinal $t0
		j Continua
	Exit:
		sb $zero,0($t1)

		
.end_macro

.macro transformarImediatoHexa (%imediatoCortado,%imediatoTransformado)

	Main:
		move $t0,%imediatoCortado
		move $t1,%imediatoTransformado
		lb $t4, 0($t0)
		lb $t7,1($t0)
		li $t3, 0
		addi $t0,$t0,2
	Confere:
		lb $t2,0($t0)
		beqz $t2,ConferirNegativo
		sll $t3,$t3,4
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
		addi $t0,$t0,1
		j Confere
	ConferirNegativo:
		li $t6,0
		beq $t7,49,ComplementoDe2
		beq $t4,49,ExtensaoSinal
		ori $t3,0x0000
		j Exit
	ComplementoDe2:
		not $t3,$t3
		addi $t3,$t3,1
	ExtensaoSinal:
		move $t5,$t3
		andi $t5,0x80000000
		beq $t5,0x80000000,ExtenderSinal
		sll $t3,$t3,1
		addi $t6,$t6,1
		j ExtensaoSinal
	ExtenderSinal:
		srav $t3,$t3,$t6
	Exit:
		sw $t3,0($t1)
		move $v0,$t3
.end_macro

.macro montadorTipoI (%opCode,%rs,%rt,%imediato,%enderecoEscrita)

	Main:
		move $t1,%opCode
		move $t2,%rs
		move $t3,%rt
		move $t4,%Imediato
		li $t5,0
	AcresencetarImediato:
		andi $t5,$t4,0x0000ffff
	AcrescentarRt:
		sll $t3,$t3,16
		or $t5,$t3,$t5
	AcrescentarRs:
		sll $t2,$t2,21
		or $t5,$t2,$t5
	Acrescetar0p:
		or $t5,$t1,$t5
	Salvar:
		sw $t5,0($t0)
	
.end_macro

.macro montarImediatoBinario (%imediato,%imediatoParte,%binarioInstrucao)
	move $a0,%imediato
	move $a1,%imediatoParte
	move $a2,%binarioInstrucao
	cortaImediatoHexa $a0,$a1
	transformarImediatoHexa $a1,$a2
.end_macro	
 
.data
################## Instruções Imediatas ##########################################################################
	
	inst_addi: .asciiz "addi"
	inst_andi: .asciiz "andi"
	inst_ori: .asciiz "ori"
	inst_xori: .asciiz "xori"
	inst_slti: .asciiz "slti"
	
###################################################################################################################	
	
	instrucaoSemFormatacao: .asciiz "    addi          $ra    ,      $rb  ,  0x000Ff8000 "
	instrucaoComFormatacao: .space 32
	instrucaoParte1: .space 32
	instrucaoParte2: .space 32
	instrucaoParte3: .space 32
	instrucaoParte4: .space 32
	imediatoParte:.space 32
	
	.align 2
	imediatoBinario:.space 32
	
	.align 2
	instrucaoBinario:.space 32
	
	
.text
	
	ComparaInstImediatas:
		la $a0,ins
		
		la $a1,inst_addi
		cmp_string $a0,$a1
		beq $v0,1,CaseAddi
		
		la $a1,inst_andi
		cmp_string $a0,$a1
		beq $v0,1,CaseAndi
		
		la $a1,inst_ori
		cmp_string $a0,$a1
		beq $v0,1,CaseOri
		
		la $a1,inst_xori
		cmp_string $a0,$a1
		beq $v0,1,CaseXori
		
		la $a1,inst_slti
		cmp_string $a0,$a1
		beq $v0,1,CaseSlti
		
	CaseAddi:
		li $s0,0x20000000
		la $a0,instrucaoParte4
		la $a1,imediatoParte
		la $a2,imediatoBinario
		montarImediatoBinario $a0,$a1,$a2
		la $a0 instrucaoBinario
		montadorTipoI $s0,$s1,$s4,$a2,$a0
		j Exit	
	CaseAndi:
		li $s0,0x30000000
		la $a0,instrucaoParte4
		la $a1,imediatoParte
		la $a2,imediatoBinario
		montarImediatoBinario $a0,$a1,$a2
		la $a0 instrucaoBinario
		montadorTipoI $s0,$s1,$s4,$a2,$a0
		j Exit	
	CaseOri:
		li $s0,0x34000000
		la $a0,instrucaoParte4
		la $a1,imediatoParte
		la $a2,imediatoBinario
		montarImediatoBinario $a0,$a1,$a2
		la $a0 instrucaoBinario
		montadorTipoI $s0,$s1,$s4,$a2,$a0		
		j Exit	
	CaseXori:
		li $s0,0x38000000
		la $a0,instrucaoParte4
		la $a1,imediatoParte
		la $a2,imediatoBinario
		montarImediatoBinario $a0,$a1,$a2
		la $a0 instrucaoBinario
		montadorTipoI $s0,$s1,$s4,$a2,$a0		
		j Exit		
	CaseSlti:
		li $s0,0x28000000
		la $a0,instrucaoParte4
		la $a1,imediatoParte
		la $a2,imediatoBinario
		montarImediatoBinario $a0,$a1,$a2
		la $a0 instrucaoBinario
		montadorTipoI $s0,$s1,$s4,$a2,$a0
		j Exit		
	Exit: