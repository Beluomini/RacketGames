#lang racket

(require 2htdp/batch-io) ;biblioteca necessária para o uso da função read-file, ou seja, fazer reuso de códigos, uma das propostas da linguagem funcional

(define (hanoi n from to using)
  (when (> n 0)
    (hanoi (- n 1) from using to)
    (displayln (~a "Pressione " from))
    (displayln (~a "Pressione " to))
    (displayln (format "Moveu disco ~a da torre ~a para torre ~a" n from to))
    (displayln " ")
    (hanoi (- n 1) using to from))) ;chamando a função hanoi recursivamente, um dos usos da linguagem funcional

(define (torres-de-hanoi n)
  (hanoi n 1 3 2)) ;ordem das torres. Sai da torre 1 para a torre 3, utilizando a torre 2.

;EXEMPLOS ABAIXO
;1
(displayln "EXEMPLO DO ARQUIVO DE TEXTO 1:")
(displayln "TAMANHO DA TORRE -> 3")
(displayln " ")
(torres-de-hanoi (string->number(read-file "exemplo1racket.txt"))) ;reuso do codigo da biblioteca para ler arquivo de texto,
                                                                   ;e reutilizando a função "string->number" para transformar string em inteiro
(displayln "FIM DO EXEMPLO DE ARQUIVO DE TEXTO 1")
(displayln "------------------------------------")

;2
(displayln "EXEMPLO PRO ARQUIVO DE TEXTO 2:")
(displayln "TAMANHO DA TORRE -> 5")
(displayln " ")
(torres-de-hanoi (string->number(read-file "exemplo2racket.txt")))
(displayln "FIM DO EXEMPLO DE ARQUIVO DE TEXTO 2")
(displayln "------------------------------------")

;3
(displayln "EXEMPLO PRO ARQUIVO DE TEXTO 3:")
(displayln "TAMANHO DA TORRE -> 4")
(displayln " ")
(torres-de-hanoi (string->number(read-file "exemplo3racket.txt")))
(displayln "FIM DO EXEMPLO DE ARQUIVO DE TEXTO 3")
(displayln "------------------------------------")


;alterar a documentação do código, "traduzindo" o que esta em inglês, cabeçalho com alunos, explicando o jogo (objetivo, jogabilidade, regras)
;printar o nmr de jogadas
