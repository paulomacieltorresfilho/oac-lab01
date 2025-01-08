.data
hexString: .asciiz "0x01ABC"  # Exemplo de string hexadecimal
binaryResult: .space 4        # Espaço para o resultado binário (32 bits)
binaryString: .space 33       # Espaço para a string binária (32 bits + null terminator)

.text
main:
    la $t0, hexString    # Carrega o endereço da string hexadecimal em $t0

    li $t1, 0            # Índice na string
    li $t2, 0            # Valor acumulado

transformaLoop:
    lb $t3, 0($t0)         # Carrega o próximo caractere da string
    beqz $t3, transformaEnd  # Se encontrar o caractere nulo, termina

    # Ignora o prefixo "0x"
    beq $t1, 0, transformaNext
    beq $t1, 1, transformaNext

    # Converte o caractere hexadecimal em valor numérico
    # '0' a '9'
    li $t4, 48           # ASCII de '0'
    li $t5, 57           # ASCII de '9'
    ble $t3, $t5, hexToDec
    # 'A' a 'F'
    li $t4, 65           # ASCII de 'A'
    li $t5, 70           # ASCII de 'F'
    ble $t3, $t5, hexToDecUpper
    # 'a' a 'f'
    li $t4, 97           # ASCII de 'a'
    li $t5, 102          # ASCII de 'f'
    ble $t3, $t5, hexToDecLower

transformaNext:
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j transformaLoop

# Converte '0' a '9'
hexToDec:
    sub $t3, $t3, 48
    j hexToDecEnd

# Converte 'A' a 'F'
hexToDecUpper:
    sub $t3, $t3, 55   # A = 65, mas queremos 10 => 65 - 55 = 10
    j hexToDecEnd

# Converte 'a' a 'f'
hexToDecLower:
    sub $t3, $t3, 87   # a = 97, mas queremos 10 => 97 - 87 = 10
    j hexToDecEnd

hexToDecEnd:
    # Shift e adição do novo dígito
    sll $t2, $t2, 4     # Shift left lógico para criar espaço para o novo dígito
    or $t2, $t2, $t3    # Adiciona o novo dígito ao acumulador
    j transformaNext

transformaEnd:
    # Armazena o resultado binário
    sw $t2, binaryResult  # Armazena o resultado binário

    # Converter resultado para string binária
    la $t0, binaryResult  # Carrega o endereço de binaryResult em $t0
    lw $t1, 0($t0)        # Carrega o valor binário em $t1

    la $t2, binaryString  # Carrega o endereço de binaryString em $t2
    li $t3, 32            # Contador de bits (32 bits)

convertLoop:
    beqz $t3, printBinary # Se o contador de bits chegar a zero, vai imprimir
    andi $t4, $t1, 0x80000000  # Obtém o bit mais significativo (MSB) de $t1
    beqz $t4, storeZero    # Se o bit for zero, armazena '0'
    li $t5, 49             # ASCII de '1'
    sb $t5, 0($t2)         # Armazena '1'
    j shiftBits

storeZero:
    li $t5, 48             # ASCII de '0'
    sb $t5, 0($t2)         # Armazena '0'

shiftBits:
    sll $t1, $t1, 1        # Desloca $t1 para a esquerda (descarta o MSB)
    addi $t2, $t2, 1       # Move o ponteiro da string
    subi $t3, $t3, 1       # Decrementa o contador de bits
    j convertLoop

printBinary:
    li $t5, 0              # Null terminator
    sb $t5, 0($t2)         # Armazena o null terminator na string

    li $v0, 4              # Syscall para imprimir a string
    la $a0, binaryString   # Passa o endereço da string
    syscall                # Chama a syscall

    li $v0, 10             # Syscall para encerrar o programa
    syscall                # Chama a syscall para encerrar
