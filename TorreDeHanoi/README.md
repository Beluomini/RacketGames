# RacketHanoiTower
-------------------------------------------------------

## Alunos:
Lucas Beluomini 120111 </br>
Arthur Martins Maciel 120119

## Curso:
Ciência da Computação (UEM)

## Diciplina: 
Paradigmas de Programação Lógica e Funcional  </br>
1 Trabalho Prático

-------------------------------------------------------
## Jogo do hanoi

Para iniciar o jogo é preciso executar o arquivo hanoi.rkt

O arquivo hanoi-solver.rkt resolve o jogo de com 3 configurações diferentes
apresentadas nos arquivos de texto. Para ver a solução basta executá-lo

Para jogar use as teclas 1, 2 e 3
1 para interagir com a primeira torre
2 para interagir com a segunda torre
3 para interagir com a terceira torre

Só é possivel remover o primeiro bloco da torre
Só é possível adicionar no topo da torre
Só é possível mover um bloco por vez
Só é possivel colocar blocos menores em cima dos maiores
 
O objetivo é empilhar os blocos na ultima torre

----------------REGRAS

1.Deslocar um disco de cada vez, o qual deverá ser o do topo de uma das três torres;
2.Cada disco nunca poderá ser colocado sobre outro de temanho menor.
3.Partida para 1 jogador.

----------------OBJETIVO
O objetivo do jogo consiste em deslocar todos os discos da torre mais a esquerda para uma a torre mais a direita, podendo utilizar a do meio.

----------------JOGABILIDADE
De acordo com as regras do jogo, para que o maior disco possa ser colocado
no eixo da direita, é obrigatório que os discos menores estejam empilhados 
na torre do meio tendo o maior disco sozinho no eixo à esquerda. A tarefa
de passar os discos menores da torre da esquerda para a torre do meio é
equivalente (em termos de números de movimentos necessários) à de passar os
discos da torre do meio para a torre da direita.
Existem 3 torres, uma mais a esquerda,a do meio e a mais a direita. Pressionando um número (1 2 3) do teclado, remove o disco do topo da torre selecionada (caso tenha discos presentes) 
para o "ar", que no código chamamos de limbo, e depois clicando mais uma vez um dos números (1 2 3), você seleciona a torre destino para o disco presente no limbo ir,
e como dissemos nas regras, não será aceito que um disco maior seja retirado de uma torre e adicionado em cima de um menor.

