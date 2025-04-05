(define-module (l-int)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (ice-9 pretty-print)
  #:use-module (ast)
  #:export (<int>
	    Int))

(define-class <int> (<leaf>))

(define-public (Int v)
  (make <int> #:value v))

(define-class <read> (<leaf>))

(define-public (Read)
  (make <read>))

(define-class <-> (<exp>))

(define-public (fx- . a)
  (make <-> #:value a))

(define-method (interp-exp (e <->))
  (apply - (map interp-exp (value e))))

(define-class <+> (<exp>))

(define-public (fx+ . a)
  (make <+> #:value a))

(define-method (interp-exp (e <+>))
  (apply + (map interp-exp (value e))))

