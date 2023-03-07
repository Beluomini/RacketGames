#lang racket

; Alunos:
; Lucas Beluomini 120111
; Arthur Martins Maciel 120119

; Curso:
; Ciência da Computação (UEM)

; Diciplina:
; Paradigmas de Programação Lógica e Funcional
; 1 Trabalho Prático

(require 2htdp/image)
(require 2htdp/universe)

(require "menu.rkt") ;chamando/requerindo arquivo para poder utilizazr as funções dele
(require "towers.rkt") 
(require "component-state.rkt")


(define (compose-components name . components)
  (lambda (initializer)
    (define screen-width 1000)
    (define screen-height 500)
    ; base-scene é usado para redimensionar rapidamente imagens mal utilizadas pelo big-bang.
    ; Sendo assim, as imagens do big-bang são trazidas para uma cena de forma redimensionada e mostradas na tela.
    (define base-scene (empty-scene screen-width screen-height))
    (define (get-current-game state)
      (control-state-component (state-private state)))
    (define (to-draw state)
      (place-image/align 
        (((get-current-game state) 'to-draw) (state-public state))
        (/ screen-width 2) (/ screen-height 2)
        'middle 'middle
        base-scene))
    (define (transition state)
      (let* [(games-left 
               (control-state-components-left (state-private state)))
             (current-game (get-current-game state))
             (current-game-state (state-public state))
             (output
               ((current-game 'output) current-game-state))]
        (if (null? games-left)
          (make-state #f output)
          (let* [(rest-games (cdr games-left))
                 (new-game ((car games-left) output))]
            (make-state
              (make-control-state rest-games new-game)
              (new-game 'initial-state))))))
    (define (on-key state key)
      (let* [(current-game-state (state-public state))
             (current-game (get-current-game state))
             (next-game-state ((current-game 'on-key) current-game-state key))]
        (if ((current-game 'stop-when) next-game-state)
          (transition (set-state-public state next-game-state))
          (set-state-public state next-game-state))))
    (define stop-when (compose1 boolean? state-private))
    (define output state-public)
    (lambda (dispatch)
      (case dispatch
        [(name) name]
        [(to-draw) to-draw]
        [(on-key) on-key]
        [(output) output]
        [(stop-when) stop-when]
        [(initial-state) 
         (let [(first-game ((car components) initializer))]
           (make-state
             (make-control-state 
               (cdr components)
               first-game)
             (first-game 'initial-state)))]))))

(define-struct control-state [components-left component])
(define tower-heights (build-list 6 (curry + 3)))
(displayln tower-heights)
(define menu-items (map number->string tower-heights))

(define (make-still-screen message font-size)
  (define (to-draw state)
    (text message font-size 'black))
  (define (on-key state key) #f)
  (define stop-when boolean?)
  (define (output state) #f)
  (define initial-state #f)
  (lambda (dispatch)
    (case dispatch
      [(name) 'towers]
      [(to-draw) to-draw]
      [(on-key) on-key]
      [(stop-when) stop-when]
      [(output) output]
      [(initial-state) initial-state])))

(define (finish-screen ignored)
  (make-still-screen "Obrigado por jogar!" 40))


(define make-game 
  (compose-components 'hanoi
    (compose-components 'first make-menu-game)
    (compose-components 'rest make-towers-game finish-screen)))

(define game (make-game (list "Escolha o tamanho da torre:"
                              menu-items
                              tower-heights)))

(big-bang
  (game 'initial-state)
  [to-draw (game 'to-draw)]
  [on-key (game 'on-key) ]
  [stop-when (game 'stop-when)])
