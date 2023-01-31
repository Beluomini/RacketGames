#lang racket
; make-menu-game is a component.
; initializer: (list string? list[string?] list[any/c])
; - first member is menu title
; - Second member is a list of keys which correspond to each value of
;   the menu.
; - third member is a list of values to be selected through the
;   title.
;
; The menu will display the keys. The currently selected key will be
; visually denoted by a small arrow to the left side of the key.
; The final state of the menu is the value which corresponds to the
; selected key. So, for instance, if `selection` is the final selected
; index (ie the chosen key is (list-ref keys selection)), then the
; final selected value is (list-ref vals selection)).

(provide make-menu-game)
(require 2htdp/image)
(require 2htdp/universe)
(require "component-state.rkt")

(define rem 30)
; number -> integer
(define make-font-size round) 

(define (draw-menu-item item)
  (text item rem 'black))

(module+ test
  (draw-menu-item "item"))

; The small arrow which denotes selection.
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
; Takes in index of currently selected item, returns index of next
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
        ; High parts of a menu are earlier in list
        ; Low parts of a menu are later in list
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
