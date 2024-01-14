;; trying guile structs to create the initial struct type created in the book using Racket

(define v (make-vtable "pw"))
(define (Int i)
  (make-struct/no-tail v i)
  )

(define a (Int 9))
