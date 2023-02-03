#lang racket

;(provide (all-defined-out))
(provide state? make-state state-public state-private
         set-state-public set-state-private)
; Split up state into a private part and public part. The structure of
; each of these can change from component to component. Public state
; is intended to be consumed by some other component. Private state is
; not. It's where most control logic information will be kept.
(define-struct state [private public])
(define (set-state-private state value)
  (make-state value (state-public state)))
(define (set-state-public state value)
  (make-state (state-private state) value))

