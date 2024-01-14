;; is_exp lambda for each uses self
;; is leaf answer for each
;; decided to use goops due to lack of support for functionality wanted from basic records

(use-modules (oop goops))

(define-class <int> ()
  (value #:init-value 0 #:getter value #:init-keyword #:value)
  (leaf #:init-value #t #:getter leaf?))

(define (Int v)
  (make <int> #:value v))

(define-class <prim> ()
  (operator #:getter op #:init-keyword #:op)
  (args #:init-value '() #:getter args #:init-keyword #:args)
  (leaf #:init-value #f #:getter leaf? #:init-keyword #:leaf))

(define (Prim op args)
  (make <prim> #:op op #:args args #:leaf (null? args)))  

(define eight (Int 8))
(define neg-eight (Prim '- (list eight)))
(define rd (Prim 'read '()))
(define ast1_1 (Prim '+ (list rd neg-eight)))

(define (is_exp ast)
  (if (null? ast)
      #f
      (if (leaf? ast)
	  #t
	  (when (is-a? ast <prim>)
            (fold (lambda (x y)
		    (and x y))
                  #t
                  (map is_exp (args ast)))))))

;; next step is to write the interpreter
(is_exp (Prim '+ (list (Int 10) (Int 32) (Int 10))))

