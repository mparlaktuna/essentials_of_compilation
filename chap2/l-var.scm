(define-module (chap2 l-var)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (chap2 base)
  #:use-module (chap2 l-int)
  #:export (interp-l-var
	    <interp-l-var>
	    ))

(define-class <interp-l-var> (<interp-l-int>)
  (env #:getter env #:init-keyword #:env))

(define-class <var> (<l-base>)
  (name #:init-value "" #:getter name #:init-keyword #:name)
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

(define-method (interp-exp (ast <var>) (interp <interp-l-var>))
  (assoc-ref (env interp) (name ast)))

(define-method (interp-exp (ast <let>) (interp <interp-l-var>))
  (assoc-set! (env interp)
	      (var ast)
              (interp-exp (var-exp ast) interp))
  (interp-exp (exp ast) interp))

(define-method (interp-exp ast (interp <interp-l-var>))
  (interp-exp ast (make <interp-l-int> #:env (env interp))))

(define (interp-l-var p)
  (interp-exp p (make <interp-l-var> #:env (make-hash-table))))

