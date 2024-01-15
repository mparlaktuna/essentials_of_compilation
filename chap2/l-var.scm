(define-module (chap2 l-var)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (chap2 base)
  #:use-module (chap2 l-int)
  #:export (interp-l-var
	    <var>
            <let>
            name
            name!
            Var
	    ))


(define-class <var> (<l-base>)
  (name #:init-value "" #:getter name #:init-keyword #:name #:setter name!)
  (leaf #:init-value #t #:getter leaf?))

(define (Var n)
  (make <var> #:name n))

(define-class <let> (<l-base>)
  (var #:getter var #:init-keyword #:var)
  (var-exp #:getter var-exp #:init-keyword #:var-exp)
  (exp #:getter exp #:init-keyword #:exp)
  (leaf #:init-value #f #:getter leaf?))

(define (Let v e1 e2)
  (make <let> #:var v #:var-exp e1 #:exp e2))  

(define-method (interp-exp (ast <var>) env)
  (assoc-ref env (name ast)))

(define-method (interp-exp (ast <let>) env)
  (interp-exp (exp ast)
	      (assoc-set! env
			  (var ast)
			  (interp-exp (var-exp ast) env))))


(define (interp-l-var p)
  (interp-exp p (make-hash-table)))

