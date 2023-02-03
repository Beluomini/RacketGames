#lang racket

(define (hanoi n from to using)
  (when (> n 0)
    (hanoi (- n 1) from using to)
    (displayln (list from to))
    (hanoi (- n 1) using to from)))

(define (torres-de-hanoi n)
  (hanoi n 0 1 2))

(torres-de-hanoi 8)
