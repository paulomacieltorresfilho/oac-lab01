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

.end_macro


.data
string1: .asciiz "Hello"
string2: .asciiz "World"
string3: .asciiz "MIPS"
buffer:  .space 100  # Espaço para o resultado concatenado

.text
.globl main
main:
    # Carregar os endereços das strings e o buffer
    la $t0, string1  # $t0 = endereço de string1
    la $t1, string2  # $t1 = endereço de string2
    la $t2, string3  # $t2 = endereço de string3
    la $t3, buffer   # $t3 = endereço do buffer de destino

    # Chamar a macro para concatenar as strings
    concatTresStrings($t0, $t1, $t2, $t3)

    # Imprimir o resultado (assumindo syscall para print_string)
    li $v0, 4         # Código para imprimir string
    la $a0, buffer    # Endereço do buffer de destino
    syscall

    # Encerrar o programa
    li $v0, 10        # Código para encerrar o programa
    syscall
