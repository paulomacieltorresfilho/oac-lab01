# Variáveis globais
# $a3 guarda o número da linha do código

.data  
file: .asciiz "file2.asm"      # filename for input
.align 2
buffer_instrucoes: .space 1024 # armazena instrução em 4 bytes
buffer_leitura: .space 1024



mif_data: .space 1024
mif_text: .space 1024
.align 2
tabela_label_endereco: .word 100 # formato 4 words para endereço e 1 word para label
tabela_pendencias: .word 100     # formato 4 words para endereço e 1 word para label

text_not_found: .asciiz ".text NÃO encontrado no arquivo.\n"
data_not_found: .asciiz ".data NÃO encontrado no arquivo.\n"

comma_not_found: .asciiz "comma NÃO encontrada no arquivo.\n"
whitespace_not_found: .asciiz "whitespace NÃO encontrado no arquivo.\n"

.text
#####################
# 1. IO -> lê e fecha arquivo
# 2. Acha .data e aloca memória
# 3. Acha .text e loop comandos
# 3.0 Lê a linha e salva a label em tabela_label_endereco 4 words para a label e 1 word para número da instrução
# 3.1 Lê a primeira letra
# 3.1.1 Pula para a árvore respectiva
# 3.2 Lê operandos

# Lógica dos registradores:
# s0 contém o Opcode e funct
# s1 contém rs
# s2 contém rt
# s3 contém rd
# s4 contém shamt
# s5 armazena o resultado da instrução
# s6 armazena o número da instrução

#s7 é o contador de linha de programa

#     Tipo R (operandos são registradores)
#		add/sub/and/or/nor/xor $t0, $s2, $t0
#		jr $t0
#		jalr $t1
#		slt $t1, $t2, $t3
#		addu/subu $t1, $t2, $t3
#		sllv $t1, $t2, $t3
#		sll/srl $t2, $t3, 10               caso diferente, shift ammount
#		mult $t1, $t2
#		div $t1, $t2
#		mfhi/mflo $t1

#		Grupo 1
#		clo $t1, $t2
#		srav $t1, $t2, $t3
#		sra $t2, $t1, 10
#		movn $t1, $t2, $t3
#		mul $t1, $t2, $t5

#		Grupo 2
#		sltu $t1, $t2, -100
#		clo $t1, $t2
#		clz $t1, $t2
#		addu $t1, $t2, $t3
#		divu $s1, $s2

#     Tipo J (as j... menos jr)
#		j LABEL
#		jal LABEL

#     Tipo I
#		lw $t0, OFFSET($s3)
#		addi/andi/ori/xori $t2, $t3, -10   
#		add $t0, $t2, 1000                 pseudo
#		addi/andi/ori/xori $t2, $t3, -10   
#		add $t0, $t2, 1000                 pseudo
#		sw $t0, OFFSET($s3)
#		beq/bne $t1, $zero, LABEL
#		lui $t1, 0xXXXX                   imm
#		lb $t1, 100($t2)                  

#		Grupo 1
#		bgez $t1, LABEL
#		addiu $t1, $t2, $t3
#		bgezal $t1, LABEL
#		sb $t4, 1000($t2)

#		Grupo 2
#		slti $t1, $t2, -100
#		bltzal $t1, LABEL
#		lhu $t1, -100($t2)
#		bgezall $s2, LABEL
#       	cop2 func
#     		
#	Formato próprio (debug)  
#       	deret
# 3.2 lê operandos ($t0 ...)

# 4.

# SEÇÂO 1
#open a file for reading
li   $v0, 13       # system call for open file
la   $a0, file     # load adress file name
li   $a1, 0        # Open for reading
li   $a2, 0        
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 
#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, buffer_leitura   # address of buffer to which to read
li   $a2, 1024     # hardcoded buffer length
syscall            # read from file
# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file
# --------------------------------------------------

# SEÇÂO 2
# 2.1 Verificar o conteúdo do buffer e procura o .data
jal read_byte
beq $t0,'.', find_data
j error_dot_not_found

error_dot_not_found:
addi $t2,$zero,496
j end

find_data:
jal read_next_4bytes
lui $at,0x6461 #"da"
ori $at,0x7461 #"ta"
beq $t0,$at, find_dot
j error_data_not_found

error_data_not_found:
addi $t2,$zero,497
j end

find_dot:
jal consume_newline

#
jal read_byte
beq $t0,'.', find_text
j error_dot2_not_found

error_dot2_not_found:
addi $t2,$zero,498
j end
# SEÇÂO 3

# 3.1 Verificar o conteúdo do buffer e achar .text
find_text:
jal read_next_4bytes
lui $at,0x7465 #"te"
ori $at,0x7874 #"xt"
beq $t0,$at, instruction_section

j error_text_not_found

error_text_not_found:
addi $t2,$zero,499
j end

instruction_section:
# contador de instrução começa em -1 ($s6 <- -1)
addi $s6,$zero,-1 
loop_instruction:
# lógica de gerenciamento da memória
# achar todas as labels '\n' (...) ':'
# primeiro achar os 2 pontos, em seguida ir voltando 
jal read_byte_no_inc
beq $t0,0,end
addiu $s6,$s6,1
jal consume_newline

jal search_label

jal consume_optional_whitespace

read_instruction:
# Primeira letra pode ser a,b,c,d,j,l,m,n,o,s,x
jal read_byte_no_inc
#check _ _ _ _ 

beq $t0, 0, solve_pendencies

beq $t0, 'a', a_read
beq $t0, 'b', b_read
beq $t0, 'c', c_read
beq $t0, 'd', d_read
beq $t0, 'j', j_read
beq $t0, 'l', l_read
beq $t0, 'm', m_read
beq $t0, 'n', n_read
beq $t0, 'o', o_read
beq $t0, 's', s_read
beq $t0, 'x', x_read

j error_instruction_not_found

########
# Branch A
# Add,and,addu,addi,andi,addiu
a_read: # a _ _ _
jal read_next_4bytes

lui $at,0x6164 #"ad"
ori $at,0x6420 #"d "
beq $t0,$at,add_inst

lui $at,0x616E #"an"
ori $at,0x6420 #"d "
beq $t0,$at,and_inst

lui $at,0x616E #"an"
ori $at,0x6469 #"di"
beq $t0,$at,andi_inst

lui $at,0x6164 #"ad"
ori $at,0x6475 #"du"
beq $t0,$at,addu_inst


lui $at,0x6164  #"ad"
ori $at,0x6469  #"di"
bne $t0,$at,error_instruction_not_found

jal read_byte_no_inc

addi $at,$zero,0x20 #" "
beq $t0,$at,addi_inst

addi $at,$zero,0x75 #"u"
beq $t0,$at,addiu_inst

j error_instruction_not_found

# INSTRUÇÔES COM A

add_inst:
# OPCODE: 0
# FUNCT: 100000 => 0010/0000 = 0x20
addi $s0,$zero,0x20
j tipo_r

and_inst:
# OPCODE: 0
# FUNCT: 10/0100 => b0010/0100= 0x24
addi $s0,$zero,0x24
j tipo_r

addu_inst:
# OPCODE: 0
# FUNCT: 100001 => b0010/0001= 0x21
jal consume_whitespace
addi $s0,$zero,0x21
j tipo_r

addi_inst:
# OPCODE: 001000 => 0010/0000 = 0x20
jal consume_whitespace
lui $s0, 0x2000
#addi $s0,$zero,0x08
#sll $s0,$s0,26
j tipo_i

andi_inst:
# OPCODE: 001100 => 0011/0000
jal consume_whitespace
lui $s0, 0x3000
j tipo_i

addiu_inst:
# OPCODE: 001001 => 0010/0100
jal read_byte_express #incrementa o ponteiro sem carregar de fato o byte
jal consume_whitespace
lui $s0,0x2400
j tipo_i


########### END BRANCH A

########
# Branch b
# Beq,bne,bgez,bgezal
b_read: # b _ _ _
jal read_next_4bytes

lui $at,0x6265 #"be"
ori $at,0x7120 #"q "
beq $t0,$at,beq_inst

lui $at,0x626E #"bn"
ori $at,0x6520 #"e "
beq $t0,$at,bne_inst

lui $at,0x6267 #"bg"
ori $at,0x657A #"ez"
bne $t0,$at,error_instruction_not_found

jal read_byte_no_inc
addi $at,$zero,0x20 #" "
beq $t0,$at,bgez_inst

jal read_next_2bytes_no_inc
addi $at,$zero,0x616C #"al"
beq $t0,$at,bgezal_inst

j error_instruction_not_found
# INSTRUÇÔES COM B
beq_inst:
# OPCODE: 000100 => 0001/0000  = 0x10
lui $s0,0x1000
j tipo_i

bne_inst:
# OPCODE: 000101 => 0001/0100 = 0x14
lui $s0,0x1400
j tipo_i


bgez_inst:
# REGIMM(31-26) len6 : 000001 => 0000/0100 => 0x04
# BGEZ(20-16) len 5: 00001 => 0000/0001 => 0x01
jal consume_whitespace
lui $s0,0x0400
addi $t1,$zero,0x01
sll $t1,$t1,16
or $s0,$s0,$t1
j tipo_i


bgezal_inst:
# REGIMM(31-26) len6 : 000001 => 0000/0100  => 0x04
# BGEZ(20-16) len 5: 10001=> 0001/0001=> 0x11
jal read_next_2bytes_express
jal consume_whitespace
lui $s0,0x0400
addi $t1,$zero,0x11
sll $t1,$t1,16
or $s0,$s0,$t1
j tipo_i

########### END BRANCH B

########

# Branch c
# Clo
c_read: # c _ _ _
jal read_next_4bytes

lui $at,0x636C#"cl"
ori $at,0x6F20#"o "
beq $t0,$at,clo_inst

j error_instruction_not_found

# INSTRUÇÔES COM c
clo_inst:
# OPCODE: 011100 => 0111/0000 => 0x70
# SHAMT: 0
# FUNCT: 100001 => 0010/0001 => 0x21
lui $s0,0x7000
ori $s0,$s0,0x21
j tipo_r
########### END BRANCH C

########

# Branch D
# Div
d_read: # d _ _ _
jal read_next_4bytes

lui $at,0x6469 #"di"
ori $at,0x7620 #"v "
beq $t0,$at,div_inst

# INSTRUÇÔES COM D
div_inst:
# OPCODE: 0
# FUNCT: 011010 => 0001/1010 = 0x1A
addi $s0,$zero,0x1A
j tipo_r

########### END BRANCH D

########
# Branch J
# Jr,jalr,j,jal
j_read: # j _ _ _
jal read_next_2bytes_no_inc

addi $at,$zero,0x6A20 #"j "
beq $t0,$at,j_inst

addi $at,$zero,0x6A72 #"jr"
beq $t0,$at,jr_inst

jal read_next_4bytes

lui $at,0x6A61 #"ja"
ori $at,0x6C20 #"l "
beq $t0,$at,jal_inst

lui $at,0x6A61 #"ja"
ori $at,0x6C72 #"lr"
beq $t0,$at,jalr_inst

j error_instruction_not_found
# INSTRUÇÔES COM J
# OPCODE: 0
# FUNCT: 010000 => 0001/0000 = 0x10
jr_inst:
jal read_next_2bytes_express
addi $s0,$zero,0x10
j tipo_r


jalr_inst:
# OPCODE: 0
# FUNCT: 001001 => 0000/1001 = 0x09
jal consume_whitespace
addi $s0,$zero,0x09
j tipo_r

j_inst:
# OPCODE: 000010 => 0000/1000 = 0x08
jal read_byte_express
jal consume_whitespace
lui $s0,0x0800
j tipo_j


jal_inst:
# OPCODE: 000011 => 0000/1100
lui $s0,0x0C00
j tipo_j

########### END BRANCH J

########
# Branch L
# Lw,lui,lb
l_read: # l _ _ _
jal read_next_2bytes_no_inc

addi $at,$zero,0x6C62 #"lb"
beq $t0,$at,lb_inst

addi $at,$zero,0x6C62 #"lw"
beq $t0,$at,lw_inst

jal read_next_4bytes
lui $at,0x6C75 #"lu"
ori $at,0x6920 #"i "
beq $t0,$at,lui_inst

j error_instruction_not_found
# INSTRUÇÔES COM L
lw_inst:
# OPCODE: 100011 => 1000/1100 =0x8C
jal read_next_2bytes_express
jal consume_whitespace
lui $s0,0x8C00
j tipo_i

lui_inst:
# OPCODE: 001111 => 0011/1100 = 0x3C
lui $s0,0x3C00
j tipo_i

lb_inst:
# OPCODE: 100000 => 1000/0000 = 0x80
jal read_next_2bytes_express
jal consume_whitespace
lui $s0,0x8000
j tipo_i

########### END BRANCH L

########

# Branch M
# Mult,movn,mul, mfhi/mflo
m_read: # m _ _ _
jal read_next_4bytes

lui $at,0x6D75 #"mu"
ori $at,0x6C74 #"lt"
beq $t0,$at,mult_inst

lui $at,0x6D6F #"mo"
ori $at,0x766E #"vn"
beq $t0,$at,movn_inst

lui $at,0x6D75 #"mu"
ori $at,0x6C20 #"l "
beq $t0,$at,mul_inst
 

lui $at,0x6D66 #"mf"
ori $at,0x6869 #"hi"
beq $t0,$at,mfhi_inst

lui $at,0x6D66 #"mf"
ori $at,0x6C6F #"lo"
beq $t0,$at,mflo_inst

j error_instruction_not_found
# INSTRUÇÔES COM M
mult_inst:
# OPCODE: 0
# FUNCT: 011000 => 0001/1000 = 0x18
jal consume_whitespace
addi $s0,$zero,0
j tipo_r

movn_inst:
# OPCODE: 0
# FUNCT: 001011 => 0000/1011 = 0x0B
jal consume_whitespace
addi $s0,$zero,0x0B
j tipo_r

mul_inst:
# OPCODE: 011100 => 0111/0000 = 0x70
# FUNCT: 000010 => 0000/0010 = 0x02
lui $s0,0x7000
ori $s0,$s0,0x02
j tipo_r

mfhi_inst:
# OPCODE: 0
# FUNCT: 010000 => 0001/0000 = 0x10
jal consume_whitespace
addi $s0,$zero,0x10
j tipo_r_onlydestiny

mflo_inst:
# OPCODE: 0
# FUNCT: 010010 => 0001/0010 = 0x12
jal consume_whitespace
addi $s0,$zero,0x12
j tipo_r_onlydestiny

########### END BRANCH M

########

# Branch N
# nor
n_read: #  _ _ _
jal read_next_4bytes
 
lui $at,0x6E6F #"no"
ori $at,0x7220 #"r "
beq $t0,$at,nor_inst

j error_instruction_not_found

# INSTRUÇÔES COM N
nor_inst:
# OPCODE: 0
# FUNCT: 100111 => 0010/0111 = 0x27
addi $s0,$zero,0x27
j tipo_r

########### END BRANCH N

########

# Branch O
# Or, ori
o_read: # o _ _ _
jal read_next_2bytes

addi $at,$zero,0x6F72 #"or"
bne $t0,$at,error_instruction_not_found

jal read_byte_no_inc

addi $at,$zero,0x20 #" "
beq $t0,$at,or_inst

addi $at,$zero,0x69 #"i"
beq $t0,$at,ori_inst

j error_instruction_not_found
# INSTRUÇÔES COM O
or_inst:
# OPCODE: 0
# FUNCT: 100101 => 0010/0101 = 0x25
jal consume_whitespace
addi $s0,$zero,0x25
j tipo_r

ori_inst:
# OPCODE: 001101 => 0011/0100 = 0x34
jal read_byte_express
jal consume_whitespace
lui $s0,0x3400
j tipo_i
########### END BRANCH 

########

# Branch S
# Sub,slt,subu,sllv,sll,srl,srav,sra,sw,sb
s_read: # s _ _ _
jal read_next_2bytes_no_inc

addi $at,$zero,0x7362 #"sb"
beq $t0,$at,lb_inst

addi $at,$zero,0x7362 #"sw"
beq $t0,$at,lw_inst

jal read_next_4bytes

lui $at,0x7375 #"su"
ori $at,0x6220 #"b "
beq $t0,$at,sub_inst

lui $at,0x736C #"sl"
ori $at,0x7420 #"t "
beq $t0,$at,slt_inst

lui $at,0x7375 #"su"
ori $at,0x6275 #"bu"
beq $t0,$at,subu_inst

lui $at,0x736C #"sl"
ori $at,0x6C76 #"lv"
beq $t0,$at,sllv_inst

lui $at,0x736C #"sl"
ori $at,0x6C20 #"l "
beq $t0,$at,sll_inst

lui $at,0x7372 #"sr"
ori $at,0x6C20 #"l "
beq $t0,$at,srl_inst

lui $at,0x7372 #"sr"
ori $at,0x6176 #"av"
beq $t0,$at,srav_inst

lui $at,0x7372 #"sr"
ori $at,0x6176 #"a "
beq $t0,$at,sra_inst

j error_instruction_not_found
# INSTRUÇÔES COM S
sub_inst:
# OPCODE: 0
# FUNCT: 100010 => 0010/0010 = 0x22
lui $s0,0x2200
j tipo_r

slt_inst:
# OPCODE: 0
# FUNCT: 0010/1010 = 0x2A
lui $s0,0x2A00
j tipo_r

subu_inst:
# OPCODE: 0
# FUNCT: 100011 => 0010/0011 = 0x23
jal consume_whitespace
lui $s0,0x2300
j tipo_r

sllv_inst:
# OPCODE: 0
# FUNCT: 000100 => 0000/0100 = 0x04
jal consume_whitespace
lui $s0,0x0400
j tipo_r

sll_inst:
# OPCODE: 0
# FUNCT: 0
addi $s0,$zero,0
j tipo_r

srl_inst:
# OPCODE: 0
# FUNCT: 000010 => 0000/0010 = 0x02
addi $s0,$zero,0x02
j tipo_r

srav_inst:
# OPCODE: 0
# FUNCT: 000111 => 0000/0111 = 0x07
jal consume_whitespace
addi $s0,$zero,0x07
j tipo_r

sra_inst:
# OPCODE: 0
# FUNCT: 000011 => 0000/0011 = 0x03
addi $s0,$zero,0x03
j tipo_r

sw_inst:
# OPCODE: 101011 => 1010/1100 = 0xAC
jal read_next_2bytes_express #incrementa o ponteiro sem carregar de fato os bytes
jal consume_whitespace
lui $s0,0xAC00
j tipo_i

sb_inst:
# OPCODE: 101000 => 1010/0000 = 0xA0
jal read_next_2bytes_express #incrementa o ponteiro sem carregar de fato os bytes
jal consume_whitespace
lui $s0,0xA000
j tipo_i

########### END BRANCH S

########

# Branch X
# 
x_read: # x _ _ _
jal read_next_4bytes

lui $at,0x786F #"xo"
ori $at,0x7220 #"r "
beq $t0,$at,xor_inst

lui $at,0x786F #"xo"
ori $at,0x7269 #"ri"
beq $t0,$at,xori_inst

j error_instruction_not_found
# INSTRUÇÔES COM X
xor_inst:
# OPCODE: 0
# FUNCT: 100110 => 0010/0110 = 0x26
addi $s0,$zero,0x26
j tipo_r

xori_inst:
# OPCODE: 001110 => 0011/1000 = 0x38
jal consume_whitespace
lui $s0,0x3800
j tipo_i

########### END BRANCH X
error_instruction_not_found:
addi $t2,$zero,500
j end
########
# end instructions
########
### Verifica operandos das funções
tipo_r:
jal read_register_operand
add $s3,$zero,$t1 #rd
sll $s3,$s3,11
jal consume_optional_whitespace
jal consume_comma
jal consume_optional_whitespace
jal read_register_operand
add $s1,$zero,$t1 #rs
sll $s1,$s1,21
jal consume_optional_whitespace
jal consume_comma
jal consume_optional_whitespace
jal read_register_operand
add $s2,$zero,$t1 #rt
sll $s2,$s2,16

or $s5,$zero,$s3
or $s5,$s5,$s2
or $s5,$s5,$s1
or $s5,$s5,$s0
j store_instruction

tipo_r_shamt:
jal read_register_operand
add $s3,$zero,$t1 #rd
jal consume_comma
jal read_register_operand
add $s1,$zero,$t1 #rs
jal consume_comma
#jal load_shift

tipo_r_onlydestiny:
jal read_register_operand
j store_instruction

tipo_i:
jal read_register_operand
add $s3,$zero,$t1 #rd
jal consume_comma
jal read_register_operand
add $s1,$zero,$t1 #rs
jal consume_comma
jal read_imm_operand



j store_instruction

tipo_j:

j store_instruction

store_instruction:
addi $t3,$zero,4
mul $t2,$s6,$t3
sw $s5,buffer_instrucoes($t2)
# incrementa contador de instrução

j loop_instruction
## Funções uso repetido
## Regra de negócio, apenas funções desse bloco alteram $a1

#######################
# PROCEDIMENTO consume_optional_whitespace
# consome opcionalmente um espaço
# Consome todos os whitespaces seguintes

# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Retornos:
# Espaço em $t0

# Efeitos globais:
# Incrementa $a1

consume_optional_whitespace:
lbu $t0, ($a1)
repeat_optional_whitespace:
bne $t0,' ', end_consume_optional_whitespace
addi $a1,$a1,1
lbu $t0, ($a1)
beq $t0,' ', repeat_optional_whitespace
end_consume_optional_whitespace:
jr $ra

#######################
# PROCEDIMENTO consume_whitespace
# consome obrigatoriamente um espaço, do contrário retorna erro
# Consome todos os whitespaces seguintes

# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Retornos:
# Espaço em $t0

# Efeitos globais:
# Incrementa $a1

consume_whitespace:
lbu $t0, ($a1)
repeat_whitespace:
addi $a1,$a1,1
bne $t0,' ', error_whitespace
lbu $t0, ($a1)
beq $t0,' ', repeat_whitespace
jr $ra

error_whitespace:
addi $t2,$zero,502
j end
#######################
# PROCEDIMENTO consume_newline
# consome obrigatoriamente uma quebra de linha, do contrário retorna erro

# No windows, newlines são composto de um \r seguido de um \n

# Consome todos os newlines seguintes
# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$a1

# Retornos:
# Espaço em $t0

# Efeitos globais:
# Incrementa $a1

consume_newline:
lbu $t0, ($a1)
repeat_newline:
addi $a1,$a1,1
beq $t0,'\r', consume_newline_n
j error_newline_r


consume_newline_n:
lbu $t0, ($a1)
addi $a1,$a1,1
bne $t0,'\n', error_newline_n
lbu $t0, ($a1)
beq $t0,'\r', repeat_newline
jr $ra

error_newline_r:
addi $t2,$zero,500
j end

error_newline_n:
addi $t2,$zero,501
j end
#######################
# PROCEDIMENTO consume_comma
# consome obrigatoriamente uma vírgula, do contrário retorna erro

# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t1,$a1

# Retornos:
# Vírgula em $t1

# Efeitos globais:
# Incrementa $a1

consume_comma:
lbu $t1, ($a1)
consume_comma_express:
addi $a1,$a1,1
bne $t1,',',error_comma
jr $ra

error_comma:
addi $t2,$zero,503
j end
#######################

# PROCEDIMENTO read_byte
# lê 1 byte do endereço apontado por $a1
# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$a1

# Retornos:
# Byte estendido para 32 bits em $t0

# Efeitos globais:
# Incrementa $a1

read_byte:
lbu $t0, ($a1)
read_byte_express:       
addi $a1,$a1,1
jr $ra

#######################
# PROCEDIMENTO read_next_2bytes
# lê 2 bytes do endereço apontado por $a1
# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$t1,$a1

# Retornos:
# Halfword estendida para 32 bits em $t0

# Efeitos globais:
# Incrementa $a1 em duas posições

## carrega 2 próximos bytes em t0
read_next_2bytes:
lbu $t0,($a1)
sll $t0,$t0,8

lbu $t1,1($a1)
or $t0,$t0,$t1 
read_next_2bytes_express:
addi $a1,$a1,2

jr $ra

#######################
# PROCEDIMENTO read_next_4bytes
# lê 4 bytes do endereço apontado por $a1
# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$t1,$a1

# Retornos:
# Word em $t0

# Efeitos globais:
# Incrementa $a1 em 4 posições

read_next_4bytes:
# (b31 b30 b29 b28 b27 b26 b25 b24) (b23 b22 b21 b20 b19 b18 b17 b16) (b15 b14 b13 b12 b11 b10 b9 b8) (b7 b6 b5 b4 b3 b2 b1 b0)
# carrega o primeiro byte da memória apontada por $a1 (primeira letra na sequencia do arquivo)
lbu $t0,($a1)
#desloca para a posição mais alta do registrador
sll $t0,$t0,24


#carrega segundo byte
lbu $t1,1($a1)
sll $t1,$t1,16
or $t0,$t0,$t1 

lbu $t1,2($a1)
sll $t1,$t1,8
or $t0,$t0,$t1 


lbu $t1,3($a1)
or $t0,$t0,$t1 

addi $a1,$a1,4

jr $ra

#######################

# PROCEDIMENTO find_dollar
# consome obrigatoriamente um $, do contrário retorna erro

# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$a1

# Retornos:
# Dollar em $t0

# Efeitos globais:
# Incrementa $a1

find_dollar:
lbu $t0, ($a1)
addi $a1,$a1,1
bne $t0,'$', error_find_dollar
jr $ra

error_find_dollar:
addi $t2,$zero,504
j end
# PROCEDIMENTO read_byte_no_inc
# lê 1 byte do endereço apontado por $a1
# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$a1

# Retornos:
# Byte estendido para 32 bits em $t0

# Efeitos globais:
# Modifica $t0

read_byte_no_inc:
lbu $t0, ($a1)
jr $ra

# PROCEDIMENTO read_next_2bytes_no_inc
# lê 2 bytes do endereço apontado por $a1
# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t0,$a1,$t1

# Retornos:
# Byte estendido para 32 bits em $t0

# Efeitos globais:
# Modifica $t0,$a1,$t1
read_next_2bytes_no_inc:
lbu $t1,($a1)
sll $t1,$t1,8

lbu $t1,1($a1)
or $t0,$t0,$t1 
jr $ra
############ termina bloco que altera o $a1
############
# PROCEDIMENTO load_register_operand


# Argumentos de entrada:
# Registrador $a1: endereço do buffer

# Registradores utilizados:
# $t1,$t0,$at

# Retornos:
# Vírgula em $t1

# Efeitos globais:
# Incrementa $a1

read_register_operand:
addi $sp,$sp,-4
sw $ra,($sp)

jal find_dollar

jal read_byte_no_inc

beq $t0,'a',read_register_number_a

beq $t0,'v',read_register_number_v

beq $t0,'t',read_register_number_t

beq $t0,'s',read_register_number_s

beq $t0,'z',read_register_number_z

j read_register_onlynumber

######################## Z
read_register_number_z:

jal read_next_4bytes

lui $at,0x7A65 #ze
ori $at,0x726F #ro

beq $t0,$at,register_zero

j error_register_number

register_zero:
add $t1,$zero,$zero
j read_register_operand_end

######################## A
read_register_number_a:
jal read_byte_express
jal read_byte

beq $t0,'t',register_at

addi $t0,$t0,-0x30 #transforma char em número

addi $at,$zero,3 #an com 0<=n<=3
bleu $t0,$at,register_a_number

register_at:
addi $t1,$zero,1
j read_register_operand_end

register_a_number:
addi $t1,$zero,20 #a0 corresponde a 4
add $t1,$t1,$t0 #offset

j read_register_operand_end

######################### V

read_register_number_v:
jal read_byte_express
jal read_byte
addi $t0,$t0,-0x30 #transforma em número

addi $at,$zero,1 #vn com 0<=n<=1
bleu $t0,$at,register_v_number

j error_register_number

register_v_number:
addi $t1,$zero,2 #v0 corresponde a 2
add $t1,$t1,$t0 #offset

j read_register_operand_end


######################### T
read_register_number_t:
jal read_byte_express
jal read_byte
addi $t0,$t0,-0x30 #transforma em int

addi $at,$zero,7 #tn 0<=n<=7
bleu $t0,$at,register_t_number_upto_7

addi $at,$zero,9 #tn n<=9
bleu $t0,$at,register_t_number_upto9

j error_register_number

register_t_number_upto_7:
addi $t1,$zero,8 #t0 corresponde a 8
add $t1,$t1,$t0 #offset
j read_register_operand_end

register_t_number_upto9:
addi $t0,$t0,-0x08 #transforma em offset
addi $t1,$zero,24 #t8 corresponde a 24
add $t1,$t1,$t0 #offset

j read_register_operand_end
######################### S
read_register_number_s:
jal read_byte_express
jal read_byte
addi $t0,$t0,-0x30 #transforma em número

addi $at,$zero,7 #at=7
bleu $t0,$at,register_s_number

j error_register_number

register_s_number:

addi $t1,$zero,16 #s0 corresponde a 16
add $t1,$t1,$t0 #offset

j read_register_operand_end

################### ONLY NUMBER
read_register_onlynumber:
jal read_byte

addi $t0,$t0,-0x30 #transforma char em número
add  $t1,$zero,$t0


# único caso que precisa concatenar bytes para obter número do registrador
lbu $t0,($a1)
beq $t0,',',only_number_compare
beq $t0,'\r',only_number_compare
beq $t0,' ',only_number_compare
beq $t0,0,only_number_compare

#chama o read_byte_express só para incrementar o índice do buffer
mul $t1,$t1,10
jal read_byte_express
addi $t0,$t0,-0x30 #transforma em número
add $t1,$t1,$t0


only_number_compare:
addi $at,$zero,31 
bleu $t1,$at,register_number #compara se o número está na range 0 a 31

j error_register_number

register_number:

read_register_operand_end:
#restaura $ra da main
lw $ra,($sp)
addi $sp,$sp,4

jr $ra
########################################
error_register_number:
addi $t2,$zero,505
j end
########################################
read_imm_operand:
addi $sp,$sp,-4
sw $ra,($sp)

# hex or decimal imm? If hex, load to register only 16 bits
# if decimal, convert to hex

lbu $t0,($a1)
addi $at,$zero,'-'
beq $t0,$at,negative_imm

jal read_next_2bytes



addi $at,$zero,0x3078
beq $t0,$at,hex_found # string 0x



j error_read_imm

negative_imm:

hex_found:

end_read_imm_operand:
lw $ra,($sp)
addi $sp,$sp,4
jr $ra

error_read_imm:
addi $t2,$zero,507
j end

####################
jr $ra
# PROCEDIMENTO SEARCH LABEL
# Itera pela linha e procura uma label
# Caso 1: encontra um ":" significa que o que vem antes é uma label, que será armazenada
# em tabela label endereco
# Em seguida, o restante da instrução é processado
# Caso 2: lê-se um \r\n sem que seja lida um ":". Significa que não há a label naquela linha
# o contador de linha volta para o começo da linha e a instrução é processada

search_label:
addi $sp,$sp,-4
sw $ra,($sp)

add $t1,$zero,$zero #contador de qual coluna na linha
loop_search_label:
lbu $t0,($a1) #carrega caracter em $t0

addi $at,$zero,0x3A # ":" adiciona em $at ":"
beq $t0,$at,found_colon # caso seja o :, fazer procedimentos de salvar a label

addi $at,$zero,'\r' #return carriage significa que a linha acabou
beq $t0,$at,found_end_of_line # ir para found_newline e termina a rotina
beq $t0,0,found_end_of_line # ir para found_newline e termina a rotina

addi $a1,$a1,1
addi $t1,$t1,1 #incrementa coluna
j loop_search_label #volta para loop search até que uma das condições de saída ser atendida


found_colon:
# subtrai de $a2 o número de caracteres lidos 
sub $a1,$a1,$t1
add $t2,$zero,$zero
label_save_loop:
lbu $t0,($a1) #carrega caracter em $t0
addi $a1,$a1,1 
addi $at,$zero,0x3A # ":" adiciona em $at ":"
beq $t0,$at,end_save_label
sb $t0,tabela_label_endereco($t2)
addi $t2,$t2,1
j label_save_loop

found_end_of_line:
sub $a1,$a1,$t1
j end_search_label

end_save_label:
sw $s6,tabela_label_endereco+16
addi $a1,$a1,1 

end_search_label:
lw $ra,($sp)
addi $sp,$sp,4
jr $ra
## FIM

end:

solve_pendencies:


