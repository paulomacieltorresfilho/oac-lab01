.data
num1: .word 4      # Declarar a palavra inicial 4
result: .word 0    # Variável para armazenar o resultado

.text
main:
    la $t0, num1       # Carrega o endereço de num1 em $t0
    lw $t0, 0($t0)     # Carrega o valor de num1 em $t0
    addi $t0, $t0, -0xfffffff  # Subtrai 1 (0xFFFF representa -1 no imediato de 16 bits)
    la $t1, result     # Carrega o endereço de result em $t1
    sw $t0, 0($t1)     # Armazena o resultado em result
    
    li $v0, 1          # Código da syscall para imprimir inteiro
    move $a0, $t0      # Move o resultado para $a0
    syscall            # Chama a syscall para imprimir o resultado
    
    li $v0, 10         # Código da syscall para encerrar o programa
    syscall            # Chama a syscall para encerrar o programa
