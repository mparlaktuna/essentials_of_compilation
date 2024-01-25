(use-modules (oop goops)
	     (srfi srfi-1)
             (ice-9 pretty-print))

(define-generic is-exp?)
(define-generic interp-exp)

(define-class <l-base> ()
  (leaf #:init-value #f #:getter leaf?))  

(define-class <interp-base> ()
  (env #:getter env #:init-keyword #:env))  

(define-generic uniquify-exp)

(define-generic remove-complex-operands)



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
  (pretty-print (format #f "(Prim ~a\n~{ ~a~})" 
	  (class-name (class-of n))
          (args n)) p #:display? #t))


(define-class <var> (<l-base>)
  (name #:init-value "" #:getter name #:init-keyword #:name #:setter name!)
  (leaf #:init-value #t #:getter leaf?))
  
(define-method (display (n <var>) p)
  (format p "(Var ~a)" (name n)))

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

(define-method (uniquify-exp (ast <l-base>) env)
  (values ast env))

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
  (values ast env))
  
(define-method (remove-complex-operands (ast <prim>) env)
  (values ast env))

(define (interp-l-var p)
  (interp-exp p (make-hash-table)))

(define (uniquify p e)
  (uniquify-exp p e))

(define (remove-complex p e)
  (remove-complex-operands p e)))
