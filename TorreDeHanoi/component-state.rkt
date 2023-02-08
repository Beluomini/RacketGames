#lang racket

;Arquivo montado para fornecer os componentes 
(provide state? make-state state-public state-private ; Estado é dividido em parte pública e privada.
         set-state-public set-state-private) 
(define-struct state [private public] #:transparent)
(define (set-state-private state value) ;Parte privada é onde a maioria das informações de lógica de controle serão mantidas
  (make-state value (state-public state)))
(define (set-state-public state value) ;Parte pública, podendo ser utilizada por outros componentes que precisarem
  (make-state (state-private state) value))

