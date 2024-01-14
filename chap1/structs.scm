;; is_exp lambda for each uses self
;; is leaf answer for each
;; decided to use goops due to lack of support for functionality wanted from basic records

(use-modules (oop goops))
(use-modules (srfi srfi-1))
(use-modules (ice-9 readline))

(define-generic is-exp?)
(define-generic interp-exp)

(define-class <int> ()
  (value #:init-value 0 #:getter value #:init-keyword #:value)
  (leaf #:init-value #t #:getter leaf?))

(define-method (is-exp? (n <int>))
  #t)

(define-method (interp-exp (n <int>))
  (value n))

(define (Int v)
  (make <int> #:value v))

(define-class <prim> ()
  (operator #:getter op #:init-keyword #:op)
  (args #:init-value '() #:getter args #:init-keyword #:args)
  (leaf #:init-value #f #:getter leaf? #:init-keyword #:leaf))

(define (Prim op args)
  (make <prim> #:op op #:args args #:leaf (null? args)))
  
(define-method (is-exp? (ast <prim>))
  (fold (lambda (x y)
	  (and x y))
        #t
        (map is-exp? (args ast))))

(define-method (interp-exp (ast <prim>))
  (case (op ast)
    [(read) (let ((n (readline "Enter number:")))
	      (interp-exp (Int (string->number n))))]
    [(-) (let ((a (args ast)))
	   (if (null? (cdr a))
	       (- (interp-exp (car a)))
               (- (interp-exp (car a))
		  (interp-exp (cadr a)))))]
    [(+) (let ((a (args ast)))
           (+ (interp-exp (car a))
	      (interp-exp (cadr a))))]
    [else #f]))
  
(define eight (Int 8))
(define neg-eight (Prim '- (list eight)))
(define rd (Prim 'read '()))
(define ast1_1 (Prim '+ (list rd neg-eight)))

;; I am planning to create each command or prim as a new class for the second pass
;; (is-exp? (Prim '+ (list (Int 10) (Int 32) (Int 10))))
;; The functions can be implemented to check if the variables are already known so it can be calculated during compilation


