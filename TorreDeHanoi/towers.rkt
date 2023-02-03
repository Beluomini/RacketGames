#lang racket
; make-towers-game is a component.
; initializer: number?
; The initializer specifies the width of the widest (bottom-most) disk
; on the tower, which is also the height of the tower. The component
; implements the game "Towers of Hanoi".

(provide
  ;draw-disk
  ;tower-height tower-top tower-remove-top
  ;tower-empty? tower-non-empty? tower-can-add?
  ;tower-add
  ;draw-tower draw-towers
  make-towers-game)
(require 2htdp/image)
(require 2htdp/universe)
(require "component-state.rkt")

; TODO
; - Allow someone to change the disk size and height.
; - Create a pause menu.
; - Create animations.

(define disk-height 20)
; A disk is a positive number.
(define (draw-disk disk)
  (overlay (text (number->string disk) (sub1 disk-height) 'white)
           (rectangle (+ 10 (* disk 30)) disk-height 'solid 'black)))

(module+ test
  (draw-disk 0)
  (draw-disk 1)
  (draw-disk 2)
  (draw-disk 10)
  (draw-disk 20))

; A tower is a list of numbers of strictly decreasing size.
; The first element (car tower) is the largest number, and (cdr tower)
; is, itself, a tower.
(define tower-height length)
(define tower-top last)
(define (tower-remove-top tower)
  (take tower (sub1 (length tower))))
; See the value of the largest disk of the tower.
(define tower-bottom car)
(define tower-remove-bottom cdr)
; Place a disk on top of (at the end of) a tower.
(define (tower-add tower disk)
  (append tower (list disk)))
(define tower-empty? null?)
(define tower-non-empty? pair?)
(define (tower-can-add? tower disk)
  (or (tower-empty? tower) (< disk (tower-top tower))))
(define (make-tower-with-bottom-disk disk)
  (reverse (cdr (build-list (+ disk 1) identity))))

; tower? -> image?
(define (draw-tower tower)
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

(define (replace-ref lst index value)
  (cond [(null? lst) lst]
        [(zero? index) (cons value (cdr lst))]
        [else (cons (car lst) 
                    (replace-ref (cdr lst) (sub1 index) value))]))

; towers are a list[tower]. So towers? can be read as list[tower].

; towers? nonnegative? -> towers?
; Returns a list of towers with the top disk removed from (list-ref
; towers index).
(define (remove-from-towers towers index)
  (replace-ref towers 
               index 
               (tower-remove-top (list-ref towers index))))
; towers? nonnegative? -> towers?
; Returns a list of towers with the given disk added to the top of
; (list-ref towers index).
(define (add-to-towers towers index disk)
  (replace-ref towers 
               index 
               (tower-add (list-ref towers index) disk)))
; towers? nonnegative? -> disk?
; Returns the disk at the top of (list-ref towers index).
(define (get-from-towers towers index)
  (tower-top (list-ref towers index)))


; Game:
; - There's three pegs (towers).
; - Pressing a number should remove a disk from a peg, if the peg has
;   a disk.
;   - After this point, there should be a disk "in limbo". This disk
;     is not on any peg.
;   - After pressing another number, the "in limbo" disk should go on
;     the peg specified by that number, if the disk can go on that
;     peg.


; limbo: (or/c boolean? positive?)
;   #f for no disk in limbo
;   positive? for disk in limbo
; towers: list[tower]
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
        ; No limbo disk.
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
        ; limbo disk.
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
  ; This component is not intended to lead into anything else.
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
