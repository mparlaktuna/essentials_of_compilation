(define-module (chap2 l-var)
  #:use-module (oop goops)
  #:use-module (srfi srfi-1)
  #:use-module (chap2 base)
  #:use-module (chap2 l-int)
  #:use-module (ice-9 pretty-print)
  #:export (interp-l-var
	    <var>
            <let>
            name
            name!
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
                          
(define-method (uniquify-exp (ast <var>) env)
  (let ((n (assoc-ref env (name ast))))
    (if n
	(values (Var n) env)
        (let ((nn (gensym)))
          (values (Var nn) (assoc-set! env (name ast) nn))))))

(define-method (uniquify-exp (ast <let>) env)
  (let* ((name (var ast))
	 (n (assoc-ref env name)))
    (if n
	(Let n
             (uniquify-exp (var-exp ast) env)
             (uniquify-exp (exp ast) env))
        (let* ((nn (gensym))
               (ne (assoc-set! env name nn)))
          (values (Let nn
		       (uniquify-exp (var-exp ast) ne)
		       (uniquify-exp (exp ast) ne))
                  ne)))))

(define-method (uniquify-exp (ast <prim>) env)
  (values (Prim (class-of ast)
		(map (lambda (x)
		       (uniquify-exp x env))
		     (args ast))) env))

(define-method (remove-complex-operands (ast <var>) env)
  ast)
  
(define-method (remove-complex-operands (ast <prim>) env)
  ast)

(define (interp-l-var p)
  (interp-exp p (make-hash-table)))

(define-method (display (n <var>) p)
  (format p "(Var ~a)" (name n)))
