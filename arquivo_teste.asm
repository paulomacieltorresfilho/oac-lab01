        .data
array:  .word 10, 20, 30, 40, 50, 60, 70, 80, 90, 100
        .word 110, 120, 130, 140, 150, 160, 170, 180, 190, 200
        .word 210, 220, 230, 240, 250, 260, 270, 280, 290, 300
        .word 310, 320, 330, 340, 350

msg:    .asciiz "Exemplo MIPS com 150 instruções, 30 dados e 15 labels."

        .text
        .globl main

main:
        addi $t0, $zero, 5
        addi $t1, $zero, 10
        add  $t2, $t0, $t1
        sub  $t3, $t1, $t0
        andi $t4, $t0, 15
        or   $t5, $t0, $t1
        xor  $t6, $t2, $t3
        slt  $t7, $t0, $t1
        slti $t8, $t0, 20
        sll  $t9, $t0, 2
        srl  $s0, $t1, 3
        sra  $s1, $t1, 1
        lui  $s2, 0x1234
        addi $s3, $s2, 100
        andi $s4, $s3, 255
        beq  $t0, $t1, label1
        bne  $t0, $t2, label2
        j    label3
label1:
        addi $s5, $s4, 5
        j    end
label2:
        sub  $s6, $t1, $t0
label3:
        add  $s7, $s6, $s5
        j    end
end:
        sw   $t0, 0($s0)
        lw   $t1, 0($s0)
        bgez $t1, positive
        bltz $t1, negative
        nop
        j    final
positive:
        addi $t2, $t1, 1
        j    final
negative:
        addi $t3, $t1, -1
final:
        sw   $t2, 4($s0)
        li   $t4, 100
        li   $t5, 50
        sub  $t6, $t4, $t5
        mul  $t7, $t4, $t5
        div  $t8, $t4, $t5
        mflo $t9
        mfhi $s0
        addi $s1, $t6, 7
        add  $s2, $s1, $t9
        sub  $s3, $s1, $s0
        mult $t4, $t5
        div  $t6, $t7
        mflo $s4
        mfhi $s5
        add  $s6, $s4, $s5
        bgez $s6, check1
        bltz $s6, check2
check1:
        add $t0, $t0, $t1
        j   check3
check2:
        sub $t2, $t1, $t0
check3:
        li   $t3, 20
        addi $t4, $t3, 30
        slt  $t5, $t4, $t2
        bne  $t5, $zero, branch1
        nop
branch1:
        xor  $t6, $t2, $t4
        and  $t7, $t3, $t5
        or   $t8, $t2, $t3
        slti $t9, $t4, 50
        j    branch2
        addi $s0, $s9, 5
branch2:
        add  $s1, $s0, $s1
        beq  $s1, $zero, labelEnd
        nop
        j    final2
labelEnd:
        addi $t0, $t0, 10
final2:
        sw   $t0, 8($s0)
        lw   $t1, 8($s0)
        sw   $t2, 12($s0)
        addi $t3, $t3, 20
        xor  $t4, $t3, $t5
        and  $t6, $t4, $t7
        slti $t8, $t6, 100
        bge  $t8, $zero, continue1
        sub  $t9, $t8, $t7
continue1:
        add  $s0, $s1, $t9
        li   $t1, 10
        li   $t2, 5
        sub  $t3, $t1, $t2
        mul  $t4, $t1, $t2
        div  $t5, $t1, $t2
        mflo $s1
        mfhi $s2
        addi $s3, $s1, 6
        sub  $s4, $s3, $s2
        xor  $s5, $s4, $s1
        mult $t1, $t2
        div  $t3, $t4
        mflo $s6
        mfhi $s7
        add  $s8, $s6, $s7
        sub  $s9, $s8, $s3
        bgtz $s9, positive2
        bltz $s9, negative2
positive2:
        addi $t0, $t0, 7
        j    final3
negative2:
        addi $t1, $t1, -3
final3:
        sw   $t2, 16($s0)
        li   $t3, 200
        li   $t4, 100
        sub  $t5, $t3, $t4
        mul  $t6, $t3, $t4
        div  $t7, $t3, $t4
        mflo $s0
        mfhi $s1
        addi $s2, $s0, 4
        sub  $s3, $s2, $s1
        xor  $s4, $s3, $s0
        mult $t4, $t5
        div  $t6, $t7
        mflo $s5
        mfhi $s6
        add  $s7, $s5, $s6
        sub  $s8, $s7, $s2
        bge  $s8, $zero, checkEnd
        nop
checkEnd:
        j    final4
final4:
        addi $t9, $s8, 9
        sw   $t9, 20($s0)
        lw   $t8, 20($s0)
        bnez $t8, continue2
        nop
continue2:
        add  $s9, $s9, $t9
        xor  $t0, $t8, $t9
        and  $t1, $t8, $t9
        or   $t2, $t8, $t9
        slt  $t3, $t1, $t2
        beq  $t3, $zero, check4
check4:
        addi $t4, $t4, 50
        li   $t5, 300
        mul  $t6, $t5, $t4
        div  $t7, $t5, $t6
        mflo $t8
        mfhi $s0
        add  $s1, $t8, $s0
        sub  $s2, $s1, $t7
        xor  $s3, $s2, $t5
        slt  $s4, $s3, $t6
        addi $s5, $s4, 25
        and  $s6, $s5, $s4
        or   $s7, $s6, $s3
        xor  $s8, $s7, $s2
        slti $s9, $s8, 400
        j    check5
check5:
        add  $t0, $s9, $s6
        li   $t1, 50
        li   $t2, 100
        mul  $t3, $t1, $t2
        div  $t4, $t3, $t1
        mflo $t5
        mfhi $t6
        sw   $t5, 24($s0)
        li   $v0, 10
        syscall
