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