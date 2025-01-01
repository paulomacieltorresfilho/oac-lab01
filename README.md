# oac-lab01

Instruções identificadas por switch case


TODO:

- [ ] Comparar Strings (Guilherme)
- [ ] Separar linhas em partes da intrução (Guilherme)


- [x] Ler arquivo por linha (Paulo)
- [x] Iterar nas linhas para montar cada instrução (Paulo)
	- [ ] Tratar quando o '\0' não estiver numa linha separada
	- [ ] Adicionar '\0' no final da linha por conta do buffer
- [ ] Ler registradores e seus apelidos ($zero = $0 ...) (Paulo)
	- [ ] Ler registradores sem máscara
	- [x] Ler registradores com máscara
	- [ ] Tratar diferentemente o t8 e t9 por não estarem na sequencia dos outros t's
	- [ ] Adicionar tratamento para registradores diferentes (sp, ra)


- [ ] Criar arquivo mif, com header e footer

- [ ] Separar .text e .data

### Obs:

1. Não foi possível ler o arquivo por linha. A solução encontrada foi ler o arquivo 
inteiro de uma vez e depois fazer um iterator para tratar cada linha individualmente.

2. Verificar necessidade de limpar o buffer de linha após o tratamento de uma linha.
