(define-module (chap2 l-int)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (chap2 base)
  #:export (interp-l-int
	    <interp-l-int>
            interp-exp
            <+>
	    ))

(define-class <interp-l-int> (<interp-base>)
  (env #:getter env #:init-keyword #:env))

(define-class <int> (<l-base>)
  (value #:init-value 0 #:getter value #:init-keyword #:value)
  (leaf #:init-value #t #:getter leaf?))

(define-method (interp-exp (n <int>) (interp <interp-l-int>))
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
  
(define-method (interp-exp (ast <->) (interp <interp-l-int>))
  (let ((a (args ast)))
	   (if (null? (cdr a))
	       (- (interp-exp (car a) interp))
               (- (interp-exp (car a) interp)
		  (interp-exp (cadr a) interp)))))

(define-public (Prim op . args)
  (make op #:args args #:leaf (null? args)))
  
(define-class <+> (<prim>)
  (args #:init-value '() #:getter args #:init-keyword #:args)
  (leaf #:init-value #f #:getter leaf? #:init-keyword #:leaf))

(define-method (interp-exp (ast <+>) (interp <interp-l-int>))
  (let ((a (args ast)))
           (+ (interp-exp (car a) interp)
	      (interp-exp (cadr a) interp))))
              
(define (interp-l-int p)
  (interp-exp p (make <interp-l-int> #:env (make-hash-table))))
