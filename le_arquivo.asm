.data
arquivo_asm: .asciiz "./lab01/arquivo_teste.asm"
loop_line_end: .asciiz "Fim do loop"
file_buffer_size: .word 20000
line_buffer_size: .word 100

# Space
file_buffer: .space 20000
line_buffer: .space 100

.text

MAIN:
    jal READ_FILE
    move $a0, $v0
    jal LINE_ITERATOR
    j EXIT

# a0: endereco da string
PRINT_STRING:
    li $v0, 4
    syscall
    jr $ra

# v0: endereco da string
READ_FILE:
    # abre arquivo
    li $v0, 13
    la $a0, arquivo_asm
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0

    # lê n bytes
    li $v0, 14
    move $a0, $s0
    la $a1, file_buffer 
    lw $a2, file_buffer_size
    syscall

    # fecha arquivo
    li $v0, 16
    move $a0, $s0
    syscall
    
    move $v0, $a1
    jr $ra
    
# a0: endereco do buffer do arquivo
LINE_ITERATOR:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $t0, $a0 # endereco do buffer do arquivo
	la $t1, line_buffer # endereco do buffer da linha
	li $t2, '\n' # caracter de nova linha
	li $t4, 1 # contador de linhas

	LOOP:
		lb $t3, ($t0) # carrega char do endereco t0 em t3
		beqz $t3, EOF # se t0 for \0, é o fim do arquivo lido
		sb $t3, ($t1) # se nao for o fim do arquivo, armazena o char em no endereco t1
		addi $t0, $t0, 1 # endereco do proximo char do arquivo
		addi $t1, $t1, 1 # proxima posicao da linha
		beq $t3, $t2, DO_SOMETHING # se o char t3 for igual '\n', a linha acabou e uma funcao deve ser chamada para tratar a linha
		j LOOP

	DO_SOMETHING:
		move $a0, $t4
		li $v0, 1
		syscall
	
		la $t1, line_buffer # volta t1 para o endereco 0 do line_buffer
		move $a0, $t1
		li $v0, 4
		syscall
		
		addi $t4, $t4, 1
		j LOOP
	
	EOF:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
	

EXIT:
    li $v0, 10
    syscall
