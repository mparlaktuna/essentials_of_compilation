(define-module (chap2 l-int)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (chap2 base)
  #:use-module (ice-9 pretty-print)
  #:export (interp-l-int
            interp-exp
            <+>
            <prim>
            args
	    ))

(define-class <int> (<l-base>)
  (value #:init-value 0 #:getter value #:init-keyword #:value)
  (leaf #:init-value #t #:getter leaf?))

(define-method (interp-exp (n <int>) env)
  (value n))

(define-public (Int v)
  (make <int> #:value v))

(define-method (is-exp? (n <int>))
  #t)

(define-class <prim> (<l-base>)
  (args #:init-value '() #:getter args #:init-keyword #:args)
  (leaf #:init-value #f #:getter leaf? #:init-keyword #:leaf))

(define-method (is-exp? (ast <prim>))
  (fold (lambda (x y)
	  (and x y))
        #t
        (map is-exp? (args ast))))

(define-class <-> (<prim>)
  (args #:init-value '() #:getter args #:init-keyword #:args)
  (leaf #:init-value #f #:getter leaf? #:init-keyword #:leaf))
  
(define-method (interp-exp (ast <->) env)
  (let ((a (args ast)))
	   (if (null? (cdr a))
	       (- (interp-exp (car a) env))
               (- (interp-exp (car a) env)
		  (interp-exp (cadr a) env)))))

(define-public (Prim op . args)
  (make op #:args args #:leaf (null? args)))
  
(define-class <+> (<prim>)
  (args #:init-value '() #:getter args #:init-keyword #:args)
  (leaf #:init-value #f #:getter leaf? #:init-keyword #:leaf))

(define-method (interp-exp (ast <+>) env)
  (let ((a (args ast)))
           (+ (interp-exp (car a) env)
	      (interp-exp (cadr a) env))))
              
(define (interp-l-int p)
  (interp-exp p (make-hash-table)))

(define-method (display (n <int>) p)
  (format p "<int: ~a>" (value n)))

(define-method (display (n <prim>) p)
  ;; (format #f "(Prim ~a" (class-name (class-of n)))
  ;; (format #t "asd")
  ;; )
  (pretty-print (format #f "(Prim ~a\n~{-~a~}\n)"
	  (class-name (class-of n))
          (args n)) p #:display? #t))

(define-method (uniquify-exp (ast <prim>) env)
  ast)
