(define-module (chap2 uniquify)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (chap2 base)
  #:use-module (chap2 l-int)
  #:use-module (chap2 l-var)
  #:export (uniquify))

(define-generic uniquify-exp)

(define-method (uniquify-exp ast env)
  ast)

(define-method (uniquify-exp (ast <var>) env)
  (name! ast (assoc-ref env (name ast))))

(define-method (uniquify-exp (ast <var>) env)
  (let ((n (assoc-ref env (name ast))))
    (if n
	(values (Var n) env)
        (let ((nn (gensym)))
          (values (Var nn) (assoc-set! env (name ast) nn))))))

(define-method (uniquify-exp (ast <let>) env)
  )

(define (uniquify p)
  (uniquify-exp p '()))

