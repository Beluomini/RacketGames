#lang racket
(require  racket/gui/init)
;Create the main frame
(define frame (instantiate frame% ("Example")
                [x 700] [y 350]
                [width 400] [height 250]
                ))

;Menu bar and menus
(define my-menu-bar (new menu-bar%
                         [parent frame]))

(define my-menu (new menu%
                     [parent my-menu-bar]
                     [label "File"]))

(define cubes-menu-iem (new menu-item%
                            [parent my-menu]
                            [label "Cubes"]
                            [callback (lambda (b e)
                                        (define s1 (send mytext get-value))
                                        (define i (string->number s1))
                                        (send my-message set-label
                             (format "The cube of ~a is ~a. " i (* i i i)))
                                        )]))

(define quit-menu-item (new menu-item%
                            [parent my-menu]
                            [label "Quit"]
                            [callback (lambda (b e) (send frame show #f))]))

;Add a text field to the frame.
(define mytext
(new text-field% [parent frame] [label "Enter Value"]))

;Add a horizontal panel for the buttons.
(define panel (new horizontal-panel% [parent frame]
                                     [alignment '(center center)]))

;Add buttons to the horizontal panel.
(new button% [parent panel] [label "Square"]
     [callback (lambda (b e) (define s1 (send mytext get-value))
                (define i (string->number s1))
                 (send my-message set-label
                       (format "The Square of ~a is ~a. " i (* i i)))
                 )])
(new button% [parent panel] [label "Print Message"]
     [callback (lambda (b e)
                 (send my-message set-label "Thanks for watching"))])

(when (system-position-ok-before-cancel?)
  (send panel change-children reverse))

(define my-message (new message%
      [parent frame]
      [label "Hello"]
      [auto-resize #t]))

;Show the frame
(send frame show #t)