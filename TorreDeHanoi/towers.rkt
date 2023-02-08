#lang racket
; torre é um componente.
; o arquivo torres é onde ficam as nossas principais funções do jogo, responsável por definir o tamanho dos discos e da torre
; "desenhar" as imagens, fazer o topo e final da lista que no caso é a torre.

(provide
  make-towers-game)
(require 2htdp/image)
(require 2htdp/universe)
(require "component-state.rkt")

; TODO
; - Permite que sejam feitas mudanças no tamanho dos discos e torres.
; - Cria um menu de pause.
; - Além dos desenhos, as animações são feitas aqui.

(define disk-height 20) ; O disco é um número positivo
(define (draw-disk disk)
  (overlay (text (number->string disk) (sub1 disk-height) 'white)
           (rectangle (+ 10 (* disk 30)) disk-height 'solid 'black)))

(module+ test
  (draw-disk 0)
  (draw-disk 1)
  (draw-disk 2)
  (draw-disk 10)
  (draw-disk 20))


(define tower-height length) ; A torre é uma lista decrescente, por conta dos menores números ficarem por cima,
                             ;sendo assim o primeiro elemento da lista é o maior número que é a base
(define tower-top last)
(define (tower-remove-top tower)
  (take tower (sub1 (length tower)))); Pega o maior valor do maior disco da torre

(define tower-bottom car)
(define tower-remove-bottom cdr) ; Coloca um disco no topo da torre
(define (tower-add tower disk)
  (append tower (list disk)))
(define tower-empty? null?)
(define tower-non-empty? pair?)
(define (tower-can-add? tower disk) 
  (or (tower-empty? tower) (< disk (tower-top tower))))
(define (make-tower-with-bottom-disk disk)
  (reverse (cdr (build-list (+ disk 1) identity))))

(define (draw-tower tower) ;imagem das torres
  (if (tower-empty? tower)
    empty-image
    (above (draw-tower (tower-remove-bottom tower))
           (draw-disk (tower-bottom tower)))))

(module+ test
  (define initial-tower (make-tower-with-bottom-disk 7))
  (draw-tower initial-tower))

(define list-max (lambda (lst) (apply max lst)))

(define (horizontal-image-append images)
  (apply beside images))

(define (draw-towers towers blank-tower)
  (let* [(width-between-towers 60)
         (separator
           (rectangle width-between-towers
                      (+(image-height blank-tower) 100)
                      'solid 'white))
         (tower-pics 
           (map (lambda (tower)
                  (if (tower-empty? tower)
                    blank-tower
                    (underlay/align 
                      'middle 'bottom
                      blank-tower (draw-tower tower))))
                towers))]
    (horizontal-image-append (add-between tower-pics separator))))

(define (replace-ref lst index value); Como a torre é uma lista, pode ser lida como uma. Sendo assim, essa função
                                     ; retorna uma lista de torres, ou seja uma lista de lista (como vimos em aula), as quais tiveram seu topo removido 
                                     ; por meio dos índices que representam cada torre.
  (cond [(null? lst) lst]
        [(zero? index) (cons value (cdr lst))]
        [else (cons (car lst) 
                    (replace-ref (cdr lst) (sub1 index) value))]))


(define (remove-from-towers towers index); Verifica se a torre tem índice negativo, se não for, essa torre pode ser adicionada na lista caso necessário.
                                         ; Essa função
                                         ; retorna uma lista de torres, ou seja uma lista de lista (como vimos em aula), as quais
                                         ; um valor adicionado em seu topo, por meio dos índices que representam cada torre
  (replace-ref towers 
               index 
               (tower-remove-top (list-ref towers index))))


(define (add-to-towers towers index disk) ; Verifica se a torre tem índice negativo, se não tiver, o disco pode ser adicionado.
  (replace-ref towers 
               index 
               (tower-add (list-ref towers index) disk))) ; Essa função retorna o valor do disco adicionado.

(define (get-from-towers towers index)
  (tower-top (list-ref towers index)))





; limbo: (or/c boolean? positivo?)
;   #f -> falso para limbo vazio de discos
;   positivo? Se tiver disco no limbo
;   torres : lista[torres] -> Já citado

(define-struct game-state [score limbo towers])
(define (make-towers-game widest-disk)
  (define num-towers 3)
  (define initial-tower (make-tower-with-bottom-disk widest-disk))
  (define height (* disk-height (tower-height initial-tower)))
  (define widest-disk-width (image-width (draw-disk widest-disk)))
  (define blank-tower (add-line
                       (add-line
                        (rectangle widest-disk-width height 'solid 'white)
                        (/ widest-disk-width 2) 0 (/ widest-disk-width 2) height
                        (make-pen "blue" 15 "solid" "round" "round"))
                       0 height widest-disk-width height
                       (make-pen "blue" 15 "solid" "butt" "round")))
  
  (define no-disk #f)
  (define score0 1)
  (define initial-state
    (make-state
      #t
      (make-game-state
        score0
        no-disk
        (cons initial-tower
              (make-list (sub1 num-towers) null)))))
  (define (to-draw state)
    (let* [(pub (state-public state))
           (towers (draw-towers (game-state-towers pub) blank-tower))
           (limbo-area (empty-scene (image-width towers)
                                    (* disk-height 3)))
           (limbo (if (game-state-limbo pub)
                    (overlay (draw-disk (game-state-limbo pub))
                             limbo-area)
                    limbo-area))
           (game-image (above limbo towers))]
      (overlay game-image 
               (empty-scene (image-width game-image)
                            (image-height game-image)))))
  (define (on-key state key)
    (let* [(pub (state-public state))
           (score (game-state-score pub))
           (towers (game-state-towers pub))
           (limbo (game-state-limbo pub))
           (validate-index (lambda (index)
                             (if (number? (string->number index))
                               (sub1 (string->number index))
                               #f)))
           (valid-index? 
             (lambda (i) (and (number? i) (< i num-towers))))
           (index (validate-index key))]
      (if (eq? limbo no-disk)
        ; Sem discos no limbo, retorna falso.
        (cond [(and (valid-index? index)
                    (tower-non-empty? (list-ref towers index)))
               (set-state-public
                 state
                 (make-game-state
                    score
                   (get-from-towers towers index)
                   (remove-from-towers towers index)))]
              [(string=? key "s")
               (begin (save-image (draw-towers towers)
                                  "current-output.jpg")
                      state)]
              [(string=? key "q") 
               (set-state-private state #f)]
              [else state])
        ; Existe disco no limbo, retorna positivo.
        (cond [(and ( = (- (/ height 20) 1) (tower-height (list-ref towers index)) ) (= index 2) )
                (println (~a "score: " score))
                (set-state-private state #f)
              ]
              [(valid-index? index)
               (if (tower-can-add? (list-ref towers index) limbo)
                 (set-state-public 
                   state
                   (make-game-state 
                    (+ score 1)
                     no-disk
                     (add-to-towers towers index limbo)))
                 state)
              ]
              [else state]))))
  (define stop-when (compose1 (curry eq? #f) state-private))
  (define (output state) #f)
  (lambda (dispatch)
    (case dispatch
      [(name) 'towers]
      [(to-draw) to-draw]
      [(on-key) on-key]
      [(stop-when) stop-when]
      [(output) output]
      [(initial-state) initial-state])))
(module+ test
  (define num-towers 3)
  (define game (make-towers-game 7))
  (big-bang
    (game 'initial-state)
    [to-draw (game 'to-draw)]
    [on-key (game 'on-key) ]
    [stop-when (game 'stop-when)]))
