#lang racket

;Menu feito como componente, montado como lista
; - primeiro é o título
; - segundo são as chaves lidos do usuário.
; - terceiro é uma lista com os valores selecionados do titulo

; O menu exibirá as teclas. A tecla atualmente selecionada será.
; indicado visualmente por uma pequena seta no lado esquerdo da tecla.
; O estado final do menu é o valor que corresponde a tecla selecionada.

(provide make-menu-game)
(require 2htdp/image)
(require 2htdp/universe)
(require "component-state.rkt")

(define rem 30)
(define make-font-size round) 

(define (draw-menu-item item)
  (text item rem 'black))

(module+ test
  (draw-menu-item "item"))

; Cursor é a seta ja mencionada para indicar onde está e qual tecla pode indicar.

(define cursor
  (beside (rectangle (make-font-size (* 3/2 rem)) 
                     rem 'solid 'black)
          (rotate -90
                  (triangle rem 'solid 'black))))

(module+ test 
  cursor
  (beside cursor (draw-menu-item "item")))


(define (draw-menu-items items selected-item)
  (define (draw-iter items-left menu-so-far distance-to-selected)
    (if (null? items-left)
      menu-so-far
      (let [(current-item
              (if (zero? distance-to-selected)
                (beside cursor (draw-menu-item (car items-left)))
                (draw-menu-item (car items-left))))]
        (draw-iter (cdr items-left)
                   (above menu-so-far current-item)
                   (sub1 distance-to-selected)))))
  (draw-iter items empty-image selected-item))

(define-struct menu [title items vals])
; Pega o índice do item selecionado e retorna esse.
; item.
(define (menu-next menu index)
  (modulo (add1 index) (length (menu-items menu))))
(define (menu-prev menu index)
  (modulo (sub1 index) (length (menu-items menu))))
(define (menu-ref menu index)
  (list-ref (menu-vals menu) index))

(define (draw-menu menu selected-item)
  (above (text (menu-title menu) 
               (make-font-size (* 3/2 rem)) 'black)
         (draw-menu-items (menu-items menu)
                          selected-item)))

(define (make-menu-game initializer)
  (define title (first initializer))
  (define items (second initializer))
  (define vals (third initializer))
  (define game-menu (make-menu title items vals))
  (define initial-state (make-state #t 0))
  (define (to-draw state)
    (draw-menu game-menu (state-public state)))
  (define (on-key state key)
    (let [(menu-entry (state-public state))]
      (case key
        ; O menu como dito é uma lista, como uma imagem de cima pra baixo,
        ; então as partes mais acima estão no começo da lista
        ; e as mais baixas mais pro final
        [("down" "j") 
         (set-state-public state (menu-next game-menu menu-entry))]
        [("up" "k")
         (set-state-public state (menu-prev game-menu menu-entry))]
        [("q" "\r")
         (set-state-private state #f)]
        [else state])))
  (define (output state)
    (let [(index (state-public state))]
      (menu-ref game-menu index)))
  (define stop-when (compose1 (curry eq? #f) state-private))
  (lambda (dispatch)
    (case dispatch
      [(name) 'menu]
      [(to-draw) to-draw]
      [(on-key) on-key]
      [(stop-when) stop-when]
      [(output) output]
      [(initial-state) initial-state])))
(module+ test
  (define vals (build-list 5 identity))
  (define items (map number->string vals))
  (define game 
    (make-menu-game (list "Select Tower Size:" items vals)))

  (big-bang
    (game 'initial-state)
    [to-draw (game 'to-draw)]
    [on-key (game 'on-key) ]
    [stop-when (game 'stop-when)]))
